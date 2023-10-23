#!/bin/bash

# NOTE: this command is meant to be used to perform any task that requires root privileges.

ENGINE=$1
IMAGE_TAG=lmhacker

# Check arguments 
if [[ "$ENGINE" != "docker" && "$ENGINE" != "podman" ]]; then
  echo "Invalid argument. Use 'docker' or 'podman'."
  exit 1
fi

# Run
$ENGINE exec -it -u root $(docker ps | grep $IMAGE_TAG | cut  -d " " -f1) bash
