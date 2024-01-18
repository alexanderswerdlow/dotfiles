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
    fig, axs = plt.subplots(4, 1, figsize=(10, 16))
    
    all_files = sorted(list(filter(lambda x: not (str(x.stem).startswith('backup') or str(x.stem).startswith('tmp')), log_folder.glob('*.csv'))))
    
    for csv_file in all_files:
        df = pd.read_csv(csv_file)
        df['timestamp'] = pd.to_datetime(df['timestamp'])
        
        file_name = csv_file.stem  # Get the file name without the .csv
        
        # Plot 'file' values
        axs[0].plot(df['timestamp'], df['file'], label=file_name)
        axs[0].set_title('Time to write/read 15 files from [1-32MB]')
        axs[0].set_ylabel('Elapsed Time (s)')
        axs[0].grid(True)

        # Plot 'fio_time' values
        axs[1].plot(df['timestamp'], df['fio_time'], label=file_name)
        axs[1].set_title('fio benchmark time')
        axs[1].set_ylabel('Elapsed Time (s)')
        axs[1].grid(True)

        # Plot 'fio_read_iops' values
        axs[2].plot(df['timestamp'], df['fio_read_iops'], label=file_name)
        axs[2].set_title('fio Read IOPS')
        axs[2].set_ylabel('Read IOPS')
        axs[2].grid(True)

        # Plot 'fio_write_iops' values
        axs[3].plot(df['timestamp'], df['fio_write_iops'], label=file_name)
        axs[3].set_title('fio Write IOPS')
        axs[3].set_ylabel('Write IOPS')
        axs[3].grid(True)

    # Add legends
    for ax in axs:
        ax.legend(loc='upper left', bbox_to_anchor=(1, 1))

    # Adjust layout
    plt.tight_layout()

    # Save the Figure as an image file
    image_file = Path(f"{log_folder.stem}.png")
    plt.savefig(image_file, bbox_inches='tight')

    # Show the plot
    plt.show()

if __name__ == "__main__":
    app()
