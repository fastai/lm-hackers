# Declare arguments
FROM "nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04"

# common vars
ENV ENVNAME=lmhacker
ENV CURRENTUSER=aieng
ENV CURRENTUSER_UID=1000
ENV CURRENTUSER_GID=1000
## Ensure bash is the default shell 
ENV SHELL=/bin/bash

# Prevent stop building ubuntu at time zone selection.  
ENV DEBIAN_FRONTEND=noninteractive

################### AS ROOT ###################

# COMMON TOOLS
RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    git time vim curl grep sed tig

# MINICONDA
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

RUN /bin/bash -c ". /opt/conda/etc/profile.d/conda.sh && conda update -n base -c defaults conda"

################# NON ROOT ###################

# Add non root user
RUN addgroup --gid=1000 $CURRENTUSER && adduser --uid=$CURRENTUSER_UID --gid=$CURRENTUSER_GID --system --shell=/bin/bash $CURRENTUSER
RUN mkdir /context && chown $CURRENTUSER /context
USER $CURRENTUSER
RUN echo "echo '===ENVIRONMENT==='" >> ~/.bashrc
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc
RUN echo "conda activate $ENVNAME" >> ~/.bashrc

# ENVIRONMENT SCRIPT
WORKDIR /context
COPY --chown=$CURRENTUSER environment.yml /context/
USER $CURRENTUSER

# INSTALL ENVIRONMENT
RUN /bin/bash -c ". /opt/conda/etc/profile.d/conda.sh && conda env create -f environment.yml -n $ENVNAME"

# INSTALL AXOLOTL TO LIBS
# Clone the repository
WORKDIR /libs
RUN git clone https://github.com/OpenAccess-AI-Collective/axolotl
# Install axolotl
RUN /bin/bash -c ". /opt/conda/etc/profile.d/conda.sh && conda activate $ENVNAME && \
    cd axolotl && \
    pip install -e '.[deepspeed]' && \
    pip install flash-attn && \
    pip install -U git+https://github.com/huggingface/peft.git"

# clean pip cache and conda
RUN /bin/bash -c ". /opt/conda/etc/profile.d/conda.sh && conda activate $ENVNAME && conda clean --all -f -y && pip cache purge"

# CONTAINER STARTUP SCRIPT
WORKDIR /context
COPY --chown=$CURRENTUSER container_startup.sh /context/
RUN chmod +x container_startup.sh

USER root
RUN mkdir -p /home/dldev/.cache/huggingface && chown -R $CURRENTUSER:$CURRENTUSER /home/dldev/.cache/huggingface
USER $CURRENTUSER

WORKDIR /workspace

CMD ["/bin/bash", "-c", "/context/container_startup.sh"]
