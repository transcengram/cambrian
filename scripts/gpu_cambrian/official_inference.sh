#!/bin/bash

#python my_inference.py \
#    --conv_mode "llama_3" \
#    --model_path "/public/home/seg_test/cambrian/checkpoints/cambrian-8b-pretrain" \
#    --model_name "cambrian-8b-pretrain" \
#    --model_base "lmsys/vicuna-7b-v1.5"

#model_path="/public/home/seg_test/zgr/cambrian_gpu/checkpoints/cambrian-vicuna7b-finetune"
#
#python my_inference.py \
#    --conv_mode "v1" \
#    --model_path "$model_path" \
#    --model_name "cambrian-8b-finetune"

model_path="nyu-visionx/cambrian-8b"

CUDA_VISIBLE_DEVICES=7 \
python my_inference.py \
    --conv_mode "llama_3" \
    --model_path "$model_path" \
    --model_name "cambrian-8b"


# /public/home/seg_test/lby/data/CLIP.png
# Describe the image as detailed as possible.
