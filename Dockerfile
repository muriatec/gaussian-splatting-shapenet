# Use the base image with PyTorch and CUDA support
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt update && \
    apt install -y tzdata git libgl-dev ninja-build build-essential wget cmake && \
    apt install -y libglew-dev libassimp-dev libboost-all-dev libgtk-3-dev libopencv-dev libglfw3-dev libavdevice-dev libavcodec-dev libeigen3-dev libxxf86vm-dev libembree-dev && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Create a workspace directory and move the repository
WORKDIR /gaussian-splatting
COPY ./ ./

# Build viewers
WORKDIR /gaussian-splatting/SIBR_viewers
RUN cmake -Bbuild . -DCMAKE_BUILD_TYPE=Release -G Ninja
RUN cmake --build build -j24 --target install
ENV PATH=/gaussian-splatting/SIBR_viewers/install/bin:$PATH

# Install miniconda
ENV CONDA_DIR=/opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

# Install optimizer
WORKDIR /gaussian-splatting
ENV TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6+PTX"
RUN conda env create --file environment.yml && conda init bash
RUN echo "conda activate gaussian_splatting" >> ~/.bashrc