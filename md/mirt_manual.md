# MIRT Functions Muanual

### 代表的な関数

- `mirt`  
    - 単一母集団でのIRT分析を実行できる。
- `mirt.model`  
    - mirt専用のモデルシンタックスを書き込むことで、様々な制約・設定を書くことができる。公式文書の言い方を借りれば、ユーザーが任意の確認的なモデルを書き込むことができる。
- `multipleGroup`  
    - 多母集団モデル推定用の関数
- `mixedmirt`
    - 受検者と項目の両方のレベルで、固定効果とランダム（変量）効果を条件付けた＝混合モデルのIRTモデルを扱うことができる関数。モデルシンタックスも少し特殊。下記の`mirtCluster`で高速化できる。
- `extract.mirt`
    - mirt系のS4クラスオブジェクトからいろんな値を引っ張ってきてくれる関数。`@`でも可
- `mirtCluster`
    - `parallel::makeCluster()`を呼び出して、parallel computingを実行してくれる。

## `mirt`および`multipleGroup`
後述するモデルシンタックスを`mirt.model`によって記述し、そのモデルを元にデータから特定のパラメタを推定する。推定に用いる計算アルゴリズムや収束基準などをかなり詳細に設定できる。
```{R}
fit1 <- mirt(data, 
             model, 
             itemtype,...
)
```
### 引数(arguments)について
- `data` 反応データ。`matrix`か`data.frame`、`tibble`でもいける。欠測値は`NA`でコーディングしておく。全回答が`NA`となる受検者行が存在する場合には、`technical = list(removeEmptyRows = T)`を指定する。
- `model` 後述するモデルシンタックス。探索的な完全情報項目因子分析を実行したい場合には、因子数に一致する単なるnumericを与えておけば良い。
- `itemtype` 項目単位で適用するIRTモデルを指定する。デフォルトの `NULL`の場合には自動的に`2PL`か`graded`が与えられる。
    - `Rasch` ラッシュモデル。1PLとも。
    - `2PL`, `3PL`, `3PLu`, `4PL` 一般的な2~4パラモデル。`u`は上方漸近線のみを推定するモデル（珍しい！！）
    - `graded` Samejimaの段階反応モデル
    - `grsm`, `grsmIRT` Graded Rating Scele Modelまたの名をModified Graded Response Modelとも。カテゴリ境界パラメタ間に等値制約を課したモデル。`IRT`がつく方は、一般的なIRTパラメトリゼーションであり、一次元モデル限定で使える。
    - `gpcm`, `gpcmIRT` 一般化部分採点モデル。スコアリング行列は`gpcm_mats`で与える。
    - `rsm` 評定尺度モデル。一次元モデル限定。
    - `nominal` Bockの名義反応モデル
    - `ideal` 2値データに対する理想点モデル
    - `ggum` 一般化段階展開モデル。
    - `sequential` 多次元連続反応モデル。Continuous Responseとは違う？
    - `Tutz`
    - `PC2PL`, `PC3PL` 2~3パラの部分補償型モデル
    - `spline` スプライン反応モデル。
    - `monopoly` 単調多項モデル。一次元モデルのみ対応。
    - その他にも自分で好きなモデルを`createItem`で作れるらしい。
- `guess` `upper` 上方漸近および下方漸近パラメタを固定して推定する。項目ごとに指定する。
- `method` パラメタの推定アルゴリズム。`BL`以外は基本的にはEMアルゴリズムに基づく。
    - `EM` 求積点を固定したEMアルゴリズム。Bok & Aitkin流のもっともベーシックな計算方法であり、一次元では効率的。求積点の数は`quadapts`で、事前分布の計算方法は`dentype`で指定できる。
    - `QMCEM` `MCEM` （擬似）モンテカルロEMアルゴリズム。
    - `MH-RM` メトロポリスヘイスティングス・ロビンモンロ。
    - `SEM` 確率的EMアルゴリズム。
    - `BL` Bock & Liebermanにより提案されたEMアルゴリズムに基づかない周辺最優推定法。
- `accelerate` 
    - `none`
    - `Ramsay`
    - `squarem`
- `optimizer` M-stepにおける最適化計算の方法。
    - `BFGS` Rの多変数最適化関数`optim`で使われる推定方法の一つ。同関数の他のoptimizerも使える。
    - `nlminb` 
    - `NR` 言わずと知れた二階偏微分まで使う多変数最適化。一般に反復回数が少ないが、複雑なモデルにおいては不安定になりがち。名義反応モデルとかでは非推奨。
    - `NR1` `method = "MHRM"`にだけ使用できる。一回しかNewton-Rapthonを更新しない。
    - `sonlp`
    - `nloptr`
- `SE` `TRUE`にすれば標準誤差を推定する。各パラメタの推定精度をチェックできるとともに、最尤推定値との差を利用して検定するWald検定にも使われる。
- `SE.type` 標準誤差の推定方法。
    - `Richardson`, `forward`, `central`
    - `crossprod` `Louis`
    - `sandwich`
    - `sandwich.Louis`
    - `Oakes` 
    - `SEM` Supplemented EM。`accelerate = ~`でEMアルゴリズムの各ステップにおいて加速方法を指定した場合には使えない。
    - `Fisher` 期待情報行列
    - `complete` 完全データ行列のHessianに基づく。
    - `MHRM` `method = "MHRM"`とした場合にだけ使える。近似的に観測情報行列を推定する。
    - `numerical` `method = "BL"`とした時に利用できる。
- `dentype` $\theta$ の事前分布の確率密度を計算する方法
    - `Gaussian`
    - `empiricalhist` `EH` EMアルゴリズムのEステップの副産物を利用して、経験的に事前分布の確率密度を推定する
    - `empiricalhist_Woods` `EMW` 上記`EH`は確率密度がギザギザな形になりやすいため、それを補間する。極端な回答パタンが多い場合には`technical = list(zeroExtreme = TRUE)`が必要になるらしい。
    - `Davidian-#` セミパラメトリックなDavidian curve。`#`はパラメタ数。一次元のIRTモデルでしか利用できず、求積点が121になる。
- `quadapts` 一次元あたりの求積点の数。必ず2以上でなくてはならない。デフォルトでは次元数`nfact`に応じて可変的に指定される。
```{R}
switch(as.character(nfact), '1'=61, '2'=31, '3'=15, '4'=9, '5'=7, 3)
```
- `TOL` EMアルゴリズムおよびMH-RMの収束基準。デフォルトはEMアルゴリズムなら0.0001、MH-RMなら0.001である。もし`SE.type = "SEM"`ならば1e-5に、`dentype = "EM" or "EHW"`ならば3e-5に変更される。もし初期値だけでモデルを評価したい場合には`Nan`を、初期値だけで評価するが対数尤度が不要な場合には`NA`を与える。
- `constrain` パラメタの等値制約を宣言する。モデルシンタックスで記述できるため、非推奨
- `parprior` 項目パラメタの事前分布を宣言する。モデルシンタックスで記述できるため、非推奨
- `pars`
- `gpcm_mat` GPCMのスコアリング係数を与える行列。次元ごとに各カテゴリのスコアリングが異なる場合に使う。デフォルトは`seq(0, k, by = 1)`のように0から1ずつ増加させる。行で指定するのはカテゴリ数にあたる`k`の部分であり、列で指定するのは次元ごとの値。
- `GenRandomPars` 論理型で指定し、初期値をランダムな値にするかどうかを決定する。時々、モデルフィットが悪いデータに対して有効。
- `verbose` consoleに対数尤度を表示するかどうか。
- `control` optimやnlminbに渡すオプション。M-stepの収束基準のデフォルトは`tol = TOL/1000`で決められている。`NR`の最大反復回数は`maxit`で指定する。
- `technical` そのほかの細々とした設定。
    - `NCYCLES` EMサイクルの最大回数。
    - `MAXQUAD` 最大求積点の数。
    - `theta_lim` 各次元の積分区間。デフォルトは+-6。
    - `set.seed` 12345
    - `warn` 推定中にwarningを表示するかどうか。
    - `message` 推定中にmessageを表示するかどうか。
    - `customK` 項目ごとに最大カテゴリ数を指定したベクトルを与えることができる。項目パラメタの推定ではなく因子得点の計算が目的である場合に使える。
    - `removeEmptyRows` 反応データが全て`NA`の行を除くかどうか。
    - `BURNIN`
    - `SEMCYCLES`
    - `MHDRAWS`
    - 
    
    
    

## モデルシンタックスの書き方

### 基本式
```{R}
mod1 <- mirt.model("F1 = 1-10")
```
上記のように記述する方法が基本。あらかじめテキストファイルに記載しておいて、それを`scan = "hoge.txt"`として読み込ませることもできる。大規模で複雑なモデル記述を行う場合におすすめ。`mirt.model()`とあえて空にして関数を呼び出すと、コンソール上でインタラクティブに入力できる。  
読み方としては、`因子名 = 項目番号（もしくは名前）`という事になる。ハイフンは範囲で指定したいときに使う。  

### Optional Kwywards of `mirt.model`

- `COV` 因子間の相関について規定する。
```{R}
COV = F1 * F2 = 1-10 # 因子間相関を項目1から10において仮定する
COV = F1 * F1 = 1-5, 6 # 非線形因子
```
- `MEAN` 多次元モデルの場合に、平均を自由母数としたい因子を指定する。複数ある場合は`MEAN = F1, F2`のようにカンマで区切る。
- `CONSTRAIN` **項目間で**等値制約をかけたい項目とそのパラメタを指定する。`CONSTRAIN = 項目1, ..., パラメタ`。気をつける点は、2PLなどの困難度はbではなくてdとなっている点。また識別力は次元ごとに求められることが多いため、`a1`となる点も注意。多母集団推定の時に特定の集団だけ制約を課したい場合には、`[集団名]`を`=`の直前につければよい。
- `CONSTRAINB` **グループ間で**等値制約をかけたい項目とそのパラメタを指定する。
- `PRIOR` 周辺ベイズ推定およびフルベイズ推定の際に項目パラメタにかける事前分布。`項目, パラメタ, 分布, 超パラメタ`の順番で指定する。使える分布は正規分布`norm`、対数正規分布`lnorm`、およびベータ分布`beta`である（基本的にstatsの確率分布の頭一文字をとった表記）。また3PLと4PLの下方漸近にはロジスティック分布で変換した後のベータ分布`expbeta`が使える。
- `LBOUND``UBOUND` パラメタのlower bound、つまり最小値を設定できる。特に、`optimizer = L-BFGS-B` or `nlminb`で必要となる。`項目, パラメタ, 値`の順番で指定する。
`START` 初期値を特別に指定したい場合に使う。`項目, パラメタ, 値`の順番で指定する。関数などを使って柔軟に初期値を推定したい場合には、推定関数`mirt`の方で`pars = "value"`を指定する必要がある（どのように初期値などを決定するかを`data.frame`構造で渡さなくてはならないらしいが、よくわからない）。ランダムな初期値を使いたい場合にも実行関数の方で`GenRandomPars = TRUE`指定する。実はこのオプションには隠しコマンド的な使い方があり、多母集団推定時に特定集団のEステップにおける平均と分散を固定したい時に役に立つ。`START = (集団, MEAN or COV _行数(列数), 値)`のように使う。
```{R}
START = (GROUP1, MEAN_1, 0.5)
START = (GROUP1, COV_11, 1.5)
```
このようにすれば、`GROUP1`の平均を0.5、分散を1.5と固定して推定できる。公式マニュアル的には
`FIXED``FREE` パラメタを初期値の時点で固定して、自由母数として推定したくない場合に使う。`FREE`はその逆。あんまり使わないと思われる。
`NEXPLORE` 探索的な完全情報項目因子分析を実行したい時は、ここに因子数を与えてやればよい。だけれども、まず使わない。


## `SingleGroupClass`および`MultipleGroupClass`のmethod

### `extract.mirt`

関数のアウトプットオブジェクト(S4 class)から色々なオブジェクトを引き出すためのgeneric function。`extract.mirt(object, what)`のように使用し、`what`の部分に適当な**string**を入れる。

- `logLik` observed log-likelihood 対数尤度。
- `logPrior` log term contributed by prior parameter distributions 周辺ベイズで使う。
- `G2` `df` `p` `RMSEA` `CFI` `TLI` `AIC` `AICc` `BIC` `SABIC` `DIC` `HQ` 各種統計量
- `F` 回転前の標準化された因子負荷行列
- `h2` 共通性の推定値
- `LLhistory` EM log-likelihood history
- `exp_resp` expected probability of the unique response patterns
- `converged` a logical value indicating whether the model terminated within the convergence criteria
- `iterations` number of iterations it took to reach the convergence criteria
- `nest` number of freely estimated parameters
- `parvec` vector containing uniquely estimated parameters
- `vcov` parameter covariance matrix (associated with parvec)
- `Prior` prior density distribution for the latent traits
- `time` estimation time, broken into different sections
以下略

#### plot
`type`  

-  `info` test information function  
- `rxx` for the reliability function  
- `infocontour` for the test information contours  
- `SE` for the test standard error function  
- `infotrace` item information traceline plots  
- `infoSE` a combined test information and standard error plot  
- `trace` item probability traceline plots  
- `itemscore` item scoring traceline plots  
- `score` expected total score surface
- `scorecontour` expected total score contour plot
- `empiricalhist` generate the empirical histogram
- `Davidian-#` to generate the curve estimates at the quadrature nodes used during estimation

`npts`  
number of quadrature points to be used for plotting features. Larger values make plots look smoother

`theta_lim`  
lower and upper limits of the latent trait (theta) to be evaluated, and is used in conjunction with npts

`which.items`  
numeric vector indicating which items to be used when plotting. Default is to use all available items

#### anova

- `object` an object of class SingleGroupClass, MultipleGroupClass, or MixedClass
- `object2` a second model estimated from any of the mirt package estimation methods

### `mixedmirt`について
受検者および項目の変動（共編量, covariates) を固定効果とランダム（変量）効果に分解して条件付けた拡張的なIRTモデルを扱うことができる関数。二値，多値のどちらにも対応しており，さらに多次元もいける。も固定効果のみをモデリングした場合は探索的なIRTに等しく，両方をモデリングしたものはマルチレベルIRTに等しい。

#### arguments

- `covdata` 受検者数 $\times$ Kの行列で，受検者レベルの固定効果とランダム効果の予測子。cov = covariates
- `fixed`　一般化線形モデルを扱う関数`glm`のモデルシンタックスと類似している表記で，`~ hogehuga`と記述する。`covdata`か`itemdesign`のいずれか，もしくは両方から指定する。
- `random`
- `lr.fixed`
- `lr.random`
- `itemdesign`
- `internal_constraints`