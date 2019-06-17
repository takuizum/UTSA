# multiple group IRT (for job panel)
library(tidyverse)
library(mirt)

load(".Rdata")

const <- c("free_var", "free_means", colnames(mat_after_2009_rev))
faclev <- dat_after_2009_rev$SURVEY %>% unique %>% .[c(5:10, 1:4)]
mgmodel <- mirt.model("F1 = 1-85
                      PRIOR = (1-85, a1, lnorm,  0.0 , 2)
                      PRIOR = (1-85, d1, norm,  -1.0 , 3)
                      PRIOR = (1-85, d2, norm,  -0.5 , 3)
                      PRIOR = (1-85, d3, norm,   0.5 , 3)
                      PRIOR = (1-85, d4, norm,   1.0 , 3)
                      ")

fit_mg_after_2009 <- mat_after_2009_rev %>% # .[colSums(., na.rm = T) != 0, ] %>% 
  multipleGroup(model = mgmodel, 
                group = dat_after_2009_rev$SURVEY %>% factor(levels = faclev), 
                invariance = const,
                optimizer = "BFGS", # "NR",
                dentype = "EH",
                GenRandomPars = TRUE, # 初期値の計算で、識別力に負の値が生成されるらしい
                accelarete = "Ramsy",
                technical = list(removeEmptyRows = TRUE, 
                                 NCYCLES = 500,
                                 set.seed = 0204))

save(file = "data/fit_mg_after_2009.Rdata", list = "fit_mg_after_2009")