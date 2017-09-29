#!/bin/bash

imgs=""
out="out_pngs"
mkdir -p $out

for d in Fig*; do
    cd $d;
    rm *.svg
    Rscript *.R
    outimg=$(readlink -f *.svg)
    echo $outimg
    imgs=$imgs" "$outimg

    cd -
done

# to png
cp $imgs $out/
cd $out
for s in *.svg; do
    echo "$s"
    convert -density 600 $s `basename $s .svg`.png
done
rm *.svg
cd -
