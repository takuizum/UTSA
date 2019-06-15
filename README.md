# 朝日新聞「政党の現在地」を検証する

朝日新聞リンク  
https://www.asahi.com/senkyo/asahitodai/asahitodai15nen/

本リポジトリに公開されているデータはすべて  
 **東京大学の名称使用のガイドラインに従って、本調査の正式名称を 東京大学谷口研究室・朝日新聞共同調査**   
および  
 **東京大学蒲島＝谷口研究室・朝日新聞共同調査**  
にもとづくものです。  
http://www.masaki.j.u-tokyo.ac.jp/utas/utasindex.html

データ，コードブックなどは許可なく**再配布が禁止**されているので注意してください。
このリポジトリに含まれているデータは公開データのリンクのみであり，データ本体は存在しません。
万が一データが読み込めない場合は，公開もとのサイトの不具合の可能性もあります。

### 政治家調査について
2003年から2017年までの，衆参両方の議員および候補者に対してのアンケート結果。データ形式はCSVおよびSAV形式です。

#### 調査一覧

- 2003年衆議院議員調査
- 2003年衆院選候補者調査
- 2004年参議院議員・参院選候補者調査
- 2005年衆院選候補者調査
- 2007年参議院議員・参院選候補者調査
- 2009年衆院選候補者調査
- 2010年参議院議員・参院選候補者調査
- 2012年衆院選候補者調査
- 2013年参議院議員・参院選候補者調査
- 2014年衆院選候補者調査
- 2016年参議院議員・参院選候補者調査
- 2017年衆院選候補者調査

コードブックは最近の調査についてはWEB上でWordおよびPDF形式で公開されているが，
2009年よりも古い調査のコードブックは紙媒体のみで発刊されている学術雑誌に記載されている。現在取り寄せ中。
なお，WEBにはコードブックの正誤表も掲載されている。

### 有権者調査について

- 2003年衆院選-04年参院選-05年衆院選世論調査（『日本政治研究』第2巻第1号（第1－3回調査）、第3巻第1号（第4回調査））
- 2007年参院選世論調査（『日本政治研究』第5巻第1・2合併号）
- 2009年衆院選－10年参院選世論調査
- 2012年衆院選－13年参院選世論調査
- 2014年衆院選－16年参院選世論調査

※（）内はコードブックが掲載されている雑誌を示している。  
こちらの調査も2009年以前のコードブックは紙媒体のみで存在している。

## 現在のデータ前処理進捗状況について
複数の異なるテスト間で共通尺度化するためのIRT分析を実行するには，テスト間に共通項目が必要になるので，現在テスト間での共通項目を特定し，共通IDを付与する作業をおこなっている。現在のところ  
- 2009年以降の衆議院議員候補調査
- 2009年以降の有権者調査
については共通IDの付与ができている。それ以外のデータは様子を見ておこなっていく予定である。

## 分析の進捗状況について

### まえおき

IRT分析の手順としては，回答パタンなどの可視化，古典的テスト理論の範囲での項目分析（トレースライン，IT相関），一次元性の確認，IRTモデルの選択およびパラメタの推定といった流れが一般的である。今回は当初から一次元性の仮定を逸脱していることが想定されるため，一次元性の確認の後に因子分析をおこない，因子分析モデルとして想定できる因子構造をもとにした情報を項目分析に加えることとする。  
本来であれば今回測定しようとしているのは「政治的態度が右寄りか左寄りか」という構成概念である。質問項目から判断するに，改憲に賛成であるとか防衛費に予算をさくほうが良い，日本の伝統を重んじる態度などがいくつかの項目で質問されており，これらの得点が高いということから一律に右寄りの思想であるとか，左寄りの思想であるということを断じることはできない。しかし，まずは先行研究に従って，得点が高いほどA側，つまり右翼，保守的な傾向が強いと判断することとする。勿論，分析の進捗によっては想定する構成概念に変更を加える必要があるだろう。  
なお自明のことではあるが，IRTの潜在変数は質問項目のスコアリングに無関係に計算されるものではない。段階反応モデルであれば，より高いカテゴリに反応するためにはより高い $\theta$ が必要となる，という仮定が存在する。その点で言えば，東京大学谷口准教授の主張している`「こう答えた政治家は右または保守、こう答えたら左またはリベラル」と主観的に判断せず、あくまで統計モデルから事後的に政策位置を得ている`というのは，明らかな誤りである。すでに質問項目を構成する時点で，**適切な構成概念を想定していなければならない**というのは潜在変数モデルの大前提である。

### 2019/06/14までの進捗
2009年以降のデータの前処理と固有値計算，トレースライン等の確認が終了した。現時点で言えることは，有権者調査はまず一因子構造とは言いがたく，このままUIRTモデルを適用することは難しいということである。  
とりあえず、先行研究の分析結果（になるべく近い値）を再現すべく、マージしたデータ行列を使用してIRT分析を試みた。単一母集団仮定であれば問題なく推定されたが、推定結果は負の識別力だったり、困難度の絶対値が異常に大きかったりと散々な結果であった。~~多母集団は推定自体がうまく走らないので、どこかコードに不備があるのかもしれない。~~RstudioCloudだと非常に重い処理を実行することはできないようだ。ラップトップ版のRstudioCloudだったら分析ができた。


#### notes

本リポジトリに収録されているデータ分析には東京大学谷口研究室・朝日新聞共同政治家／有権者調査データを使用した。