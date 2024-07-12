#!/bin/bash
#SBATCH -J cambrian_debug  # Job name
#SBATCH -o sbatch_logs_node.out                  # Name of stdout output log file (%n expands to nodeID)
#SBATCH -e sbatch_logs_node.out                  # Name of stderr output log file (%n expands to nodeID)
#SBATCH --nodes=2                                 # Total number of nodes requested
#SBATCH --ntasks-per-node=1                       # Total number of task requested
#SBATCH --cpus-per-task=1                        # Total number of cores requested
#SBATCH --mem=16G
#SBATCH -t 720:00:00                          # Time limit (hh:mm:ss)
#SBATCH --gpus-per-node=1                       # Specify a list of generic consumable resources (per node)
########
nodes=( $( scontrol show hostnames $SLURM_JOB_NODELIS ) )
nodes_array=($nodes)
head_node=${nodes_array[0]}
echo $SLURM_JOB_NODELIS
echo $head_node