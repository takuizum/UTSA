# data reading and make it tidy

# Missing value coding
na_code <- c("", "NA", 66, 99, 999, "・")

# 衆議院データ ----
# 2009
dat_syu_2009 <- seijika_syu_link$`2009_syu` %>% read_csv(locale=locale(encoding="CP932"), #候補者名にJISが入ってる。
                                                      na = c("", "NA", 99, "・") # 99 = NA
                                                      )
names(dat_syu_2009)
dat_syu_2009$NAME # すごい，本当に候補者名全員の名前載ってる...
dat_syu_2009$Q12 # 
write_csv(tibble(names=names(dat_syu_2009)), "name_csv/2009_names.csv")

# 2012
dat_syu_2012 <- seijika_syu_link$`2012_syu` %>% read_csv(locale=locale(encoding="CP932"), na = na_code)
write_csv(tibble(names=names(dat_syu_2012)), "name_csv/2012_names.csv")

# 2014
dat_syu_2014 <- seijika_syu_link$`2014_syu` %>% read_csv(locale=locale(encoding="CP932"), na = na_code)
write_csv(tibble(names=names(dat_syu_2014)), "name_csv/2014_names.csv")

# 2017
dat_syu_2017 <- seijika_syu_link$`2017_syu` %>% read_csv(locale=locale(encoding="CP932"), na = na_code)
write_csv(tibble(names=names(dat_syu_2017)), "name_csv/2017_names.csv")

# read questionnaire data
qtable <- read_csv("tables/questionnaire_table.csv") # UTF-8で作成しているので，localeオプションは不要
qtable

qtable_key <- read_csv("tables/questionnaire_table_match.csv") # 同上
qtable_key_long <- qtable_key %>% 
  select(common_id, `2009_id`, `2012_id`, `2014_id`, `2017_id`) %>% 
  gather(key = year, value = sub_id, -common_id) %>% 
  mutate(year = as.numeric(str_extract(year, "[0-9][0-9][0-9][0-9]")))

# data merge
for(y in c(2009, 2012, 2014, 2017)){
  sub_key <- qtable_key_long %>% filter(year == y)
  sub_table <- get(paste("dat",y,sep="")) %>% select()
}



# 有権者データ ----
# 有権者データは質問項目がとても多いので，R上で項目番号を指定して取り出す形式をとる。

# 2009 & 2010
dat_ykn_2009_to_2010 <- yukensya_link$`2009_to_2010` %>% read_sav # SPSS file is read via haven pkg
write_csv(tibble(names=names(dat_ykn_2009_to_2010)), "name_csv/2009_to_2010_names.csv")
common_item_to_giin_2009 <- c("Q010700", "Q013801", "Q013802", "Q013803", "Q013804", "Q013805", "Q013806", "Q013807", "Q013808", "Q013809", "Q013810", 
                              "Q013811", "Q013812", "Q013813", "Q013814", "Q013815", "Q013816", "Q013817", "Q013818", "Q013819", "Q013820", "Q014001", 
                              "Q014002", "Q014003")
common_item_to_giin_2010 <- c("Q020601", "Q020602" , "Q020603", "Q022701", "Q022702", "Q022703", "Q022704", "Q022705", "Q022706", "Q022707", "Q022708", 
                              "Q022709", "Q022710", "Q022711", "Q022712", "Q022713", "Q022714", "Q022715", "Q022801","Q022802","Q022803")
dat_ykn_2009 <- dat_ykn_2009_to_2010 %>% select(ID, PREF, CITY, HORDIST, common_item_to_giin_2009)
dat_ykn_2010 <- dat_ykn_2009_to_2010 %>% select(ID, PREF, CITY, HORDIST, ANSWER2, common_item_to_giin_2010)

# 2012 & 2013
dat_ykn_2012_to_2013 <- yukensya_link$`2012_to_2013` %>% read_sav(encoding = "CP932")
write_csv(tibble(names = names(dat_ykn_2012_to_2013)), "name_csv/2012_to_2013_names.csv")
common_item_to_giin_2012 <- c("Q010601", "Q010602", "Q010603", "Q013001", "Q013002", "Q013003", "Q013004", "Q013005", "Q013006", "Q013007", "Q013008", 
                              "Q013009", "Q013010", "Q013011", "Q013012", "Q013013", "Q013014", "Q013015", "Q013016", "Q013017", "Q013018", "Q013019", 
                              "Q013020", "Q013021", "Q013022", "Q013023", "Q013024", "Q013025", "Q013026", "Q013101", "Q013102", "Q013103", "Q013104", 
                              "Q013105", "Q013106", "Q013107", "Q013108", "Q013109")
common_item_to_giin_2013 <- c("Q020501", "Q020502", "Q020503", "Q021201", "Q021202", "Q021203", "Q021204", "Q021205", "Q021206", "Q021207", "Q021208", 
                              "Q021209", "Q021210", "Q021211", "Q021212", "Q021301", "Q021302", "Q021303", "Q021304", "Q021305")
dat_ykn_2012 <- dat_ykn_2012_to_2013 %>% select(ID, PREFNAME, CITY, PREFEC, HRDIST, common_item_to_giin_2012)
dat_ykn_2013 <- dat_ykn_2012_to_2013 %>% select(ID, PREFNAME, CITY, PREFEC, HRDIST, RESPONSE, common_item_to_giin_2012)

# 2014 & 2016
dat_ykn_2014_to_2016 <- yukensya_link$`2014_to_2016` %>% read_csv(locale=locale(encoding = "CP932"), na = na_code)
write_csv(tibble(names = names(dat_ykn_2014_to_2016)), "name_csv/2014_to_2016_names.csv")
