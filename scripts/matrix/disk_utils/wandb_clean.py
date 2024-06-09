#!/home/aswerdlo/dotfiles/venv/bin/python

import wandb
import typer
from typing import List, Optional
import datetime
app = typer.Typer(pretty_exceptions_show_locals=False)

typer.main.get_command_name = lambda name: name
bytes_to_mb = lambda bytes: bytes / 1024 ** 2

@app.command(context_settings={"allow_extra_args": True, "ignore_unknown_options": True})
def main(project: str, min_size_mb: float = 0.2):
    api = wandb.Api()
    runs = api.runs(f"aswerdlow/{project}")
    total_size = 0
    for run in runs:
        now = datetime.datetime.now()
        over_a_week = now - datetime.timedelta(days=7) > datetime.datetime.fromisoformat(run.metadata['startedAt'])
        if over_a_week:
            files = run.files()
            for file in files:
                if bytes_to_mb(file.size) >= min_size_mb:
                    print(f"Deleting {file.name} ({bytes_to_mb(file.size):.2f} MB)")
                    total_size += bytes_to_mb(file.size)
                    file.delete()

    print(f"Deleted {total_size:.2f} MB")
            
	
if __name__ == "__main__":
    app()