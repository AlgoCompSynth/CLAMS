set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ./set_pico_envars

echo "Adding Python virtual environment"
source $NUTTX_VENV/bin/activate

echo "Adding Arm tools to PATH"
export PATH=$NUTTX_ARM_TOOLS:$PATH

echo "Adding ESP32-C3/C6 tools to PATH"
export PATH=$NUTTX_RISCV_TOOLS:$PATH

echo "Adding ESP32-S3 tools to PATH"
export PATH=$NUTTX_XTENSA_TOOLS:$PATH

echo "Adding kconfig front ends to PATH"
export PATH=$NUTTX_KCONFIG_TOOLS:$PATH

echo "Adding rust tools to PATH"
export PATH=$NUTTX_RUST_TOOLS:$PATH
echo "Setting default rust to stable"
rustup default stable

echo "Adding wasi-sdk to PATH"
export PATH=$NUTTX_WASI_TOOLS:$PATH

echo ""
echo "PATH: $PATH"
