library(tidyverse)
library(mirt)
library(psych)

load(".Rdata")

fafit2 <- mat_after_2009_rev %>% as_tibble %>% select(-remove_names) %>% 
  map_df(function(x){x[is.na(x)] <- mean(x, na.rm = T);x})  %>% fa(nfactors = 4)
remove_names_fa <- names(fafit2$communalities)[fafit2$communalities < 0.1]

const <- c("free_var", "free_means", colnames(mat_after_2009_rev))
faclev <- dat_after_2009_rev$SURVEY %>% unique %>% .[c(5:10, 1:4)]
mgmodel3 <- mirt.model("F1 = 1-53
                      PRIOR = (1-53, a1, lnorm,  0.0 , 2)
                      PRIOR = (1-53, d1, norm,  -1.0 , 3)
                      PRIOR = (1-53, d2, norm,  -0.5 , 3)
                      PRIOR = (1-53, d3, norm,   0.5 , 3)
                      PRIOR = (1-53, d4, norm,   1.0 , 3)
                      ")
fit_mg_after_2009_3 <- mat_after_2009_rev %>% as_tibble %>% select(-remove_names, -remove_names_fa) %>% as.matrix %>% 
  multipleGroup(model = mgmodel3, 
                group = dat_after_2009_rev$SURVEY %>% factor(levels = faclev), 
                invariance = const,
                optimizer = "BFGS", #
                dentype = "EH",
                GenRandomPars = TRUE, # 初期値の計算で、識別力に負の値が生成されるらしい
                accelarete = "Ramsy",
                technical = list(removeEmptyRows = TRUE, 
                                 NCYCLES = 1000,
                                 set.seed = 0204))

save(file = "data/fit_mg_after_2009_3.Rdata", list = "fit_mg_after_2009_3")