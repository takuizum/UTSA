#　発端の記事
# https://www.asahi.com/senkyo/asahitodai/asahitodai15nen/

# donwload csv data

library(tidyverse)

# コードブックリンク
codebook_link <- list("2009_syu_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2009UTASP_codebook20150910.pdf",
                      "2010_san_giin_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2010ates_codebook101105.docx", 
                      "2012_syu_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2012UTASP_codebook20150910.pdf",
                      "2013_san__giin_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2013UTASP_codebook131128.doc",
                      "2014_syu_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2014UTASP_codebook20150910.pdf",
                      "2016_san_giin_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2016UTASP_codebook20161010.docx",
                      "2017_syu_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2017UTASP_codebook20180628.docx"
                      )

# 政治家調査
seijika_syu_link_before2009 <- list("2003_giin" = "http://www.masaki.j.u-tokyo.ac.jp/utas/ates1v1.csv",
                     "2003_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/ates2v1.csv",
                     "2005_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2005ates0801171.sav"
                     )

seigika_san_link <- list("2004_giin_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2004ates0801172.sav",
                          "2007_giin_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2007ates071221.sav", 
                         "2010_giin_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2010ates101105.sav",
                         "2013_giin_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2013UTASP130722.sav",
                         "2016_giin_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2016UTASP20161010.csv"
                          )

seijika_syu_link <- list("2009_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2009UTASP20150910.csv", 
                         "2012_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2012UTASP20150910.csv",
                         "2014_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2014UTASP20150910.csv",
                         "2017_kouho" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2017UTASP20180628.csv"
                         )

# 有権者調査
yukensya_link <- list("2003_to_2005" = "http://www.masaki.j.u-tokyo.ac.jp/utas/utas060104xls.zip",
                      "2007" = "http://www.masaki.j.u-tokyo.ac.jp/utas/utas080112.xls.zip",
                      "2009_to_2010" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2009_2010utas130816.sav",
                      "2012_to_2013" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2012-2013UTASV131129.sav", 
                      "2014_to_2016" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2014_2016UTASV20161004.csv"
                      )

