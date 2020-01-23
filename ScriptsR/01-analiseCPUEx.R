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


### Análise de desempenho do ambiente KVM
### Esta análise considera apenas os 3 flavors do ambiente KVM 
tabelaDados <- read.table('../Tabelas/TabelaCPUEx.log',
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

cpuKvmEx <- ggplot(tabelaKvm, aes(fill = Ambiente, x = CPUs, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  scale_fill_manual(values=c("#756bb1", "#bcbddc", "#efedf5")) +
  labs(title="Desempenho do KVM",x="CPUs", y = "Tempo Médio (seg)")+
  ylim(0, 115) +
  theme_bw(base_size = 20) 
ggsave(filename = "../Graficos/CPU/01cpuKvmEx.png", width = 10, height = 7, dpi = 300) 

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

cpuXenEx <- ggplot(tabelaXen, aes(fill = Ambiente, x = CPUs, y = Tempo_Medio, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  geom_errorbar(aes(ymin=Tempo_Medio - Intervalo_Confianca, ymax=Tempo_Medio+Intervalo_Confianca),
                position='dodge') +
  labs(title="Desempenho do Xen",x="CPUs", y = "Tempo Médio (seg)") +
  scale_fill_manual(values=c("#31a354", "#a1d99b", "#e5f5e0")) +
  ylim(0, 115) +
  theme_bw(base_size = 20) 
ggsave(filename = "../Graficos/CPU/02cpuXenEx.png", width = 10, height = 7, dpi = 300) 


### Análise do ambiente comparado
### Este script considera uma comparação entre o ambiente Nativo, kvm_1 e xen_1
### Nesse caso, além do gráfico em barras para fazer a comparação de tempo também 
### é utilizado um gráfico para apresentar o coefiente de variação.
tabelaComparada <- tabelaDados %>%
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
  labs(title="Desempenho dos Ambientes Comparados",x="CPUs", y = "Tempo Médio (seg)") +
  ggtitle("Desempenho dos Ambientes Comparados") +
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  ylim(0, 115) +
  theme_bw(base_size = 20) 
ggsave(filename = "../Graficos/CPU/03cpuComparaEx.png", width = 10, height = 7, dpi = 300) 

### Gráfico com Coeficiente de Variação dos ambientes 
### Esse gráfico tem o objetivo de apresentar a variação dos dados obtidos em porcentagem
cpuCoeficienteEx <- ggplot(tabelaComparada, aes(fill = Ambiente, x = CPUs, y = Coeficiente_Variacao, group = Ambiente)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  ggtitle("Coefiente de Variação dos Resultados") +
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  theme_bw(base_size = 20) +
  scale_y_continuous(limits = c(0,0.2), labels = scales::percent) 
ggsave(filename = "../Graficos/CPU/05cpuCoeficienteEx.png", width = 10, height = 7, dpi = 300)


### BoxPlot
### Este gráfico tem o objetivo de verificar a variação dos dados obtidos por meio de quartis 
### ele indica a mediana e a variabilidade fora do quartil superior, inferior e outliers
tabelaComparada <- tabelaDados %>%
  filter(Ambiente == 'Xen_1' | Ambiente == 'kvm_1' | Ambiente == 'Nativo' )

tabelaComparada$CPUs <- factor(tabelaComparada$CPUs, levels = c(unique(tabelaComparada$CPUs)[order(unique(tabelaComparada$CPUs))]))

cpuBoxEx <- ggplot(tabelaComparada, aes(x=CPUs, y=Tempo, fill=Ambiente)) + 
  geom_boxplot(outlier.colour="red", outlier.shape=9, outlier.size=2) +
  labs(title="Variação do Tempo de Desempenho",x="CPUs", y = "Tempo (seg)")+
  scale_fill_manual(values=c("#756bb1", "#fdae6b", "#31a354")) +
  theme_bw(base_size = 20)
ggsave(filename = "../Graficos/CPU/04cpuBoxEx.png", width = 10, height = 7, dpi = 300)



### Cria a tabelaNativo com os tempo médios de desempenho 
### Cria campos com o valor de 5% e 10% de overhead
tabelaNativoExclusivo <- tabelaDados %>%
  filter(Ambiente == 'Nativo' )

tabelaNativoExclusivo <- tabelaNativoExclusivo %>%
  group_by(CPUs, Ambiente) %>%
  summarize(Tempo_Nativo = mean(Tempo),
            Tempo_Nativo5 = mean(Tempo)*1.05,
            Tempo_Nativo10 = mean(Tempo)*1.1,
  )
write_csv(tabelaNativoExclusivo, "../Tabelas/tabelaNativoExclusivo.csv")

### Cria a tabelaKvm_1Xen_1Ex com os tempos de desempenho 
tabelaKvm_1Xen_1Ex <- tabelaDados %>%
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

### Plot: bitmap de alcance de desempenho com o tempo Nativo 
cpuAlcanceEx <- ggplot(tabelaFreq, aes(fill = Ambiente, x = CPUs, y = Desempenho, group = Ambiente, colour = Ambiente)) +
  geom_line(position = 'dodge', stat = 'identity', size=2) +
  ggtitle("Alcance de Desempenho") +
  theme_bw(base_size = 20) +
  scale_color_manual(values=c("#756bb1", "#31a354")) +
  scale_y_continuous(labels = scales::percent)
ggsave(filename = "../Graficos/CPU/06cpuAlcanceEx.png", width = 10, height = 7, dpi = 300) 

### Plot: bitmap de alcance de desempenho com o tempo Nativo + 5% de overhead
cpuAlcanceEx5 <- ggplot(tabelaFreq, aes(fill = Ambiente, x = CPUs, y = Desempenho5, group = Ambiente, colour = Ambiente)) +
  geom_line(position = 'dodge', stat = 'identity', size=2) +
  ggtitle("Alcance de Desempenho com 5% de Overhead") +
  theme_bw(base_size = 20) +
  scale_color_manual(values=c("#756bb1", "#31a354")) +
  scale_y_continuous(labels = scales::percent)
ggsave(filename = "../Graficos/CPU/07cpuAlcanceEx5.png", width = 10, height = 7, dpi = 300) 

### Plot: bitmap de alcance de desempenho com o tempo Nativo + 10% de overhead
cpuAlcanceEx10 <- ggplot(tabelaFreq, aes(fill = Ambiente, x = CPUs, y = Desempenho10, group = Ambiente, colour = Ambiente)) +
  geom_line(position = 'dodge', stat = 'identity', size=2) +
  ggtitle("Alcance de Desempenho com 10% de Overhead") +
  theme_bw(base_size = 20) +
  scale_color_manual(values=c("#756bb1", "#31a354")) +
  scale_y_continuous(limits = c(0,1), labels = scales::percent) 
ggsave(filename = "../Graficos/CPU/08cpuAlcanceEx10.png", width = 10, height = 7, dpi = 300) 

