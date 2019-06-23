# full MCMC
library(tidyverse);library(rstan)
load("data/data.Rdata")

# detect the number of using cores
options(mc.cores = 10)
rstan_options(auto_write = TRUE)

# data set 
list_2009_3 <- list(Y = mat_after_2009_rev %>% as_tibble %>% select(-remove_names, -remove_names_fa) %>% map_df(function(x){x[is.na(x)] <- 999;as.integer(x)}) %>% as.matrix, 
                    N = nrow(mat_after_2009_rev), 
                    J = mat_after_2009_rev %>% as_tibble %>% select(-remove_names, -remove_names_fa) %>% ncol,
                    K = mat_after_2009_rev %>% as_tibble %>% select(-remove_names, -remove_names_fa) %>% map(max, na.rm = T) %>% unlist ,# %>% `names<-`(NULL), 
                    group = dat_after_2009_rev$SURVEY %>% factor(levels = faclev) %>% as.numeric,
                    base = 1,
                    nonbase = dat_after_2009_rev$SURVEY %>% factor(levels = faclev) %>% as.numeric %>% unique %>% .[. != 1] %>% sort
)  %>% map_if(is.vector, as.integer)

# MCMC
grm_mg2 <- stan_model("stan_model/grm_mg_2.stan") # stan_model("~takuizum/local_documents/R/rstan/rstan/grm_mg.stan")# 

cat("VB NOW....\n")
# fit_after_2009_vb <- vb(data = list_2009_3, object = grm_mg2)

cat("MCMC NOW....\n")
# inits <- list("a" = fit_after_2009_vb %>% rstan::extract() %$% a %>% apply(2, mean),
#               "d" = fit_after_2009_vb %>% rstan::extract() %$% d %>% apply(c(2,3), mean) %>% matrix(ncol = 4, nrow = 53),
#               "theta" = fit_after_2009_vb %>% rstan::extract() %$% theta %>% apply(2, mean),
#               "mu_d" = matrix(1, ncol = 5, nrow = 53),
#               "mu_free" = rep(0, 9),
#               "sigma_free" =  rep(1, 9))
fit_after_2009_mcmc <- sampling(data = list_2009_3, object = grm_mg2, seed = 0204)#, init = list(inits, inits, inits, inits))
save(c("fit_after_2009_mcmc", "fit_after_2009_vb"), file = "data/mcmc1.Rdata")

