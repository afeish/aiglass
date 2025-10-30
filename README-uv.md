# AI 智能盲人眼镜系统 - uv 管理指南

## 概述

本项目已配置使用 [uv](https://github.com/astral-sh/uv) 进行依赖管理和虚拟环境管理。uv 是一个极快的 Python 包安装工具，用 Rust 编写，旨在替代 pip 和 pipenv。

## 安装 uv

### Linux/macOS
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Windows
```powershell
powershell -Command "Invoke-WebRequest -UseBasicParsing -Uri https://astral.sh/uv/install.ps1 | Invoke-Expression"
```

## 项目设置

### 1. 克隆项目
```bash
git clone https://github.com/yourusername/aiglass.git
cd aiglass
```

### 2. 安装依赖
```bash
# 安装所有项目依赖
uv sync

# 启用 CUDA 支持（如需要）
uv pip install torch==2.0.1+cu118 torchvision==0.15.2+cu118 --index-url https://download.pytorch.org/whl/cu118
uv sync
```

### 3. 运行项目
```bash
# 直接运行应用
uv run python app_main.py

# 或者在 uv 管理的虚拟环境中运行
uv run bash  # 启动 uv shell
python app_main.py
```

## 常用 uv 命令

### 依赖管理
```bash
# 同步项目依赖 (相当于 pip install -r requirements.txt)
uv sync

# 同步项目依赖（包含音频功能）
uv sync --all-extras
# 或
uv sync --extra audio

# 添加新依赖
uv add requests

# 添加开发依赖
uv add --dev pytest

# 移除依赖
uv remove requests

# 升级依赖
uv sync --upgrade
```

### 虚拟环境
```bash
# 创建虚拟环境
uv venv

# 指定 Python 版本创建虚拟环境
uv venv --python 3.11

# 激活虚拟环境
source .venv/bin/activate  # Linux/macOS
.venv\Scripts\activate     # Windows
```

### 运行命令
```bash
# 在项目环境中运行 Python 脚本
uv run python app_main.py

# 在项目环境中运行测试
uv run pytest

# 在项目环境中运行任意命令
uv run <command>
```

## 项目结构

- `pyproject.toml` - 项目配置和依赖声明
- `uv.lock` - 锁定的依赖版本
- `.python-version` - 指定的 Python 版本

## 开发工作流

### 使用 uv 进行开发
1. 确保已安装 uv
2. 运行 `uv sync` 来设置开发环境
3. 使用 `uv run python app_main.py` 启动应用
4. 使用 `uv add/remove` 管理依赖

### 添加新依赖
```bash
# 添加运行时依赖
uv add <package-name>

# 添加开发依赖
uv add --dev <package-name>

# 添加特定版本
uv add <package-name>==1.2.3

# 重新同步
uv sync
```

## 与传统工具的区别

- `pip install -r requirements.txt` → `uv sync`
- `pip install <package>` → `uv add <package>`
- `pip uninstall <package>` → `uv remove <package>`
- `python -m venv venv && source venv/bin/activate` → `uv venv && source .venv/bin/activate`
- `python <script.py>` → `uv run python <script.py>`

## 故障排除

### PyAudio 安装问题

在 macOS 或 Linux 上安装 PyAudio 时可能出现编译错误，因为需要系统级的 PortAudio 库：

#### macOS
```bash
# 安装系统依赖
brew install portaudio

# 然后安装依赖
uv sync --extra audio
```

#### Linux (Ubuntu/Debian)
```bash
# 安装系统依赖
sudo apt-get install portaudio19-dev python3-pyaudio

# 然后安装依赖
uv sync --extra audio
```

#### Windows
Windows 用户可以直接安装预编译的 wheel：
```bash
uv pip install pyaudio
```

### 如何重新安装所有依赖
```bash
rm uv.lock
uv sync
```

### 如何更新所有依赖到最新兼容版本
```bash
uv sync --upgrade
```

### 如何指定不同的 Python 版本
```bash
uv venv --python 3.10
source .venv/bin/activate
```

## 性能优势

使用 uv 可以显著提高依赖管理的速度：
- 比 pip 快 10-100 倍
- 更快的依赖解析
- 并行安装包
- 预编译的可执行文件

## 与现有流程的兼容性

本项目仍然支持传统的 pip + virtualenv 工作流，但推荐使用 uv 以获得更好的性能和体验。