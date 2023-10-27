#! /bin/bash

set -e

export MAMBAFORGE_HOME="$HOME/mambaforge"
source $MAMBAFORGE_HOME/etc/profile.d/conda.sh
source $MAMBAFORGE_HOME/etc/profile.d/mamba.sh
mamba activate PicoVision
mpremote ls
mpremote cp -r alert/ :
mpremote cp -r bouncing_logo/ :
mpremote cp -r floppy_birb/ :
mpremote cp -r pride/ :
mpremote cp -r sneks_and_ladders/ :
mpremote cp main.py :
mpremote cp rainbow_wheel.py :
mpremote cp screenmodes.py :
mpremote cp scrollgroups.py :
mpremote cp starfield.py :
mpremote cp starfield_rainbow.py :
mpremote cp toaster.png :
mpremote cp vector_clock.py :
mpremote cp vector_clock_smooth.py :
mpremote ls
mpremote reset
