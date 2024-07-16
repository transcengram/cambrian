#!/bin/bash

export WANDB_NAME="cambrian-8b-finetune"
export WANDB_MODE="offline"

export IF_TRAIN=True
export _ROOT_DIR_="/public/home/seg_test/"

export CKPT_NAME="cambrian-8b-finetune" &&
export CKPT_DIR="$_ROOT_DIR_/cambrian/test_checkpoints/$CKPT_NAME" &&

deepspeed cambrian/train/train_gpu.py \
    --deepspeed ./scripts/zero2.json \
    --model_name_or_path lmsys/vicuna-7b-v1.5 \
    --version v1 \
    --data_path "$_ROOT_DIR_/zgr/data/Cambrian-10M/jsons/Cambrian7M_withsystemprompt.jsonl" \
    --image_folder "$_ROOT_DIR_/zgr/data/Cambrian-10M/" \
    --pretrain_mm_mlp_adapter "$_ROOT_DIR_/cambrian/test_checkpoints/cambrian-8b-pretrain/mm_projector.bin" \
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
    --unfreeze_mm_vision_tower False \
    --mm_vision_select_layer -2 \
    --mm_use_im_start_end False \
    --mm_use_im_patch_token False \
    --image_aspect_ratio pad \
    --group_by_modality_length True \
    --bf16 True \
    --output_dir $CKPT_DIR \
    --num_train_epochs 1 \
    --per_device_train_batch_size 8 \
    --per_device_eval_batch_size 4 \
    --gradient_accumulation_steps 1 \
    --evaluation_strategy "no" \
    --save_strategy "steps" \
    --save_steps 2000 \
    --save_total_limit 1 \
    --learning_rate 4e-5 \
    --weight_decay 0. \
    --warmup_ratio 0.03 \
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
