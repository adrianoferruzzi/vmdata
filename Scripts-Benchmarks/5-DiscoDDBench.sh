#!/bin/bash

## Executa o benchmark de tempo de escrita em disco 
# 1G
for i in {1..30} ; do
	dd bs=10k count=102400 oflag=direct if=/dev/zero of=testehd 2>> escrita1G.log
	echo " " >> escrita1G.log
	rm -rf testehd
done

# 10G
for i in {1..30} ; do
        dd bs=10k count=1002400 oflag=direct if=/dev/zero of=testehd 2>> escrita10G.log
        echo " " >> escrita10G.log
        rm -rf testehd
done



## Executa o benchmark de tempo de leitura de disco
# 1G
dd bs=10k count=102400 oflag=direct if=/dev/zero of=testehd
for i in {1..30} ; do
	dd bs=10K count=102400 iflag=direct if=testehd of=/dev/null 2>> leitura1G.log
        echo " " >> leitura1G.log
done

rm -rf testehd

# 10G
dd bs=10k count=1002400 oflag=direct if=/dev/zero of=testehd
for i in {1..30} ; do
        dd bs=10K count=1002400 iflag=direct if=testehd of=/dev/null 2>> leitura10G.log
        echo " " >> leitura10G.log
done

rm -rf testehd


## Executa o benchmark de performance de disco
for i in {1..30} ; do
	hdparm -t /dev/xvda >> desempenhoBuffer.log	
	echo " " >> desempenhoBuffer.log
done	

for i in {1..30} ; do
        hdparm -T /dev/xvda >> desempenhoCache.log
        echo " " >> desempenhoCache.log
done

