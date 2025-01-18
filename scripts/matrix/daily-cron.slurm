#!/bin/bash
#SBATCH --job-name=daily-cron
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --hint=nomultithread         # we get physical cores not logical
#SBATCH --time=0:30:00               # maximum execution time (HH:MM:SS)
#SBATCH --output=/home/aswerdlo/dotfiles/local/logs/%x-%j.out           # output file name
#SBATCH --partition=general
#SBATCH --mail-user=swerdlow@cmu.edu
#SBATCH --mail-type=FAIL

set -Eeuo pipefail

# ensure to restart self first
sbatch --begin=now+24hour $DOTFILES/scripts/matrix/daily-cron.slurm

# now launch any slurm scripts in cron.daily
cd $DOTFILES/local/cron/daily

for f in *.slurm; do
  sbatch "$f"
done