#!/bin/bash

### Altera os valores da tabela Compartilhada
sed -i 's/kvm_2/kvm_2_Co/g' ../Tabelas/tabelaKvmXen23Co.csv
sed -i 's/kvm_3/kvm_3_Co/g' ../Tabelas/tabelaKvmXen23Co.csv

### Altera os valores da tabela Exclusiva
sed -i 's/kvm_2/kvm_2_Ex/g' ../Tabelas/tabelaKvmXen23Ex.csv
sed -i 's/kvm_3/kvm_3_Ex/g' ../Tabelas/tabelaKvmXen23Ex.csv

### Altera os valores da tabela Compartilhada
sed -i 's/Xen_2/Xen_2_Co/g' ../Tabelas/tabelaKvmXen23Co.csv
sed -i 's/Xen_3/Xen_3_Co/g' ../Tabelas/tabelaKvmXen23Co.csv

### Altera os valores da tabela Exclusiva
sed -i 's/Xen_2/Xen_2_Ex/g' ../Tabelas/tabelaKvmXen23Ex.csv
sed -i 's/Xen_3/Xen_3_Ex/g' ../Tabelas/tabelaKvmXen23Ex.csv

cat ../Tabelas/tabelaKvmXen23Ex.csv | grep -v Ambiente >> ../Tabelas/tabelaKvmXen23Co.csv


