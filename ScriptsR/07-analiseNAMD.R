#####
# Script R para analise de desempenho do NAMD
# Todas as tabelas são modeladas e todos os gráficos são feitos com este script em R
# Basta executá-lo ... ;)
####
require(ggplot2)
require(ggthemes)
require(dplyr)
library(stringr)
library(readr)

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
  labs(title="Kvm x Nativo x Xen",x="CPUs", y = "Nanossegundos")+
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  theme_bw(base_size = 20)
ggsave(filename = "../Graficos/NAMD/01namdHT.png", width = 10, height = 7, dpi = 300) 

### Gráfico com Coeficiente de Variação dos ambientes 
### Esse gráfico tem o objetivo de apresentar a variação dos dados obtidos em porcentagem
namdCoeficienteHT <- ggplot(tabelaDadosHT, aes(fill = Ambiente, x = CPUs, y = Coeficiente_Variacao, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  ggtitle("Coefiente de Variação dos Resultados") +
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  theme_bw(base_size = 20) +
  scale_y_continuous(limits = c(0,0.25), labels = scales::percent) 
ggsave(filename = "../Graficos/NAMD/03namdCoeficienteHT.png", width = 10, height = 7, dpi = 300)

### BoxPlot
### Este gráfico tem o objetivo de verificar a variação dos dados obtidos por meio de quartis 
### ele indica a mediana e a variabilidade fora do quartil superior, inferior e outliers
tabelaComparadaHT <- read.table('../Tabelas/TabelaNAMDHT.log',
                                header = T)
tabelaComparadaHT$CPUs <- factor(tabelaComparadaHT$CPUs, levels = c(unique(tabelaComparadaHT$CPUs)[order(unique(tabelaComparadaHT$CPUs))]))

namdBoxHT <- ggplot(tabelaComparadaHT, aes(x=CPUs, y=Tempo, fill=Ambiente)) + 
  geom_boxplot(outlier.colour="red", outlier.shape=9, outlier.size=2) +
  labs(title="Variação do Tempo de Desempenho",x="CPUs", y = "Nanossegundos")+
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  theme_bw(base_size = 20)
ggsave(filename = "../Graficos/NAMD/02namdBoxHT.png", width = 10, height = 7, dpi = 300)



### Análise de desempenho do NAMD sem HyperThreading
### Esta análise considera apenas os 3 ambientes
tabelaDados <- read.table('../Tabelas/TabelaNAMDsemHT.log',
                          header = T)

tabelaDados <- tabelaDados %>%
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

tabelaDados$CPUs <- factor(tabelaDados$CPUs, levels = c(unique(tabelaDados$CPUs)[order(unique(tabelaDados$CPUs))]))

namdSemHT <- ggplot(tabelaDados, aes(fill = Ambiente, x = CPUs, y = Nanosegundos, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Nanosegundos - Intervalo_Confianca, ymax=Nanosegundos+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Nanosegundos - Intervalo_Confianca, ymax=Nanosegundos+Intervalo_Confianca),
                position='dodge') +
  labs(title="Kvm x Nativo x Xen",x="CPUs", y = "Nanossegundos")+
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  theme_bw(base_size = 20)
ggsave(filename = "../Graficos/NAMD/04namdSemHT.png", width = 10, height = 7, dpi = 300) 

### Gráfico com Coeficiente de Variação dos ambientes 
### Esse gráfico tem o objetivo de apresentar a variação dos dados obtidos em porcentagem
namdCoeficienteSemHT <- ggplot(tabelaDados, aes(fill = Ambiente, x = CPUs, y = Coeficiente_Variacao, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  ggtitle("Coefiente de Variação dos Resultados") +
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  theme_bw(base_size = 20) +
  scale_y_continuous(limits = c(0,0.25), labels = scales::percent) 
ggsave(filename = "../Graficos/NAMD/06namdCoeficienteSemHT.png", width = 10, height = 7, dpi = 300)

### BoxPlot
### Este gráfico tem o objetivo de verificar a variação dos dados obtidos por meio de quartis 
### ele indica a mediana e a variabilidade fora do quartil superior, inferior e outliers
tabelaComparada <- read.table('../Tabelas/TabelaNAMDsemHT.log',
                              header = T)
tabelaComparada$CPUs <- factor(tabelaComparada$CPUs, levels = c(unique(tabelaComparada$CPUs)[order(unique(tabelaComparada$CPUs))]))

namdBoxSemHT <- ggplot(tabelaComparada, aes(x=CPUs, y=Tempo, fill=Ambiente)) + 
  geom_boxplot(outlier.colour="red", outlier.shape=9, outlier.size=2) +
  labs(title="Variação do Tempo de Desempenho",x="CPUs", y = "Nanossegundos")+
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  theme_bw(base_size = 20)
ggsave(filename = "../Graficos/NAMD/05namdBoxSemHT.png", width = 10, height = 7, dpi = 300)











