#!/bin/bash

#module load compiler/gcc-9.2.0
#module load openmpi/openmpi-3.1.3

### GCC
export PATH=/softwares/gcc/gcc-9.2.0/bin:$PATH
export LD_LIBRARY_PATH=/softwares/gcc/gcc-9.2.0/lib64:$LD_LIBRARY_PATH

### OpenMPI 3.1.3
export PATH=/softwares/openmpi-3.1.3/bin:$PATH
export LD_LIBRARY_PATH=/softwares/openmpi-3.1.3/lib:$LD_LIBRARY_PATH

### Gromacs MPI 2020
export PATH=/softwares/gromacs/gromacs-mpi-2020.2/bin:$PATH
export LD_LIBRARY_PATH=/softwares/gromacs/gromacs-mpi-2020.2/lib64:$LD_LIBRARY_PATH


#### Benchmark com Gromacs com HT
echo "-----------------------------------------"
echo "Inicio do job:" `date`

host=( 1 2 4 8 10 16 20 32 40 )
for cpu in "${host[@]}" ; do
        export OMP_NUM_THREADS=$cpu
        for elt in {1..30} ; do
                ### Rodando um script ###
                gmx_mpi mdrun -s benchMEM.tpr 2> "output/gmxbench-"$cpu"-"$elt".log"
        done
        rm /home/adriano/kvm1/Gromacs/*md.log.*
        rm /home/adriano/kvm1/Gromacs/*ener.edr.*
        rm /home/adriano/kvm1/Gromacs/*confout.gro.*
done


#### Extrai os tempo e cria a tabela
echo "CPUs Experimento Ambiente Tempo" > output/GromacsHTnativoNanoDia.log
echo "CPUs Experimento Ambiente Tempo" > output/GromacsHTnativoTempo.log
for cpu in "${host[@]}" ; do
        for elt in {1..30} ; do
                nanodia=`grep Performance "output/gmxbench-"$cpu"-"$elt".log" | awk '{print $2}'`
                tempo=`grep Time "output/gmxbench-"$cpu"-"$elt".log" | awk '{print $3}'`
                echo "$cpu $elt nativo $nanodia" >> output/GromacsHTnativoNanoDia.log
                echo "$cpu $elt nativo $tempo" >> output/GromacsHTnativoTempo.log
        done
done


echo "Final do job:" `date`
echo "-----------------------------------------"
