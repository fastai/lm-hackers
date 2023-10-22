# Containerized workflow for lm-hackers

## Description

This repository contains Dockerfiles and scripts for setting up and running a containerized development environment with GPU support for `lm-hackers`. The container is fully isolated from the host system but can mount local files for development ease. This setup is ideal for working on projects that require specific system configurations and dependencies, including computer vision, deep learning, and computer graphics tasks.

## Prerequisites

- Docker or Podman
- NVIDIA Docker (nvidia-docker)
- NVIDIA GPU (tested with GTX 3090 and 4090)

## Credentials

To properly run lm-hackers notebook end-to-end you need to provide proper Openai and Huggingface credentials.
There are two supported way to do it:

1) Using `./Docker/env.list` file like this:
```
OPENAI_API_KEY=...
HUGGINGFACE_TOKEN=...
```

2) Adding `OPENAI_API_KEY` and `HUGGINGFACE_TOKEN` environment variables to the host.

NOTE: the credentials will be used only during run step, none of them will be saved inside the container during build step.

## Additional steps

In order to download llama2 models you need to accept META and Huggingface terms of service. For more information see [https://huggingface.co/meta-llama/Llama-2-7b-hf](https://huggingface.co/meta-llama/Llama-2-7b-hf).

## Build
The following step is needed to build the container. The build step will install conda, create the environment and install all additional libraries (ie: axolotl, deepspeed, peft). The result is the `lmhacker` image that will be used in the next step.

NOTE: the base image is official nvidia cuda one (`nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04`).

**TO EXECUTE**: From `./Docker` folder:
+ `./build.sh docker` : to build for docker.
+ `./build.sh podman` : to build for podman.

## Run
The following step will execute the container, mounting the `lm-hacker` repo folder as `/workspace` inside the container and optionally (with `localstorage` option) mounting Huggingface `.cache` to `localstorage` subfolder of `lm-hacker` repo.

IMPORTANT: the container runs in a stateless way (with `--rm` option), so anything that's saved outside the `workspace` folder is dropped once the container get stopped. The only exception to this rule is if we us the `localstorage` option of `run.sh` that will store the Huggingface data (models, datasets, token)

**TO EXECUTE**: From `./Docker` folder:
+ `./run.sh docker` : to run for docker.
+ `./run.sh podman` : to run for podman.
+ `./run.sh docker localstorage` : run with docker and mount huggingface cache to `localstorage`.
+ `./run.sh podman localstorage` : run with podman and mount huggingface cache to `localstorage`.

### Container startup

The file `./Docker/container_startup.sh` is executed during container startup.

NOTE: you need to rebuild the container if you change this file in order to apply the change.

### Launch jupyter

An instance of jupyter is started with the container and the following text is printed in the terminal:

```shell
    To access the notebook, open this file in a browser:
        file:///home/aieng/.local/share/jupyter/runtime/nbserver-32-open.html
    Or copy and paste one of these URLs:
        http://e44039fd787e:8888/?token=c107ed326c873303a1bee4329435ceb281e2cbd721a960a0
     or http://127.0.0.1:8888/?token=c107ed326c873303a1bee4329435ceb281e2cbd721a960a0
```

To access it you need to open the last link: `http://127.0.0.1:8888/?token=c107ed326c873306d5bee4325852ceb261e2cbd622a960a0` in a browser.

### Running jupyter on a different port than 8888

If you need to run jupyter on a different port (ie: 8889), open `run.sh`, set `LOCAL_PORT=8889` and run it as usual; then to connect to it replace in the access link the `8888` with `8889` like in this example: `http://127.0.0.1:8889/?token=.....`


## Development Workflow

### Transient Dependencies

When you're testing or experimenting, you often find yourself installing new packages or tools. It's important to note that, similar to environments like Kaggle or Colab notebooks, any packages you install will be transient. This means that these packages will be removed once you restart the container. If you wish for certain packages to persist, you'll need to add them to the `environment.yml` file and then rebuild the container.

### Root Access and Security

For security reasons, the `sudo` command is not available in the container. However, we understand that there are instances where root-level access is necessary—for example, when you need to run commands like `apt-get install`. For such scenarios, we offer a specialized script, `login_as_root_in_running_container.sh`, which allows you to log in to a running container with root privileges.

### Making Permanent Changes

If you find that a particular package or setting needs to be permanent, you must add it to either the `environment.yml` or the `Dockerfile`. Once you've made these changes, you'll need to rebuild the container to make them permanent. Remember, any package or setting not made permanent in this manner will be lost upon container restart.