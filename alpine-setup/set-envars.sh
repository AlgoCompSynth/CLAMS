echo "....Setting environment variables"
export RAM_MB="$(free -m | grep "Mem:" | sed 's/Mem: *//' | sed 's/ .*$//')"
echo "RAM_MB: $RAM_MB"

if [ "$RAM_MB" -lt "1500" ]
then
    export MAKE_JOBS=1

else
    export MAKE_JOBS="$(nproc)"

fi

echo "MAKE_JOBS: $MAKE_JOBS"

export CHUCK_URL="--branch chuck-1.5.5.8 https://github.com/ccrma/chuck.git"
echo "CHUCK_URL: $CHUCK_URL"
