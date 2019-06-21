# FIFA


load("data/fafit.Rdata")
# データが大きすぎるので，.Rdataに記録しないように削除
rm(list = c("fa1fit_after_2009", "fa2fit_after_2009", "fa3fit_after_2009", "fa4fit_after_2009")) 

anova(fa1fit_after_2009, fa2fit_after_2009)
anova(fa2fit_after_2009, fa3fit_after_2009)
anova(fa3fit_after_2009, fa4fit_after_2009)

# F = 1
fa1fit_after_2009 %>% extract.mirt(what = "F")
fa1fit_after_2009 %>% extract.mirt(what = "h2")
fa1fit_after_2009 %>% coef()

# F = 2
fa2fit_after_2009 %>% extract.mirt(what = "F")
fa2fit_after_2009 %>% extract.mirt(what = "h2")
