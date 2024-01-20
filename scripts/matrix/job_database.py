#!/home/aswerdlo/dotfiles/venv/bin/python

from pathlib import Path
import sqlite3
import subprocess
import json
from typing import Optional
import typer

typer.main.get_command_name = lambda name: name
app = typer.Typer(pretty_exceptions_show_locals=False)

conn = sqlite3.connect(Path(__file__).parent / 'job_database.db')
cursor = conn.cursor()
cursor.execute('''
CREATE TABLE IF NOT EXISTS jobs (
    job_id TEXT PRIMARY KEY,
    gpu_names TEXT,
    machine_name TEXT
)
''')
conn.commit()

def is_job_active(job_id):
    try:
        result = subprocess.run(['squeue', '-j', job_id], capture_output=True, text=True)
        return job_id in result.stdout
    except subprocess.CalledProcessError:
        return False

def delete_inactive_jobs(machine_name: Optional[str] = None):
    if machine_name:
        cursor.execute('SELECT job_id FROM jobs WHERE machine_name = ?', (machine_name,))
    else:
        cursor.execute('SELECT job_id FROM jobs')
    
    for (job_id,) in cursor.fetchall():
        if not is_job_active(job_id):
            cursor.execute('DELETE FROM jobs WHERE job_id = ?', (job_id,))
    
    conn.commit()

@app.command()
def add_job(job_id: str, machine_name: str, gpu_ids: str):
    delete_inactive_jobs()
    gpu_names_json = json.dumps(gpu_ids.split(","))
    # Delete existing job with the same ID if it exists
    cursor.execute('DELETE FROM jobs WHERE job_id = ?', (job_id,))
    # Insert the new job
    cursor.execute('INSERT INTO jobs (job_id, gpu_names, machine_name) VALUES (?, ?, ?)',
                   (job_id, gpu_names_json, machine_name))
    conn.commit()
    typer.echo(f"Job {job_id} added to machine {machine_name} with GPUs {gpu_ids}")

@app.command()
def get_gpus(machine_name: str):
    delete_inactive_jobs()
    cursor.execute('SELECT job_id, gpu_names FROM jobs WHERE machine_name = ?', (machine_name,))
    active_gpus = []

    for job_id, gpu_names in cursor.fetchall():
        if is_job_active(job_id):
            active_gpus.extend(json.loads(gpu_names))
    
    active_gpus = sorted([int(gpu) for gpu in active_gpus])
    typer.echo(f"{','.join(map(str, active_gpus))}")

@app.command()
def clear_db():
    cursor.execute('DELETE FROM jobs')
    conn.commit()
    typer.echo("Database cleared.")

@app.command()
def get_all_data():
    cursor.execute('SELECT machine_name, job_id, gpu_names FROM jobs ORDER BY machine_name')
    data = cursor.fetchall()

    if not data:
        typer.echo("No data available.")
        return

    current_machine = None
    for machine_name, job_id, gpu_names in data:
        if machine_name != current_machine:
            if current_machine is not None:
                typer.echo("\n")
            typer.echo(f"Machine: {machine_name}")
            current_machine = machine_name
        typer.echo(f"  Job ID: {job_id}, GPUs: {','.join(json.loads(gpu_names))}")

if __name__ == "__main__":
    app()
