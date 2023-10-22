#!/bin/bash
ENGINE=$1
IMAGE_TAG=lmhacker

if [[ "$ENGINE" != "docker" && "$ENGINE" != "podman" ]]; then
  echo "Invalid argument. Use 'docker' or 'podman'."
  exit 1
fi

# We're using context to avoid docker build to copy workspace folder inside container
mkdir -p ./context
cp ./container_startup.sh ./context/
cp ../environment.yml ./context/
cp ./nb_memory_fix.py ./context/
cp ./lorafix.py ./context/ # temporary till HF fix peft

# Common build args
BUILD_ARGS="-t $IMAGE_TAG -f ./Dockerfile ./context"

# Build
if [[ "$ENGINE" == "docker" ]]; then
  DOCKER_BUILDKIT=1 $ENGINE build $BUILD_ARGS
else
  $ENGINE build  $BUILD_ARGS
fi

# Cleanup
rm -rf ./context

# ./build.sh docker 
# ./build.sh podman 

