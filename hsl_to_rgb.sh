hue_to_rgb() {
  local v1=$1
  local v2=$2
  local vH=$3

  if [ $(echo "$vH < 0" | bc -l) -eq 1 ]; then vH=$(bc -l <<< "$vH + 1"); fi
  if [ $(echo "$vH > 1" | bc -l) -eq 1 ]; then vH=$(bc -l <<< "$vH - 1"); fi
  if [ $(echo "(6 * $vH) < 1" | bc -l) -eq 1 ]; then echo $(bc -l <<< "$v1 + ( $v2 - $v1 ) * 6 * $vH"); exit; fi
  if [ $(echo "(2 * $vH) < 1" | bc -l) -eq 1 ]; then echo $v2; exit; fi
  if [ $(echo "(3 * $vH) < 2" | bc -l) -eq 1 ]; then echo $(bc -l <<< "$v1 + ( $v2 - $v1 ) * ( ( 2 / 3 ) - $vH ) * 6"); exit; fi

  echo "$v1"
}

H=$1
S=$2
L=$3
R=0
B=0
G=0
var_1=0
var_2=0

if [ $(echo "$S == 0" | bc -l) -eq 1 ]; then
  R=$(bc <<< "$L * 255")
  G=$(bc <<< "$L * 255")
  B=$(bc <<< "$L * 255")
else
  if [ $(echo "$L < 0.5" | bc -l) -eq 1 ]; then
    var_2=$(echo "$L * (1 + $S)" | bc -l)
  else
    var_2=$(echo "($L + $S) - ( $S * $L )" | bc -l)
  fi

  var_1=$(echo "2 * $L - $var_2" | bc -l)

  temp_vH=$(echo "$H + (1 / 3)" | bc -l)
  temp_val=`hue_to_rgb "$var_1" "$var_2" "$temp_vH"`
  R=$(bc <<< "(255 * $temp_val) / 1")

  temp_val=`hue_to_rgb "$var_1" "$var_2" "$H"`
  G=$(bc <<< "(255 * $temp_val) / 1")

  temp_vH=$(echo "$H - (1 / 3)" | bc -l)
  temp_val=`hue_to_rgb "$var_1" "$var_2" "$temp_vH"`
  B=$(bc <<< "(255 * $temp_val) / 1")
fi

printf "%.2x%.2x%.2x" $R $G $B
