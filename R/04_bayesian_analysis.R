# stan script
library(rstan)
library(shinystan)
options(mc.cores = parallel::detectCores())

list_2009_3 <- list(Y = mat_after_2009_rev %>% as_tibble %>% select(-remove_names, -remove_names_fa) %>% map_df(function(x){x[is.na(x)] <- 999;as.integer(x)}) %>% as.matrix, 
                    N = nrow(mat_after_2009_rev), 
                    J = mat_after_2009_rev %>% as_tibble %>% select(-remove_names, -remove_names_fa) %>% ncol,
                    K = mat_after_2009_rev %>% as_tibble %>% select(-remove_names, -remove_names_fa) %>% map(max, na.rm = T) %>% unlist ,# %>% `names<-`(NULL), 
                    group = dat_after_2009_rev$SURVEY %>% factor(levels = faclev) %>% as.numeric,
                    base = 1,
                    nonbase = dat_after_2009_rev$SURVEY %>% factor(levels = faclev) %>% as.numeric %>% unique %>% .[. != 1] %>% sort
                    )  %>% map_if(is.vector, as.integer)
list_2009_3 %>% map(class)


# まずはカテゴリ境界の制約が強いモデルから。
grm_mg <- stan_model("stan_model/grm_mg.stan") # stan_model("~takuizum/local_documents/R/rstan/rstan/grm_mg.stan")# 
fit_2009_3 <- vb(data = list_2009_3, object = grm_mg) # eta = 1
fit_2009_3 <- fit_after_2009_vb
# かなりのイテレーションで発散してしまっているようなので，事前分布が不適切な可能性がある。

fit_2009_3@model_pars
fit_2009_3 %>% rstan::extract() %$% a %>% apply(2, mean)
fit_2009_3 %>% rstan::extract() %$% d %>% apply(c(2,3), mean)
fit_2009_3 %>% rstan::extract() %$% mu %>% apply(2, mean)
fit_2009_3 %>% rstan::extract() %$% sigma %>% apply(2, mean)
fit_2009_3 %>% rstan::extract() %$% theta %>% apply(2, mean) %>% hist
fit_2009_3 %>% rstan::extract() %$% mu_d %>% apply(2, mean) # No data
fit_2009_3 %>% rstan::extract() %$% sigma_d %>% apply(2, mean)

# カテゴリ困難度の事前分布の超パラを，平均のみ経験的に推定するように変更したモデルを実行
grm_mg2 <- stan_model("stan_model/grm_mg_2.stan") # stan_model("~takuizum/local_documents/R/rstan/rstan/grm_mg.stan")# 
fit_2009_4 <- vb(data = list_2009_3, object = grm_mg2) # eta = 0.1, adapt_engaged = FALSE
# きちんと収束するし，計算も速い。
fit_2009_4@model_pars
fit_2009_4 %>% rstan::extract() %$% a %>% apply(2, mean)
fit_2009_4 %>% rstan::extract() %$% d %>% apply(c(2,3), mean)
fit_2009_4 %>% rstan::extract() %$% mu %>% apply(2, mean)
fit_2009_4 %>% rstan::extract() %$% sigma %>% apply(2, mean)
fit_2009_4 %>% rstan::extract() %$% theta %>% apply(2, mean) %>% hist
fit_2009_4 %>% rstan::extract() %$% mu_d %>% apply(c(2,3), mean) # No data


# MCMC
# まずは小標本サイズから

# sampling data to be observed all vategory at least 1 time.
flag <- FALSE
t <- 0
while(!flag){
  t <- t + 1
  testdat <- dat_after_2009_rev %>% 
    group_by(SURVEY) %>% 
    sample_n(size = 100) %>% 
    select(SURVEY, starts_with("q")) %>% 
    ungroup
  flag <- testdat %>% select(-SURVEY) %>% 
    map(unique) %>% map(function(x){ length(x) == 6}) %>% unlist %>%  all
  cat(t, "TIME SAMPLING...\r")
}

list_test   <- list(Y = testdat %>% select(-SURVEY, -remove_names, -remove_names_fa) %>% map_df(function(x){x[is.na(x)] <- 999;as.integer(x)}) %>% as.matrix, 
                    N = nrow(testdat), 
                    J = testdat %>% select(-SURVEY, -remove_names, -remove_names_fa) %>% ncol,
                    K = testdat %>% select(-SURVEY, -remove_names, -remove_names_fa) %>% map(max, na.rm = T) %>% unlist ,# %>% `names<-`(NULL), 
                    group = testdat$SURVEY %>% factor(levels = faclev) %>% as.numeric,
                    base = 1,
                    nonbase = testdat$SURVEY %>% factor(levels = faclev) %>% as.numeric %>% unique %>% .[. != 1] %>% sort
)  %>% map_if(is.vector, as.integer)

vb_test <- vb(data = list_test, object = grm_mg2) # eta = 1
mcmc_test <- sampling(data = list_test, object = grm_mg2, verbose = TRUE) 
# 最初の10％のサンプリングに非常に時間がかかるが，その後は比較的スムーズ
launch_shinystan(mcmc_test)
# 実行結果を確認すると，なんだか収束していないパラメタが一部見受けられる。とくにmu_d。
# なにやらn_leapfrogが大きすぎることが，サンプリングに時間がかかる原因かもしれない。
