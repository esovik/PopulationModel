# Population model

## Make everything probability based. # Do year by year

MinRep <- 15
MaxRep <- 35
Children <- 0.105
StartingGeneration <- 1900
StartTime <- 2001
MaxTime <- 2100

Population <- expand.grid(TimeStep = 2000:MaxTime,
                          Generation = StartingGeneration:MaxTime,
                          Population = 0,
                          Children = 0)

options(stringsAsFactors = FALSE)
StartingPopulation <- read.table("StartingPopulation.csv", header = TRUE, sep = ",", dec = ".")

Population$Population[Population$TimeStep==2000&Population$Generation %in% StartingGeneration:2000] <- rev(StartingPopulation$Population)
Population <- Population[Population$Generation<=Population$TimeStep,]

TimeSteps <- StartTime:MaxTime

for(i in TimeSteps){
  for(k in Population$Generation[Population$TimeStep == i-1&Population$Population > 0]){
      Population$Population[Population$Generation == k&Population$TimeStep == i] <- Population$Population[Population$Generation == k&Population$TimeStep == i-1] - (Population$Population[Population$Generation == k&Population$TimeStep == i-1] * (MortalityRate(i - k)))
     if((i - k) %in% seq(MinRep,MaxRep)){
       Population$Population[Population$Generation == i&Population$TimeStep==i] <- Population$Population[Population$Generation == i&Population$TimeStep==i] + (Population$Population[Population$Generation == k&Population$TimeStep == i] * (Children/2))
       Population$Children[Population$Generation == k&Population$TimeStep==i] <- Population$Children[Population$Generation == k&Population$TimeStep==i - 1] + (Population$Population[Population$Generation == k&Population$TimeStep == i] * (Children/2))
     }
   }
}


ggplot(Population, aes(x = TimeStep, y = Population, colour = as.factor(Generation))) +
  geom_line(show.legend = FALSE) +
  stat_summary(fun.y=mean, geom="line", colour="black") +
  scale_y_continuous(expand = c(0,0)) +
  scale_x_continuous(expand = c(0,0)) +
  theme_classic()

require(dplyr)

data.frame(Population %>% group_by(TimeStep) %>% summarise(pop = sum(Population))) -> sumPopulation

require(ggplot2)
require(scales)

ggplot(sumPopulation, aes(x = TimeStep, y = pop)) +
  geom_line() +
  geom_hline(yintercept = 7256490011, colour = "red") + ## 2015 world population estimate
  scale_y_continuous("Population (billions)", labels=billion, expand = c(0,0)) +
    scale_x_continuous("Year", expand = c(0,0)) +
    theme_classic(base_size = 20)