#!/bin/bash

# Convert images to EPS under desired density, preserving scale

line="\
0.65     350    hpainter_inheritance_small.png
1.5	 350    pedcreate.png
1	 350    dos2.png
0.7      350    all_in_one.png
1.2	 350    path_finder.png
1.4	 350    graph_and_path2.png
0.92	 350    homology.png
0.25     1200    x_compare.jpg\
"

IFS='
'

num=${1:-99}
#[ "$1" != "" ] && num=$1 || num=99

count=0

for f in $line; do
    density=";echo no"

    count=$(( $count + 1 ))
    [ $count != $num ] && [ $num != 99 ] && continue
    
    scale=$(echo $f | awk '{print $1}');
    density=$(echo $f | awk '{print $2}')
    fname=../imgs/$(echo $f | awk '{print $3}');

    nscal=`echo "$scale * $density" | bc | awk -F. '{print $1}'`"%"
    nname=$(basename $fname | awk -F. '{print $1}').4.eps

    echo "$fname -- $scale * $density = $nscal"

    convert $fname -density $density -geometry $nscal eps3:$nname
done




