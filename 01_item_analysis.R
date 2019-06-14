library(psych)
library(Hmisc)
library(mirt)

# single year analysis
names(dat_ykn_2009)
View(dat_ykn_2009)
dat_ykn_2009 %>% map(class)

# histgram
dat_ykn_2009 %>% 
  select(-Q010700) %>% 
  gather(key = item, value = response, -ID, -PREF, -CITY, -HORDIST) %>% 
  ggplot(aes(x = response, group = item, fill = item))+
  geom_histogram(binwidth = 1)+
  facet_wrap(item~., nrow = 2)+
  theme(legend.position = "bottom")

dat_ykn_2009 %>% 
  select(-Q010700, -ID, -PREF, -CITY, -HORDIST) %>% map(table)

# item analysis
nrow(dat_ykn_2009)
tracedat_ykn_2009 <- dat_ykn_2009 %>% select(starts_with("Q"), -Q010700) %>%  # extract 5 categories response data
  mutate(total = rowSums(., na.rm = T)) %>% 
  filter(total > 0) %>% 
  mutate(level = cut2(x = total, g = 7)) %>%  # split by cut points
  gather(key = item, value = response, -level, -total) %>% 
  group_by(item, level) 
# basic statistics
tracedat_ykn_2009 %>% summarise(mean = mean(response, na.rm = T), sd = sd(response, na.rm = T))
# trace plot
traceplot_ykn_2009 <- tracedat_ykn_2009 %>% 
  count(response) %>% 
  mutate(rate = n/nrow(dat_ykn_2010)) %>% 
  ggplot(aes(x = level, y = rate, colour = as.character(response)))+
  geom_text(aes(label = response))+
  geom_line(aes(group = response))+
  facet_wrap(.~item, nrow = 5) # themeをいじって，もう少し整形する必要がある。
# item-test correlation
itcor_ykn_2009 <- dat_ykn_2009 %>% select(starts_with("Q"), -Q010700) %>%  # extract 5 categories response data
  mutate(total = rowSums(., na.rm = T)) %>% map_dbl(.f = cor ,y = .$total, use = "p")

# dimensionality check
mat_ykn_2009 <- dat_ykn_2009 %>% select(starts_with("Q"), -Q010700) %>% as.matrix
mat_ykn_2009 %>% cor(use = "p") %>% eigen %$% values %>% plot(xlab = "component", ylab = "eigen value", main = "scree plot") # 4因子くらいとれそう

# FA
mat_ykn_2009 %>% fa(nfactors = 4)
ncol(mat_ykn_2009)
fit_ykn_2009 <- mat_ykn_2009 %>% .[colSums(., na.rm = T) != 0, ] %>% mirt(mirt.model("F1 = 1-23"), technical = list(removeEmptyRows = T))

summary(fit_ykn_2009)
coef(fit_ykn_2009, IRTpars = T)


# マージした行列を使って項目分析

names(dat_after_2009)

# histgram
hist_after_2009 <- dat_after_2009 %>% 
  gather(key = item, value = response, -ID, -NAME, -PARTY, -SURVEY, -LENGTH) %>% 
  ggplot(aes(x = response, group = item, fill = item, colour = response))+
  geom_histogram(binwidth = 1)+
  facet_wrap(item~., nrow = 4)+
  theme(legend.position = "none")

dat_after_2009 %>% select(-ID, -NAME, -PARTY, -SURVEY, -LENGTH) %>% map(table)
dat_after_2009 %>% select(-ID, -NAME, -PARTY, -SURVEY, -LENGTH) %>% map(unique) %>% map(length) %>% `==`(6) %>% all # 欠測値を含めて全てのカテゴリが6

# item analysis
nrow(dat_after_2009)
tracedat_after_2009 <- dat_after_2009 %>% select(starts_with("q"), LENGTH) %>%  # extract 5 categories response data
  mutate(total = (rowSums(., na.rm = T) - LENGTH)/(LENGTH*5)*100) %>%  # 相対的な得点にするため，0～100の間に抑える
  filter(total > 0) %>% 
  select(-LENGTH) %>% 
  mutate(level = cut2(x = total, g = 7)) %>%  # split by cut points
  gather(key = item, value = response, -level, -total) %>% 
  group_by(item, level) 
# basic statistics
tracedat_after_2009 %>% summarise(mean = mean(response, na.rm = T), sd = sd(response, na.rm = T))
# trace plot
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
# item-test correlation
itcor_after_2009 <- dat_after_2009 %>% select(starts_with("q")) %>%  # extract 5 categories response data
  mutate(total = rowSums(., na.rm = T)) %>% map_dbl(.f = cor ,y = .$total, use = "p")

# IT相関が負の項目は全て逆転処理をかける
itcor_after_2009_rev <- itcor_after_2009
dat_after_2009_rev <- dat_after_2009
t <- 0
while(!all(itcor_after_2009_rev > 0)){
  t <- t + 1
  cat(t, "time reverse coding.\n")
  for(i in itcor_after_2009_rev){
    if(i < 0){
      itemid <- names(itcor_after_2009_rev[itcor_after_2009_rev == i])
      resp <- dat_after_2009_rev %>% select(itemid) %>% pluck(itemid)
      dat_after_2009_rev <- dat_after_2009_rev %>% mutate(!!sym(itemid) := as.double(c(5:1)[resp]))
    }
  }
  itcor_after_2009_rev <- dat_after_2009_rev %>% select(starts_with("q")) %>%  # extract 5 categories response data
    mutate(total = rowSums(., na.rm = T)) %>% map_dbl(.f = cor ,y = .$total, use = "p")
}

cbind(itcor_after_2009, itcor_after_2009_rev)

# dimensionality check
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


# FA

fafit_after_2009_rev <- mat_after_2009_rev %>% fa(nfactors = 4)
mat_after_2009_rev %>% factanal(factors = 4, na.action = mean)
ncol(mat_ykn_2009)
fit_ykn_2009 <- mat_ykn_2009 %>% .[colSums(., na.rm = T) != 0, ] %>% mirt(mirt.model("F1 = 1-23"), technical = list(removeEmptyRows = T))

summary(fit_ykn_2009)
coef(fit_ykn_2009, IRTpars = T)