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

# 質問項目の一覧表
qtable <- read_csv("tables/questionnaire_table.csv") # UTF-8で作成しているので，localeオプションは不要
qtable

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
                              "Q013105", "Q013106", "Q013107", "Q013108", "Q013109","Q013300")
common_item_to_giin_2013 <- c("Q020501", "Q020502", "Q020503", "Q021201", "Q021202", "Q021203", "Q021204", "Q021205", "Q021206", "Q021207", "Q021208", 
                              "Q021209", "Q021210", "Q021211", "Q021212", "Q021301", "Q021302", "Q021303", "Q021304", "Q021305")
dat_ykn_2012 <- dat_ykn_2012_to_2013 %>% select(ID, PREFNAME, CITY, PREFEC, HRDIST, common_item_to_giin_2012)
dat_ykn_2013 <- dat_ykn_2012_to_2013 %>% select(ID, PREFNAME, CITY, PREFEC, HRDIST, RESPONSE, common_item_to_giin_2013)

# 2014 & 2016
dat_ykn_2014_to_2016 <- yukensya_link$`2014_to_2016` %>% read_csv(locale=locale(encoding = "CP932"), na = na_code)
write_csv(tibble(names = names(dat_ykn_2014_to_2016)), "name_csv/2014_to_2016_names.csv")
common_item_to_giin_2014 <- c("W1Q5_1","W1Q5_2","W1Q5_3","W1Q16_1","W1Q16_2","W1Q16_3","W1Q16_4","W1Q16_5","W1Q16_6","W1Q16_7","W1Q16_8","W1Q16_9",
                              "W1Q16_10","W1Q16_11","W1Q16_12","W1Q16_13","W1Q16_14","W1Q16_15","W1Q16_16","W1Q16_17","W1Q17_1","W1Q17_2","W1Q17_3",
                              "W1Q17_4","W1Q17_5","W1Q17_6","W1Q17_7","W1Q17_8","W1Q17_9","W1Q17_10")
common_item_to_giin_2016 <- c("W2Q7_1","W2Q7_2","W2Q7_3","W2Q19_1","W2Q19_2","W2Q19_3","W2Q19_4","W2Q19_5","W2Q19_6","W2Q19_7","W2Q19_8","W2Q19_9",
                              "W2Q19_10","W2Q19_11","W2Q19_12","W2Q20_1","W2Q20_2","W2Q20_3","W2Q20_4","W2Q20_5","W2Q20_6","W2Q21","W2Q22_1")
dat_ykn_2014 <- dat_ykn_2014_to_2016 %>% select(ID, PREFNAME, CITY, PREFEC, HRDIST, common_item_to_giin_2014)
dat_ykn_2016 <- dat_ykn_2014_to_2016 %>% select(ID, PREFNAME, CITY, PREFEC, HRDIST, RESPONSE, common_item_to_giin_2016)


# 分冊データをマージ
# read questionnaire data
qtable_key <- read_csv("tables/questionnaire_table_match.csv") # 同上
qtable_key <- read_csv("tables/qtable_match_for_merge.csv") # 5件法以外の項目削除版

survey_type <- c("syu_2009", "syu_2012",	"syu_2014",	"syu_2017",	"ykn_2009",	"ykn_2010",	"ykn_2012",	"ykn_2013",	"ykn_2014",	"ykn_2016")
qtable_key_long <- qtable_key %>% 
  select(common_id, survey_type) %>% 
  gather(key = survey, value = sub_id, -common_id)

# data merge
# 手順: まずは各テストの項目ラベルを共通IDに差し替え，テスト版ID列を追加する。
for(s in survey_type){
  sub_dat <- get(paste("dat", s, sep = "_"))
  matched_id <- qtable_key_long %>% filter(survey == s, !is.na(sub_id))
  new_name <- sub_dat %>% names %>% as.list %>% map_chr(function(chr){ # なせかif_elseコードだと走ってくれない...
    if(chr %in% matched_id$sub_id)
      matched_id$common_id[matched_id$sub_id == chr]
    else
      chr
    })
  names(sub_dat) <- new_name
  if(str_detect(s, "syu"))
    sub_dat %<>% select(ID , NAME, PARTY, str_subset(names(.), "q")) %>% add_column(SURVEY = s, .after = "PARTY") %>% add_column(LENGTH = ncol(.)-4, .after = "SURVEY")
  else
    sub_dat %<>% select(ID, str_subset(names(.), "q")) %>% add_column(NAME = NA, PARTY = 999, SURVEY = s, .after = "ID") %>% add_column(LENGTH = ncol(.)-4, .after = "SURVEY") %>% mutate(NAME = as.character(NAME))
  
  if(s == "syu_2009")
    dat_after_2009 <- sub_dat
  else
    dat_after_2009 <- full_join(dat_after_2009, sub_dat)
}
rm(sub_dat)

# chack the data
dat_after_2009 %>% str
dat_after_2009 %>% names
dat_after_2009 %>% group_by(SURVEY) %>% summarise(LEN = unique(LENGTH))
