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

# @app.command(context_settings={"allow_extra_args": True, "ignore_unknown_options": True})

@app.command()
def main(
    node: Annotated[Optional[str], typer.Argument()] = None,
    attach: bool = True,
    gpus: int = 1,
    echo_ids: bool = False, # Used to export GPU UUIDs
    big: bool = False,
    partition: str = os.environ.get('PARTITION', ''),
    no_exit: bool = False,
    cpu: Optional[int] = None,
    mem: Optional[int] = None,
):
    cluster_name = os.environ.get('CLUSTER_NAME', '')
    dotfiles_dir = os.environ.get("DOTFILES")
    extra_args = []
    if cluster_name == "grogu":
        extra_args = ["-L", "aswerdlo", "-f", f"{dotfiles_dir}/.tmux.conf"]
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

    try:
        subprocess.run(['tmux', *extra_args, 'has-session', '-t', session_name], check=True)
        session_name = f"{session_name}_{random.randint(100,999)}"
        print(f"Session already exists, Setting session name: {session_name}")
    except subprocess.CalledProcessError:
        pass

    print('Creating session: ', session_name)
    subprocess.run(['tmux', *extra_args, 'new-session', '-d', '-s', session_name])

    if gpus == 0:
        resources = '-c4 --mem=8g'
    elif gpus == 1:
        resources = '--gres=gpu:1 -c8 --mem=48g'
    elif gpus == 2:
        resources = '--gres=gpu:2 -c16 --mem=96g'
    elif gpus == 3:
        resources = '--gres=gpu:3 -c24 --mem=144g'
    elif gpus == 4:
        resources = '--gres=gpu:4 -c32 --mem=192g'
    elif gpus == 5:
        resources = '--gres=gpu:5 -c40 --mem=240g'
    elif gpus == 6:
        resources = '--gres=gpu:6 -c48 --mem=288g'
    elif gpus == 7:
        resources = '--gres=gpu:7 -c56 --mem=336g'
    elif gpus == 8:
        resources = '--gres=gpu:8 -c64 --mem=384g'
    else:
        raise ValueError("Invalid number of GPUs")
    
    if cpu is not None:
        resources = re.sub(r'-c[0-9]+', f'-c{cpu}', resources)

    if mem is not None:
        resources = re.sub(r'--mem=[0-9]+g', f'--mem={mem}g', resources)
    
    if big:
        resources = f'{resources} --constraint=\'A100|6000ADA\''
    
    if re.match(fr"^{cluster_name}-[0-9]{{1}}-[0-9]{{2}}$", node):
        resources = f'{resources} --nodelist="{node}"'
    elif re.match(fr"^{cluster_name}-[0-9]{{1}}-[0-9]{{1}}$", node):
        resources = f'{resources} --nodelist="{node}"'

    id_str = ''
    if echo_ids:
        id_str = " -c '~/perm/scripts/gpu_data/run.sh'"

    if partition == 'all':
        time_limit = '--time=06:00:00'
    elif partition == 'deepaklong':
        time_limit = '--time=48:00:00'
    else:
        time_limit = '--time=72:00:00'

    comment = ''
    if cluster_name == 'grogu':
        comment = "--comment='aswerdlo' "

    srun_command = 'srun' if no_exit else 'srun_custom.sh' # srun_custom.sh auto kills the tmux when srun stops. Use srun otherwise.
    subprocess.run(['tmux', *extra_args, 'send-keys', '-t', session_name,
                    f'{srun_command} -p {partition} {comment}{time_limit} {resources} '
                    f'--pty $SHELL{id_str}', 'C-m'])
    
    if attach:
        subprocess.run(['tmux', *extra_args, 'attach', '-t', session_name])
    else:
        print(f"Session Created: {session_name}, to manually rename: tmux rename-session -t {session_name}")


if __name__ == "__main__":
    app()
