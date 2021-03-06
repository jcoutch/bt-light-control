# hsl_to_rgb.sh <H> <S> <L>
#
# example: ./hsl_to_rgb.sh 90 100 50
#
# H - value from 0 to 360
# S - value from 0 to 100
# L - value from 0 to 255 (I'm dividing by 511 since full luminance is achieved at 50% with my light strand)

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

H=$(bc -l <<< "$1 / 360")
S=$(bc -l <<< "$2 / 100")
L=$(bc -l <<< "$3 / 511")
R=0
B=0
G=0
var_1=0
var_2=0

if [ $(echo "$S == 0" | bc -l) -eq 1 ]; then
  R=$(bc <<< "x = ($L * 255); scale = 0; x / 1")
  G=$(bc <<< "x = ($L * 255); scale = 0; x / 1")
  B=$(bc <<< "x = ($L * 255); scale = 0; x / 1")
else
  if [ $(echo "$L < 0.5" | bc -l) -eq 1 ]; then
    var_2=$(echo "$L * (1 + $S)" | bc -l)
  else
    var_2=$(echo "($L + $S) - ( $S * $L )" | bc -l)
  fi

  var_1=$(echo "2 * $L - $var_2" | bc -l)

  temp_vH=$(echo "$H + (1 / 3)" | bc -l)
  temp_val=`hue_to_rgb "$var_1" "$var_2" "$temp_vH"`
  R=$(bc <<< "x = (255 * $temp_val); scale = 0; x / 1")

  temp_val=`hue_to_rgb "$var_1" "$var_2" "$H"`
  G=$(bc <<< "x = (255 * $temp_val); scale = 0; x / 1")

  temp_vH=$(echo "$H - (1 / 3)" | bc -l)
  temp_val=`hue_to_rgb "$var_1" "$var_2" "$temp_vH"`
  B=$(bc <<< "x = (255 * $temp_val); scale = 0; x / 1")
fi

printf "%.2x%.2x%.2x" $R $G $B
