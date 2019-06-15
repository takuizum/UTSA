# MIRT Functions Muanual

### 代表的な関数

- `mirt`  
    - 単一母集団でのIRT分析を実行できる。
- `mirt.model`  
    - mirt専用のモデルシンタックスを書き込むことで、様々な制約・設定を書くことができる。公式文書の言い方を借りれば、ユーザーが任意の確認的なモデルを書き込むことができる。
- `multipleGroup`  
    - 多母集団モデル推定用の関数
- `extract.mirt`
    - mirt系のS4クラスオブジェクトからいろんな値を引っ張ってきてくれる関数。`@`でも可
- `mirtCluster`
    - `parallel::makeCluster()`を呼び出して、parallel computingを実行してくれる。

## `mirt`および`multipleGroup`


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
