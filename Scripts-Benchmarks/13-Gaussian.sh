#!/bin/bash

export PATH=/softwares/g09:$PATH
export GAUSS_EXEDIR=/softwares/g09
mkdir /tmp/adrianof
export GAUSS_SCRDIR=/tmp/adrianof
export TIMEFORMAT=%R

#### Benchmark com Gaussian com HT
echo "-----------------------------------------"
echo "Inicio do job:" `date`

host=( 1 2 4 8 10 16 20 32 40 )
for cpu in "${host[@]}" ; do
        for elt in {1..30} ; do
                ### Rodando um script ###
                # time g09 < ccsd_"$cpu".freq > "output/gaussbench-"$cpu"-"$elt".log"
                { time g09 < energia-"$cpu".gjf > output/energia-"$cpu"-"$elt".log ; } 2>> output/energia-"$cpu"-"$elt".log
        done
done


#### Extrai os tempo e cria a tabela
echo "CPUs Experimento Ambiente Tempo" > output/GaussianHTnativoTempo.log
for cpu in "${host[@]}" ; do
        for elt in {1..30} ; do
                tempo=`tail -1 output/energia-"$cpu"-"$elt".log`
                echo "$cpu $elt nativo $tempo" >> output/GaussianHTnativoTempo.log
        done
done

echo "Final do job:" `date`
echo "-----------------------------------------"
