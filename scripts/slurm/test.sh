#!/bin/bash
#SBATCH -J holder2  # Job name
#SBATCH -o sbatch_logs.out                  # Name of stdout output log file (%j expands to jobID)
#SBATCH -e sbatch_logs.out                  # Name of stderr output log file (%j expands to jobID)
#SBATCH --nodes=2                                 # Total number of nodes requested
#SBATCH --ntasks-per-node=8                       # Total number of task requested
#SBATCH --cpus-per-task=8                        # Total number of cores requested
#SBATCH --mem=512G
#SBATCH -t 72:00:00                          # Time limit (hh:mm:ss)
#SBATCH --gpus-per-node=8                       # Specify a list of generic consumable resources (per node)
########
python -c "import time; time.sleep(3600*72)"