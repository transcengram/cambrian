#!/bin/bash

#python my_inference.py \
#    --conv_mode "llama_3" \
#    --model_path "/public/home/seg_test/cambrian/checkpoints/cambrian-8b-pretrain" \
#    --model_name "cambrian-8b-pretrain" \
#    --model_base "lmsys/vicuna-7b-v1.5"

python my_inference.py \
    --conv_mode "llama_3" \
    --model_path "/public/home/seg_test/lby/cambrian/checkpoints/cambrian-8b-finetune" \
    --model_name "cambrian-8b-finetune"

# /public/home/seg_test/lby/data/CLIP.png
# Describe the image as detailed as possible.
