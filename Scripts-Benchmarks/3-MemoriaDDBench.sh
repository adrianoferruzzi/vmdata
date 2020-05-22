#!/bin/bash

#### Observacao: Antes de executar esse script crie uma área na memória RAM no mesmo diretório do script com o comando:
#### sudo mount -t tmpfs -o rw,size=15G tmpfs mem


## Executa o benchmark de tempo de escrita em memoria
for i in {1..30} ; do
	dd if=/dev/zero of=mem/teste_memoria bs=1M count=15096 2>> escrita15.log
	echo " " >> escrita15.log
	rm -rf mem/teste_memoria
done

## Executa o benchmark de tempo de leitura em memoria
dd if=/dev/zero of=mem/teste_memoria bs=1M count=15096
for i in {1..30} ; do
        dd if=mem/teste_memoria of=/dev/null bs=1M count=15096 2>> leitura15.log
        echo " " >> leitura15.log
done

## Executa o benchmark de tempo de escrita em memoria
for i in {1..30} ; do
dd if=/dev/zero of=mem/teste_memoria bs=1M count=30096 2>> escrita30.log
echo " " >> escrita30.log
rm -rf mem/teste_memoria
done

## Executa o benchmark de tempo de leitura em memoria
dd if=/dev/zero of=mem/teste_memoria bs=1M count=30096
for i in {1..30} ; do
 dd if=mem/teste_memoria of=/dev/null bs=1M count=30096 2>> leitura30.log
echo " " >> leitura30.log
done


## Executa o benchmark de tempo de escrita em memoria
for i in {1..30} ; do
dd if=/dev/zero of=mem/teste_memoria bs=1M count=50096 2>> escrita50.log
echo " " >> escrita50.log
rm -rf mem/teste_memoria
done

## Executa o benchmark de tempo de leitura em memoria
dd if=/dev/zero of=mem/teste_memoria bs=1M count=50096
for i in {1..30} ; do
dd if=mem/teste_memoria of=/dev/null bs=1M count=50096 2>> leitura50.log
echo " " >> leitura50.log
done


## Executa Benchmark com sysbench
for i in {1..30} ; do
        sysbench memory --time=0 --events=10000  run >> desempenhoSysbench.log
        echo " " >> desempenhoSysbench.log
done

