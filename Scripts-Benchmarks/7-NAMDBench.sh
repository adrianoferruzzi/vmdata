#!/bin/bash

echo "-----------------------------------------"
echo "Inicio do job:" `date`
## Carregando modulo do namd-multicore-cuda

##source /etc/profile.d/modules.sh
##module load namd/namd-2.13_multicore

host=( 1 2 4 8 10 16 20 32 40 )
for cpu in "${host[@]}" ; do 
	for elt in {1..30} ; do 
		### Rodando um script ###
		namd2 +idlepoll +p$cpu apoa1.namd  > "dynamics-"$cpu"-"$elt".log"
	done
done 

echo "Final do job:" `date`
echo "-----------------------------------------"
