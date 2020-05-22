#!/bin/bash

cpus=( 1 2 4 8 10 16 20 32 40 )

echo "CPUs Experimento Ambiente Tempo" > NAMD_xen1HT.log
for cpu in "${cpus[@]}" ; do
	for elt in {1..30} ; do
		nano=`grep days "dynamics-"$cpu"-"$elt".log" | tail -1 | awk '{print $8}'`
		nanodia=`echo "scale=4;1/$nano" | bc -l `
		echo "$cpu $elt xen-1 $nanodia" >> NAMD_xen1HT.log
	done 
done 

