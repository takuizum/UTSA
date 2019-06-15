#　発端の記事
# https://www.asahi.com/senkyo/asahitodai/asahitodai15nen/

# install.packages(c("tidyverse", "psych", "mirt", "Hmisc"))
# install.packages("haven")
# donwload csv data

library(tidyverse)
library(haven)
library(Hmisc)
library(mirt)

# コードブックリンク
codebook_link <- list("2009_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2009UTASP_codebook20150910.pdf",
                      "2010_san" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2010ates_codebook101105.docx", 
                      "2012_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2012UTASP_codebook20150910.pdf",
                      "2013_san" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2013UTASP_codebook131128.doc",
                      "2014_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2014UTASP_codebook20150910.pdf",
                      "2016_san" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2016UTASP_codebook20161010.docx",
                      "2017_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2017UTASP_codebook20180628.docx",
                      "2009_to_2010_ykn" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2009_2010utas_codebook.docx",
                      "2012_to_2013_ykn" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2012_2013UTASV_codebook20131129.docx", # SPSS
                      "2014_to_2016_ykn" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2014_2016UTASV_codebook20161004.docx"
                      )

# 政治家調査
seijika_syu_link_before2009 <- list("2003_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/ates1v1.csv",
                                    "2003_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/ates2v1.csv",
                                    "2005_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2005ates0801171.sav"
                                    )

seigika_san_link <- list("2004_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2004ates0801172.sav",
                         "2007_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2007ates071221.sav", 
                         "2010_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2010ates101105.sav",
                         "2013_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2013UTASP130722.sav",
                         "2016_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2016UTASP20161010.csv"
                          )

seijika_syu_link <- list("2009_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2009UTASP20150910.csv", 
                         "2012_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2012UTASP20150910.csv",
                         "2014_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2014UTASP20150910.csv",
                         "2017_syu" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2017UTASP20180628.csv"
                         )

# 有権者調査
yukensya_link <- list("2003_to_2005" = "http://www.masaki.j.u-tokyo.ac.jp/utas/utas060104xls.zip",
                      "2007" = "http://www.masaki.j.u-tokyo.ac.jp/utas/utas080112.xls.zip",
                      "2009_to_2010" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2009_2010utas130816.sav", # SPSS
                      "2012_to_2013" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2012-2013UTASV131129.sav", # SPSS
                      "2014_to_2016" = "http://www.masaki.j.u-tokyo.ac.jp/utas/2014_2016UTASV20161004.csv"
                      )

