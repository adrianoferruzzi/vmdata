#####
# Script R para analise de desempenho de disco com uso Compartilhado
# Todas as tabelas são modeladas e todos os gráficos são feitos com este script em R
# Basta executá-lo ... ;)
####
require(ggplot2)
require(ggthemes)
require(dplyr)
library(stringr)
library(readr)

tabelaDados <- read.table('../Tabelas/TabelaDiscoLeituraCo.log',
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
discoLeituraCo <- ggplot(tabelaDados, aes(fill = Ambiente, x = GB, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  theme_bw(base_size = 20)
ggsave(filename = "../Graficos/Disco/07DiscoLeituraCo.png", width = 10, height = 7, dpi = 300) 

### Gráfico com Coeficiente de Variação dos ambientes 
### Esse gráfico tem o objetivo de apresentar a variação dos dados obtidos em porcentagem
coeficienteLeituraCo <- ggplot(tabelaDados, aes(fill = Ambiente, x = GB, y = Coeficiente_Variacao, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  labs(title="Coefiente de Variação dos Resultados",x="GB", y = "Coeficiente_Variação (%)")+
  theme_bw(base_size = 20) +
  scale_y_continuous(limits = c(0,1), labels = scales::percent) 
ggsave(filename = "../Graficos/Disco/09DiscoCoeficienteLeituraCo.png", width = 10, height = 7, dpi = 300)


### BoxPlot
### Este gráfico tem o objetivo de verificar a variação dos dados obtidos por meio de quartis 
### ele indica a mediana e a variabilidade fora do quartil superior, inferior e outliers
tabelaComparada <- read.table('../Tabelas/TabelaDiscoLeituraCo.log',
                              header = T)

tabelaComparada$GB <- factor(tabelaComparada$GB, levels = c(unique(tabelaComparada$GB)[order(unique(tabelaComparada$GB))]))

boxLeituraCo <- ggplot(tabelaComparada, aes(x=GB, y=Tempo, fill=Ambiente)) + 
  geom_boxplot(outlier.colour="red", outlier.shape=9, outlier.size=2) +
  labs(title="Variação do Tempo de Desempenho",x="GB", y = "Tempo (seg)")+
  theme_bw(base_size = 20)
ggsave(filename = "../Graficos/Disco/08DiscoBoxLeituraCo.png", width = 10, height = 7, dpi = 300)


########################
##
## Escrita
##
########################
tabelaEscritaCo <- read.table('../Tabelas/TabelaDiscoEscritaCo.log',
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
discoEscritaCo <- ggplot(tabelaEscritaCo, aes(fill = Ambiente, x = GB, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  theme_bw(base_size = 20)
ggsave(filename = "../Graficos/Disco/10DiscoEscritaCo.png", width = 10, height = 7, dpi = 300) 

### Gráfico com Coeficiente de Variação dos ambientes 
### Esse gráfico tem o objetivo de apresentar a variação dos dados obtidos em porcentagem
coeficienteEscritaCo <- ggplot(tabelaEscritaCo, aes(fill = Ambiente, x = GB, y = Coeficiente_Variacao, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  labs(title="Coefiente de Variação dos Resultados",x="GB", y = "Coeficiente_Variação (%)")+
  theme_bw(base_size = 20) +
  scale_y_continuous(limits = c(0,1), labels = scales::percent) 
ggsave(filename = "../Graficos/Disco/12DiscoCoeficienteEscritaCo.png", width = 10, height = 7, dpi = 300)


### BoxPlot
### Este gráfico tem o objetivo de verificar a variação dos dados obtidos por meio de quartis 
### ele indica a mediana e a variabilidade fora do quartil superior, inferior e outliers
tabelaComparadaEscritaCo <- read.table('../Tabelas/TabelaDiscoEscritaCo.log',
                                       header = T)

tabelaComparadaEscritaCo$GB <- factor(tabelaComparadaEscritaCo$GB, levels = c(unique(tabelaComparadaEscritaCo$GB)[order(unique(tabelaComparadaEscritaCo$GB))]))

boxEscritaCo <- ggplot(tabelaComparadaEscritaCo, aes(x=GB, y=Tempo, fill=Ambiente)) + 
  geom_boxplot(outlier.colour="red", outlier.shape=9, outlier.size=2) +
  labs(title="Variação do Tempo de Desempenho",x="GB", y = "Tempo (seg)")+
  theme_bw(base_size = 20)
ggsave(filename = "../Graficos/Disco/11DiscoBoxEscritaCo.png", width = 10, height = 7, dpi = 300)





