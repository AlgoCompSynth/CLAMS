#! /bin/bash

set -e

mpremote ls
mpremote cp -r alert/ :
mpremote cp -r basic/ :
mpremote cp -r bouncing_logo/ :
mpremote cp -r co2/ :
mpremote cp -r floppy_birb/ :
mpremote cp -r magic_mirror/ :
mpremote cp -r pride/ :
mpremote cp -r sneks_and_ladders/ :
mpremote cp *.py :
mpremote cp toaster.png :
mpremote ls
mpremote ls :alert
mpremote ls :basic
mpremote ls :bouncing_logo
mpremote ls :co2
mpremote ls :floppy_birb
mpremote ls :magic_mirror
mpremote ls :pride
mpremote ls :sneks_and_ladders
mpremote reset
