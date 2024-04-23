export CLAMS_BASE=$HOME
source ./set_pico_envars
export PATH=$NUTTX_TOOLS/rust/cargo/bin:$PATH
export PATH=$NUTTX_TOOLS/riscv-none-elf-gcc/bin:$PATH
export PATH=$NUTTX_TOOLS/xtensa-esp32s3-elf-gcc/bin:$PATH
source $NUTTX_PATH/esptool/bin/activate
echo "PATH: $PATH"
