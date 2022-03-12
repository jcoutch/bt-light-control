hue_to_rgb() {
  local v1=$1
  local v2=$2
  local vH=$3

  if `echo "$vH -lt 0" | bc -l`; then vH=0; fi
  if `echo "$vH -gt 1" | bc -l `; then vH=1; fi
  if `echo "(6 * $vH) -lt 1" | bc -l`; then return bc -l <<< "$v1 + ( $v2 - $v1 ) * 6 * $vH"; fi
  if `echo "(2 * $vH) -lt 1" | bc -l`; then return $v2; fi
  if `echo "(3 * $vH) -lt 2" | bc -l`; then return bc -l <<< "$v1 + ( $v2 - $v1 ) * ( ( 2 / 3 ) - $vH ) * 6"; fi

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

if `echo "$S -eq 0" | bc -l`; then
  R="$L * 255" | bc -l
  G="$L * 255" | bc -l
  B="$L * 255" | bc -l
else
  if `echo "$L -lt 0.5" | bc -l`; then
    var_2=`echo "$L * (1 + $S)" | bc -l`
  else
    var_2=`echo "($L + $S) - ( $S * $L )" | bc -l`
  fi

  var_1=echo "2 * $L - $var_2" | bc -l

  temp_vH=`echo "$H + (1 / 3)" | bc -l`
  temp_val=`hue_to_rgb "$var_1" "$var_2" "$temp_vH"`
  R=echo "255 * $temp_val" | bc -l

  temp_val=`hue_to_rgb "$var_1" "$var_2" "$H"`
  G=echo "255 * $temp_val" | bc -l

  temp_vH=`echo "$H - (1 / 3)" | bc -l`
  temp_val=`hue_to_rgb "$var_1" "$var_2" "$temp_vH"`
  B=echo "255 * $temp_val" | bc -l
fi

printf "%.2x%.2x%.2x" $R $G $B
