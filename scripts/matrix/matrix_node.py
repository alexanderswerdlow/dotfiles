#!/home/aswerdlo/dotfiles/venv/bin/python

import argparse
import re
import subprocess
import random
import typer 

import typer

app = typer.Typer(pretty_exceptions_show_locals=False)

typer.main.get_command_name = lambda name: name

@app.command(context_settings={"allow_extra_args": True, "ignore_unknown_options": True})
def main(
    node_name: str,
    attach: bool = True,
    gpus: int = 1,
    echo_ids: bool = False, # Used to export GPU UUIDs
):

    if re.match(r"^[0-9]{3}$", node_name):
        node_name = f"matrix-{node_name[0]}-{node_name[1:3]}"
    elif re.match(r"^[0-9]{1}-[0-9]{2}$", node_name):
        node_name = f"matrix-{node_name}"

    match = re.match(r"matrix-([0-9])-([0-9]{2})", node_name)
    if not node_name:
        session_name = f"{random.randint(1000, 9999)}"
    elif match:
        session_name = f"{match.group(1)}{match.group(2)}"
    else:
        session_name = node_name

    try:
        subprocess.run(['tmux', 'has-session', '-t', session_name], check=True)
        session_name = f"{session_name}_{random.randint(100,999)}"
        print(f"Session already exists, Setting session name: {session_name}")
    except subprocess.CalledProcessError:
        pass

    print('Creating session: ', session_name)
    subprocess.run(['tmux', 'new-session', '-d', '-s', session_name])

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
        resources = '--gres=gpu:6 -c56 --mem=336g'
    elif gpus == 8:
        resources = '--gres=gpu:6 -c64 --mem=384g'
    else:
        raise ValueError("Invalid number of GPUs")

    if re.match(r"^matrix-[0-9]{1}-[0-9]{2}$", node_name):
        id_str = ''
        if echo_ids:
            id_str = " -c '~/perm/scripts/gpu_data/run.sh'"
        subprocess.run(['tmux', 'send-keys', '-t', session_name,
                        f'srun_custom.sh -p $PARTITION --time=72:00:00 {resources} '
                        f'--nodelist="{node_name}" --pty $SHELL{id_str}', 'C-m'])
    else:
        subprocess.run(['tmux', 'send-keys', '-t', session_name,
                        f'srun -p $PARTITION --time=72:00:00 {resources} --pty $SHELL', 'C-m'])

    if attach:
        subprocess.run(['tmux', 'attach', '-t', session_name])
    else:
        print(f"Session Created: {session_name}, to manually rename: tmux rename-session -t {session_name}")


if __name__ == "__main__":
    app()
