#!/bin/bash
#SBATCH -J cambrian_debug  # Job name
#SBATCH -o sbatch_logs.out                  # Name of stdout output log file (%j expands to jobID)
#SBATCH -e sbatch_logs.out                  # Name of stderr output log file (%j expands to jobID)
#SBATCH --nodes=2                                 # Total number of nodes requested
#SBATCH --ntasks-per-node=8                       # Total number of task requested
#SBATCH --cpus-per-task=8                        # Total number of cores requested
#SBATCH --mem=512G
#SBATCH -t 720:00:00                          # Time limit (hh:mm:ss)
#SBATCH --gpus-per-node=8                       # Specify a list of generic consumable resources (per node)
########

# ******************************************************************************************
export PATH=/public/home/seg_test/zgr/bin/pdsh/bin:$PATH
mkdir -p slurm_tmp
export HOSTFILE="./slurm_tmp/hostfile${SLURM_JOB_ID}"
scontrol show hostnames $SLURM_JOB_NODELIS | while read NODE; do
    echo "$NODE slots=$SLURM_GPUS_PER_NODE" >> $HOSTFILE
done

export RANK=$SLURM_PROCID
export LOCAL_RANK=$SLURM_LOCALID

export MASTER_PORT=55555
export WORLD_SIZE=$(($SLURM_NNODES * $SLURM_JOB_NUM_NODES))

export MASTER_ADDR=$(scontrol show hostnames "$SLURM_JOB_NODELIST" | head -n 1)

export NCCL_P2P_LEVEL=NVL
# ******************************************************************************************


export CKPT_NAME="cambrian-8b-finetune" &&
export CKPT_DIR="/public/home/seg_test/cambrian/checkpoints/$CKPT_NAME" &&

#env viarables used in the program need to be added here
export DS_ENV_FILE="$(pwd)/scripts/slurm/.deepspeed_env"

export _ROOT_DIR_="/public/home/seg_test/"


deepspeed \
    --num_nodes $SLURM_JOB_NUM_NODES \
    --num_gpus $SLURM_GPUS_PER_NODE \
    --master_addr $MASTER_ADDR \
    --master_port $MASTER_PORT \
    --hostfile $HOSTFILE \
    --no_ssh_check \
    cambrian/train/train_gpu.py \
    --deepspeed ./scripts/zero2.json \
    --model_name_or_path lmsys/vicuna-7b-v1.5 \
    --version plain \
    --data_path "$_ROOT_DIR_/zgr/data/Cambrian-Alignment/jsons/alignment_2.5m.jsonl" \
    --image_folder "$_ROOT_DIR_/zgr/data/Cambrian-Alignment/" \
    --vision_tower_aux_list '["siglip/CLIP-ViT-SO400M-14-384", "openai/clip-vit-large-patch14-336", "facebook/dinov2-giant-res378", "clip-convnext-XXL-multi-stage"]' \
    --vision_tower_aux_token_len_list '[576, 576, 576, 9216]' \
    --image_token_len 576 \
    --num_query_group 1 \
    --query_num_list '[576]' \
    --connector_depth 3 \
    --image_position 91 \
    --vision_hidden_size 1024 \
    --connector_only False \
    --num_of_vision_sampler_layers 10 \
    --start_of_vision_sampler_layers 0 \
    --stride_of_vision_sampler_layers 3 \
    --mm_projector_type sva \
    --mm_vision_sampler_lr 1e-4 \
    --tune_mm_mlp_adapter True \
    --mm_vision_select_layer -2 \
    --mm_use_im_start_end False \
    --mm_use_im_patch_token False \
    --image_aspect_ratio pad \
    --bf16 True \
    --output_dir $CKPT_DIR \
    --num_train_epochs 1 \
    --per_device_train_batch_size 16 \
    --per_device_eval_batch_size 4 \
    --gradient_accumulation_steps 1 \
    --evaluation_strategy "no" \
    --save_strategy "steps" \
    --save_steps 1000 \
    --save_total_limit 1 \
    --learning_rate 1e-3 \
    --weight_decay 0. \
    --warmup_ratio 0.06 \
    --lr_scheduler_type "cosine" \
    --logging_steps 1 \
    --tf32 True \
    --model_max_length 2048 \
    --gradient_checkpointing True \
    --dataloader_num_workers 4 \
    --lazy_preprocess True \
    --run_name $CKPT_NAME \
    --report_to wandb

#CKPT_PATH=checkpoints/$CKPT_NAME
CKPT_PATH=$CKPT_DIR
# check if the checkpoint path exists
if [ ! -d "$CKPT_PATH" ]; then
    echo "Checkpoint path does not exist. Exiting..."
    exit 1
fi
#echo "Training finished. Syncing checkpoints to GCS..."
#gcloud alpha storage rsync $CKPT_PATH gs://us-central2-storage/cambrian/checkpoints/$CKPT_NAME
echo "Training (Finetune) finished."
echo "Syncing finished. Checkpoints are now available at $CKPT_DIR"
