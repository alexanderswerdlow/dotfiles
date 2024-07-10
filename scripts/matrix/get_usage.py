#!/bin/sh
'''exec' "$(dirname "$0")/../../venv/bin/python" "$0" "$@"
' '''

import os
from simple_slurm import Slurm
from pathlib import Path
from typing import Optional
from datetime import datetime, timedelta
import typer
from typing import List, Optional
import subprocess
import time

app = typer.Typer(pretty_exceptions_show_locals=False)

typer.main.get_command_name = lambda name: name

def get_all_nodes(partition):
    command = f'sinfo --partition={partition} --format="%n" --noheader'
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    if result.returncode == 0:
        nodes = result.stdout.strip().split('\n')
        return nodes
    else:
        print(f"Error: {result.stderr}")
        return []

@app.command(context_settings={"allow_extra_args": True, "ignore_unknown_options": True})
def main(partition: str):
    nodes = get_all_nodes(partition)
    print(nodes)
    from concurrent.futures import ThreadPoolExecutor, as_completed

    def run_ssh_command(node):
        if 'LC_MONETARY' in os.environ:
            del os.environ['LC_MONETARY']
        ssh_command = f"ssh -o StrictHostKeyChecking=no -f {node} '/bin/sh /home/mprabhud/aswerdlo/dotfiles/scripts/matrix/get_usage.sh' --norc --noprofile"
        result = subprocess.run(ssh_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode == 0:
            return f"Succeeded on {node}"
        else:
            return f"Error on {node}"

    with ThreadPoolExecutor() as executor:
        futures = [executor.submit(run_ssh_command, node) for node in nodes]
        for future in as_completed(futures):
            print(future.result())

if __name__ == "__main__":
    app()

# PARTITION='all' sb --quick 'sleep 300'
# cat $HOMEDIR/perm/scripts/gpu_data/gpus/*.txt > $HOMEDIR/perm/scripts/gpu_data/uuids.txt