#!/bin/bash

## Após rodar o Benchmark de CPU use este script para criar a tabela com os tempos

## Imprime cabeçalho 
echo "CPUs Experimento Ambiente Tempo" > TabelaCpuXen_3Ex.log
## Exibe o tempo de cada cpu usado
for cpus in 1 2 4 8 10 16 20 32 40; do
	for experimento in {1..30} ; do
		tempo=`grep "total time:" "cpu_"$cpus"_"$experimento".log" | awk '{print $3}' | awk -F"s" '{print $1}'`
		## Imprime o tempo de cada calculo 
		echo "$cpus $experimento xen_3 $tempo " >> TabelaCpuXen_3Ex.log
	done
done

