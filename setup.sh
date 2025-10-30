#!/bin/bash
# AI Glass System - Linux/macOS 快速安装脚本 (uv-managed)

set -e  # 遇到错误立即退出

echo "=========================================="
echo "  AI Glass System - 自动安装脚本 (uv-managed)"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 uv
echo "正在检查 uv..."
if ! command -v uv &> /dev/null; then
    echo -e "${YELLOW}uv 未找到，正在安装...${NC}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

UV_VERSION=$(uv --version)
echo -e "${GREEN}✓ 找到 $UV_VERSION${NC}"

# 检查 Python 版本
echo "正在检查 Python 版本..."
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}错误: 未找到 Python 3${NC}"
    echo "请先安装 Python 3.9-3.11"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo -e "${GREEN}✓ 找到 Python $PYTHON_VERSION${NC}"

# 检查 Python 版本是否在支持范围内
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

if [ "$PYTHON_MAJOR" -ne 3 ] || [ "$PYTHON_MINOR" -lt 9 ] || [ "$PYTHON_MINOR" -gt 11 ]; then
    echo -e "${YELLOW}警告: Python 版本 $PYTHON_VERSION 可能不受支持${NC}"
    echo "推荐使用 Python 3.9-3.11"
    read -p "是否继续? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 检查 CUDA（可选）
echo ""
echo "正在检查 CUDA..."
if command -v nvidia-smi &> /dev/null; then
    echo -e "${GREEN}✓ 检测到 NVIDIA GPU${NC}"
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
    HAS_GPU=true
else
    echo -e "${YELLOW}! 未检测到 NVIDIA GPU，将使用 CPU 模式（速度较慢）${NC}"
    HAS_GPU=false
fi

# 初始化项目
echo ""
echo "正在初始化项目..."
if [ ! -f "pyproject.toml" ]; then
    echo -e "${RED}错误: pyproject.toml 未找到${NC}"
    echo "请确保在项目根目录中运行此脚本"
    exit 1
fi

# 安装 uv 项目依赖
echo "正在使用 uv 安装依赖..."
if [ "$HAS_GPU" = true ]; then
    echo "检测到 GPU，使用 PyTorch CUDA 版本..."
    # uv requires setting PyTorch index URL for CUDA packages
    uv pip install torch==2.0.1+cu118 torchvision==0.15.2+cu118 --index-url https://download.pytorch.org/whl/cu118
else
    echo "使用 CPU 版本 PyTorch..."
    uv pip install torch torchvision
fi

# 安装项目依赖
uv sync
echo -e "${GREEN}✓ 项目依赖已安装${NC}"

# 验证 PyTorch
echo "验证 PyTorch 安装..."
python3 -c "import torch; print(f'PyTorch 版本: {torch.__version__}'); print(f'CUDA 可用: {torch.cuda.is_available()}')"

# 安装系统依赖（Linux）
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo ""
    echo "正在检查系统依赖..."
    
    # 检测发行版
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        OS="unknown"
    fi
    
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        echo "检测到 Ubuntu/Debian 系统"
        echo "可能需要 sudo 权限来安装系统依赖..."
        sudo apt-get update -qq
        sudo apt-get install -y -qq portaudio19-dev libgl1-mesa-glx libglib2.0-0
        echo -e "${GREEN}✓ 系统依赖已安装${NC}"
    else
        echo -e "${YELLOW}! 未知的 Linux 发行版，请手动安装依赖${NC}"
        echo "  需要: portaudio19-dev, libgl1-mesa-glx, libglib2.0-0"
    fi
fi

# 创建 .env 文件
echo ""
if [ ! -f ".env" ]; then
    echo "正在创建 .env 配置文件..."
    cp .env.example .env
    echo -e "${GREEN}✓ .env 文件已创建${NC}"
    echo -e "${YELLOW}请编辑 .env 文件，填入您的 DASHSCOPE_API_KEY${NC}"
else
    echo -e "${YELLOW}.env 文件已存在，跳过${NC}"
fi

# 创建必要的目录
echo ""
echo "正在创建目录结构..."
mkdir -p recordings model music voice
echo -e "${GREEN}✓ 目录结构已创建${NC}"

# 检查模型文件
echo ""
echo "正在检查模型文件..."
MODELS=("yolo-seg.pt" "yoloe-11l-seg.pt" "shoppingbest5.pt" "trafficlight.pt" "hand_landmarker.task")
MISSING_MODELS=()

for model in "${MODELS[@]}"; do
    if [ -f "model/$model" ]; then
        echo -e "${GREEN}✓ $model${NC}"
    else
        echo -e "${RED}✗ $model (缺失)${NC}"
        MISSING_MODELS+=("$model")
    fi
done

if [ ${#MISSING_MODELS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}警告: 缺少以下模型文件:${NC}"
    for model in "${MISSING_MODELS[@]}"; do
        echo "  - $model"
    done
    echo "请将模型文件放入 model/ 目录"
fi

# 完成
echo ""
echo "=========================================="
echo -e "${GREEN}安装完成!${NC}"
echo "=========================================="
echo ""
echo "下一步:"
echo "1. 编辑 .env 文件，填入您的 API 密钥:"
echo "   nano .env"
echo ""
echo "2. 确保所有模型文件已放入 model/ 目录"
echo ""
echo "3. 启动系统 (uv managed):"
echo "   uv run python app_main.py"
echo ""
echo "4. 或在 uv 环境中启动开发模式:"
echo "   uv venv  # 创建虚拟环境"
echo "   source .venv/bin/activate  # 或 uv run bash"
echo "   python app_main.py"
echo ""
echo "5. 访问 http://localhost:8081"
echo ""

# 提示 uv 命令
echo -e "${YELLOW}uv 常用命令:${NC}"
echo "  uv run python app_main.py  # 直接运行应用"
echo "  uv venv                    # 创建虚拟环境"
echo "  uv sync                    # 同步依赖"
echo "  uv add <package>           # 添加依赖"
echo "  uv remove <package>        # 移除依赖"
echo ""

