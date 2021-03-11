#!/bin/bash

#module load openmpi/openmpi-3.0.0
export PATH=/softwares/openmpi-3.0.0/bin:$PATH
export LD_LIBRARY_PATH=/softwares/openmpi-3.0.0/lib:$LD_LIBRARY_PATH
export PATH=/softwares/lammps/lammps-16Mar18:$PATH
export TIMEFORMAT=%R

#### Benchmark com Gaussian com HT
echo "-----------------------------------------"
echo "Inicio do job:" `date`

host=( 1 2 4 8 10 16 20 32 40 )
for cpu in "${host[@]}" ; do
        for elt in {1..30} ; do
                ### Rodando um script ###
                { time mpirun -n $cpu --hostfile hostfile.txt lmp_mpi -in benchmark.in > output/log-"$cpu"-"$elt".lammps ; } 2>> output/log-"$cpu"-"$elt".lammps
        done
done


#### Extrai os tempo e cria a tabela
echo "CPUs Experimento Ambiente Tempo" > output/lammpsHTnativoTempo.log
for cpu in "${host[@]}" ; do
        for elt in {1..30} ; do
                tempo=`tail -1 output/log-"$cpu"-"$elt".lammps`
                echo "$cpu $elt nativo $tempo" >> output/lammpsHTnativoTempo.log
        done
done

echo "Final do job:" `date`
echo "-----------------------------------------"
