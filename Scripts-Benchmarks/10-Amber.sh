#!/bin/bash

#module load openmpi/openmpi-3.0.0
#module load cuda/cuda-10.1

export PATH=/softwares/openmpi-3.0.0/bin:$PATH
export LD_LIBRARY_PATH=/softwares/openmpi-3.0.0/lib:$LD_LIBRARY_PATH

source /softwares/amber/amber20/amber.sh

export TIMEFORMAT=%R

#### Benchmark com Amber com HT
echo "-----------------------------------------"
echo "Inicio do job:" `date`

### Rodando com 1 thread
for elt in {1..30} ; do
                ### Rodando um script ###
                { time pmemd -O -i benchmark.in -o output/AmbersemHT-1-"$elt".out -c benchmark.rst -p benchmark.top -r benchmark.restrt -x benchmark.mdcrd ; } 2>> output/AmbersemHT-1-"$elt".out
done

host=( 2 4 8 10 16 20 32 40 )
for cpu in "${host[@]}" ; do
        for elt in {1..30} ; do
                ### Rodando um script ###
                { time mpirun -np $cpu pmemd.MPI -O -i benchmark.in -o output/AmberHT-"$cpu"-"$elt".out -c benchmark.rst -p benchmark.top -r benchmark.restrt -x benchmark.mdcrd ; } 2>> output/AmberHT-"$cpu"-"$elt".out
        done
done


host=( 1 2 4 8 10 16 20 32 40 )
#### Extrai os tempo e cria a tabela
echo "CPUs Experimento Ambiente Tempo" > output/AmberHTnativoTempo.log
for cpu in "${host[@]}" ; do
        for elt in {1..30} ; do
                tempo=`tail -1 output/AmberHT-"$cpu"-"$elt".out`
                echo "$cpu $elt kvm1 $tempo" >> output/AmberHTnativoTempo.log
        done
done

echo "Final do job:" `date`
echo "-----------------------------------------"
