#!/bin/bash

export PATH=$PATH:/home/adriano/gamess/gamess
echo "CPU experimento ambiente tempo disco" > disco_usado.log
for cpu in 1 2 4 8 10 16 20 ; do
	for elt in {1..30}  ; do
		echo "$elt : inicio " `date`
		time -p rungms rapido-memoria.inp 00 $cpu > rapido-memoria-$cpu-$elt.log 
		tempo=`grep real nohup.out | tail -1 | awk '{print $2}'`
		rm -rf /home/adriano/gamess/gamess/rapido-memoria*
		rm -rf /tmp/adriano/*
		disco=`grep /tmp/adriano rapido-memoria-$cpu-$elt.log | awk '{n+=$5} END {print n}'`
		echo "$cpu $elt xen $tempo $disco" >> disco_usado.log   
		echo ""
	done
done
