  #####
  # Script R para analise de desempenho do Lammps
  # Todas as tabelas são modeladas e todos os gráficos são feitos com este script em R
  # Basta executá-lo ... ;)
  ####
  require(ggplot2)
  require(ggthemes)
  require(dplyr)
  library(stringr)
  library(readr)
  
  ###################################
  ###################################
  ###
  ### Análise com Hyperthreading
  ###
  ##################################
  
  ### Análise de desempenho do Lammps com HyperThreading
  ### Esta análise considera apenas os 3 ambientes
  tabelaDados <- read.table('../Tabelas/lammpsHTTotal.log',
                              header = T)
  
  tabelaDados <- tabelaDados %>%
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
  
  tabelaDados$CPUs <- factor(tabelaDados$CPUs, levels = c(unique(tabelaDados$CPUs)[order(unique(tabelaDados$CPUs))]))
  
  progHT <- ggplot(tabelaDados, aes(fill = Ambiente, x = CPUs, y = Tempo_Medio, group = Ambiente)) +
    geom_bar(position = 'dodge', stat = 'identity') +
    geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                  position='dodge') +
    geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                  position='dodge') +
    labs(x="CPUs", y = "Tempo (seg)")+
    ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
    theme_bw(base_size = 30) +
    scale_fill_grey() +
    theme(legend.position = c(0.9, 0.8))
  ggsave(filename = "../Graficos/Lammps/01lammpsHT.png", width = 10, height = 7, dpi = 300) 
  
  ### Gráfico com Coeficiente de Variação dos ambientes 
  ### Esse gráfico tem o objetivo de apresentar a variação dos dados obtidos em porcentagem
  progCoeficienteHT <- ggplot(tabelaDados, aes(fill = Ambiente, x = CPUs, y = Coeficiente_Variacao, group = Ambiente)) +
    geom_bar(position = 'dodge', stat = 'identity') +
    # ggtitle("Coefiente de Variação dos Resultados") +
    theme_bw(base_size = 30) +
    ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
    scale_y_continuous(limits = c(0,0.25), labels = scales::percent) +
    scale_fill_grey() +
    theme(legend.position = c(0.2, 0.8))
  ggsave(filename = "../Graficos/Lammps/03lammpsCoeficienteHT.png", width = 10, height = 7, dpi = 300)
  
  ### BoxPlot
  ### Este gráfico tem o objetivo de verificar a variação dos dados obtidos por meio de quartis 
  ### ele indica a mediana e a variabilidade fora do quartil superior, inferior e outliers
  tabelaComparada <- read.table('../Tabelas/lammpsHTTotal.log',
                                header = T)
  tabelaComparada$CPUs <- factor(tabelaComparada$CPUs, levels = c(unique(tabelaComparada$CPUs)[order(unique(tabelaComparada$CPUs))]))
  
  progBoxHT <- ggplot(tabelaComparada, aes(x=CPUs, y=Tempo, fill=Ambiente)) + 
    geom_boxplot(outlier.colour="red", outlier.shape=9, outlier.size=2) +
    labs(x="CPUs", y = "Tempo (seg)")+
    ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
    theme_bw(base_size = 30) +
    scale_fill_grey() +
    theme(legend.position = c(0.9, 0.8))
  ggsave(filename = "../Graficos/Lammps/02lammpsBoxHT.png", width = 10, height = 7, dpi = 300)
  
  
  
  
  
  
  
  ###################################
  ###################################
  ###
  ### Análise sem Hyperthreading
  ###
  ##################################
  
  ### Análise de desempenho do Lammps sem HyperThreading
  ### Esta análise considera apenas os 3 ambientes
  tabelaDados2 <- read.table('../Tabelas/lammpssemHTTotal.log',
                            header = T)
  
  tabelaDados2 <- tabelaDados2 %>%
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
  
  tabelaDados2$CPUs <- factor(tabelaDados2$CPUs, levels = c(unique(tabelaDados2$CPUs)[order(unique(tabelaDados2$CPUs))]))
  
  progsemHT <- ggplot(tabelaDados2, aes(fill = Ambiente, x = CPUs, y = Tempo_Medio, group = Ambiente)) +
    geom_bar(position = 'dodge', stat = 'identity') +
    geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                  position='dodge') +
    geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                  position='dodge') +
    labs(x="CPUs", y = "Tempo (seg)")+
    ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
    theme_bw(base_size = 30) +
    scale_fill_grey() +
    theme(legend.position = c(0.9, 0.8))
  ggsave(filename = "../Graficos/Lammps/04lammpssemHT.png", width = 10, height = 7, dpi = 300) 
  
  ### Gráfico com Coeficiente de Variação dos ambientes 
  ### Esse gráfico tem o objetivo de apresentar a variação dos dados obtidos em porcentagem
  progCoeficienteSemHT <- ggplot(tabelaDados2, aes(fill = Ambiente, x = CPUs, y = Coeficiente_Variacao, group = Ambiente)) +
    geom_bar(position = 'dodge', stat = 'identity') +
    # ggtitle("Coefiente de Variação dos Resultados") +
    theme_bw(base_size = 30) +
    ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
    scale_y_continuous(limits = c(0,0.25), labels = scales::percent) +
    scale_fill_grey() +
    theme(legend.position = c(0.2, 0.8))
  ggsave(filename = "../Graficos/Lammps/06lammpsCoeficientesemHT.png", width = 10, height = 7, dpi = 300)
  
  ### BoxPlot
  ### Este gráfico tem o objetivo de verificar a variação dos dados obtidos por meio de quartis 
  ### ele indica a mediana e a variabilidade fora do quartil superior, inferior e outliers
  tabelaComparada2 <- read.table('../Tabelas/lammpssemHTTotal.log',
                                header = T)
  tabelaComparada2$CPUs <- factor(tabelaComparada2$CPUs, levels = c(unique(tabelaComparada2$CPUs)[order(unique(tabelaComparada2$CPUs))]))
  
  progBoxsemHT <- ggplot(tabelaComparada2, aes(x=CPUs, y=Tempo, fill=Ambiente)) + 
    geom_boxplot(outlier.colour="red", outlier.shape=9, outlier.size=2) +
    labs(x="CPUs", y = "Tempo (seg)")+
    ## scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
    theme_bw(base_size = 30) +
    scale_fill_grey() +
    theme(legend.position = c(0.9, 0.8))
  ggsave(filename = "../Graficos/Lammps/05lammpsBoxsemHT.png", width = 10, height = 7, dpi = 300)
  
  
  
  
  
  
  
