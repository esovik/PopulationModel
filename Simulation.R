# Population model
source("function.R")
## Make everything probability based. # Do year by year

StartingGeneration <- 1900
StartTime <- 2001
MaxTime <- 2050

Population <- expand.grid(TimeStep = 2000:MaxTime,
                          Generation = StartingGeneration:MaxTime,
                          Population = 0,
                          Children = 0,
                          Scenario = c(1,2,3,4))

options(stringsAsFactors = FALSE)
StartingPopulation <- read.table("StartingPopulation.csv", header = TRUE, sep = ",", dec = ".")

Population$Population[Population$TimeStep==2000&Population$Generation %in% StartingGeneration:2000] <- rev(StartingPopulation$Population)
Population <- Population[Population$Generation<=Population$TimeStep,]

Population$NumChildren[Population$Scenario == 1] <- 2
Population$NumChildren[Population$Scenario == 2] <- 2
Population$NumChildren[Population$Scenario == 3] <- 3
Population$NumChildren[Population$Scenario == 4] <- 3

Population$StartReproduction[Population$Scenario == 1] <- 20
Population$StopReproduction[Population$Scenario == 1] <- 30

Population$StartReproduction[Population$Scenario == 2] <- 30
Population$StopReproduction[Population$Scenario == 2] <- 40

Population$StartReproduction[Population$Scenario == 3] <- 20
Population$StopReproduction[Population$Scenario == 3] <- 30

Population$StartReproduction[Population$Scenario == 4] <- 30
Population$StopReproduction[Population$Scenario == 4] <- 40

TimeSteps <- StartTime:MaxTime

for(s in unique(Population$Scenario)){
  StartReproduction <- Population$StartReproduction[Population$Scenario == s][1]
  StopReproduction <- Population$StopReproduction[Population$Scenario == s][1]
  NumChildren <- Population$NumChildren[Population$Scenario == s][1]
  ChildRate <- NumChildren/(StopReproduction-StartReproduction)
  for(i in TimeSteps){
    for(k in Population$Generation[Population$TimeStep == i-1&Population$Population > 0&Population$Scenario == s]){
      Population$Population[Population$Generation == k&Population$TimeStep == i&Population$Scenario == s] <- Population$Population[Population$Generation == k&Population$TimeStep == i-1&Population$Scenario == s] - (Population$Population[Population$Generation == k&Population$TimeStep == i-1&Population$Scenario == s] * (MortalityRate(i - k)))
      if((i - k) %in% seq(StartReproduction,StopReproduction)){
        Population$Population[Population$Generation == i&Population$TimeStep==i&Population$Scenario == s] <- Population$Population[Population$Generation == i&Population$TimeStep==i&Population$Scenario == s] + (Population$Population[Population$Generation == k&Population$TimeStep == i&Population$Scenario == s] * (ChildRate/2))
        Population$Children[Population$Generation == k&Population$TimeStep==i&Population$Scenario == s] <- Population$Children[Population$Generation == k&Population$TimeStep==i - 1&Population$Scenario == s] + (Population$Population[Population$Generation == k&Population$TimeStep == i&Population$Scenario == s] * (ChildRate/2))
      }
    }
  }
}

#ggplot(Population, aes(x = TimeStep, y = Population, colour = as.factor(Generation))) +
#  geom_line(show.legend = FALSE) +
#  stat_summary(fun.y=mean, geom="line", colour="black") +
#  scale_y_continuous(expand = c(0,0)) +
#  scale_x_continuous(expand = c(0,0)) +
#  theme_classic()

require(dplyr)

data.frame(Population %>% group_by(TimeStep,Scenario) %>% summarise(pop = sum(Population))) -> sumPopulation

require(ggplot2)
require(scales)

WorldPopulation <- read.table("WorldPopulation.csv", header = T, sep = ",")

ggplot(sumPopulation, aes(x = TimeStep, y = pop)) +
  geom_line(aes(linetype = "solid", colour = as.factor(Scenario)), show.legend = FALSE) +
  geom_line(data = WorldPopulation, aes(y = Population, x = Year, linetype = "dashed")) + ## 2015 world population estimate
  scale_linetype_identity() +
  scale_color_manual(values = c("red","blue","black","green")) +
  scale_y_continuous("Population (billions)", labels=billion, expand = c(0,0)) +
  scale_x_continuous("Year", expand = c(0,0)) +
  theme_classic(base_size = 20)