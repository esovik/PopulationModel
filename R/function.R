billion <- function(n){
  return(n/10^9)
}

MortalityRate <- function(Age){
  return(1 - exp(-0.003*exp((Age - 35)/10)))
}
