#!/bin/bash
# Modifidation of the original for the optimal-spc

tmpdir=tmpdir
list=$1

[ -z "$list" ] && echo "Need list" && exit 1
[ ! -f $list ] && echo "$list is not a file" && exit 1

rm -rf $tmpdir
mkdir -p $tmpdir

cp dcicpp.spc $tmpdir
cp $list $tmpdir
cd $tmpdir
rm -f fail.list
c=0
T=0
for problem in $(cat $list)
do
  echo "Running problem $problem"
  g=$(rundcicpp -D $problem -lgfortran -lgfortranbegin 2> /dev/null | grep Converged)
  if [ ! -z "$g" ]; then
    c=$(($c+1))
  else
    echo $problem >> fail.list
  fi
  T=$(($T+1))
  echo "Partial count: $c/$T = $(echo "scale=2;100*$c/$T"|bc)%"
done

p=$(echo "scale=2;100*$c/$T"|bc)
echo "Convergence: $c/$T = $p"
if [ $(echo "$p > 90" | bc) -eq 1 ];
then
  exit 0
else
  exit 1
fi
