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
fit_ykn_2009 <- mat_ykn_2009 %>% as_tibble %>% mirt(mirt.model("F1 = 1-23"), technical = list(removeEmptyRows = T))

summary(fit_ykn_2009)
coef(fit_ykn_2009, IRTpars = T)