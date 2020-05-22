#!/bin/bash

echo "GB Experimento Ambiente Tempo" > leitura_xen_ex.log
cont=1
for line in $(cat Memoria_xen_ex_leitura15.log) ; do 
	echo "15 $cont xen $line"  >> leitura_xen_ex.log
	cont=$(($cont+1))
done 

cont=1
for line in $(cat Memoria_xen_ex_leitura30.log) ; do
        echo "30 $cont xen $line"  >> leitura_xen_ex.log
        cont=$(($cont+1))
done

cont=1
for line in $(cat Memoria_xen_ex_leitura50.log) ; do
        echo "50 $cont xen $line"  >> leitura_xen_ex.log
        cont=$(($cont+1))
done


echo "GB Experimento Ambiente Tempo" > escrita_xen_ex.log
cont=1
for line in $(cat Memoria_xen_ex_escrita15.log) ; do
        echo "15 $cont xen $line"  >> escrita_xen_ex.log
        cont=$(($cont+1))
done

cont=1
for line in $(cat Memoria_xen_ex_escrita30.log) ; do
        echo "30 $cont xen $line"  >> escrita_xen_ex.log
        cont=$(($cont+1))
done

cont=1
for line in $(cat Memoria_xen_ex_escrita50.log) ; do
        echo "50 $cont xen $line"  >> escrita_xen_ex.log
        cont=$(($cont+1))
done
 
