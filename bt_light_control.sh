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

hue_to_rgb() {
  local v1=$1
  local v2=$2
  local vH=$3

  [$vH -lt 0] && $((vh += 1))
  [$vH -gt 1] && $((vH -= 1))
  if [$(( 6 * vH )) -lt 1 ]; then return $(( v1 + ( v2 - v1 ) * 6 * vH )); fi
  if [$(( 2 * vH )) -lt 1 ]; then return $(( v2 )); fi
  if [$(( 3 * vH )) -lt 2 ]; then return $(( v1 + ( v2 - v1 ) * ( ( 2 / 3 ) - vH ) * 6)); fi

  return $v1
}

hsl_to_rgb () {
  local H=$1
  local S=$2
  local L=$3
  local R=0
  local B=0
  local G=0
  local var_1=0
  local var_2=0

  if [$S -eq 0]; then
    R = $((L * 255))
    G = $((L * 255))
    B = $((L * 255))
  else
    if [$L -lt 0.5]; then
      var_2 = $((L * ( 1 + S )))
    else
      var_2 = $((( L + S ) - ( S * L )))
    fi

    var_1 = $((2 * L - var_2))

    local temp_val = hue_to_rgb $var_1 $var_2 $((H + ( 1 / 3 )))
    R = $((255 * temp_val))

    temp_val = hue_to_rgb $var_1 $var_2 $H
    G = $((255 * temp_val))

    temp_val = hue_to_rgb $var_1 $var_2 $((H - ( 1 / 3 )))
    B = $((255 * temp_val))
  fi

  return printf "%.2x%.2x%.2x" $R $G $B
}

case $state in
  on)
    gatttool -i $bt_controller -b $mac --char-write-req -a 0x0009 -n cc2333
    ;;
  
  off)
    gatttool -i $bt_controller -b $mac --char-write-req -a 0x0009 -n cc2433
    ;;
  
  color)
    hue = $3
    sat = $4

    rgb_color = hsl_to_rgb $hue $sat $level
    gatttool -i $bt_controller -b $mac --char-write-req -a 0x0009 -n "56${rgb_color}00f0aa"
    ;;
  
  level)
    level = $3

    rgb_color = hsl_to_rgb $hue $sat $level
    gatttool -i $bt_controller -b $mac --char-write-req -a 0x0009 -n "56${rgb_color}00f0aa"
    ;;
esac

export CURRENT_HUE=$hue
export CURRENT_SAT=$sat
export CURRENT_LEVEL=$level