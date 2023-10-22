#!/bin/bash

# Check needed variables
[[  -z $OPENAI_API_KEY  ]] && echo "⚠️ WARNING: missing variable 'OPENAI_API_KEY'"
[[  -z $HUGGINGFACE_TOKEN  ]] && echo "⚠️ WARNING: missing variable 'HUGGINGFACE_TOKEN'"

source /opt/conda/etc/profile.d/conda.sh
conda activate $ENVNAME

# Create hf token
python -c "from huggingface_hub import HfFolder; HfFolder.save_token(\"$HUGGINGFACE_TOKEN\")"

jupyter notebook --ip=0.0.0.0
#bash
