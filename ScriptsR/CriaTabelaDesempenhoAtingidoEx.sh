#!/bin/bash

echo "CPUs,Experimento,Ambiente,Tempo,Tempo_Nativo,Perf,Perf5,Perf10" > ../Tabelas/tabelaDesEx.csv

for cpu in 1 2 4 8 10 16 20 32 40; do
	tempo=`grep "^$cpu," ../Tabelas/tabelaNativoExclusivo.csv | awk -F"," '{printf ("%.4f", $3)}'`
	tempo5=`grep "^$cpu," ../Tabelas/tabelaNativoExclusivo.csv | awk -F"," '{printf ("%.4f", $4)}'`
	tempo10=`grep "^$cpu," ../Tabelas/tabelaNativoExclusivo.csv | awk -F"," '{printf ("%.4f", $5)}'`
	for ambiente in kvm_1 Xen_1; do
		for experimento in {1..30} ; do
			tempovirt=`grep "^$cpu,$experimento,$ambiente" ../Tabelas/tabelaKvm_1Xen_1Ex.csv | awk -F"," '{printf ("%.4f", $4)}'`
			if awk -v x="$tempovirt" -v y="$tempo" 'BEGIN { exit (x <= y) ? 0 : 1 }'; then
				perf=1
			else
				perf=0
			fi

			if awk -v x="$tempovirt" -v y="$tempo5" 'BEGIN { exit (x <= y) ? 0 : 1 }'; then
				perf5=1
			else
				perf5=0
			fi

			if awk -v x="$tempovirt" -v y="$tempo10" 'BEGIN { exit (x <= y) ? 0 : 1 }'; then
				perf10=1
			else
				perf10=0
			fi

			echo "$cpu,$experimento,$ambiente,$tempovirt,$tempo,$perf,$perf5,$perf10" >> ../Tabelas/tabelaDesEx.csv
		done
	done
done		
		

