import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
import numpy as np
import typer

app = typer.Typer(pretty_exceptions_show_locals=False)

@app.command(context_settings={"allow_extra_args": True, "ignore_unknown_options": True})
def main(
    log_folder: Path
):
    # Load the DataFrame from the CSV file
    csv_file = Path(log_folder / 'data.csv')
    df = pd.read_csv(csv_file)

    # Parse the Timestamp column to datetime
    df['timestamp'] = pd.to_datetime(df['timestamp'])

    # Create a Figure object with multiple subplots
    fig, axs = plt.subplots(4, 1, figsize=(10, 16))

    # Plot 'file' values
    axs[0].plot(df['timestamp'], df['file'], label='file', color='orange', marker='o', linestyle='none')
    axs[0].scatter(df['timestamp'], df['file'].where(df['file'].isna()), color='red', label='NaN', marker='x')
    axs[0].set_title(f'Time to write/read 1MB file, min: {round(df["file"].min(), 2)}')
    axs[0].set_xlabel('Timestamp')
    axs[0].set_ylabel('Elapsed Time (s)')
    axs[0].grid(True)
    axs[0].legend()

    # Plot 'fio_time' values
    axs[1].plot(df['timestamp'], df['fio_time'], label='fio_time', color='blue', marker='o', linestyle='none')
    axs[1].scatter(df['timestamp'], df['fio_time'].where(df['fio_time'].isna()), color='red', label='NaN', marker='x')
    axs[1].set_title(f'fio benchmark time, min: {round(df["fio_time"].min(), 2)}')
    axs[1].set_xlabel('Timestamp')
    axs[1].set_ylabel('Elapsed Time (s)')
    axs[1].grid(True)
    axs[1].legend()

    # Plot 'fio_read_iops' values
    axs[2].plot(df['timestamp'], df['fio_read_iops'], label='fio_read_iops', color='green', marker='o', linestyle='none')
    axs[2].scatter(df['timestamp'], df['fio_read_iops'].where(df['fio_read_iops'].isna()), color='red', label='NaN', marker='x')
    axs[2].set_title(f'fio Read IOPS, max: {round(df["fio_read_iops"].max(), 2)}')
    axs[2].set_xlabel('Timestamp')
    axs[2].set_ylabel('Read IOPS')
    axs[2].grid(True)
    axs[2].legend()

    # Plot 'fio_write_iops' values
    axs[3].plot(df['timestamp'], df['fio_write_iops'], label='fio_write_iops', color='purple', marker='o', linestyle='none')
    axs[3].scatter(df['timestamp'], df['fio_write_iops'].where(df['fio_write_iops'].isna()), color='red', label='NaN', marker='x')
    axs[3].set_title(f'fio Write IOPS, max: {round(df["fio_write_iops"].max(), 2)}')
    axs[3].set_xlabel('Timestamp')
    axs[3].set_ylabel('Write IOPS')
    axs[3].grid(True)
    axs[3].legend()

    # Adjust layout
    plt.tight_layout()

    # Save the Figure as an image file
    image_file = Path(f"{log_folder.stem}.png")
    plt.savefig(image_file)

    # Show the plot
    plt.clf()

if __name__ == "__main__":
    app()