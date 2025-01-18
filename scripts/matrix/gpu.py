"""A simple tool for summarising GPU statistics on a slurm cluster.

The tool can be used in two ways:
1. To simply query the current usage of GPUs on the cluster.
2. To launch a daemon which will log usage over time.  This can then later be queried
   to provide simple usage statistics.
"""
import argparse
import ast
import atexit
import functools
import os
import re
import signal
import subprocess
import sys
import time
from collections import defaultdict
from datetime import datetime
from pathlib import Path

import humanfriendly as hf
import humanize
import numpy as np
import pandas as pd
from beartype import beartype
from beartype.typing import List, Optional, Tuple
from tabulate import tabulate
from termcolor import colored

# SLURM states which indicate that the node is not available for submitting jobs
INACCESSIBLE = {"drain*", "down*", "drng", "drain", "down"}

# printed between each section of output
DIVIDER = ""


class Daemon:
    """A Generic linux daemon base class for python 3.x.

    This code is a Python3 port of Sander Marechal's Daemon module:
    http://web.archive.org/web/20131017130434/http://www.jejik.com/articles/
    2007/02/a_simple_unix_linux_daemon_in_python/

    It's a little difficult to credit the author of the Python3 port, since the code was
    published anonymously. The original can be found here:
    http://web.archive.org/web/20131101191715/http://www.jejik.com/files/examples/
    daemon3x.py
    """

    def __init__(self, pidfile):
        self.pidfile = pidfile

    def daemonize(self):
        """Deamonize class. UNIX double fork mechanism."""
        try:
            pid = os.fork()
            if pid > 0:
                # exit first parent
                sys.exit(0)
        except OSError as err:
            sys.stderr.write('fork #1 failed: {0}\n'.format(err))
            sys.exit(1)

        # decouple from parent environment
        os.chdir('/')
        os.setsid()
        os.umask(0)

        # do second fork
        try:
            pid = os.fork()
            if pid > 0:
                # exit from second parent
                sys.exit(0)
        except OSError as err:
            sys.stderr.write('fork #2 failed: {0}\n'.format(err))
            sys.exit(1)

        # redirect standard file descriptors
        sys.stdout.flush()
        sys.stderr.flush()
        si = open(os.devnull, 'r')
        so = open(os.devnull, 'a+')
        se = open(os.devnull, 'a+')

        os.dup2(si.fileno(), sys.stdin.fileno())
        os.dup2(so.fileno(), sys.stdout.fileno())
        os.dup2(se.fileno(), sys.stderr.fileno())

        # write pidfile
        atexit.register(self.delpid)

        pid = str(os.getpid())
        with open(self.pidfile, 'w+') as f:
            f.write(pid + '\n')

    def delpid(self):
        os.remove(self.pidfile)

    def start(self):
        """Start the daemon."""

        # Check for a pidfile to see if the daemon already runs
        try:
            with open(self.pidfile, 'r') as pf:

                pid = int(pf.read().strip())
        except IOError:
            pid = None

        if pid:
            message = "pidfile {0} already exists. Is the daemon already running?\n"
            sys.stderr.write(message.format(self.pidfile))
            sys.exit(1)

        # Start the daemon
        self.daemonize()
        self.run()

    def stop(self):
        """Stop the daemon."""

        # Get the pid from the pidfile
        try:
            with open(self.pidfile, 'r') as pf:
                pid = int(pf.read().strip())
        except IOError:
            pid = None

        if not pid:
            message = "pidfile {0} does not exist. Daemon not running?\n"
            sys.stderr.write(message.format(self.pidfile))
            return  # not an error in a restart

        # Try killing the daemon process
        try:
            while 1:
                os.kill(pid, signal.SIGTERM)
                time.sleep(0.1)
        except OSError as err:
            e = str(err.args)
            if e.find("No such process") > 0:
                if os.path.exists(self.pidfile):
                    os.remove(self.pidfile)
            else:
                print(str(err.args))
                sys.exit(1)

    def restart(self):
        """Restart the daemon."""
        self.stop()
        self.start()

    def run(self):
        """You should override this method when you subclass Daemon.
        It will be called after the process has been daemonized by
        start() or restart()."""
        raise NotImplementedError("Must override this class")


class GPUStatDaemon(Daemon):
    """A lightweight daemon which intermittently logs gpu usage to a text file.
    """
    timestamp_format = "%Y-%m-%d_%H:%M:%S"

    def __init__(self, pidfile, log_path, log_interval):
        """Create the daemon.

        Args:
            pidfile (str): the location of the daemon pid file.
            log_path (str): the location where the historical log will be stored.
            log_interval (int): the time interval (in seconds) at which gpu usage will
                be stored to the log.
        """
        Path(pidfile).parent.mkdir(exist_ok=True, parents=True)
        super().__init__(pidfile=pidfile)
        Path(log_path).parent.mkdir(exist_ok=True, parents=True)
        self.log_interval = log_interval
        self.log_path = log_path

    def serialize_usage(self, usage):
        """Convert data structure into an appropriate string for serialization.

        Args:
            usage (a dict-like structure): a data-structure which has the form of a
                dictionary, but may contain variants with length string representations
                (e.g. defaultdict, OrderedDict etc.)

        Returns:
            (str): a string representation of the usage data strcture.
        """
        for user, gpu_dict in usage.items():
            for key, subdict in gpu_dict.items():
                usage[user][key] = dict(subdict)
        usage = dict(usage)
        return usage.__repr__()

    @staticmethod
    def deserialize_usage(log_path):
        """Parse the `usage` data structure by reading in the contents of the text-based
        log file and deserializing.

        Args:
            log_path (str): the location of the log file.

        Returns:
            (list[dict]): a list of dicts, where each dict contains the time stamp
                associated with a set of usage statistics, together with the statistics
                themselves.
        """
        if not Path(log_path).exists():
            raise ValueError("No historical log found.  Did you start the daemon?")
        with open(log_path, "r") as f:
            rows = f.read().splitlines()
        data = []
        for row in rows:
            ts, usage = row.split(maxsplit=1)
            dt = datetime.strptime(ts, GPUStatDaemon.timestamp_format)
            usage = ast.literal_eval(usage)
            data.append({"timestamp": dt, "usage": usage})
        return data

    def run(self):
        """Run the daemon - will intermittently log gpu usage to disk.
        """
        while True:
            resources = get_node2gpus_mapping()
            usage = gpu_usage_grouped_by_user(resources)
            log_row = self.serialize_usage(usage)
            timestamp = datetime.now().strftime(GPUStatDaemon.timestamp_format)
            with open(self.log_path, "a") as f:
                f.write(f"{timestamp} {log_row}\n")
            time.sleep(self.log_interval)


def historical_summary(data):
    """Print a short summary of the historical gpu usage logged by the daemon.

    Args:
        data (list): the data structure deserialized from the daemon log file (this is
            the output of the GPUStatDaemon.deserialize_usage() function.)
    """
    first_ts, last_ts = data[0]["timestamp"], data[-1]["timestamp"]
    print(f"Historical data contains {len(data)} samples ({first_ts} to {last_ts})")
    latest_usage = data[-1]["usage"]
    users, gpu_types = set(), set()
    for user, resources in latest_usage.items():
        users.add(user)
        gpu_types.update(set(resources.keys()))
    history = {}
    for row in data:
        for user, subdict in row["usage"].items():
            if user not in history:
                history[user] = {gpu_type: [] for gpu_type in gpu_types}
            type_counts = {key: sum(val.values()) for key, val in subdict.items()}
            for gpu_type in gpu_types:
                history[user][gpu_type].append(type_counts.get(gpu_type, 0))

    for user, subdict in history.items():
        print(f"GPU usage for {user}:")
        total = 0
        for gpu_type, counts in subdict.items():
            counts = np.array(counts)
            if counts.sum() == 0:
                continue
            print(f"{gpu_type:5s} > avg: {int(counts.mean())}, max: {np.max(counts)}")
            total += counts.mean()
        print(f"total > avg: {int(total)}\n")


def split_node_str(node_str):
    """Split SLURM node specifications into node_specs. Here a node_spec defines a range
    of nodes that share the same naming scheme (and are grouped together using square
    brackets).   E.g. 'node[1-3,4,6-9]' represents a single node_spec.

    Examples:
       A `node_str` of the form 'node[001-003]' will be returned as a single element
           list: ['node[001-003]']
       A `node_str` of the form 'node[001-002],node004' will be split into
           ['node[001-002]', 'node004']

    Args:
        node_str (str): a SLURM-formatted list of nodes

    Returns:
        (list[str]): SLURM node specs.
    """
    node_str = node_str.strip()
    breakpoints, stack = [0], []
    for ii, char in enumerate(node_str):
        if char == "[":
            stack.append(char)
        elif char == "]":
            stack.pop()
        elif not stack and char == ",":
            breakpoints.append(ii + 1)
    end = len(node_str) + 1
    return [node_str[i: j - 1] for i, j in zip(breakpoints, breakpoints[1:] + [end])]


def parse_node_names(node_str):
    """Parse the node list produced by the SLURM tools into separate node names.

    Examples:
       A slurm `node_str` of the form 'node[001-003]' will be split into a list of the
           form ['node001', 'node002', 'node003'].
       A `node_str` of the form 'node[001-002],node004' will be split into
           ['node001', 'node002', 'node004']

    Args:
        node_str (str): a SLURM-formatted list of nodes

    Returns:
        (list[str]): a list of separate node names.
    """
    names = []
    node_specs = split_node_str(node_str)
    for node_spec in node_specs:
        if "[" not in node_spec:
            names.append(node_spec)
        else:
            head, tail = node_spec.index("["), node_spec.index("]")
            prefix = node_spec[:head]
            subspecs = node_spec[head + 1:tail].split(",")
            for subspec in subspecs:
                if "-" not in subspec:
                    subnames = [f"{prefix}{subspec}"]
                else:
                    start, end = subspec.split("-")
                    num_digits = len(start)
                    subnames = [f"{prefix}{str(x).zfill(num_digits)}"
                                for x in range(int(start), int(end) + 1)]
                names.extend(subnames)
    return names


def parse_cmd(cmd, split=True):
    """Parse the output of a shell command...
     and if split set to true: split into a list of strings, one per line of output.

    Args:
        cmd (str): the shell command to be executed.
        split (bool): whether to split the output per line
    Returns:
        (list[str]): the strings from each output line.
    """
    output = subprocess.check_output(cmd, shell=True).decode("utf-8")
    if split:
        output = [x for x in output.split("\n") if x]
    return output


@beartype
def node_states(partition: Optional[str] = None) -> dict:
    """Query SLURM for the state of each managed node.

    Args:
        partition: the partition/queue (or multiple, comma separated) of interest.
            By default None, which queries all available partitions.

    Returns:
        a mapping between node names and SLURM states.
    """
    cmd = "sinfo --noheader"
    if partition:
        cmd += f" --partition={partition}"
    rows = parse_cmd(cmd)
    states = {}
    for row in rows:
        tokens = row.split()
        state, names = tokens[4], tokens[5]
        node_names = parse_node_names(names)
        states.update({name: state for name in node_names})
    return states


@functools.lru_cache(maxsize=64, typed=True)
def occupancy_stats_for_node(node: str) -> dict:
    """Query SLURM for the occupancy of a given node.

    Args:
        (node): the name of the node to query

    Returns:
        a mapping between node names and occupancy stats.
    """
    cmd = f"scontrol show node {node}"
    rows = [x.strip() for x in parse_cmd(cmd)]
    keys = ("AllocTRES", "CfgTRES")
    metrics = {}
    for row in rows:
        for key in keys:
            if row.startswith(key):
                row = row.replace(f"{key}=", "")
                tokens = row.split(",")
                if tokens == [""]:
                    # SLURM sometimes omits information, so we alert the user to its
                    # its exclusion and report nothing for this node
                    # print(f"Missing information for {node}: {key}, skipping....")
                    metrics[key] = {}
                else:
                    metrics[key] = {x.split("=")[0]: x.split("=")[1] for x in tokens}

    occupancy = {}
    for metric, alloc_val in metrics["AllocTRES"].items():
        try:
            cfg_val = metrics["CfgTRES"][metric]
        except KeyError:
            if 'gres/gpu:' in metric and 'gres/gpu' in metrics['AllocTRES'].keys():
              continue
            else:
              raise KeyError(f"KeyError for {metric} in occupancy_stats_for_node. {metrics['AllocTRES']}")
            
        if metric == "mem":
            # SLURM appears to sometimes misformat large numbers, producing summary strings
            # like 68G/257669M, rather than 68G/258G. The humanfriendly library provides
            # a more reliable number parser, and the humanize library provides a nice
            # formatter.
            alloc_val = humanize.naturalsize(hf.parse_size(alloc_val), format="%d")
            cfg_val = humanize.naturalsize(hf.parse_size(cfg_val), format="%d")
        occupancy[metric] = f"{alloc_val}/{cfg_val}"

    if 'gres/gpu:' in occupancy.keys():
      assert False, f"gres/gpu: in occupancy.keys(): {occupancy}"
    # if node == 'babel-4-25':
    #     breakpoint()
    return occupancy


@beartype
def get_node2gpus_mapping(
        partition: Optional[str] = None,
) -> dict:
    """Query SLURM for the number and types of GPUs under management.

    Args:
        partition: the partition/queue (or multiple, comma separated) of interest.
            By default None, which queries all available partitions.

    Returns:
        a mapping between node names and a list of the GPUs that they have available.
    """
    cmd = "sinfo -o '%1000N|%1000G' --noheader"
    if partition:
        cmd += f" --partition={partition}"
    rows = parse_cmd(cmd)
    resources = defaultdict(list)

    for row in rows:
        node_str, resource_strs = row.split("|")
        for resource_str in resource_strs.split(","):
            if not resource_str.startswith("gpu"):
                continue

            gpu_type, gpu_count = parse_gpu_type_and_count_via_regex(resource_str)
            node_names = parse_node_names(node_str)
            for name in node_names:
                resources[name].append({"type": gpu_type, "count": gpu_count})

    return resources


@beartype
def parse_gpu_type_and_count_via_regex(
        resource_str: str,
        default_gpus: int = 4,
        default_gpu_name: str = "NONAME_GPU",
) -> Tuple[str, int]:
    """Parse the gpu type and gpu count from an sinfo output string using regex.

    Args:
        resource_str: the string parsed from sinfo from which we wish to extract information
        default_gpus: The number of GPUs estimated for nodes that have incomplete SLURM
            meta data.
        default_gpu_name: The name of the GPU for nodes that have incomplete SLURM meta
        data.
    """

    # Debug the regular expression below at
    # https://regex101.com/r/RHYM8Z/3
    p = re.compile(r"gpu:(?:(\w*?):)?(\d*)(?:\(\S*\))?\s*")
    match = p.search(resource_str)
    gpu_type = match.group(1) if match.group(1) is not None else default_gpu_name
    # if the number of GPUs is not specified, we assume it is `default_gpus`
    gpu_count = int(match.group(2)) if match.group(2) != "" else default_gpus
    return gpu_type, gpu_count


@beartype
def resource_by_type(resources: dict) -> dict:
    """Determine the cluster capacity by gpu type

    Args:
        resources: a summary of the cluster resources, organised by node name.

    Returns:
        resources: a summary of the cluster resources, organised by gpu type
    """
    by_type = defaultdict(list)
    for node, specs in resources.items():
        for spec in specs:
            by_type[spec["type"]].append({"node": node, "count": spec["count"]})
    return by_type


@beartype
def summary_by_type(resources: dict, tag: str) -> List[List]:
    """Print out out a summary of cluster resources, organised by gpu type.

    Args:
        resources (dict): a summary of cluster resources, organised by node name.
        tag (str): a term that will be included in the printed summary.
    """
    summary_table = []
    by_type = resource_by_type(resources)
    total = sum(x["count"] for sublist in by_type.values() for x in sublist)
    summary_table.append(["total", total])
    for key, val in sorted(by_type.items(), key=lambda x: sum(y["count"] for y in x[1])):
        gpu_count = sum(x["count"] for x in val)
        summary_table.append([key, gpu_count])
    return summary_table


@beartype
def summary(mode: str, resources: dict = None, states: dict = None) -> List[List]:
    """Generate a printed summary of the cluster resources.

    Args:
        mode (str): the kind of resources to query (must be one of 'online', 'all').
        resources (dict :: None): a summary of cluster resources, organised by node name.
        states (dict[str: str] :: None): a mapping between node names and SLURM states.
    """
    if not resources:
        resources = get_node2gpus_mapping()
    if not states:
        states = node_states()
    if mode == "online":
        res = {key: val for key, val in resources.items()
               if states.get(key, "down") not in INACCESSIBLE}
    elif mode == "all":
        res = resources
    else:
        raise ValueError(f"Unknown mode: {mode}")
    return summary_by_type(res, tag=mode)


@beartype
def gpu_usage_grouped_by_user(resources: dict, partition: Optional[str] = None) -> dict:
    """Build a data structure of the cluster resource usage, organised by user.

    Args:
        resources (dict :: None): a summary of cluster resources, organised by node name.

    Returns:
        (dict): a summary of resources organised by user (and also by node name).
    """
    version_cmd = "sinfo -V"
    slurm_version = parse_cmd(version_cmd, split=False).split(" ")[1]
    if slurm_version.startswith("17"):
        resource_flag = "gres"
    else:
        resource_flag = "tres-per-node"
    cmd = f"squeue -O {resource_flag}:100,nodelist:100,username:100,jobid:100 --noheader"
    if partition:
        cmd += f" --partition={partition}"
    detailed_job_cmd = "scontrol show jobid -dd %s"
    rows = parse_cmd(cmd)
    usage = defaultdict(dict)
    for row in rows:
        tokens = row.split()
        # ignore pending jobs
        if len(tokens) < 4 or 'gpu' not in tokens[0]:
            continue
        gpu_count_str, node_str, user, jobid = tokens
        gpu_count_tokens = gpu_count_str.split(":")
        if not gpu_count_tokens[-1].isdigit():
            gpu_count_tokens.append("1")
        num_gpus = int(gpu_count_tokens[-1])
        # get detailed job information, to check if using bash
        detailed_job_info = {row.split('=')[0].strip(): row.split('=')[1].strip()
                             for row in parse_cmd(detailed_job_cmd % jobid, split=True) if '=' in row}
        node_names = parse_node_names(node_str)
        for node_name in node_names:
            # If a node still has jobs running but is draining, it will not be present
            # in the "available" resources, so we ignore it
            if node_name not in resources:
                continue
            node_gpu_types = [x["type"] for x in resources[node_name]]
            if len(gpu_count_tokens) == 2:
                gpu_type = None
            elif len(gpu_count_tokens) == 3:
                gpu_type = gpu_count_tokens[1]
                if gpu_type == 'gpu':
                    gpu_type = detailed_job_info['JOB_GRES'].split(':')[1]
            if gpu_type is None:
                if len(node_gpu_types) != 1:
                    gpu_type = sorted(
                        resources[node_name],
                        key=lambda k: k['count'],
                        reverse=True
                    )[0]['type']
                    msg = (f"cannot determine node gpu type for {user} on {node_name}"
                           f" (guessing {gpu_type})")
                    print(f"WARNING >>> {msg}")
                else:
                    gpu_type = node_gpu_types[0]
            if gpu_type in usage[user]:
                usage[user][gpu_type][node_name]['n_gpu'] += num_gpus

            else:
                usage[user][gpu_type] = defaultdict(lambda: {'n_gpu': 0})
                usage[user][gpu_type][node_name]['n_gpu'] += num_gpus
    return usage


@beartype
def in_use(
        resources: dict = None,
        partition: Optional[str] = None,
        verbose: bool = False,
) -> List[List]:
    """Print a short summary of the resources that are currently used by each user.

    Args:
        resources: a summary of cluster resources, organised by node name.
    """
    if not resources:
        resources = get_node2gpus_mapping()
    usage = gpu_usage_grouped_by_user(resources, partition=partition)
    aggregates = {}
    for user, subdict in usage.items():
        aggregates[user] = {}
        aggregates[user]['n_gpu'] = {key: sum([x['n_gpu'] for x in val.values()])
                                     for key, val in subdict.items()}
    in_use_table = [["user", "total GPU's allocated", "count per GPU"]]
    for user, subdict in sorted(aggregates.items(),
                                key=lambda x: sum(x[1]['n_gpu'].values()), reverse=True):
        total = (f"{str(sum(subdict['n_gpu'].values())):2s} ")
        summary_str = ", ".join([f"{key}: {val}" for key, val in subdict['n_gpu'].items()])
        in_use_table.append([user, total, summary_str])
    return in_use_table


@beartype
def available(
        node2gpus_map: dict = None,
        states: dict = None,
        verbose: bool = False,
) -> List[List]:
    """Print a short summary of resources available on the cluster.

    Args:
        node2gpus_map: a summary of cluster resources, organised by node name.
        states: a mapping between node names and SLURM states.
        verbose: whether to output a more verbose summary of the cluster state.

    NOTES: Some systems allow users to share GPUs.  The logic below amounts to a
    conservative estimate of how many GPUs are available.  The algorithm is:

    For each user that requests a GPU on a node, we assume that a new GPU is allocated
      until all GPUs on the server are assigned.  If more GPUs than this are listed as
      allocated by squeue, we assume any further GPU usage occurs by sharing GPUs.
    """
    avail_table = []
    if not node2gpus_map:
        node2gpus_map = get_node2gpus_mapping()
    if not states:
        states = node_states()

    # drop nodes that are in down/inaccessible
    node2gpus_map = {node: gpus for node, gpus in node2gpus_map.items()
                     if states.get(node, "down") not in INACCESSIBLE}

    gpu_usage_by_user = gpu_usage_grouped_by_user(resources=node2gpus_map)

    for gpu_usage_for_user in gpu_usage_by_user.values():
        for gpu_type, node_dicts in gpu_usage_for_user.items():
            for node_name, user_gpu_count in node_dicts.items():
                gpu_types = [x["type"] for x in node2gpus_map.get(node_name, [])]
                
                if gpu_type not in gpu_types:
                    print(f"WARNING: GPU type '{gpu_type}' not found in node '{node_name}'. Skipping...")
                    continue  # Skip to the next iteration

                resource_idx = gpu_types.index(gpu_type)
                count = node2gpus_map[node_name][resource_idx]["count"]
                count = max(count - user_gpu_count['n_gpu'], 0)
                node2gpus_map[node_name][resource_idx]["count"] = count

    by_type = resource_by_type(node2gpus_map)
    total = sum(x["count"] for sublist in by_type.values() for x in sublist)
    avail_table.append(["total", total, ""])
    for key, counts_for_gpu_type in by_type.items():
        gpu_count = sum(x["count"] for x in counts_for_gpu_type)
        tail = ""
        if verbose:
            summary_strs = []
            for x in counts_for_gpu_type:
                node, count = x["node"], x["count"]
                if count:
                    occupancy = occupancy_stats_for_node(node)
                    users = [user for user in gpu_usage_by_user
                             if node in gpu_usage_by_user[user].get(key, [])]
                    details = [f"{key}: {val}" for key, val in sorted(occupancy.items())]
                    details = f"[{', '.join(details)}] [{','.join(users)}]"
                    summary_strs.append(f"\n -> {node}: {count} {key} {details}")
            tail = " ".join(summary_strs)
        avail_table.append([key, gpu_count, tail])
    return avail_table


@beartype
def all_info(color: int, verbose: bool, partition: Optional[str] = None):
    """Print a collection of summaries about SLURM gpu usage, including: all nodes
    managed by the cluster, nodes that are currently accesible and gpu usage for each
    active user.

    Args:
        partition: the partition/queue (or multiple, comma separated) of interest.
            By default None, which queries all available partitions.
    """
    divider, slurm_str = DIVIDER, "SLURM"
    if color:
        # colors = sns.color_palette("hls", 8).as_hex()
        divider = colored(divider, "magenta")
        slurm_str = colored(slurm_str, "red")
    print(divider)
    if verbose:
        print(f"Under {slurm_str} management")
        print(divider)
    resources = get_node2gpus_mapping(partition=partition)
    states = node_states(partition=partition)

    all_gpus_table = summary(mode="all", resources=resources, states=states)
    online_table = summary(mode="online", resources=resources, states=states)
    avail_table = available(node2gpus_map=resources, states=states, verbose=verbose)

    available_gpus = get_available_gpus_per_node(resources, states)
    print_available_gpus_summary(available_gpus)

    # Existing summary printing
    if verbose:
        print("all GPU's:")
        for row in all_gpus_table:
            for x in row:
                print(x, end='\t')
            print('\n', end='')
        print()
        print("GPU's online:")
        for row in online_table:
            for x in row:
                print(x, end='\t')
            print('\n', end='')
        print()
        print("GPU's available:")
        for row in avail_table:
            for x in row:
                print(x, end='\t')
            print('\n', end='')
        print()
        print("Usage by user:")
    # in non-verbose mode, merge the three summaries into one nice table
    else:
        all_gpus_df = pd.DataFrame(all_gpus_table, columns=["GPU model", "all"])
        all_gpus_df = all_gpus_df.set_index(["GPU model"])

        online_df = pd.DataFrame(online_table, columns=["GPU model", "online"])
        online_df = online_df.set_index(["GPU model"])

        avail_df = pd.DataFrame(avail_table, columns=["GPU model", "available", "notes"])
        # notes only exist in verbose mode
        avail_df.drop(columns="notes", inplace=True)
        avail_df = avail_df.set_index(["GPU model"])

        big_df = pd.DataFrame()
        for df in [all_gpus_df, online_df, avail_df]:
            big_df = big_df.merge(df, how='outer', left_index=True, right_index=True)
        big_df = big_df.sort_values(by="all", ascending=False)
        print(tabulate(big_df, headers=(["GPU model", "all", "online", "available"])))
        print(divider)
    in_use_table = in_use(resources, partition=partition, verbose=verbose)
    print(tabulate(in_use_table, showindex=False, headers="firstrow"))


def count_free_gpus_per_type(node2gpus_map: dict) -> dict:
    """
    Count the number of nodes that have a specific number of free GPUs for each GPU type.

    Args:
        node2gpus_map (dict): A mapping between node names and their GPU specifications.

    Returns:
        dict: A dictionary where each key is a GPU type and the value is another dictionary
              mapping the number of free GPUs to a dictionary containing the count of nodes
              and a list of node names having that number of free GPUs.

              Example:
              {
                  "A100": {
                      8: {"count": 3, "nodes": ["node1", "node2", "node3"]},
                      7: {"count": 5, "nodes": ["node4", "node5", ...]},
                      ...
                  },
                  ...
              }
    """
    from collections import defaultdict
    gpu_type_free_counts = defaultdict(lambda: defaultdict(lambda: {"count": 0, "nodes": []}))

    for node, gpus in node2gpus_map.items():
        for gpu in gpus:
            gpu_type = gpu["type"]
            free_gpus = gpu["count"]
            gpu_type_free_counts[gpu_type][free_gpus]["count"] += 1
            gpu_type_free_counts[gpu_type][free_gpus]["nodes"].append(node)

    return gpu_type_free_counts


@beartype
def get_available_gpus_per_node(
        node2gpus_map: dict = None,
        states: dict = None,
) -> dict:
    """Get a mapping of nodes to their available (unallocated) GPUs using SLURM's TRES data.

    Args:
        node2gpus_map: a summary of cluster resources, organised by node name.
        states: a mapping between node names and SLURM states.

    Returns:
        dict: A mapping of node names to lists of available GPUs, where each GPU is
              represented by a dict containing its type and count.
    """
    if not node2gpus_map:
        node2gpus_map = get_node2gpus_mapping()
    if not states:
        states = node_states()

    # Only consider accessible nodes
    available_gpus = {
        node: [gpu.copy() for gpu in gpus]
        for node, gpus in node2gpus_map.items()
        if states.get(node, "down") not in INACCESSIBLE
    }

    # For each node, query SLURM for actual GPU allocation
    for node_name in list(available_gpus.keys()):
        occupancy = occupancy_stats_for_node(node_name)
        
        # Parse GPU allocations from TRES data
        for metric, alloc_str in occupancy.items():
            if not metric.startswith("gres/gpu"):
                continue
                
            # Parse allocation string (format: "used/total")
            alloc_val, total_val = map(int, alloc_str.split("/"))
            
            # If this is a specific GPU type (e.g., "gres/gpu:a100")
            if ":" in metric:
                gpu_type = metric.split(":")[1]
                gpu_types = [x["type"] for x in available_gpus[node_name]]
                if gpu_type in gpu_types:
                    idx = gpu_types.index(gpu_type)
                    available_gpus[node_name][idx]["count"] = total_val - alloc_val
            # If this is the generic "gres/gpu" and we only have one GPU type
            elif len(available_gpus[node_name]) == 1:
                available_gpus[node_name][0]["count"] = total_val - alloc_val

    # Remove nodes with no available GPUs
    available_gpus = {
        node: gpus for node, gpus in available_gpus.items()
    }

    return available_gpus


def print_available_gpus_summary(available_gpus: dict):
    """Print a summary of available GPUs by type, including node names.

    Args:
        available_gpus: Output from get_available_gpus_per_node()
    """
    # Group nodes by GPU type and count
    gpu_type_groups = defaultdict(lambda: defaultdict(list))
    for node, gpus in available_gpus.items():
        for gpu in gpus:
            #if gpu["count"] > 0:  # Only include nodes with available GPUs
            gpu_type_groups[gpu["type"]][gpu["count"]].append(node)

    print("\nAvailable (Unallocated) GPUs by Type:")
    for gpu_type, counts in gpu_type_groups.items():
        print(f"\n{gpu_type}:")
        for gpu_count, nodes in sorted(counts.items(), reverse=True):
            node_list = ", ".join(sorted(nodes))
            print(f"  {gpu_count} GPUs free on {len(nodes)} nodes: [ {node_list} ]")


def main():
    parser = argparse.ArgumentParser(description="slurm_gpus tool")
    parser.add_argument("--action", default="current",
                        choices=["current", "history", "daemon-start", "daemon-stop"],
                        help=("The function performed by slurm_gpustat: `current` will"
                              " provide a summary of current usage, 'history' will "
                              "provide statistics from historical data (provided that the"
                              "logging daemon has been running). 'daemon-start' and"
                              "'daemon-stop' will start and stop the daemon, resp."))
    parser.add_argument("-p", "--partition", default=None,
                        help=("the partition/queue (or multiple, comma separated) of"
                              " interest. By default set to all available partitions."))
    parser.add_argument("--log_path",
                        default=Path.home() / "data/daemons/logs/slurm_gpustat.log",
                        help="the location where daemon log files will be stored")
    parser.add_argument("--gpustat_pid",
                        default=Path.home() / "data/daemons/pids/slurm_gpustat.pid",
                        help="the location where the daemon PID file will be stored")
    parser.add_argument("--daemon_log_interval", type=int, default=43200,
                        help="time interval (secs) between stat logging (default 12 hrs)")
    parser.add_argument("--color", type=int, default=1, help="color output")
    parser.add_argument("--verbose", action="store_true",
                        help="provide a more detailed breakdown of resources")
    args = parser.parse_args()

    if args.action == "current":
        all_info(color=args.color, verbose=args.verbose, partition=args.partition)
    elif args.action == "history":
        data = GPUStatDaemon.deserialize_usage(args.log_path)
        historical_summary(data)
    elif args.action.startswith("daemon"):
        daemon = GPUStatDaemon(
            log_path=args.log_path,
            pidfile=args.gpustat_pid,
            log_interval=args.daemon_log_interval,
        )
        if args.action == "daemon-start":
            print("Starting daemon")
            daemon.start()
        elif args.action == "daemon-stop":
            print("Stopping daemon")
            daemon.stop()

    # New action for printing free GPUs count
    elif args.action == "free-count":
        resources = get_node2gpus_mapping(partition=args.partition)
        free_gpus_counts = count_free_gpus_per_type(resources)
        print("Count of Nodes with n Free GPUs per GPU Type:")
        for gpu_type, counts in free_gpus_counts.items():
            sorted_counts = sorted(counts.items(), key=lambda x: x[0], reverse=True)
            for free_gpu, node_count in sorted_counts:
                print(f"{gpu_type} {free_gpu} GPUs Free: {node_count}")


if __name__ == "__main__":
    main()