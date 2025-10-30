@echo off
REM AI Glass System - Windows 快速安装脚本 (uv-managed)

echo ==========================================
echo   AI Glass System - 自动安装脚本 (uv-managed)
echo ==========================================
echo.

REM 检查 uv
echo 正在检查 uv...
uv --version >nul 2>&1
if errorlevel 1 (
    echo [警告] uv 未找到，正在安装...
    powershell -Command "Invoke-WebRequest -UseBasicParsing -Uri https://astral.sh/uv/install.ps1 | Invoke-Expression"
    echo [提示] 请重启终端以使 uv 可用，然后重新运行此脚本
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('uv --version') do set UV_VERSION=%%i
echo [成功] 找到 %UV_VERSION%

REM 检查 Python
echo.
echo 正在检查 Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 Python
    echo 请从 https://www.python.org/downloads/ 下载并安装 Python 3.9-3.11
    pause
    exit /b 1
)

python --version
echo [成功] Python 已安装

REM 检查 CUDA
echo.
echo 正在检查 CUDA...
nvidia-smi >nul 2>&1
if errorlevel 1 (
    echo [警告] 未检测到 NVIDIA GPU，将使用 CPU 模式（速度较慢）
    set HAS_GPU=0
) else (
    echo [成功] 检测到 NVIDIA GPU
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader,nounits
    set HAS_GPU=1
)

REM 检查 pyproject.toml
echo.
echo 正在检查项目配置...
if not exist pyproject.toml (
    echo [错误] pyproject.toml 未找到
    echo 请确保在项目根目录中运行此脚本
    pause
    exit /b 1
)

REM 安装 uv 项目依赖
echo.
echo 正在使用 uv 安装依赖...
if %HAS_GPU%==1 (
    echo 检测到 GPU，使用 PyTorch CUDA 版本...
    uv pip install torch==2.0.1+cu118 torchvision==0.15.2+cu118 --index-url https://download.pytorch.org/whl/cu118
) else (
    echo 使用 CPU 版本 PyTorch...
    uv pip install torch torchvision
)

REM 安装项目依赖
uv sync
echo [成功] 项目依赖已安装

REM 验证 PyTorch
echo.
echo 验证 PyTorch 安装...
python -c "import torch; print(f'PyTorch 版本: {torch.__version__}'); print(f'CUDA 可用: {torch.cuda.is_available()}')"

REM 安装 PyAudio
echo.
echo 正在安装 PyAudio...
echo [警告] PyAudio 在 Windows 上可能需要手动安装
echo 如果自动安装失败，请从以下地址下载 wheel 文件:
echo https://www.lfd.uci.edu/~gohlke/pythonlibs/#pyaudio
echo.
uv pip install pyaudio
if errorlevel 1 (
    echo [警告] PyAudio 自动安装失败，请手动安装
) else (
    echo [成功] PyAudio 已安装
)

REM 创建 .env 文件
echo.
if not exist .env (
    echo 正在创建 .env 配置文件...
    copy .env.example .env >nul
    echo [成功] .env 文件已创建
    echo [提示] 请编辑 .env 文件，填入您的 DASHSCOPE_API_KEY
) else (
    echo [跳过] .env 文件已存在
)

REM 创建必要的目录
echo.
echo 正在创建目录结构...
if not exist recordings mkdir recordings
if not exist model mkdir model
if not exist music mkdir music
if not exist voice mkdir voice
echo [成功] 目录结构已创建

REM 检查模型文件
echo.
echo 正在检查模型文件...
set MISSING=0
if exist model\yolo-seg.pt (echo [成功] yolo-seg.pt) else (echo [缺失] yolo-seg.pt & set MISSING=1)
if exist model\yoloe-11l-seg.pt (echo [成功] yoloe-11l-seg.pt) else (echo [缺失] yoloe-11l-seg.pt & set MISSING=1)
if exist model\shoppingbest5.pt (echo [成功] shoppingbest5.pt) else (echo [缺失] shoppingbest5.pt & set MISSING=1)
if exist model\trafficlight.pt (echo [成功] trafficlight.pt) else (echo [缺失] trafficlight.pt & set MISSING=1)
if exist model\hand_landmarker.task (echo [成功] hand_landmarker.task) else (echo [缺失] hand_landmarker.task & set MISSING=1)

if %MISSING%==1 (
    echo.
    echo [警告] 部分模型文件缺失，请将模型文件放入 model\ 目录
)

REM 完成
echo.
echo ==========================================
echo [成功] 安装完成!
echo ==========================================
echo.
echo 下一步:
echo 1. 编辑 .env 文件，填入您的 API 密钥:
echo    notepad .env
echo.
echo 2. 确保所有模型文件已放入 model\ 目录
echo.
echo 3. 启动系统 ^(uv managed^):
echo    uv run python app_main.py
echo.
echo 4. 或在 uv 环境中启动开发模式:
echo    uv venv  ^(创建虚拟环境^)
echo    uv run bash  ^(启动 uv 管理的 shell^)
echo    python app_main.py
echo.
echo 5. 访问 http://localhost:8081
echo.
echo uv 常用命令:
echo   uv run python app_main.py  ^(直接运行应用^)
echo   uv venv                    ^(创建虚拟环境^)
echo   uv sync                    ^(同步依赖^)
echo   uv add ^<package^>          ^(添加依赖^)
echo   uv remove ^<package^>       ^(移除依赖^)
echo.

pause

