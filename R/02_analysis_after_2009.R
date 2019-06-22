# マージした行列を使って項目分析
names(dat_after_2009)

# histgram----
hist_after_2009 <- dat_after_2009 %>% 
  gather(key = item, value = response, -ID, -NAME, -PARTY, -SURVEY, -LENGTH) %>% 
  ggplot(aes(x = response, group = item, fill = item, colour = response))+
  geom_histogram(binwidth = 1)+
  facet_wrap(item~., nrow = 4)+
  theme(legend.position = "none")

dat_after_2009 %>% select(-ID, -NAME, -PARTY, -SURVEY, -LENGTH) %>% map(table)
dat_after_2009 %>% select(-ID, -NAME, -PARTY, -SURVEY, -LENGTH) %>% map(unique) %>% map(length) %>% `==`(6) %>% all # 欠測値を含めて全てのカテゴリが6

# item analysis----
nrow(dat_after_2009)
tracedat_after_2009 <- dat_after_2009 %>% select(starts_with("q"), LENGTH) %>%  # extract 5 categories response data
  mutate(total = (rowSums(., na.rm = T) - LENGTH)/(LENGTH*5)*100) %>%  # 相対的な得点にするため，0～100の間に抑える
  filter(total > 0) %>% 
  select(-LENGTH) %>% 
  mutate(level = cut2(x = total, g = 7)) %>%  # split by cut points
  gather(key = item, value = response, -level, -total) %>% 
  group_by(item, level) 
# basic statistics----
tracedat_after_2009 %>% 
  summarise(mean = mean(response, na.rm = T), sd = sd(response, na.rm = T))
# trace plot----
traceplot_after_2009 <- tracedat_after_2009 %>% 
  filter(!is.na(response)) %>%  # na omit
  count(response, name = "count") %>%
  mutate(rate = count/sum(count)) %>% 
  ggplot(aes(x = level, y = rate, colour = as.character(response)))+
  geom_text(aes(label = response))+
  geom_line(aes(group = response))+
  facet_wrap(.~item, ncol = 5)+
  theme(legend.position = "none", axis.text.x = element_text(angle = -20))# themeをいじって，もう少し整形する必要がある。
ggsave(plot = traceplot_after_2009, "graphics/traceplot_after_2009.png", height = 20, width = 10)
# item-test correlation----
itcor_after_2009 <- dat_after_2009 %>% select(starts_with("q")) %>%  # extract 5 categories response data
  mutate(total = rowSums(., na.rm = T)) %>% map_dbl(.f = cor ,y = .$total, use = "p")

# IT相関が負の項目は全て逆転処理をかける
itcor_after_2009_rev <- itcor_after_2009
dat_after_2009_rev <- dat_after_2009
reverse_item <- NULL
t <- 0
while(!all(itcor_after_2009_rev > 0)){
  t <- t + 1
  cat(t, "time reverse coding.\n")
  for(i in itcor_after_2009_rev){
    if(i < 0){
      itemid <- names(itcor_after_2009_rev[itcor_after_2009_rev == i])
      reverse_item <- c(reverse_item, itemid)
      resp <- dat_after_2009_rev %>% select(itemid) %>% pluck(itemid)
      dat_after_2009_rev <- dat_after_2009_rev %>% mutate(!!sym(itemid) := as.double(c(5:1)[resp]))
    }
  }
  itcor_after_2009_rev <- dat_after_2009_rev %>% select(starts_with("q")) %>%  # extract 5 categories response data
    mutate(total = rowSums(., na.rm = T)) %>% map_dbl(.f = cor ,y = .$total, use = "p")
}

# cbind(itcor_after_2009, itcor_after_2009_rev)

# dimensionality check----
mat_after_2009_rev <- dat_after_2009_rev %>% select(starts_with("q")) %>% as.matrix
mat_after_2009_rev %>% colSums(na.rm = T)
# Dosen't work
mat_after_2009_rev %>% cor(use = "p") %>% eigen %$% values %>% plot(xlab = "component", ylab = "eigen value", main = "scree plot") # 4因子くらいとれそう
# 全ての項目で完全につながってはいないため，冊子ごとにスクリープロットを描画する。
png("graphics/screeplot.png", width = 720)
par(mfrow = c(3, 4))
for(s in survey_type){
  sub_mat <- mat_after_2009_rev[dat_after_2009$SURVEY == s, ] %>% .[ , colSums(.,na.rm = T) != 0]
  sub_mat %>% cor(use = "p") %>% eigen %$% values %>% plot(type = "b",
                                                           xlab = "component", ylab = "eigen value", 
                                                           main = paste("scree plot (", s, sep = "", ")"))
}
dev.off()

# core setting
mirtCluster(4)
#mirtCluster(remove = T)
# FA----
dat <- mat_after_2009_rev %>% as_tibble
fafit_after_2009_rev <- mat_after_2009_rev %>% fa(nfactors = 4, missing = TRUE)
fafit <- dat %>% map_df(function(x){x[is.na(x)] <- mean(x, na.rm = T);x})  %>% fa(nfactors = 4)
fafit$communality %>% sort %>% plot # comunality
fafit$communalities

write_csv(dat, path = "data/fadata.csv")
dat %>% map_df(function(x){x[is.na(x)] <- mean(x, na.rm = T);x}) %>% cor %>% eigen %$% values %>% plot(type = "b",
                                                                                                      xlab = "component", ylab = "eigen value", 
                                                                                                      main = "scree plot")
cor(dat) %>% eigen %$% values %>% plot(type = "b",
                                       xlab = "component", ylab = "eigen value", 
                                       main = "scree plot")

# FIFA
fafit_after_2009 <- mat_after_2009_rev %>% 
  mirt(4, method, technical = list(removeEmptyRows = TRUE))
load("data/fit_after_2009.Rdata")
coef(fafit_after_2009)
floadings <- extract.mirt(fafit_after_2009, "F")

# MIRT (FULL INFORMATION FACTOR ANALYSIS)----
ncol(mat_after_2009_rev) # of items

# UNIDIM IRT with Single Group----
sgmodel <- mirt.model("F1 = 1-85
                      PRIOR = (1-85, a1, lnorm,  0.0 , 2)
                      PRIOR = (1-85, d1, norm,  -1.0 , 3)
                      PRIOR = (1-85, d2, norm,  -0.5 , 3)
                      PRIOR = (1-85, d3, norm,   0.5 , 3)
                      PRIOR = (1-85, d4, norm,   1.0 , 3)
                      ")
fit_after_2009 <- mat_after_2009_rev %>% 
  mirt(sgmodel, technical = list(removeEmptyRows = TRUE), dentype = "EHW", GenRandomPars = TRUE)
save(file = "data/fit_after_2009.Rdata", list = "fit_after_2009")

extract.mirt(fit_after_2009, "time")
extract.mirt(fit_after_2009, "AIC")

fit_after_2009
summary(fit_after_2009)
pars1 <- coef(fit_after_2009, IRTpars = T) # negative discrimi paramter in some items.

# UNIDIM IRT with Multiple Group----
const <- c("free_var", "free_means", colnames(mat_after_2009_rev))
faclev <- dat_after_2009_rev$SURVEY %>% unique %>% .[c(5:10, 1:4)]
mgmodel <- mirt.model("F1 = 1-85
                      PRIOR = (1-85, a1, lnorm,  0.0 , 2)
                      PRIOR = (1-85, d1, norm,  -1.0 , 3)
                      PRIOR = (1-85, d2, norm,  -0.5 , 3)
                      PRIOR = (1-85, d3, norm,   0.5 , 3)
                      PRIOR = (1-85, d4, norm,   1.0 , 3)
                      ")
set.seed(0204)
fit_mg_after_2009 <- mat_after_2009_rev %>% # .[colSums(., na.rm = T) != 0, ] %>% 
  multipleGroup(model = mgmodel, 
                group = dat_after_2009_rev$SURVEY %>% factor(levels = faclev), 
                invariance = const,
                optimizer = "BFGS", # "NR",
                dentype = "EH",
                GenRandomPars = TRUE, # 初期値の計算で、識別力に負の値が生成されるらしい
                accelarete = "Ramsy",
                technical = list(removeEmptyRows = TRUE, 
                                 NCYCLES = 1000,
                                 set.seed = 0204))
load("data/fit_mg_after_2009.Rdata")
fit_mg_after_2009
plot(fit_mg_after_2009, type = "trace")
plot(fit_mg_after_2009, type = "empiricalhist", npts = 30)
# LL history
# だいたい100回～400回くらいで完全におちきっている。
extract.mirt(fit_mg_after_2009, what = "LLhistory") %>% `*`(-1) %>% plot(type = "l", ylim = c(508400, 509000))
extract.mirt(fit_mg_after_2009, what = "AIC")
pars2 <- coef(fit_mg_after_2009, IRTpars = T)
# model comparison
extract.mirt(fit_after_2009, "AIC")
extract.mirt(fit_mg_after_2009, what = "AIC")
list(sg = fit_after_2009, mg = fit_mg_after_2009) %>% map_df(extract.mirt, what = "AIC")
# population distribution
pars2 %>% map_df(~.x$GroupPars) %>% t %>% `colnames<-`(c("mean", "var")) %>% as.data.frame %>% rownames_to_column(var = "survey") %>% mutate(sd = sqrt(var))

# 識別力が低い項目を削除して再推定。-----
item_names <- pars2$ykn_2009 %>% names %>% unlist
remove_names <- numeric()
for(j in 1:length(item_names)) if(pars2$ykn_2009[[j]] %>% .[1] < 0.1) remove_names <- c(remove_names, item_names[[j]])
remove_names <- remove_names[-length(remove_names)]

mgmodel2 <- mirt.model("F1 = 1-73
                      PRIOR = (1-73, a1, lnorm,  0.0 , 2)
                      PRIOR = (1-73, d1, norm,  -1.0 , 3)
                      PRIOR = (1-73, d2, norm,  -0.5 , 3)
                      PRIOR = (1-73, d3, norm,   0.5 , 3)
                      PRIOR = (1-73, d4, norm,   1.0 , 3)
                      ")

fit_mg_after_2009_2 <- mat_after_2009_rev %>% as_tibble %>% select(-remove_names) %>% as.matrix %>% 
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

load("data/fit_mg_after_2009_2.Rdata")

# population distribution pars
coef(fit_mg_after_2009_2) %>% 
  map_df(~.x$GroupPars) %>% t %>% 
  `colnames<-`(c("mean", "var")) %>% 
  as.data.frame %>% rownames_to_column(var = "survey") %>% 
  mutate(sd = sqrt(var))


# population distribution
plt <- plot(fit_mg_after_2009_2, type = "empiricalhist", npts = 21, pch = 20, lwd = 3)
tbl <- tibble(prob = plt$panel.args[[1]]$y,
              theta = plt$panel.args[[1]]$x, 
              group = plt$panel.args.common$groups)
tbl %>% ggplot(aes(x = theta, y = prob, group = group, colour = group))+
  geom_line()+
  facet_wrap(group~., ncol = 6)
ggsave(filename = "graphics/mg_after_2009.png", width = 10, height = 7)


# 項目削除したデータでもう一度因子分析----
# FA----
fafit2 <- mat_after_2009_rev %>% as_tibble %>% select(-remove_names) %>% 
  map_df(function(x){x[is.na(x)] <- mean(x, na.rm = T);x})  %>% fa(nfactors = 4)
mat_after_2009_rev %>% as_tibble %>% select(-remove_names) %>% map_df(function(x){x[is.na(x)] <- mean(x, na.rm = T);x}) %>% cor %>% eigen %$% values %>% plot(type = "b",
                                                                                                       xlab = "component", ylab = "eigen value", 
                                                                                                       main = "scree plot")
fafit2$communalities %>% sort %>% plot
remove_names_fa <- names(fafit2$communalities)[fafit2$communalities < 0.1]

# 尺度化対象となっている項目を確認----

# IRTの識別力基準で除外した項目
non_scaling_item <- qtable_key %>% filter(common_id %in% remove_names) %>% select(質問項目１, 質問項目２, 回答欄, 朝日項目名)
View(non_scaling_item)
# 因子分析の共通性が0.1以下という基準で除外したもの
non_scaling_item2 <- qtable_key %>% filter(common_id %in% remove_names_fa) %>% select(質問項目１, 質問項目２, 回答欄, 朝日項目名)
View(non_scaling_item2)

as.list(remove_names_fa) %>% map(~pluck(pars2$ykn_2009, .x))
# 全体的に識別力が低く，困難度もかなり広がってしまっている項目がいくつか見受けられる。

# さらに項目を削除して再推定。----
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

load("data/fit_mg_after_2009_3.Rdata")

# population distribution pars
coef(fit_mg_after_2009_3) %>% 
  map_df(~.x$GroupPars) %>% t %>% 
  `colnames<-`(c("mean", "var")) %>% 
  as.data.frame %>% rownames_to_column(var = "survey") %>% 
  mutate(sd = sqrt(var))


# population distribution
plt <- plot(fit_mg_after_2009_3, type = "empiricalhist", npts = 21, pch = 20, lwd = 3)
tbl <- tibble(prob = plt$panel.args[[1]]$y,
              theta = plt$panel.args[[1]]$x, 
              group = plt$panel.args.common$groups)
tbl %>% ggplot(aes(x = theta, y = prob, group = group, colour = group))+
  geom_line()+
  facet_wrap(group~., ncol = 6)
ggsave(filename = "graphics/mg_after_2009_2.png", width = 10, height = 7)
