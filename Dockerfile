# AI Glass System - Dockerfile (uv-managed)
# 基于 NVIDIA CUDA 的 Python 镜像

FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    python3-dev \
    portaudio19-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    git \
    wget \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv
RUN pip install --upgrade pip
RUN pip install uv

# 复制 project files
COPY pyproject.toml uv.lock .python-version ./

# Install torch with CUDA support first
RUN uv pip install torch==2.0.1+cu118 torchvision==0.15.2+cu118 --index-url https://download.pytorch.org/whl/cu118

# Install project dependencies using uv
# Install without audio dependencies initially due to compilation issues
RUN uv sync --no-dev

# Install PyAudio separately with pre-compiled wheels to avoid compilation
RUN pip install --no-cache-dir --force-reinstall pyaudio

# Re-sync to ensure consistency
RUN uv sync --no-dev

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p recordings model music voice static templates

# Expose ports
EXPOSE 8081 12345/udp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8081/api/health || exit 1

# Start command
CMD ["sh", "-c", "uv run python app_main.py"]

