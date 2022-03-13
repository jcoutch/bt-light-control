#!/bin/bash

# Based on information found at the following URLs:
# https://stackoverflow.com/questions/46169415/understanding-hsl-to-rgb-color-space-conversion-algorithm
# https://community.home-assistant.io/t/controlling-a-bluetooth-led-strip-with-ha/286029/5

# Parameters:
# bt_light_control.sh MAC_ADDRESS STATE PARAMETERS
#
# Turn on:          bt_light_control.sh 00:00:00:00:00:00 on
# Turn off:         bt_light_control.sh 00:00:00:00:00:00 off
# Set level to 25%: bt_light_control.sh 00:00:00:00:00:00 level 25
# Adjust hue/sat:   bt_light_control.sh 00:00:00:00:00:00 color 45 70

bt_controller="hci0"
SCRIPT_PATH="$(dirname $BASH_SOURCE)"

mac=$1
state=$2

hue=$3
sat=$4
level=$5

if test -z "$hue"; then hue="0"; fi
if test -z "$sat"; then sat="0"; fi
if test -z "$level"; then level="50"; fi

case $state in
  on)
    gatttool -i $bt_controller -b $mac --char-write-req -a 0x0009 -n cc2333
    ;;
  
  off)
    gatttool -i $bt_controller -b $mac --char-write-req -a 0x0009 -n cc2433
    ;;
  
  color)
    rgb_color=`$SCRIPT_PATH/hsl_to_rgb.sh "$hue" "$sat" "$level"`
    gatttool -i $bt_controller -b $mac --char-write-req -a 0x0009 -n "56${rgb_color}00f0aa"
    ;;
esac

# echo "Light Color: $rgb_color, State: $state, Level: $level, Hue: $hue, Sat: $sat, Script Path: $SCRIPT_PATH"