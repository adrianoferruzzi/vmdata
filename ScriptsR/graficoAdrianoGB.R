require(ggplot2)
require(ggthemes)
require(dplyr)

tabelaDados <- read.table('~/Desktop//Imagens/Tabelas/TabelaMemLeituraEx.log',
                          header = T)

tabelaDados <- tabelaDados %>%
  group_by(GB, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())))

# summary(tabelaDados)
# str(tabelaDados)

tabelaDados$GB <- factor(tabelaDados$GB, levels = c(unique(tabelaDados$GB)[order(unique(tabelaDados$GB))]))

ggplot(tabelaDados, aes(fill = Ambiente, x = GB, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  theme_bw(base_size = 20)

