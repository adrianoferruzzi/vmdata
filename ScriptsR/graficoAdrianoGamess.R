require(ggplot2)
require(ggthemes)
require(dplyr)

tabelaDados <- read.table('~/Desktop/TabelasGamess.log',
                          header = T)

tabelaDados <- tabelaDados %>%
  group_by(CPUs, Ambiente) %>%
  summarize(Tempo_Medio = mean(Tempo),
            Tempo_Minimo = min(Tempo),
            Tempo_Maximo = max(Tempo),
            Desvio_Padrao = sd(Tempo),
            Intervalo_Confianca = (2.042*sd(Tempo))/(sqrt(n())))

# summary(tabelaDados)
# str(tabelaDados)

tabelaDados$CPUs <- factor(tabelaDados$CPUs, levels = c(unique(tabelaDados$CPUs)[order(unique(tabelaDados$CPUs))]))

ggplot(tabelaDados, aes(fill = Ambiente, x = CPUs, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  theme_bw(base_size = 20) 

