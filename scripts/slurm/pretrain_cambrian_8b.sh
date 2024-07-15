#!/bin/bash
#SBATCH -J cambrian_debug  # Job name
#SBATCH -o sbatch_logs.out                  # Name of stdout output log file (%j expands to jobID)
#SBATCH -e sbatch_logs.out                  # Name of stderr output log file (%j expands to jobID)
#SBATCH --nodes=1                                 # Total number of nodes requested
#SBATCH --ntasks=8                                     # Total number of task requested
#SBATCH --cpus-per-task=16                        # Total number of cores requested
#SBATCH --mem=1024G
#SBATCH -t 720:00:00                          # Time limit (hh:mm:ss)
#SBATCH --gres=gpu:8                       # Specify a list of generic consumable resources (per node)
########

env
hostname
nvidia-smi

export WANDB_BASE_URL="http://10.10.10.26:8080"
export WANDB_API_KEY="local-1d1a38070771d4b60e996cf2ac75859f268ada0e"
export WANDB_PROJECT="cambrian"
#export WANDB_MODE="offline"
bash scripts/gpu_cambrian/pretrain_cambrian_8b.sh
