#####
# Script R para analise de desempenho de CPUs com uso exclusivo
# Todas as tabelas são modeladas e todos os gráficos são feitos com este script em R
# Basta executá-lo ... ;)
####
require(ggplot2)
require(ggthemes)
require(dplyr)
library(stringr)
library(readr)
library(grid)
library("gridExtra")
library(ggpubr)


### Análise de desempenho do ambiente KVM
### Esta análise considera apenas os 3 flavors do ambiente KVM 
tabelaCpuEx <- read.table('../Tabelas/TabelaCPUEx.log',
                          header = T)

tabelaKvm$CPUs <- factor(tabelaKvm$CPUs, levels = c(unique(tabelaKvm$CPUs)[order(unique(tabelaKvm$CPUs))]))

### Análise do ambiente comparado
### Este script considera uma comparação entre o ambiente Nativo, kvm_1 e xen_1
### Nesse caso, além do gráfico em barras para fazer a comparação de tempo também 
### é utilizado um gráfico para apresentar o coefiente de variação.
tabelaComparada <- tabelaCpuEx %>%
  filter(Ambiente == 'Xen_1' | Ambiente == 'kvm_1' | Ambiente == 'Nativo' )

### Cria uma tabela com as Medidas de Posição e Medidas de Variação
tabelaComparada <- tabelaComparada %>%
  group_by(CPUs, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = Desvio_Padrao/Tempo_Medio,
            )  

tabelaComparada$CPUs <- factor(tabelaComparada$CPUs, levels = c(unique(tabelaComparada$CPUs)[order(unique(tabelaComparada$CPUs))]))

### Gráfico com o tempo médio de desempenho de cada ambiente + intervalo de confiança
cpuComparaEx <- ggplot(tabelaComparada, aes(fill = Ambiente, x = CPUs, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(title=" Ambientes Comparados",x="CPUs", y = "Tempo Médio (seg)") +
  ggtitle("Ambientes Comparados") +
  ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  ## scale_fill_manual(values=c("grey20", "grey50", "grey80")) +
  ## scale_fill_brewer(palette="Set2") +
  ylim(0, 115) +
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.8, 0.75)) 
ggsave(filename = "../Graficos/WCGA/01cpuComparaEx.png", width = 10, height = 7, dpi = 300) 


### Gráfico com Coeficiente de Variação dos ambientes 
### Esse gráfico tem o objetivo de apresentar a variação dos dados obtidos em porcentagem
cpuCoeficienteEx <- ggplot(tabelaComparada, aes(fill = Ambiente, x = CPUs, y = Coeficiente_Variacao, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  ggtitle("Coefiente de Variação") +
  ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.2, 0.75)) +
  scale_y_continuous(limits = c(0,0.16), labels = scales::percent) 
ggsave(filename = "../Graficos/WCGA/02cpuCoeficienteEx.png", width = 10, height = 7, dpi = 300)


### BoxPlot
### Este gráfico tem o objetivo de verificar a variação dos dados obtidos por meio de quartis 
### ele indica a mediana e a variabilidade fora do quartil superior, inferior e outliers
tabelaComparada <- tabelaCpuEx %>%
  filter(Ambiente == 'Xen_1' | Ambiente == 'kvm_1' | Ambiente == 'Nativo' )

tabelaComparada$CPUs <- factor(tabelaComparada$CPUs, levels = c(unique(tabelaComparada$CPUs)[order(unique(tabelaComparada$CPUs))]))

cpuBoxEx <- ggplot(tabelaComparada, aes(x=CPUs, y=Tempo, fill=Ambiente)) + 
  geom_boxplot(outlier.colour="red", outlier.shape=9, outlier.size=2) +
  labs(title="Variação do Tempo de Desempenho",x="CPUs", y = "Tempo (seg)")+
  ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.8, 0.75)) 
ggsave(filename = "../Graficos/WCGA/03cpuBoxEx.png", width = 10, height = 7, dpi = 300)



### Cria a tabelaNativo com os tempo médios de desempenho 
### Cria campos com o valor de 5% e 10% de overhead
tabelaNativoExclusivo <- tabelaCpuEx %>%
  filter(Ambiente == 'Nativo' )

tabelaNativoExclusivo <- tabelaNativoExclusivo %>%
  group_by(CPUs, Ambiente) %>%
  summarize(Tempo_Nativo = mean(Tempo),
            Tempo_Nativo5 = mean(Tempo)*1.05,
            Tempo_Nativo10 = mean(Tempo)*1.1,
  )
write_csv(tabelaNativoExclusivo, "../Tabelas/tabelaNativoExclusivo.csv")

### Cria a tabelaKvm_1Xen_1Ex com os tempos de desempenho 
tabelaKvm_1Xen_1Ex <- tabelaCpuEx %>%
  filter(Ambiente == 'Xen_1' | Ambiente == 'kvm_1' )
write_csv(tabelaKvm_1Xen_1Ex, "../Tabelas/tabelaKvm_1Xen_1Ex.csv")

### 
### Para encontrar a frequencia em que o hypervisor atinge o desempenho nativo
### É necessário executar o bash script CriaTabelaDesempenhoAtingidoEx.sh 
### Para descobrir a frequencia com que o hypervisor atinge os tempos especificados 
### Esse script faz a comparação de tempo e coloca 1 para "sim" e 0 para "não"
### 1 = o hypervisor conseguiu um desempenho igual ou melhor
### 0 = o hypervisor NÃO conseguiu um desempenho igual ou melhor
system('bash -c "./CriaTabelaDesempenhoAtingidoEx.sh"')

tabelaFreq <- read.csv('../Tabelas/tabelaDesEx.csv',  
                       header = T)
### Considera o desempenho virtual e o desempenho nativo com 5% e 10% de overhead
tabelaFreq <- tabelaFreq %>%
  group_by(CPUs, Ambiente) %>%
  summarize(Desempenho = (sum(Perf)/30),
            Desempenho5 = (sum(Perf5)/30),
            Desempenho10 = (sum(Perf10)/30),
  )

tabelaFreq$CPUs <- factor(tabelaFreq$CPUs, levels = c(unique(tabelaFreq$CPUs)[order(unique(tabelaFreq$CPUs))]))

### Plot: bitmap de alcance de desempenho com o tempo Nativo + 10% de overhead
cpuAlcanceEx10 <- ggplot(tabelaFreq, aes(fill = Ambiente, x = CPUs, y = Desempenho10, group = Ambiente, colour = Ambiente)) +
  geom_line(position = 'dodge', stat = 'identity', size=2) +
  ggtitle("VMs x 10% de Overhead") +
  ## scale_color_manual(values=c("#756bb1", "#31a354")) +
  scale_color_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.2, 0.3)) +
  scale_y_continuous(limits = c(0,1), labels = scales::percent) 
ggsave(filename = "../Graficos/WCGA/04cpuAlcanceEx10.png", width = 10, height = 7, dpi = 300) 


######################################
##
## Analise de CPU Compartilhada
##
######################################
##### 
## Comparação entre os tempos com uso de CPU exclusivo e compartilhado
## Essa parte do script faz a comparação entre todos os ambiente
## Tempo Exclusivo x Tempo Compartilhado
##### 

tabelaCpuCo <- read.table('../Tabelas/TabelaCPUCo.log',
                          header = T)

tabelaCpuExCo <- read.table('../Tabelas/TabelaCPUEx.log',
                           header = T)

tabelaKvmXen23Co <- tabelaCpuCo %>%
  filter(Ambiente == 'Xen_2' | Ambiente == 'Xen_3' | Ambiente == 'kvm_2' | Ambiente == 'kvm_3' )
write_csv(tabelaKvmXen23Co, "../Tabelas/tabelaKvmXen23Co.csv")

tabelaKvmXen23Ex <- tabelaCpuExCo %>%
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
  ## scale_fill_manual(values=c("#bcbddc", "#fc9272", "#efedf5", "#fee0d2")) +
  ylim(0, 115) +
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.8, 0.75)) 
ggsave(filename = "../Graficos/WCGA/05cpuComparaKvm23.png", width = 10, height = 7, dpi = 300)


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
  ## scale_fill_manual(values=c("#a1d99b", "#9ecae1", "#e5f5e0", "#deebf7")) +
  ylim(0, 100) +
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.8, 0.75)) 
ggsave(filename = "../Graficos/WCGA/06cpuComparaXen23.png", width = 10, height = 7, dpi = 300)




######################################
##
## Analise de Memoria Exclusiva
##
######################################

tabelaMemEx <- read.table('../Tabelas/TabelaMemLeituraEx.log',
                          header = T)

tabelaMemEx <- tabelaMemEx %>%
  group_by(GB, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = Desvio_Padrao/Tempo_Medio,
  )

# summary(tabelaMemEx)
# str(tabelaMemEx)

tabelaMemEx$GB <- factor(tabelaMemEx$GB, levels = c(unique(tabelaMemEx$GB)[order(unique(tabelaMemEx$GB))]))
### Gráfico em barras com o tempo médio de desempenho de cada ambiente + intervalo de confiança
memoriaLeituraEx <- ggplot(tabelaMemEx, aes(fill = Ambiente, x = GB, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(x="GB", y = "Tempo (seg)")+
  ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  scale_y_continuous(limits = c(0, 10))+
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.35, 0.75))
## ggsave(filename = "../Graficos/Memoria/07memoriaLeituraEx.png", width = 10, height = 7, dpi = 300) 

############
# Escrita
############
tabelaEscritaEx <- read.table('../Tabelas/TabelaMemEscritaEx.log',
                              header = T)

tabelaEscritaEx <- tabelaEscritaEx %>%
  group_by(GB, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = Desvio_Padrao/Tempo_Medio,
  )

tabelaEscritaEx$GB <- factor(tabelaEscritaEx$GB, levels = c(unique(tabelaEscritaEx$GB)[order(unique(tabelaEscritaEx$GB))]))
### Gráfico em barras com o tempo médio de desempenho de cada ambiente + intervalo de confiança
memoriaEscritaEx <- ggplot(tabelaEscritaEx, aes(fill = Ambiente, x = GB, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(x="GB", y = "Tempo (seg)")+
  ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  scale_y_continuous(limits = c(0,30))+
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.35, 0.75))
## ggsave(filename = "../Graficos/Memoria/08memoriaEscritaEx.png", width = 10, height = 7, dpi = 300) 

memLeituraEscritaEx <- ggarrange(memoriaLeituraEx, memoriaEscritaEx, labels = c("Leitura", "Escrita"), 
                                 common.legend = TRUE, legend = "bottom")
ggsave(filename = "../Graficos/WCGA/07memoriaLeituraEscritaEx.png", width = 10, height = 7, dpi = 300) 

### BoxPlot
### Este gráfico tem o objetivo de verificar a variação dos dados obtidos por meio de quartis 
### ele indica a mediana e a variabilidade fora do quartil superior, inferior e outliers
tabelaComparada <- read.table('../Tabelas/TabelaMemLeituraEx.log',
                              header = T)

tabelaComparada$GB <- factor(tabelaComparada$GB, levels = c(unique(tabelaComparada$GB)[order(unique(tabelaComparada$GB))]))

boxLeituraEx <- ggplot(tabelaComparada, aes(x=GB, y=Tempo, fill=Ambiente)) + 
  geom_boxplot(outlier.colour="red", outlier.shape=9, outlier.size=2) +
  labs(x="GB", y = "Tempo (seg)")+
  ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.7, 0.8))
## ggsave(filename = "../Graficos/Memoria/02MemoriaBoxLeituraEx.png", width = 10, height = 7, dpi = 300)

### BoxPlot
### Este gráfico tem o objetivo de verificar a variação dos dados obtidos por meio de quartis 
### ele indica a mediana e a variabilidade fora do quartil superior, inferior e outliers
tabelaComparadaEscritaEx <- read.table('../Tabelas/TabelaMemEscritaEx.log',
                                       header = T)

tabelaComparadaEscritaEx$GB <- factor(tabelaComparadaEscritaEx$GB, levels = c(unique(tabelaComparadaEscritaEx$GB)[order(unique(tabelaComparadaEscritaEx$GB))]))

boxEscritaEx <- ggplot(tabelaComparadaEscritaEx, aes(x=GB, y=Tempo, fill=Ambiente)) + 
  geom_boxplot(outlier.colour="red", outlier.shape=9, outlier.size=2) +
  labs(x="GB", y = "Tempo (seg)")+
  ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.3, 0.8))
### ggsave(filename = "../Graficos/Memoria/07MemoriaBoxEscritaEx.png", width = 10, height = 7, dpi = 300)

boxLeituraEscritaEx <- ggarrange(boxLeituraEx, boxEscritaEx, labels = c("Leitura", "Escrita"),
                                   common.legend = TRUE, legend = "bottom")
ggsave(filename = "../Graficos/WCGA/08boxMemLeituraEscritaEx.png", width = 10, height = 7, dpi = 300) 





######################################
##
## Analise de Memoria Compartilhada
##
######################################


tabelaMemLeituraCo <- read.table('../Tabelas/TabelaMemLeituraCo.log',
                          header = T)

tabelaMemLeituraCo <- tabelaMemLeituraCo %>%
  group_by(GB, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = Desvio_Padrao/Tempo_Medio,
  )

# summary(tabelaMemLeituraCo)
# str(tabelaMemLeituraCo)

tabelaMemLeituraCo$GB <- factor(tabelaMemLeituraCo$GB, levels = c(unique(tabelaMemLeituraCo$GB)[order(unique(tabelaMemLeituraCo$GB))]))
### Gráfico em barras com o tempo médio de desempenho de cada ambiente + intervalo de confiança
memoriaLeituraCo <- ggplot(tabelaMemLeituraCo, aes(fill = Ambiente, x = GB, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(title="Kvm x Xen",x="GB", y = "Tempo (seg)")+
  ## scale_fill_manual(values=c("#756bb1", "#31a354")) +
  scale_y_continuous(limits = c(0,10))+
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.3, 0.8))
## ggsave(filename = "../Graficos/Memoria/11MemoriaLeituraCo.png", width = 10, height = 7, dpi = 300) 

###########
# Escrita
###########

tabelaEscritaCo <- read.table('../Tabelas/TabelaMemEscritaCo.log',
                              header = T)

tabelaEscritaCo <- tabelaEscritaCo %>%
  group_by(GB, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = Desvio_Padrao/Tempo_Medio,
  )

tabelaEscritaCo$GB <- factor(tabelaEscritaCo$GB, levels = c(unique(tabelaEscritaCo$GB)[order(unique(tabelaEscritaCo$GB))]))
### Gráfico em barras com o tempo médio de desempenho de cada ambiente + intervalo de confiança
memoriaEscritaCo <- ggplot(tabelaEscritaCo, aes(fill = Ambiente, x = GB, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(title="Kvm x Xen",x="GB", y = "Tempo (seg)")+
  ## scale_fill_manual(values=c("#756bb1", "#31a354")) +
  scale_y_continuous(limits = c(0,15))+
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.3, 0.8))
## ggsave(filename = "../Graficos/Memoria/14MemoriaEscritaCo.png", width = 10, height = 7, dpi = 300) 


memLeituraEscritaCo <- ggarrange(memoriaLeituraCo, memoriaEscritaCo, labels = c("Leitura", "Escrita"),
                                 common.legend = TRUE, legend = "bottom")
ggsave(filename = "../Graficos/WCGA/09memoriaLeituraEscritaCo.png", width = 10, height = 7, dpi = 300) 




######################################
##
## Analise de Disco Exclusivo
##
######################################

tabelaDiscoLeituraEx <- read.table('../Tabelas/TabelaDiscoLeituraEx.log',
                          header = T)

tabelaDiscoLeituraEx <- tabelaDiscoLeituraEx %>%
  group_by(GB, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = Desvio_Padrao/Tempo_Medio,
  )

# summary(tabelaDiscoLeituraEx)
# str(tabelaDiscoLeituraEx)

tabelaDiscoLeituraEx$GB <- factor(tabelaDiscoLeituraEx$GB, levels = c(unique(tabelaDiscoLeituraEx$GB)[order(unique(tabelaDiscoLeituraEx$GB))]))
### Gráfico em barras com o tempo médio de desempenho de cada ambiente + intervalo de confiança
discoLeituraEx <- ggplot(tabelaDiscoLeituraEx, aes(fill = Ambiente, x = GB, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(title="Leitura",x="GB", y = "Tempo (seg)")+
  ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  scale_y_continuous(limits = c(0,170))+
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.3, 0.8))
## ggsave(filename = "../Graficos/Disco/01DiscoLeituraEx.png", width = 10, height = 7, dpi = 300) 

########################
## Escrita
########################
tabelaEscritaEx <- read.table('../Tabelas/TabelaDiscoEscritaEx.log',
                              header = T)

tabelaEscritaEx <- tabelaEscritaEx %>%
  group_by(GB, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = Desvio_Padrao/Tempo_Medio,
  )

tabelaEscritaEx$GB <- factor(tabelaEscritaEx$GB, levels = c(unique(tabelaEscritaEx$GB)[order(unique(tabelaEscritaEx$GB))]))
### Gráfico em barras com o tempo médio de desempenho de cada ambiente + intervalo de confiança
discoEscritaEx <- ggplot(tabelaEscritaEx, aes(fill = Ambiente, x = GB, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(title="Escrita",x="GB", y = "Tempo (seg)")+
  ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  scale_y_continuous(limits = c(0,200))+
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.3, 0.8))
## ggsave(filename = "../Graficos/Disco/04DiscoEscritaEx.png", width = 10, height = 7, dpi = 300) 

discoLeituraEscritaEx <- ggarrange(discoLeituraEx, discoEscritaEx, common.legend = TRUE, legend = "bottom")
ggsave(filename = "../Graficos/WCGA/10discoLeituraEscritaEx.png", width = 10, height = 7, dpi = 300) 





######################################
##
## Analise de Disco Compartilhado
##
######################################

tabelaDiscoLeituraCo <- read.table('../Tabelas/TabelaDiscoLeituraCo.log',
                          header = T)

tabelaDiscoLeituraCo <- tabelaDiscoLeituraCo %>%
  group_by(GB, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = Desvio_Padrao/Tempo_Medio,
  )

# summary(tabelaDiscoLeituraCo)
# str(tabelaDiscoLeituraCo)

tabelaDiscoLeituraCo$GB <- factor(tabelaDiscoLeituraCo$GB, levels = c(unique(tabelaDiscoLeituraCo$GB)[order(unique(tabelaDiscoLeituraCo$GB))]))
### Gráfico em barras com o tempo médio de desempenho de cada ambiente + intervalo de confiança
discoLeituraCo <- ggplot(tabelaDiscoLeituraCo, aes(fill = Ambiente, x = GB, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(title="Leitura",x="GB", y = "Tempo (seg)")+
  ## scale_fill_manual(values=c("#756bb1","#fdae6b", "#31a354")) +
  scale_y_continuous(limits = c(0,400))+
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.3, 0.8))
## ggsave(filename = "../Graficos/Disco/07DiscoLeituraCo.png", width = 10, height = 7, dpi = 300) 


########################
## Escrita
########################
tabelaDiscoEscritaCo <- read.table('../Tabelas/TabelaDiscoEscritaCo.log',
                              header = T)

tabelaDiscoEscritaCo <- tabelaDiscoEscritaCo %>%
  group_by(GB, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = Desvio_Padrao/Tempo_Medio,
  )

tabelaDiscoEscritaCo$GB <- factor(tabelaDiscoEscritaCo$GB, levels = c(unique(tabelaDiscoEscritaCo$GB)[order(unique(tabelaDiscoEscritaCo$GB))]))
### Gráfico em barras com o tempo médio de desempenho de cada ambiente + intervalo de confiança
discoEscritaCo <- ggplot(tabelaDiscoEscritaCo, aes(fill = Ambiente, x = GB, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(title="Escrita",x="GB", y = "Tempo (seg)")+
  ## scale_fill_manual(values=c("#756bb1","#fdae6b", "#31a354")) +
  scale_y_continuous(limits = c(0,400))+
  scale_fill_grey() +
  theme_bw(base_size = 30) +
  theme(legend.position = c(0.3, 0.8))
## ggsave(filename = "../Graficos/Disco/10DiscoEscritaCo.png", width = 10, height = 7, dpi = 300) 

discoLeituraEscritaCo <- ggarrange(discoLeituraCo, discoEscritaCo, common.legend = TRUE, legend = "bottom")
ggsave(filename = "../Graficos/WCGA/11discoLeituraEscritaCo.png", width = 10, height = 7, dpi = 300) 







######################################
##
## Analise de NAMD
##
######################################

### Análise de desempenho do NAMD com HyperThreading
### Esta análise considera apenas os 3 ambientes
tabelaDadosHT <- read.table('../Tabelas/TabelaNAMDHT.log',
                            header = T)

tabelaDadosHT <- tabelaDadosHT %>%
  group_by(CPUs, Ambiente) %>%
  summarize(Nanosegundos = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = Desvio_Padrao/Nanosegundos,
  )

# summary(tabelaDados)
# str(tabelaDados)

tabelaDadosHT$CPUs <- factor(tabelaDadosHT$CPUs, levels = c(unique(tabelaDadosHT$CPUs)[order(unique(tabelaDadosHT$CPUs))]))

namdHT <- ggplot(tabelaDadosHT, aes(fill = Ambiente, x = CPUs, y = Nanosegundos, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Nanosegundos - Intervalo_Confianca, ymax=Nanosegundos+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Nanosegundos - Intervalo_Confianca, ymax=Nanosegundos+Intervalo_Confianca),
                position='dodge') +
  labs(title="Hyperthreading",x="CPUs", y = "Nanossegundos")+
  ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  scale_y_continuous(limits = c(0,2.6))+
  scale_fill_grey() +
  theme_bw(base_size = 25) +
  theme(legend.position = c(0.3, 0.8))
## ggsave(filename = "../Graficos/NAMD/01namdHT.png", width = 10, height = 7, dpi = 300) 


### Análise de desempenho do NAMD sem HyperThreading
### Esta análise considera apenas os 3 ambientes
tabelaDadosSemHT <- read.table('../Tabelas/TabelaNAMDsemHT.log',
                          header = T)

tabelaDadosSemHT <- tabelaDadosSemHT %>%
  group_by(CPUs, Ambiente) %>%
  summarize(Nanosegundos = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = Desvio_Padrao/Nanosegundos,
  )

# summary(tabelaDados)
# str(tabelaDados)

tabelaDadosSemHT$CPUs <- factor(tabelaDadosSemHT$CPUs, levels = c(unique(tabelaDadosSemHT$CPUs)[order(unique(tabelaDadosSemHT$CPUs))]))

namdSemHT <- ggplot(tabelaDadosSemHT, aes(fill = Ambiente, x = CPUs, y = Nanosegundos, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Nanosegundos - Intervalo_Confianca, ymax=Nanosegundos+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Nanosegundos - Intervalo_Confianca, ymax=Nanosegundos+Intervalo_Confianca),
                position='dodge') +
  labs(title="Sem Hyperthreading",x="CPUs", y = "Nanossegundos")+
  ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  scale_y_continuous(limits = c(0,2.6))+
  scale_fill_grey() +
  theme_bw(base_size = 25) +
  theme(legend.position = c(0.3, 0.8))
## ggsave(filename = "../Graficos/NAMD/04namdSemHT.png", width = 10, height = 7, dpi = 300) 

namdGrafico <- ggarrange(namdHT, namdSemHT, common.legend = TRUE, legend = "bottom")
ggsave(filename = "../Graficos/WCGA/12namdGrafico.png", width = 10, height = 7, dpi = 300) 




######################################
##
## Analise de Gamess
##
######################################

### Análise de desempenho do Gamess sem Hyperthreading
### Esta análise considera apenas os 3 ambientes
tabelaGamess <- read.table('../Tabelas/TabelasGamess.log',
                          header = T)

tabelaGamess <- tabelaGamess %>%
  group_by(CPUs, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = Desvio_Padrao/Tempo_Medio,
  )

# summary(tabelaDados)
# str(tabelaDados)

tabelaGamess$CPUs <- factor(tabelaGamess$CPUs, levels = c(unique(tabelaGamess$CPUs)[order(unique(tabelaGamess$CPUs))]))

gamessSemHT <- ggplot(tabelaGamess, aes(fill = Ambiente, x = CPUs, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(title="Gamess",x="CPUs", y = "Tempo (seg)")+
  ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  scale_fill_grey() +
  theme_bw(base_size = 25) +
  theme(legend.position = c(0.8, 0.8))
## ggsave(filename = "../Graficos/Gamess/01gamessSemHT.png", width = 10, height = 7, dpi = 300) 

### Análise de desempenho do ambiente KVM
### Esta análise considera apenas os 3 flavors do ambiente KVM 
tabelaCpuEx <- read.table('../Tabelas/TabelaCPUEx.log',
                          header = T)

tabelaKvm$CPUs <- factor(tabelaKvm$CPUs, levels = c(unique(tabelaKvm$CPUs)[order(unique(tabelaKvm$CPUs))]))

### Análise do ambiente comparado
### Este script considera uma comparação entre o ambiente Nativo, kvm_1 e xen_1
### Nesse caso, além do gráfico em barras para fazer a comparação de tempo também 
### é utilizado um gráfico para apresentar o coefiente de variação.
tabelaComparada <- tabelaCpuEx %>%
  filter(Ambiente == 'Xen_1' | Ambiente == 'kvm_1' | Ambiente == 'Nativo' )

### Cria uma tabela com as Medidas de Posição e Medidas de Variação
tabelaComparada <- tabelaComparada %>%
  group_by(CPUs, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = Desvio_Padrao/Tempo_Medio,
  )  

tabelaComparada$CPUs <- factor(tabelaComparada$CPUs, levels = c(unique(tabelaComparada$CPUs)[order(unique(tabelaComparada$CPUs))]))

### Gráfico com o tempo médio de desempenho de cada ambiente + intervalo de confiança
cpuComparaGamess <- ggplot(tabelaComparada, aes(fill = Ambiente, x = CPUs, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(title=" Ambientes Comparados",x="CPUs", y = "Tempo Médio (seg)") +
  ggtitle("CPUs Bench") +
  ylim(0, 115) +
  scale_fill_grey() +
  theme_bw(base_size = 25) +
  theme(legend.position = c(0.8, 0.75)) 

gamessGrafico <- ggarrange(gamessSemHT, cpuComparaGamess, common.legend = TRUE, legend = "bottom")
ggsave(filename = "../Graficos/WCGA/13gamessGrafico.png", width = 10, height = 7, dpi = 300) 






























