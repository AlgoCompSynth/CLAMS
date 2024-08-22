echo "Checking RAM capacity"
export RAM_MEGABYTES=`free --mega | grep Mem: | sed 's/^Mem: *//' | sed 's/ .*$//'`
if [ "$RAM_MEGABYTES" -lt "3800" ]
then
  echo "$RAM_MEGABYTES is insufficient - aborting!"
  exit -255
fi
