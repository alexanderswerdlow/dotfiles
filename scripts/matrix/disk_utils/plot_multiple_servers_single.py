#!/home/aswerdlo/dotfiles/venv/bin/python

import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
import typer

app = typer.Typer(pretty_exceptions_show_locals=False)

@app.command(context_settings={"allow_extra_args": True, "ignore_unknown_options": True})
def main(
    log_folder: Path
):
    # Create a Figure object with multiple subplots
    fig, axs = plt.subplots(5, 1, figsize=(10, 16))
    
    all_files = sorted(list(filter(lambda x: not (str(x.stem).startswith('backup') or str(x.stem).startswith('tmp')), log_folder.glob('*.csv'))))
    
    for csv_file in all_files:
        df = pd.read_csv(csv_file)
        
        file_name = csv_file.stem.lstrip('matrix-').rstrip('.eth')  # Get the file name without the .csv
        
        # Plot 'file' values
        axs[0].bar(file_name, df['file'].values[0], color='orange')
        axs[0].set_title('Time to write/read 4 files from [1-4MB]')
        axs[0].set_ylabel('Elapsed Time (s)')
        axs[0].grid(True)

        # Plot 'fio_time' values
        axs[1].bar(file_name, df['fio_time'].values[0], color='blue')
        axs[1].set_title('fio benchmark time')
        axs[1].set_ylabel('Elapsed Time (s)')
        axs[1].grid(True)

        # Plot 'fio_read_iops' values
        axs[2].bar(file_name, df['fio_read_iops'].values[0], color='green')
        axs[2].set_title('fio Read IOPS')
        axs[2].set_ylabel('Read IOPS')
        axs[2].grid(True)

        # Plot 'fio_write_iops' values
        axs[3].bar(file_name, df['fio_write_iops'].values[0], color='purple')
        axs[3].set_title('fio Write IOPS')
        axs[3].set_ylabel('Write IOPS')
        axs[3].grid(True)

        # Plot 'total_seconds' values
        axs[4].bar(file_name, df['total_seconds'].values[0], color='red')
        axs[4].set_title('Total time elapsed')
        axs[4].set_ylabel('Elapsed Time (s)')
        axs[4].grid(True)

    # Adjust layout
    plt.tight_layout()

    # Save the Figure as an image file
    image_file = Path(log_folder / f"{log_folder.stem}.png")
    image_file.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(image_file)

    # Show the plot
    plt.show()

if __name__ == "__main__":
    app()
