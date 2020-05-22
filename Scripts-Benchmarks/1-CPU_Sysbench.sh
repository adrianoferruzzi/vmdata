#!/bin/bash

## Executa o benchmark de tempo de cpu
for ncpus in 1 2 4 8 10 16 20 32 40; do
	for i in {1..30} ; do
		sysbench cpu --time=0 --events=100000 --threads=$ncpus run > "cpu_"$ncpus"_"$i".log"
	done
done

