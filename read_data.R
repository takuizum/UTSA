# data reading and make it tidy

na_code <- c("", "NA", 66, 99, 999, "・")

dat_syu_2009 <- seijika_syu_link$`2009_syu` %>% read_csv(locale=locale(encoding="CP932"), #候補者名にJISが入ってる。
                                                      na = c("", "NA", 99, "・") # 99 = NA
                                                      )
names(dat_syu_2009)
dat_syu_2009$NAME # すごい，本当に候補者名全員の名前載ってる...
dat_syu_2009$Q12 # 
write_csv(tibble(names=names(dat_syu_2009)), "name_csv/2009_names.csv")

dat_syu_2012 <- seijika_syu_link$`2012_syu` %>% read_csv(locale=locale(encoding="CP932"), na = na_code)
write_csv(tibble(names=names(dat_syu_2012)), "name_csv/2012_names.csv")

dat_syu_2014 <- seijika_syu_link$`2014_syu` %>% read_csv(locale=locale(encoding="CP932"), na = na_code)
write_csv(tibble(names=names(dat_syu_2014)), "name_csv/2014_names.csv")

dat_syu_2017 <- seijika_syu_link$`2017_syu` %>% read_csv(locale=locale(encoding="CP932"), na = na_code)
write_csv(tibble(names=names(dat_syu_2017)), "name_csv/2017_names.csv")


# analize questionnaire
qtable <- read_csv("tables/questionnaire_table.csv") # UTF-8で作成しているので，localeオプションは不要
qtable

qtable_key <- read_csv("tables/questionnaire_table_match.csv")
qtable_key_long <- qtable_key %>% 
  select(common_id, `2009_id`, `2012_id`, `2014_id`, `2017_id`) %>% 
  gather(key = year, value = sub_id, -common_id) %>% 
  mutate(year = as.numeric(str_extract(year, "[0-9][0-9][0-9][0-9]")))

# data merge
for(y in c(2009, 2012, 2014, 2017)){
  sub_key <- qtable_key_long %>% filter(year == y)
  sub_table <- get(paste("dat",y,sep="")) %>% select()
}



# 有権者データ

dat_ykn_2009_to_2010 <- yukensya_link$`2009_to_2010` %>% read_sav # SPSS file is read via haven pkg
write_csv(tibble(names=names(dat_ykn_2009_to_2010)), "name_csv/2009_to_2010_names.csv")
common_item_to_giin_2009 <- c("Q010700", "Q013801", "Q013802", "Q013803", "Q013804", "Q013805", "Q013806", "Q013807", "Q013808", "Q013809", "Q013810", "Q013811", "Q013812", "Q013813", "Q013814", "Q013815", "Q013816", "Q013817", "Q013818", "Q013819", "Q013820", "Q014001", "Q014002", "Q014003")
common_item_to_giin_2010 <- c("Q020601", "Q020602" , "Q020603", "Q022701", "Q022702", "Q022703", "Q022704", "Q022705", "Q022706", "Q022707", "Q022708", "Q022709", "Q022710", "Q022711", "Q022712", "Q022713", "Q022714", "Q022715", "Q022801","Q022802","Q022803")
dat_ykn_2009 <- dat_ykn_2009_to_2010 %>% select(ID, PREF, CITY, HORDIST, common_item_to_giin_2009)
dat_ykn_2010 <- dat_ykn_2009_to_2010 %>% select(ID, PREF, CITY, HORDIST, common_item_to_giin_2010)


dat_ykn_2012_to_2013 <- yukensya_link$`2012_to_2013` %>% read_sav 
write_csv(tibble(names=names(dat_ykn_2012_to_2013)), "name_csv/2012_to_2013_names.csv")


dat_ykn_2014_to_2016 <- yukensya_link$`2014_to_2016` %>% read_csv(locale=locale(encoding="CP932"), na = na_code)
write_csv(tibble(names=names(dat_ykn_2014_to_2016)), "name_csv/2014_to_2016_names.csv")
