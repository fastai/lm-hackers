#!/bin/bash
ENGINE=$1
OPTIONS=$2
IMAGE_TAG=lmhacker
LOCAL_PORT=8888

# Check arguments 
if [[ "$ENGINE" != "docker" && "$ENGINE" != "podman" ]]; then
  echo "Invalid argument. Use 'docker' or 'podman'."
  exit 1
fi

# Support for local storage for downloaded models and datasets
if [[ "$OPTIONS" == "localstorage" ]]; then
  LS_ROOT=../localstorage
  echo "ℹ️  USING LOCAL STORAGE ON: \"$LS_ROOT\""
  CACHE_HUGGINGFACE=$LS_ROOT/huggingface
  # create folder with normal user rights
  if [[ -v SUDO_USER ]]; then
    sudo -u $SUDO_USER mkdir -p $CACHE_HUGGINGFACE
  else
    mkdir -p $CACHE_HUGGINGFACE
  fi
  LOCALSTORAGE=" -v $PWD/$CACHE_HUGGINGFACE:/home/aieng/.cache/huggingface/"
else
  LOCALSTORAGE=''
fi

# Pass keys and tokens
ENV_FILE="./env.list"
if [[ -e $ENV_FILE ]]; then
  echo "TOKENS: USING: $ENV_FILE"
  ENV_VARS="--env-file $ENV_FILE"
elif [[ -v OPENAI_API_KEY && -v HUGGINGFACE_TOKEN ]]; then
  echo "TOKENS: USING ENV VARIABLES"
  ENV_VARS="--env OPENAI_API_KEY=$OPENAI_API_KEY --env HUGGINGFACE_TOKEN=$HUGGINGFACE_TOKEN"
else
  echo "❌ ERROR: you need to provide 'OPENAI_API_KEY' and 'HUGGINGFACE_TOKEN'. You have two options:"
  echo "1) define both of them as environment variable"
  echo "2) In this folder create a file '$ENV_FILE' that contains:"
  echo "OPENAI_API_KEY=..."
  echo "HUGGINGFACE_TOKEN=..."
  exit 1
fi

# Run
$ENGINE run -it --rm --gpus all --shm-size="2g" -p 127.0.0.1:$LOCAL_PORT:8888 -v "$PWD/..":"/workspace:Z" $LOCALSTORAGE $ENV_VARS $IMAGE_TAG

#$ENGINE run --user 1000:1000 \
#    --security-opt=no-new-privileges \
#    --cap-drop=ALL \
#    --security-opt label=type:nvidia_container_t \
#    -it \
#    --gpus all \
#    --shm-size="2g" \
#    -p 127.0.0.1:8888:8888 \
#    -v "$PWD/..":"/workspace:Z" \
#    --mount type=bind,source=/home/$USER/.cache/huggingface,target=/home/dldev/.cache/huggingface,z \
#    --env-file $ENV_FILE \
#    $IMAGE_TAG

#for bash
#-it --gpus all \
#-w /workspace  # Set the working directory to /workspace

# before running
#sudo chown -R $USER:$USER /home/$USER/.cache/huggingface/
#sudo chmod -R 777 /home/$USER/.cache/huggingface/
