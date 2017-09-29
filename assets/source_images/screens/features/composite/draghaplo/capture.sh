#!/bin/bash

echo 3
sleep 1
echo 2
sleep 1
echo 1
sleep 1

for f in `seq 1 100`; do
	fname=`printf "%03d" $f`.jpg
	import -window "Haplotype Reconstruction - Nightly" $fname
done

