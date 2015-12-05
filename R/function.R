billion <- function(n){
  return(n/10^9)
}

MortalityRate <- function(Age){
  return(1 - exp(-0.003*exp((Age - 35)/10)))
}

FecundityRate <- function(Age){
  if(Age<15){return(0)}
  if(Age<20&&Age>=15){return(0.23*((Age-15)/4))}
  if(Age>=20&&Age<=33){return(0.23)}
  if(Age>33&&Age<=45){return(0.23*((45-Age)/12))}
  if(Age>45){return(0)}
}