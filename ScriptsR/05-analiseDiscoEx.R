#####
# Script R para analise de desempenho de disco com uso exclusivo
# Todas as tabelas são modeladas e todos os gráficos são feitos com este script em R
# Basta executá-lo ... ;)
####
require(ggplot2)
require(ggthemes)
require(dplyr)
library(stringr)
library(readr)

tabelaDados <- read.table('../Tabelas/TabelaDiscoLeituraEx.log',
                          header = T)

tabelaDados <- tabelaDados %>%
  group_by(GB, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())),
            Coeficiente_Variacao = Desvio_Padrao/Tempo_Medio,
  )

# summary(tabelaDados)
# str(tabelaDados)

tabelaDados$GB <- factor(tabelaDados$GB, levels = c(unique(tabelaDados$GB)[order(unique(tabelaDados$GB))]))
### Gráfico em barras com o tempo médio de desempenho de cada ambiente + intervalo de confiança
discoLeituraEx <- ggplot(tabelaDados, aes(fill = Ambiente, x = GB, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(title="Kvm x Nativo x Xen",x="GB", y = "Tempo (seg)")+
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  theme_bw(base_size = 20)
ggsave(filename = "../Graficos/Disco/01DiscoLeituraEx.png", width = 10, height = 7, dpi = 300) 

### Gráfico com Coeficiente de Variação dos ambientes 
### Esse gráfico tem o objetivo de apresentar a variação dos dados obtidos em porcentagem
coeficienteLeituraEx <- ggplot(tabelaDados, aes(fill = Ambiente, x = GB, y = Coeficiente_Variacao, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  labs(title="Coefiente de Variação dos Resultados",x="GB", y = "Coeficiente_Variação (%)")+
  theme_bw(base_size = 20) +
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  scale_y_continuous(limits = c(0,0.1), labels = scales::percent) 
ggsave(filename = "../Graficos/Disco/03DiscoCoeficienteLeituraEx.png", width = 10, height = 7, dpi = 300)


### BoxPlot
### Este gráfico tem o objetivo de verificar a variação dos dados obtidos por meio de quartis 
### ele indica a mediana e a variabilidade fora do quartil superior, inferior e outliers
tabelaComparada <- read.table('../Tabelas/TabelaDiscoLeituraEx.log',
                              header = T)

tabelaComparada$GB <- factor(tabelaComparada$GB, levels = c(unique(tabelaComparada$GB)[order(unique(tabelaComparada$GB))]))

boxLeituraExclusiva <- ggplot(tabelaComparada, aes(x=GB, y=Tempo, fill=Ambiente)) + 
  geom_boxplot(outlier.colour="red", outlier.shape=9, outlier.size=2) +
  labs(title="Variação do Tempo de Desempenho",x="GB", y = "Tempo (seg)")+
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  theme_bw(base_size = 20)
ggsave(filename = "../Graficos/Disco/02DiscoBoxLeituraEx.png", width = 10, height = 7, dpi = 300)


########################
##
## Escrita
##
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
  labs(title="Kvm x Nativo x Xen",x="GB", y = "Tempo (seg)")+
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  theme_bw(base_size = 20)
ggsave(filename = "../Graficos/Disco/04DiscoEscritaEx.png", width = 10, height = 7, dpi = 300) 

### Gráfico com Coeficiente de Variação dos ambientes 
### Esse gráfico tem o objetivo de apresentar a variação dos dados obtidos em porcentagem
coeficienteEscritaEx <- ggplot(tabelaEscritaEx, aes(fill = Ambiente, x = GB, y = Coeficiente_Variacao, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  labs(title="Coefiente de Variação dos Resultados",x="GB", y = "Coeficiente_Variação (%)")+
  theme_bw(base_size = 20) +
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  scale_y_continuous(limits = c(0,0.2), labels = scales::percent) 
ggsave(filename = "../Graficos/Disco/06DiscoCoeficienteEscritaEx.png", width = 10, height = 7, dpi = 300)


### BoxPlot
### Este gráfico tem o objetivo de verificar a variação dos dados obtidos por meio de quartis 
### ele indica a mediana e a variabilidade fora do quartil superior, inferior e outliers
tabelaComparadaEscritaEx <- read.table('../Tabelas/TabelaDiscoEscritaEx.log',
                                       header = T)

tabelaComparadaEscritaEx$GB <- factor(tabelaComparadaEscritaEx$GB, levels = c(unique(tabelaComparadaEscritaEx$GB)[order(unique(tabelaComparadaEscritaEx$GB))]))

boxEscritaEx <- ggplot(tabelaComparadaEscritaEx, aes(x=GB, y=Tempo, fill=Ambiente)) + 
  geom_boxplot(outlier.colour="red", outlier.shape=9, outlier.size=2) +
  labs(title="Variação do Tempo de Desempenho",x="GB", y = "Tempo (seg)")+
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  theme_bw(base_size = 20)
ggsave(filename = "../Graficos/Disco/05DiscoBoxEscritaEx.png", width = 10, height = 7, dpi = 300)





