#!/home/aswerdlo/dotfiles/venv/bin/python

import os
import shutil
import time
from typing import Optional
import pandas as pd
import matplotlib.pyplot as plt
import schedule
from datetime import datetime, timedelta
from pathlib import Path
import subprocess
import json
import typer
from pathlib import Path
import random
import shutil
import re

app = typer.Typer(pretty_exceptions_show_locals=False)
typer.main.get_command_name = lambda name: name

all_columns = ["timestamp", "fio_time", "file", "fio_read_iops", "fio_write_iops"]

def test_file_write_read():
    dir_path = test_folder / (datetime.now().strftime("%Y_%m_%d-%I_%M_%S_%p") + "_" + str(random.randint(1000000, 9999999)))
    try:
        start_time = time.time()
        dir_path.mkdir(exist_ok=True)
        file_paths = []
        for i in range(num_test_files_):
            file_size_bytes = int((test_file_max_size_mb_ / (2**i)) * 1024 * 1024)
            file_name = f"random_file_{str(random.randint(1000000, 9999999))}.bin"
            file_path = dir_path / file_name
            with open(file_path, "wb") as f:
                f.write(os.urandom(file_size_bytes))
            file_paths.append(file_path)
            subprocess.run(f'/usr/bin/ls {dir_path}', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        for file_path in file_paths:
            with open(file_path, "rb") as f:
                _ = f.read()
        
        shutil.rmtree(dir_path)
        elapsed_time = time.time() - start_time
    except Exception as e:
        print(e)
        elapsed_time = float('nan')

    try:
        shutil.rmtree(dir_path)
    except Exception as e:
        pass

    return elapsed_time

def test_fio():
    datetimestr = datetime.now().isoformat()
    log_file = fio_output / f'{datetimestr}.json'
    runtime_str = ''
    if runtime_ is not None:
        runtime_str = f' --time_based --runtime={runtime_}'
    cmd = f'fio --name="4k_randomrw" --rw=randrw --ioengine=sync --bs={fio_bs_} --numjobs=1 --size={fio_size_} --group_reporting --directory="{test_folder}" --output-format=json -o {log_file}{runtime_str}'
    print(cmd)
    start_time = time.time()
    completed_process = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    end_time = time.time()

    elapsed_time, read_iops, write_iops = float('nan'), float('nan'), float('nan')
    if completed_process.returncode != 0:
        print(f"Error occurred. at {datetimestr} stderr:")
        print(completed_process.stderr)
    else:
        elapsed_time = end_time - start_time
        with log_file.open('r') as file:
            content = json.load(file)
            read_iops = content['jobs'][0]['read']['iops']
            write_iops = content['jobs'][0]['write']['iops']

    return elapsed_time, read_iops, write_iops

def job():
    global df

    elapsed_time_file_write_read = test_file_write_read()
    elapsed_time_fio, read_iops, write_iops = test_fio()

    timestamp = datetime.now()
    total_seconds = (timestamp - datetime.fromisoformat(init_timestamp_str_)).total_seconds() if init_timestamp_str_ is not None else None

    new_row = pd.DataFrame({
        "timestamp": [timestamp], 
        "fio_time": [elapsed_time_fio], 
        "fio_read_iops": [read_iops], 
        "fio_write_iops": [write_iops], 
        "file": [elapsed_time_file_write_read],
        "total_seconds": [total_seconds]
        }, 
        index=[0],
    )
    df = pd.concat([df, new_row], ignore_index=True)

    if os.path.exists(csv_file_path):
        shutil.copy(csv_file_path, backup_csv_file_path)
    df.to_csv(tmp_csv_file_path, index=False)
    os.replace(tmp_csv_file_path, csv_file_path)

    print(f"At {datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}; Elapsed time for file write/read: {elapsed_time_file_write_read} sec, fio: {elapsed_time_fio} sec, read_iops: {read_iops}, write_iops: {write_iops}")

@app.command(context_settings={"allow_extra_args": True, "ignore_unknown_options": True})
def main(
    interval_sec: int = 30,
    log_output: Path = Path.cwd() / 'logs',
    log_file: str = 'data',
    use_hostname: bool = False,
    test_file_max_size_mb: int = 32,
    num_test_files: int = 15,
    append: bool = True,
    fio_size: str = '32M',
    fio_bs: str = '4k',
    once: bool = False,
    minutes: Optional[int] = None,
    test_folder_ : Path = Path.home() / '.cache' / 'debug',
    timestamp_str: Optional[str] = None,
    runtime: Optional[int] = None
):
    global test_folder, interval, df, csv_file_path, backup_csv_file_path, tmp_csv_file_path, fio_output, test_file_max_size_mb_, num_test_files_, fio_size_, fio_bs_, init_timestamp_str_, runtime_

    fio_size_ = fio_size
    fio_bs_ = fio_bs
    runtime_ = runtime

    fio_output = log_output / 'fio'
    fio_output.mkdir(parents=True, exist_ok=True)

    test_folder = test_folder_
    test_folder.mkdir(parents=True, exist_ok=True)

    test_file_max_size_mb_ = test_file_max_size_mb
    num_test_files_ = num_test_files 

    init_timestamp_str_ = timestamp_str

    assert test_file_max_size_mb / (2 ** num_test_files_) >= (1 / 1024)

    interval = interval_sec

    if use_hostname:
        import socket
        log_file = socket.gethostname()
        log_file = re.sub(r"\.eth$", "", log_file)
        log_file = re.sub(r"\.ml\.cmu\.edu$", "", log_file)
        log_file = re.sub(r"^matrix-", "", log_file)

    csv_file_path = log_output / f"{log_file}.csv"
    backup_csv_file_path = log_output / f"backup_{log_file}.csv"
    tmp_csv_file_path = log_output / f"tmp_{log_file}.csv"

    if append and os.path.exists(csv_file_path):
        df = pd.read_csv(csv_file_path)
    else:
        df = pd.DataFrame(columns=all_columns)

    if once:
        job()
    else:
        if minutes is not None:
            schedule.every(interval).seconds.until(timedelta(minutes=minutes)).do(job)
        else:
            schedule.every(interval).seconds.do(job)

        try:
            while schedule.idle_seconds() is not None:
                schedule.run_pending()
                time.sleep(1)
        except KeyboardInterrupt:
            print("Scheduler Stopped")

if __name__ == "__main__":
    app()