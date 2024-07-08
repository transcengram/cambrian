import os
# Ensure the environment variable is set
os.environ['HF_ENDPOINT'] = "https://hf-mirror.com"

from transformers import AutoModel, AutoTokenizer

# Load model and tokenizer
model_name = "nyu-visionx/cambrian-8b"
tokenizer = AutoTokenizer.from_pretrained(model_name)
print("tokenizer done")
model = AutoModel.from_pretrained(model_name)
