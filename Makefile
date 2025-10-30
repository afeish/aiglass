# AI Glass System - Makefile for uv-based development

# Default target
help:
	@echo "AI Glass System - uv-based Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make setup     - Install dependencies using uv"
	@echo "  make setup-audio - Install dependencies with audio support (PyAudio)"
	@echo "  make run       - Run the application using uv"
	@echo "  make dev       - Run in development mode with auto-reload"
	@echo "  make install   - Install additional package with uv"
	@echo "  make add       - Add a new dependency"
	@echo "  make remove    - Remove a dependency"
	@echo "  make sync      - Sync dependencies from pyproject.toml"
	@echo "  make update    - Update all dependencies"
	@echo "  make venv      - Create uv-managed virtual environment"
	@echo "  make clean     - Clean uv cache and virtual environment"
	@echo "  make test      - Run tests (if available)"
	@echo ""

# Install dependencies using uv
setup:
	@echo "Setting up project with uv..."
	uv sync
	@echo "Setup complete!"

# Install dependencies with audio support
setup-audio:
	@echo "Setting up project with uv (including audio)..."
	uv sync --extra audio
	@echo "Setup complete with audio support!"

# Run the main application
run:
	@echo "Starting AI Glass System..."
# 	uv pip install git+https://github.com/ultralytics/CLIP.git
	uv run python app_main.py

# Run in development mode with auto-reload
dev:
	@echo "Starting AI Glass System in development mode..."
	uv run uvicorn app_main:app --reload --host 0.0.0.0 --port 8081

# Create a virtual environment managed by uv
venv:
	@echo "Creating virtual environment with uv..."
	uv venv
	@echo "Virtual environment created at .venv/"

# Synchronize dependencies from pyproject.toml
sync:
	@echo "Synchronizing dependencies..."
	uv sync
	@echo "Dependencies synchronized!"

# Update all dependencies
update:
	@echo "Updating dependencies..."
	uv sync --upgrade
	@echo "Dependencies updated!"

# Add a new dependency
add:
	@echo "Usage: make add PKG=package_name"
	@if [ -n "$(PKG)" ]; then \
		uv add $(PKG); \
	else \
		echo "Please specify a package name: make add PKG=package_name"; \
	fi

# Remove a dependency
remove:
	@echo "Usage: make remove PKG=package_name"
	@if [ -n "$(PKG)" ]; then \
		uv remove $(PKG); \
	else \
		echo "Please specify a package name: make remove PKG=package_name"; \
	fi

# Clean uv cache and virtual environment
clean:
	@echo "Cleaning uv cache and virtual environment..."
	rm -rf .venv/
	uv cache clean
	@echo "Clean complete!"

# Run tests (if available)
test:
	@echo "Running tests..."
	uv run pytest tests/ || echo "No tests found or pytest not installed"

# Run code formatting
format:
	@echo "Formatting code..."
	uv run black . || echo "black not installed, install with: uv add --dev black"

# Run linting
lint:
	@echo "Linting code..."
	uv run flake8 . || echo "flake8 not installed, install with: uv add --dev flake8"

# Install GPU PyTorch
gpu:
	@echo "Installing GPU version of PyTorch..."
	uv pip install torch==2.0.1+cu118 torchvision==0.15.2+cu118 --index-url https://download.pytorch.org/whl/cu118
	uv sync
	@echo "GPU PyTorch installed!"

.PHONY: help setup run dev venv sync update add remove clean test format lint gpu