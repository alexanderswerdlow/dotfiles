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


def tail_log_file(log_file_path_prefix):
    max_retries = 60
    retry_interval = 2
    seen_files = set()

    print(f"Looking for logs: {log_file_path_prefix}")
    for _ in range(max_retries):
        for log_file_path in Path(log_file_path_prefix.parent).glob(f'{log_file_path_prefix.stem}*'):
            if log_file_path not in seen_files and os.path.exists(log_file_path):
                with open(log_file_path, 'r') as f:
                    print(f.read())

                seen_files.add(log_file_path)
        time.sleep(retry_interval)

    print(f"File not found: {log_file_path} after {max_retries * retry_interval} seconds...")

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
    wait: bool = False,
    quick: bool = False,
    log_dir: Optional[Path] = None,
    log_filename: Optional[str] = None,
):
    if quick:
        all_machines = True
        cpu_count = 1
        mem = 1
        gpu_count = 0

    log_datetime = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
    
    if log_dir is None:
        if quick:
            log_dir = Path('output_logs')
        else:
            log_dir = Path.home() / 'logs'
        
    if log_filename is None:
        if quick:
            log_filename = log_dir / f'{Slurm.JOB_NAME}_{Slurm.HOSTNAME}_{Slurm.JOB_ID}.out'
        else:
            log_filename = log_dir / f'{log_datetime}_{Slurm.JOB_NAME}_{Slurm.HOSTNAME}_{Slurm.JOB_ID}.out'

    log_filename.parent.mkdir(exist_ok=True)
    print(f'Logging to: {log_filename}')

    if job_name is None:
        ms = datetime.now().strftime('%M%S')
        job_name = f'{working_dir.stem}_{ms}'

    timelimit = timedelta(days=3)
    if quick:
        timelimit = timedelta(minutes=5)
    elif partition == 'all':
        timelimit = timedelta(hours=6)
    elif partition == 'deepaklong':
        timelimit = timedelta(hours=48)

    task_def = dict(
        partition=partition,
        job_name=job_name,
        chdir=working_dir,
        output=log_filename,
        error=log_filename,
        time=timelimit,
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
        if wait:
            del task_def['output']
            del task_def['error']
        for node in get_all_nodes(partition=partition):
            print(f'Submitting to node: {node}')
            task_def['nodelist'] = node
            slurm = Slurm(**task_def)
            if wait:
                slurm.srun(extra_args)
            else:
                slurm.sbatch(extra_args)
    else:
        slurm = Slurm(**task_def)
        slurm.sbatch(extra_args)

    if quick and not wait:
        tail_log_file(log_dir / f'{log_datetime}_{job_name}')

    

if __name__ == "__main__":
    app()