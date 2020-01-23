#####
# Script R para análise de desempenho de CPUs com uso compartilhado
# Todas as tabelas são modeladas e todos os gráficos são feitos com este script em R
# Basta executá-lo ... ;)
####
require(ggplot2)
require(ggthemes)
require(dplyr)
library(stringr)
library(readr)


### Análise de desempenho do ambiente KVM
### Esta análise considera apenas os 3 flavors do ambiente KVM 
tabelaDados <- read.table('../Tabelas/TabelaCPUCo.log',
                          header = T)

tabelaKvm <- tabelaDados
tabelaKvm <- tabelaKvm %>% filter(str_detect(Ambiente, 'kvm_'))

tabelaKvm <- tabelaKvm %>%
  group_by(CPUs, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())))

tabelaKvm$CPUs <- factor(tabelaKvm$CPUs, levels = c(unique(tabelaKvm$CPUs)[order(unique(tabelaKvm$CPUs))]))

cpuKvmCo <- ggplot(tabelaKvm, aes(fill = Ambiente, x = CPUs, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  scale_fill_manual(values=c("#bcbddc", "#efedf5")) +
  labs(title="Desempenho do KVM",x="CPUs", y = "Tempo Médio (seg)")+
  ylim(0, 115) +
  theme_bw(base_size = 20) 
ggsave(filename = "../Graficos/CPU/09cpuKvmCo.png", width = 10, height = 7, dpi = 300) 

### Análise de desempenho do ambiente Xen
### Esta análise considera apenas os 3 flavors do ambiente Xen
tabelaXen <- tabelaDados
tabelaXen <- tabelaXen %>% filter(str_detect(Ambiente, 'Xen_'))

tabelaXen <- tabelaXen %>%
  group_by(CPUs, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())))

tabelaXen$CPUs <- factor(tabelaXen$CPUs, levels = c(unique(tabelaXen$CPUs)[order(unique(tabelaXen$CPUs))]))

cpuXenCo <- ggplot(tabelaXen, aes(fill = Ambiente, x = CPUs, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(title="Desempenho do Xen",x="CPUs", y = "Tempo Médio (seg)") +
  scale_fill_manual(values=c("#a1d99b", "#e5f5e0")) +
  ylim(0, 115) +
  theme_bw(base_size = 20) 
ggsave(filename = "../Graficos/CPU/10cpuXenCo.png", width = 10, height = 7, dpi = 300) 


### Análise do ambiente comparado
### Este pedaço do script faz uma comparação entre o ambiente kvm e xen em todos os flavors 
### Nesse caso, além do gráfico em barras para fazer a comparação de tempo também 
### é utilizado um gráfico de barras para apresentar o coefiente de variação.
tabelaComparada <- tabelaDados %>%
  filter(Ambiente == 'Xen_2' | Ambiente == 'Xen_3' | Ambiente == 'kvm_2' | Ambiente == 'kvm_3' )

### Cria uma tabela com as Medidas de Posição e Medidas de Variação
tabelaComparada <- tabelaComparada %>%
  group_by(CPUs, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = (Desvio_Padrao/Tempo_Medio),
            )  

tabelaComparada$CPUs <- factor(tabelaComparada$CPUs, levels = c(unique(tabelaComparada$CPUs)[order(unique(tabelaComparada$CPUs))]))

### Gráfico com o tempo médio de desempenho de cada ambiente + intervalo de confiança
cpuComparaCo <- ggplot(tabelaComparada, aes(fill = Ambiente, x = CPUs, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  scale_fill_manual(values=c("#bcbddc", "#efedf5", "#a1d99b", "#e5f5e0")) +
  labs(title="KVM x Xen",x="CPUs", y = "Tempo Médio (seg)")+
  ylim(0, 115) +
  theme_bw(base_size = 20) 
ggsave(filename = "../Graficos/CPU/11cpuComparaCo.png", width = 10, height = 7, dpi = 300) 

### Gráfico com Coeficiente de Variação dos ambientes 
### Esse gráfico tem o objetivo de apresentar a porcentagem de variação dos dados obtidos 
cpuCoeficienteCo <- ggplot(tabelaComparada, aes(fill = Ambiente, x = CPUs, y = Coeficiente_Variacao, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  ggtitle("Coefiente de Variação dos Resultados") +
  scale_fill_manual(values=c("#bcbddc", "#efedf5", "#a1d99b", "#e5f5e0")) +
  theme_bw(base_size = 20) +
  scale_y_continuous(limits = c(0,0.2), labels = scales::percent) 
ggsave(filename = "../Graficos/CPU/13cpuCoeficienteCo.png", width = 10, height = 7, dpi = 300)


### BoxPlot
### Este gráfico tem o objetivo de verificar a variação dos dados obtidos por meio de quartis 
### ele indica a mediana e a variabilidade fora do quartil superior, inferior e outliers
tabelaComparada <- tabelaDados %>%
  filter(Ambiente == 'Xen_2' | Ambiente == 'Xen_3' | Ambiente == 'kvm_2' | Ambiente == 'kvm_3' )

tabelaComparada$CPUs <- factor(tabelaComparada$CPUs, levels = c(unique(tabelaComparada$CPUs)[order(unique(tabelaComparada$CPUs))]))

cpuBoxCo <- ggplot(tabelaComparada, aes(x=CPUs, y=Tempo, fill=Ambiente)) + 
  geom_boxplot(outlier.colour="red", outlier.shape=9, outlier.size=2) +
  labs(title="Variação do Tempo de Desempenho",x="CPUs", y = "Tempo (seg)")+
  scale_fill_manual(values=c("#bcbddc", "#efedf5", "#a1d99b", "#e5f5e0")) +
  theme_bw(base_size = 20)
ggsave(filename = "../Graficos/CPU/12cpuBoxCo.png", width = 10, height = 7, dpi = 300)


##### 
## Comparação entre os tempos com uso de CPU exclusivo e compartilhado
## Essa parte do script faz a comparação entre todos os ambiente
## Tempo Exclusivo x Tempo Compartilhado
##### 

tabelaDados2 <- read.table('../Tabelas/TabelaCPUEx.log',
                          header = T)

tabelaKvmXen23Co <- tabelaDados %>%
  filter(Ambiente == 'Xen_2' | Ambiente == 'Xen_3' | Ambiente == 'kvm_2' | Ambiente == 'kvm_3' )
write_csv(tabelaKvmXen23Co, "../Tabelas/tabelaKvmXen23Co.csv")

tabelaKvmXen23Ex <- tabelaDados2 %>%
  filter(Ambiente == 'Xen_2' | Ambiente == 'Xen_3' | Ambiente == 'kvm_2' | Ambiente == 'kvm_3' )
write_csv(tabelaKvmXen23Ex, "../Tabelas/tabelaKvmXen23Ex.csv")

### Script para modificar os valores de kvm_2 para kvm_2_Co e kvm_2_Ex 
### o Script também faz a união dos registros
system('bash -c "./substituicaoTabelasCo.sh"')

tabelaKvm23Xen23 <- read.csv('../Tabelas/tabelaKvmXen23Co.csv',
                           header = T)

tabelaKvm23 <-tabelaKvm23Xen23  %>%
  filter(Ambiente == 'kvm_2_Ex' | Ambiente == 'kvm_2_Co' | Ambiente == 'kvm_3_Ex' | Ambiente == 'kvm_3_Co' )

tabelaKvm23 <- tabelaKvm23 %>%
  group_by(CPUs, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())))

tabelaKvm23$CPUs <- factor(tabelaKvm23$CPUs, levels = c(unique(tabelaKvm23$CPUs)[order(unique(tabelaKvm23$CPUs))]))

### Gera o gráfico de comparação entre os ambientes com uso Compartilhado x Exclusivo do KVM
cpuComparaKvm23 <- ggplot(tabelaKvm23, aes(fill = Ambiente, x = CPUs, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(title="KVM Exclusivo x KVM Compartilhado",x="CPUs", y = "Tempo Médio (seg)") +
  scale_fill_manual(values=c("#bcbddc", "#fc9272", "#efedf5", "#fee0d2")) +
  ylim(0, 115) +
  theme_bw(base_size = 20) 
ggsave(filename = "../Graficos/CPU/14cpuComparaKvm23.png", width = 10, height = 7, dpi = 300)


### Gera o data frame de comparação entre os ambientes com uso Compartilhado x Exclusivo do Xen
tabelaXen23 <-tabelaKvm23Xen23  %>%
  filter(Ambiente == 'Xen_2_Ex' | Ambiente == 'Xen_2_Co' | Ambiente == 'Xen_3_Ex' | Ambiente == 'Xen_3_Co' )

tabelaXen23 <- tabelaXen23 %>%
  group_by(CPUs, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())))

tabelaXen23$CPUs <- factor(tabelaXen23$CPUs, levels = c(unique(tabelaXen23$CPUs)[order(unique(tabelaXen23$CPUs))]))

### Gera o gráfico de comparação entre os ambientes com uso Compartilhado x Exclusivo do Xen
cpuComparaXen23 <- ggplot(tabelaXen23, aes(fill = Ambiente, x = CPUs, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(title="Xen Exclusivo x Xen Compartilhado",x="CPUs", y = "Tempo Médio (seg)") +
  scale_fill_manual(values=c("#a1d99b", "#9ecae1", "#e5f5e0", "#deebf7")) +
  ylim(0, 115) +
  theme_bw(base_size = 20) 
ggsave(filename = "../Graficos/CPU/15cpuComparaXen23.png", width = 10, height = 7, dpi = 300)




