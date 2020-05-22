#!/bin/bash

echo "GB Experimento Ambiente Tempo" > leitura_xen_ex.log
cont=1
for line in $(cat disco_xen_ex_leitura1.log) ; do 
	echo "1 $cont xen_1 $line"  >> leitura_xen_ex.log
	cont=$(($cont+1))
done 

cont=1
for line in $(cat disco_xen_ex_leitura10.log) ; do
        echo "10 $cont xen_1 $line"  >> leitura_xen_ex.log
        cont=$(($cont+1))
done


echo "GB Experimento Ambiente Tempo" > escrita_xen_ex.log
cont=1
for line in $(cat disco_xen_ex_escrita1.log) ; do
        echo "1 $cont xen_1 $line"  >> escrita_xen_ex.log
        cont=$(($cont+1))
done

cont=1
for line in $(cat disco_xen_ex_escrita10.log) ; do
        echo "10 $cont xen_1 $line"  >> escrita_xen_ex.log
        cont=$(($cont+1))
done

 
