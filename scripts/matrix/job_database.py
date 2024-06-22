#!/bin/sh
'''exec' "$(dirname "$0")/../../venv/bin/python" "$0" "$@"
' '''

from typer import Typer, echo, main
from json import dumps, loads
from os import environ
from pathlib import Path
from sqlite3 import connect
from subprocess import CalledProcessError, run
from typing import Optional

main.get_command_name = lambda name: name
app = Typer(pretty_exceptions_show_locals=False)

user = environ.get("USER", "")

conn = connect(Path(__file__).parent / "job_database.db")
cursor = conn.cursor()
cursor.execute(
    """
CREATE TABLE IF NOT EXISTS jobs (
    job_id TEXT PRIMARY KEY,
    gpu_names TEXT,
    machine_name TEXT
)
"""
)
conn.commit()


def is_job_active(job_id):
    try:
        result = run(
            ["squeue", "-u", user, "-o", '"%.T"', "-j", job_id],
            capture_output=True,
            text=True,
        ).stdout.splitlines()
        return len(result) > 1 and "RUNNING" in result[1]
    except CalledProcessError:
        return False


def delete_inactive_jobs(machine_name: Optional[str] = None):
    if machine_name:
        cursor.execute(
            "SELECT job_id FROM jobs WHERE machine_name = ?", (machine_name,)
        )
    else:
        cursor.execute("SELECT job_id FROM jobs")

    for (job_id,) in cursor.fetchall():
        if not is_job_active(job_id):
            cursor.execute("DELETE FROM jobs WHERE job_id = ?", (job_id,))

    conn.commit()


@app.command()
def add_job(job_id: str, machine_name: str, gpu_ids: str):
    delete_inactive_jobs()
    gpu_names_json = dumps(gpu_ids.split(","))
    # Delete existing job with the same ID if it exists
    cursor.execute("DELETE FROM jobs WHERE job_id = ?", (job_id,))
    # Insert the new job
    cursor.execute(
        "INSERT INTO jobs (job_id, gpu_names, machine_name) VALUES (?, ?, ?)",
        (job_id, gpu_names_json, machine_name),
    )
    conn.commit()
    echo(f"Job {job_id} added to machine {machine_name} with GPUs {gpu_ids}")


@app.command()
def get_gpus(machine_name: str):
    delete_inactive_jobs()
    
    cursor.execute(
        "SELECT job_id, gpu_names FROM jobs WHERE machine_name = ?", (machine_name,)
    )
    active_gpus = []

    for job_id, gpu_names in cursor.fetchall():
        active_gpus.extend(loads(gpu_names))

    active_gpus = sorted([int(gpu) for gpu in active_gpus if gpu != ""])
    if len(active_gpus) == 0:
        echo("8")
    else:
        echo(f"{','.join(map(str, active_gpus))}")


@app.command()
def clear_db():
    cursor.execute("DELETE FROM jobs")
    conn.commit()
    echo("Database cleared.")


@app.command()
def get_all():
    cursor.execute(
        "SELECT machine_name, job_id, gpu_names FROM jobs ORDER BY machine_name"
    )
    data = cursor.fetchall()

    if not data:
        echo("No data available.")
        return

    current_machine = None
    for machine_name, job_id, gpu_names in data:
        if machine_name != current_machine:
            echo(f"Machine: {machine_name}")
            current_machine = machine_name
        echo(f"  Job ID: {job_id}, GPUs: {','.join(loads(gpu_names))}")


if __name__ == "__main__":
    app()
