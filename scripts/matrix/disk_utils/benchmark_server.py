#!/home/aswerdlo/dotfiles/venv/bin/python

from pathlib import Path
import shutil
import subprocess
from flask import Flask, jsonify, send_from_directory, render_template_string
import ngrok
from datetime import datetime
import os

app = Flask(__name__)
try:
    listener = ngrok.connect(5000, authtoken_from_env=True, domain='liberal-firm-macaque.ngrok-free.app')
    print(f"Ingress established at {listener.url()}")
except Exception as e:
    print(f'Failed to establish ingress with ngrok. Please port forward on port 5000 to access server')

home_dir = Path('/home/aswerdlo')
log_dir = home_dir / 'tmp' / 'scratch' / 'disk_testing' / 'server'
log_dir.mkdir(parents=True, exist_ok=True)
script_folder = home_dir / 'dotfiles' / 'scripts' / 'matrix'

@app.route('/')
def index():
    template = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Run Command</title>
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    </head>
    <body>
        <button id="benchmark">Run New Benchmark</button>
        <button id="fetchImageBtn">Get Plot</button>
        <pre id="benchmarkOutput"></pre>
        <img id="outputImage" src="" alt="Generated Image" style="display:none;"/>
        
        <script>
            $(document).ready(function() {
                fetchImage();  // Fetch image immediately on page load
            });

            $("#benchmark").click(function() {
                $("#outputImage").attr("src", "").hide();
                $.post("/benchmark", function(data) {
                    if (data.success) {
                        $("#benchmarkOutput").text(data.output);
                        setTimeout(fetchImage, 1000);  // 10 seconds after data.success
                        setTimeout(fetchImage, 5000);  // 10 seconds after data.success
                        setTimeout(fetchImage, 10000);  // 10 seconds after data.success
                        setTimeout(fetchImage, 15000);  // 10 seconds after data.success
                        setTimeout(fetchImage, 20000);  // 10 seconds after data.success
                        setTimeout(fetchImage, 30000);  // 30 seconds after data.success
                        setTimeout(fetchImage, 60000);  // 30 seconds after data.success
                        setTimeout(fetchImage, 120000);  // 30 seconds after data.success
                    }
                });
            });

            $("#fetchImageBtn").click(fetchImage);

            function fetchImage() {
                $.get("/plot", function(data) {
                    $("#outputImage").attr("src", data.image_path).show();
                });
            }
        </script>
    </body>
    </html>
    """
    return render_template_string(template)

@app.route('/benchmark', methods=['POST'])
def benchmark():
    shutil.rmtree(log_dir, ignore_errors=True)
    timestamp_str = datetime.now().isoformat()
    
    partition_str = ''
    if 'PARTITION' in os.environ:
        partition_str = f"--partition={os.environ['PARTITION']} "

    result = subprocess.run([(
        fr'{script_folder / "sbatch.py"} '
        fr'{partition_str}--gpu_count=0 --mem=4 --cpu_count=4 --all_machines '
        fr'{script_folder / "benchmark.py"} '
        fr'--fio_size=8M --fio_bs=8k --once --test_file_max_size_mb=4 --num_test_files=4 '
        fr'--use_hostname --no-append --log_output {log_dir} ' 
        fr'--timestamp_str \'{timestamp_str}\''
    )], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    output = result.stdout + result.stderr
    return jsonify(success=True, output=output)

@app.route('/plot', methods=['GET'])
def plot():
    subprocess.run([f'{script_folder / "plot_multiple_servers_single.py"} {log_dir}'], shell=True)
    image_url = f"/images/{log_dir.stem}.png"
    return jsonify(image_path=image_url)

@app.route('/images/<filename>')
def serve_image(filename):
    try:
        return send_from_directory(log_dir, filename)
    except FileNotFoundError:
        return jsonify(error="File not found"), 404

if __name__ == '__main__':
    app.run()