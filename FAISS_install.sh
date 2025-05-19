#!/bin/bash

set -e  # Encerra o script em caso de erro

echo "====== Atualizando pacotes ======"
sudo apt-get update

echo "====== Instalando dependências ======"
sudo apt-get install -y \
    cmake \
    git \
    swig \
    python3-dev \
    python3-numpy \
    python3-setuptools \
    libopenblas-dev \
    liblapack-dev \
    libgflags-dev \
    nvidia-cuda-toolkit\
    build-essential

# Verifica se CUDA está instalado (opcional)
if ! command -v nvcc &> /dev/null; then
    echo "CUDA não encontrado (nvcc). Pulando suporte a GPU."
    GPU_FLAG="-DFAISS_ENABLE_GPU=OFF"
else
    echo "CUDA detectado. Incluindo suporte a GPU."
    GPU_FLAG="-DFAISS_ENABLE_GPU=ON"
fi

echo "====== Clonando repositório FAISS ======"
git clone https://github.com/facebookresearch/faiss.git
cd faiss

echo "====== Invocando CMake ======"
cmake -B build . \
    ${GPU_FLAG} \
    -DFAISS_ENABLE_PYTHON=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DFAISS_OPT_LEVEL=avx2 \
    -DFAISS_USE_LTO=ON \
    -DFAISS_USE_MKL=OFF

echo "======== Compilando FAISS ======"
make -C build -j$(( $(nproc) / 2 )) faiss_avx2

echo "====== Compilando bindings Python ======"
make -C build -j$(( $(nproc) / 2 )) swigfaiss

echo "====== Instalando pacote Python ======"
cd build/faiss/python
sudo python3 setup.py install

echo "====== FAISS instalado com sucesso ======"
