# FULL INFORMATION FACTOR ANALYSIS (for job panel)
library(tidyverse)
library(mirt)

load(".Rdata")

cat("FACTOR 1 \n")
fa1fit_after_2009 <- mat_after_2009_rev %>% 
  mirt(1, 
       method = "MCEM",
       GenRandomPars = TRUE,
       technical = list(removeEmptyRows = TRUE, NCYCLES = 200))

cat("FACTOR 2 \n")
fa2fit_after_2009 <- mat_after_2009_rev %>% 
  mirt(2, 
       method = "MCEM",
       GenRandomPars = TRUE,
       technical = list(removeEmptyRows = TRUE, NCYCLES = 300))

cat("FACTOR 3 \n")
fa3fit_after_2009 <- mat_after_2009_rev %>% 
  mirt(3, 
       method = "MCEM",
       GenRandomPars = TRUE,
       technical = list(removeEmptyRows = TRUE, NCYCLES = 500))

cat("FACTOR 4 \n")
fa4fit_after_2009 <- mat_after_2009_rev %>% 
  mirt(4, 
       method = "MCEM",
       GenRandomPars = TRUE,
       technical = list(removeEmptyRows = TRUE, NCYCLES = 700))

cat("FACTOR 5 \n")
fa5fit_after_2009 <- mat_after_2009_rev %>% 
  mirt(5, 
       method = "MCEM",
       GenRandomPars = TRUE,
       technical = list(removeEmptyRows = TRUE, NCYCLES = 900))

cat("FACTOR 6 \n")
fa6fit_after_2009 <- mat_after_2009_rev %>% 
  mirt(6, 
       method = "MCEM",
       GenRandomPars = TRUE,
       technical = list(removeEmptyRows = TRUE, NCYCLES = 1100))



save(list = c("fa1fit_after_2009", "fa2fit_after_2009", "fa3fit_after_2009", "fa4fit_after_2009", 
              "fa5fit_after_2009", "fa6fit_after_2009"), file = "data/fafit.Rdata")