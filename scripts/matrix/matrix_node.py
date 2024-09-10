#!/bin/sh
'''exec' "$(dirname "$0")/../../venv/bin/python" "$0" "$@"
' '''

import argparse
import os
import re
import subprocess
import random
from typing import Optional
import typer 
from typing_extensions import Annotated

app = typer.Typer(pretty_exceptions_show_locals=False)

typer.main.get_command_name = lambda name: name

@app.command(context_settings={"allow_extra_args": True, "ignore_unknown_options": True})
def main(
    ctx: typer.Context,
    node: Annotated[Optional[str], typer.Argument()] = None,
    attach: bool = True,
    gpus: int = 1,
    echo_ids: bool = False, # Used to export GPU UUIDs
    big: bool = False,
    partition: str = os.environ.get('PARTITION', ''),
    no_exit: bool = False,
    cpu: Optional[int] = None,
    mem: Optional[int] = None,
    constraint: Optional[str] = None,
    sbatch: bool = False,
    comment: Optional[str] = None,
):
    
    if node is not None and "--" in node:
        ctx.args = [node] + ctx.args
        node = None

    cluster_name = os.environ.get('CLUSTER_NAME', '')
    dotfiles_dir = os.environ.get("DOTFILES")
    extra_tmux_args = []
    if cluster_name == "grogu":
        extra_tmux_args = ["-L", "aswerdlo", "-f", f"{dotfiles_dir}/.tmux.conf"]
    if node is None:
        session_name = f"{random.randint(1000, 9999)}"
        node = ''
    else:
        if re.match(r"^[0-9]{3}$", node):
            node = f"{cluster_name}-{node[0]}-{node[1:3]}"
        elif re.match(r"^[0-9]{1}-[0-9]{2}$", node):
            node = f"{cluster_name}-{node}"
        elif re.match(r"^[0-9]{1}-[0-9]{1}$", node) or re.match(r"^[0-9]{2}$", node):
            node = f"{cluster_name}-{node[0]}-{node[1]}"

        match = re.match(r"{cluster_name}-([0-9])-([0-9]{2})", node)
        match2 = re.match(r"{cluster_name}-([0-9])-([0-9])", node)
        if match:
            session_name = f"{match.group(1)}{match.group(2)}"
        elif match2:
            session_name = f"{match2.group(1)}{match2.group(2)}"
        else:
            session_name = node

    if sbatch is False:
        try:
            subprocess.run(['tmux', *extra_tmux_args, 'has-session', '-t', session_name], check=True)
            session_name = f"{session_name}_{random.randint(100,999)}"
        except subprocess.CalledProcessError:
            pass

        print(f'Creating session: {session_name}')
        subprocess.run(['tmux', *extra_tmux_args, 'new-session', '-d', '-s', session_name])

    if big and constraint is None:
        if cluster_name == "grogu":
            resources = f'{resources} --constraint=\'A5000|A6000\''
        else:
            resources = f'{resources} --constraint=\'A100|6000ADA\''
    elif constraint is not None:
        if cluster_name == "babel":
            gres_prefix = f"gpu:{constraint}:"
        else:
            resources = f'{resources} --constraint=\'{constraint}\''

    gres_prefix = "gpu:"
    if cluster_name == "babel":
        gres_prefix += f"{constraint}:" if constraint else "A6000|6000Ada|L40|A100_40GB|A100_80GB|A5000|3090:"

    if gpus == 0:
        resources = '-c4 --mem=8g'
    elif gpus in range(1, 9):
        cores = gpus * 8
        mem = gpus * 48
        resources = f'--gres={gres_prefix}{gpus} -c{cores} --mem={mem}g'
    else:
        raise ValueError("Invalid number of GPUs")
        raise ValueError("Invalid number of GPUs")
    
    if cpu is not None:
        resources = re.sub(r'-c[0-9]+', f'-c{cpu}', resources)

    if mem is not None:
        resources = re.sub(r'--mem=[0-9]+g', f'--mem={mem}g', resources)

    if big and gpus == 1:
        partition = 'all'
        print(f"Warning: using all partition!!!")
    
    if re.match(fr"^{cluster_name}-[0-9]{{1}}-[0-9]{{2}}$", node):
        resources = f'{resources} --nodelist="{node}"'
    elif re.match(fr"^{cluster_name}-[0-9]{{1}}-[0-9]{{1}}$", node):
        resources = f'{resources} --nodelist="{node}"'
    elif re.match(fr"^{cluster_name}-[0-9]{{2}}-[0-9]{{2}}$", node):
        resources = f'{resources} --nodelist="{node}"'

    id_str = ''
    if echo_ids:
        id_str = " -c '~/perm/scripts/gpu_data/run.sh'"

    time_limits = {
        'all': '--time=06:00:00',
        'deepaklong': '--time=48:00:00'
    }
    if cluster_name == 'babel':
        time_limits.update({
            'debug': '--time=02:00:00',
            'general': '--time=2-00:00:00',
            'long': '--time=7-00:00:00',
            'cpu': '--time=2-00:00:00',
            'mld': '--time=20-01:00:00'
        })
    time_limit = time_limits.get(partition, '--time=72:00:00')

    comment = '' if comment is None else f' --comment="{comment}" '
    if cluster_name == 'grogu' and comment == '':
        comment = "--comment='aswerdlo' "

    extra_sbatch_args = ""
    if ctx.args:
        print(f"Args: {ctx.args}")
        extra_sbatch_args = " ".join(ctx.args)
        if len(extra_tmux_args) > 0:
            extra_sbatch_args = f" {extra_sbatch_args}"

    if sbatch:
        cmd = f'sbatch -p {partition} {comment}{time_limit} {resources}{extra_sbatch_args} create_tmux_sleep.sh'
        print(f'Running: {cmd}')
        subprocess.run(cmd, shell=True)
    else:
        command = 'srun' if no_exit else 'srun_custom.sh' # srun_custom.sh auto kills the tmux when srun stops. Use srun otherwise.
        subprocess.run(['tmux',  *extra_tmux_args, 'send-keys', '-t', session_name,
                        f'{command} -p {partition} {comment}{time_limit}{extra_sbatch_args} {resources} ',
                        f'--pty $SHELL{id_str}', 'C-m'])
    
        if attach and 'TMUX' not in os.environ:
            print(f"Attaching to session: {session_name}")
            subprocess.run(['tmux', *extra_tmux_args, 'attach', '-t', session_name])
        else:
            print(f"Session Created: {session_name}, to manually rename: tmux rename-session -t {session_name}")


if __name__ == "__main__":
    app()
