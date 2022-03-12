#!/bin/bash

# Based on information found at the following URLs:
# https://stackoverflow.com/questions/46169415/understanding-hsl-to-rgb-color-space-conversion-algorithm
# https://community.home-assistant.io/t/controlling-a-bluetooth-led-strip-with-ha/286029/5

# Parameters:
# bt_light_control.sh MAC_ADDRESS STATE PARAMETERS
#
# Turn on:          bt_light_control.sh 00:00:00:00:00:00 on
# Turn off:         bt_light_control.sh 00:00:00:00:00:00 off
# Set level to 25%: bt_light_control.sh 00:00:00:00:00:00 level 0.25
# Adjust hue/sat:   bt_light_control.sh 00:00:00:00:00:00 color 0.10 0.70

bt_controller="hci0"

mac=$1
state=$2

hue=$CURRENT_HUE
sat=$CURRENT_SAT
level=$CURRENT_LEVEL

case $state in
  on)
    gatttool -i $bt_controller -b $mac --char-write-req -a 0x0009 -n cc2333
    ;;
  
  off)
    gatttool -i $bt_controller -b $mac --char-write-req -a 0x0009 -n cc2433
    ;;
  
  color)
    hue=$3
    sat=$4

    rgb_color=`./hsl_to_rgb.sh "$hue" "$sat" "$level"`
    gatttool -i $bt_controller -b $mac --char-write-req -a 0x0009 -n "56${rgb_color}00f0aa"
    ;;
  
  level)
    level=$3

    rgb_color=`./hsl_to_rgb.sh "$hue" "$sat" "$level"`
    gatttool -i $bt_controller -b $mac --char-write-req -a 0x0009 -n "56${rgb_color}00f0aa"
    ;;
esac

export CURRENT_HUE=$hue
export CURRENT_SAT=$sat
export CURRENT_LEVEL=$level