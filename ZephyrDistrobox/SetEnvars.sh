
echo ""
echo "Setting Distrobox environment variables"
export DBX_CONTAINER_IMAGE="docker.io/library/ubuntu:22.04"
export DBX_CONTAINER_NAME="Jammy-Zephyr"
export DBX_CONTAINER_HOME_PREFIX="$HOME/dbx-homes"

echo ""
echo "Setting Zephyr environment variables"
export ZEPHYR_HOME=$HOME/zephyrproject
export ZEPHYR_SDK_VERSION="0.16.5-1"

# you shouldn't need to change these
export DBX_CONTAINER_DIRECTORY="$DBX_CONTAINER_HOME_PREFIX/$DBX_CONTAINER_NAME"
export DBX_CONTAINER_HOSTNAME="$DBX_CONTAINER_NAME"

export ZEPHYR_VENV=$ZEPHYR_HOME/.venv
export ZEPHYR_SDK_URL="https://github.com/zephyrproject-rtos/sdk-ng/releases/download"
export ZEPHYR_SDK_DIR="zephyr-sdk-$ZEPHYR_SDK_VERSION"
export ZEPHYR_SDK_TARBALL="${ZEPHYR_SDK_DIR}_linux-x86_64.tar.xz"
