hue_to_rgb() {
  local v1=$1
  local v2=$2
  local vH=$3

  if `bc -l <<< "$vH -lt 0"`; then vH=0; fi
  if `bc -l <<< "$vH -gt 1"`; then vH=1; fi
  if `bc -l <<< "(6 * $vH) -lt 1"`; then return bc -l <<< "$v1 + ( $v2 - $v1 ) * 6 * $vH"; fi
  if `bc -l <<< "(2 * $vH) -lt 1"`; then return $v2; fi
  if `bc -l <<< "(3 * $vH) -lt 2"`; then return bc -l <<< "$v1 + ( $v2 - $v1 ) * ( ( 2 / 3 ) - $vH ) * 6"; fi

  return $v1
}

H=$1
S=$2
L=$3
R=0
B=0
G=0
var_1=0
var_2=0

if `bc -l <<< "$S -eq 0"`; then
  R=bc <<< "$L * 255"
  G=bc <<< "$L * 255"
  B=bc <<< "$L * 255"
else
  if `bc -l <<< "$L -lt 0.5"`; then
    var_2=`bc -l <<< "$L * (1 + $S)"`
  else
    var_2=`bc -l <<< "($L + $S) - ( $S * $L )"`
  fi

  var_1=`bc -l <<< "2 * $L - $var_2"`

  temp_vH=`bc -l <<< "$H + (1 / 3)"`
  temp_val=`hue_to_rgb "$var_1" "$var_2" "$temp_vH"`
  R=bc <<< "255 * $temp_val"

  temp_val=`hue_to_rgb "$var_1" "$var_2" "$H"`
  G=bc <<< "255 * $temp_val"

  temp_vH=`bc -l <<< "$H - (1 / 3)"`
  temp_val=`hue_to_rgb "$var_1" "$var_2" "$temp_vH"`
  B=bc <<< "255 * $temp_val"
fi

printf "%.2x%.2x%.2x" $R $G $B
