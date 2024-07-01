#!/bin/sh
nvidia-smi --query-gpu=index,uuid --format=csv,noheader | awk -v host=$(hostname) '{gsub(/, /, ","); print $0 "," host}' > /home/mprabhud/aswerdlo/perm/scripts/gpu_data/gpus/$(hostname).txt