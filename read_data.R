# data reading and make it tidy

# ----------------------
# 2009年政治家調査（衆議院）
# codebook
# ID: 通し番号
# oldID: 旧バージョンの通し番号（いらないかも？）
# NAME: 候補者名
# YOMI: よみがな
# RESPONSE: 回答状況 1なら有効回答あり，2なら有効回答なし
# PREFEC: 候補者の選挙区都道府県？1～47が北海道から沖縄まで割り振られている。対応させるベクトルがあると良いが，今は不要
# DISTINCT: 都道府県内の選挙区番号，非該当は"・"で処理されている。
# INCUMB: 1:新人, 2:元職（現職の誤字？）, 3:前職
# TERM: 当選回数0~16
# PARTY: 1. 自民党， 2.民主党，3. 公明党，4. 共産党，5. 社民党，6. 国民新党，7. みんなの党，
#        8. 新党日本，9. 新党大地，10. 改革クラブ，11. 諸派，12. 無所属
# SEX: 1. MAN, 2. WOMAN
# AGE: 
# RESULT: 選挙結果　1. 小選挙区で当選，2. 比例区単独で当選，3. 比例区で復活当選，4. 落選
# 
# 2012年政治家調査（衆議院）
# 主な変更点
# PREFEC: 比例区単独候補者は66
# DISTINCT: 比例区単独候補者は66
# PR: 比例区ダミー 0. 選挙区候補, 1. 比例区単独候補
# PRBLOCK: 51. 北海道 52. 東北 53. 北関東 54. 南関東 55. 東京 56. 北陸・信越  57. 東海 58. 近畿 59. 中国 60. 四国 61. 九州 66. 非該当（小選挙区単独候補）
# PARTY: 公認政党　1. 民主党　2. 自民党　3. 未来の党　4. 公明党　5. 日本維新の会　6. 共産党　7. みんなの党　
#                  8. 社民党　9. 新党大地　10. 国民新党　11. 新党日本　12. 新党改革　13. 諸派　14. 無所属
# RESULT: 一部コーディングが変更に。0. 落選 1. 小選挙区で当選 2. 比例区で復活当選 3. 比例区単独で当選
#
# 2014年政治家調査（衆議院）
# PARTY: 1. 自民党 2. 民主党 3. 維新の党 4. 公明党 5. 次世代の党 6. 共産党 7. 生活の党 8. 社民党 9. 新党改革 
#        10. 幸福実現党 11. 支持政党なし 12. 諸派 13. 無所属
#
#
#



dat2009 <- seijika_syu_link$`2009_kouho` %>% read_csv(locale=locale(encoding="CP932"), #候補者名にJISが入ってる。
                                                      na = c("", "NA", 99, "・") # 99 = NA
                                                      )
names(dat2009)
dat2009$NAME # すごい，本当に候補者名全員の名前載ってる...
dat2009$Q12 # 
write_csv(tibble(names=names(dat2009)), "2009_names.csv")

dat2012 <- seijika_syu_link$`2012_kouho` %>% read_csv(locale=locale(encoding="CP932"),  na = c("", "NA", 99, 999, "・"))
dat2012$Q2_3
write_csv(tibble(names=names(dat2012)), "2012_names.csv")

dat2014 <- seijika_syu_link$`2014_kouho` %>% read_csv(locale=locale(encoding="CP932"),  na = c("", "NA", 99, 999, "・"))
write_csv(tibble(names=names(dat2014)), "2014_names.csv")
