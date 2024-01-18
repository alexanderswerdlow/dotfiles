import subprocess
from pathlib import Path
from pathlib import Path
from typing import Dict, Optional
from datetime import datetime, timedelta
import typer
from typing_extensions import Annotated
from typing import List, Optional
import sys
import os
import pwd
import subprocess

cachedir = 'cache'
from joblib import Memory
memory = Memory(cachedir, verbose=0)

@memory.cache
def get_size(path):
    print('Getting size of', path)
    result = subprocess.run(['diskus', path], capture_output=True, text=True)
    return result.stdout.strip()

app = typer.Typer(pretty_exceptions_show_locals=False)

@app.command()
def main(top_path: Path):
    bytes_to_gb = lambda bytes: bytes / 1024**3
    size_dict: Dict[int, Path] = {}

    for path in top_path.iterdir():
        if path.is_dir():
            result = get_size(str(path))
            size = int(result)
            size_dict[size] = path            

    print('\n\n\nResults:')
    for size, path in sorted(size_dict.items(), key=lambda item: item[0], reverse=True):
        owner_name = os.stat(path).st_uid
        try:
            owner_name = pwd.getpwuid(owner_name).pw_name
        except Exception as e:
            pass
        if bytes_to_gb(size) > 1:
            print(f'{path},{bytes_to_gb(size):.2f}GB,{owner_name}')

    total_space = sum(size_dict.keys())
    print(f'\n\nTotal space: {bytes_to_gb(total_space):.2f}GB')

if __name__ == "__main__":
    app()