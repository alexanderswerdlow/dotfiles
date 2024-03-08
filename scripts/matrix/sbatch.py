#!/home/aswerdlo/dotfiles/venv/bin/python

import os
from simple_slurm import Slurm
from pathlib import Path
from typing import Optional
from datetime import datetime, timedelta
import typer
from typing import List, Optional
import subprocess

gpu_ref_gb = {'A5500': 24, 'A100': 40, 'volta': 32, '6000ADA': 48, '2080Ti': 11, 'titanx': 12}

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
def main(
    ctx: typer.Context,
    mem: Optional[int] = None,
    cpu_count: Optional[int] = None,
    gpu_mem: Optional[int] = None, 
    gpu_name: Optional[str] = None, 
    gpu_count: Optional[int] = 1,
    node_name: Optional[str] = None,
    export_env: bool = True,
    working_dir: Path = Path.cwd(),
    job_name: Optional[str] = None,
    all_machines: bool = False,
    partition: str = os.environ.get('PARTITION', ''),
):
    log_datetime = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
    log_dir = Path.home() / 'logs'
    log_dir.mkdir(exist_ok=True)
    log_filename = log_dir / f'{log_datetime}_{Slurm.JOB_NAME}_{Slurm.HOSTNAME}_{Slurm.JOB_ID}'
    print(f'Logging to: {log_filename}')

    if job_name is None:
        ms = datetime.now().strftime('%M%S')
        job_name = f'{working_dir.stem}_{ms}'

    task_def = dict(
        partition=partition,
        job_name=job_name,
        chdir=working_dir,
        output=f'{log_filename}.out',
        error=f'{log_filename}.out',
        time=timedelta(hours=6) if partition == 'all' else timedelta(days=3),
    )

    if gpu_count > 0:
        if gpu_name is not None:
            task_def['constraint'] = gpu_name
            print(f'Taking GPUs with name: {gpu_name}')
        elif gpu_mem is not None:
            allowable_gpus = [gpu for gpu, gb in gpu_ref_gb.items() if gb >= gpu_mem]
            task_def['constraint'] = '|'.join(allowable_gpus)
            print(f'Taking GPUs with >={gpu_mem} GB VRAM: {", ".join(allowable_gpus)}')

        task_def['gres'] = f'gpu:{gpu_count}'
        print(f'Using {gpu_count} GPU(s)')

    if mem is not None:
        task_def['mem'] = f'{mem}g'
    else:
        task_def['mem'] = f'{32 * max(1, gpu_count)}g'
    
    print(f"Using {task_def['mem']} of RAM")

    if cpu_count is not None:
        task_def['cpus_per_task'] = cpu_count
    else:
        task_def['cpus_per_task'] = 8 * max(1, gpu_count)

    print(f"Using {task_def['cpus_per_task']} CPUs")

    if node_name is not None:
        task_def['nodelist'] = node_name
        print(f"Using node: {node_name}")

    if export_env:
        task_def['export'] = 'ALL'

    extra_args = " ".join(ctx.args)
    print(f"Extra args: {extra_args}")

    if all_machines:
        for node in get_all_nodes(partition=partition):
            print(f'Submitting to node: {node}')
            task_def['nodelist'] = node
            slurm = Slurm(**task_def)
            slurm.sbatch(extra_args)
    else:
        slurm = Slurm(**task_def)
        slurm.sbatch(extra_args)

if __name__ == "__main__":
    app()