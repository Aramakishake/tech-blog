+++
date = '2025-10-31T16:14:25+09:00'
draft = false
title = 'Hugoでブログはじめましたpart1_20251031'
tags = ["静的サイト", "Hugo"]
+++

# はじめに
技術ブログに関して、Copilotさんに問いかけながら、勢いとノリで実装を行った。

その振り返りを行うべく本記事にまとめる。

使用した道具をどう使ったかについて述べたい。

- Hugo : 静的サイトジェネレーター
- GitHub Actions : CI/CDプラットフォーム

本記事のpart1では、Hugoの概要と今回実施した工程を紹介する。

# Hugoについて
Hugoとは静的サイトジェネレーターであると述べた。

まず、それは何かを説明する。
## 静的サイトジェネレーターとは

この語彙を説明するために、
- 静的サイト
- ジェネレーター

の2つに分割しよう。

### ◯静的サイト
静的サイトというのは、

**「閲覧者や条件が変わっても、内容の変わらないサイト」**

のことである。

ちなみに、対義語としては動的サイトがある。
こちらはログインするユーザー毎に内容を変化させることができるものだ。

例を挙げると、X(Twitter)は、
- ユーザーごとにタイムラインの表示が変わる
- 見るタイミングごとにもタイムラインの表示が変わる

そのため、条件や閲覧者ごとに内容が変わる。

つまり、動的サイトにカテゴライズされる。

今回実現しようとしているのは、自らの技術ブログの開設である。

ブログは、ユーザー毎に表示する内容を変える（動的にする）必要はない。

そこで、静的なサイトとして作成しようと相成った。
### ◯ジェネレーター

本来、ホームページをステゴロで作ろうとすると、

- HTML(HyperText Markup Language)

ホームページに表示する中身の部分

- CSS(Cascading Style Sheets)

ホームページの見た目を制御する部分

- JavaScript

ホームページの一部パーツを作成するための部分。

所謂ハンバーガーメニュー（「三」みたいな記号をクリックすると選択肢が出るメニュー）などを作るのに使う。

以上の3つを自らの手で書く必要がある。
（最低限はHTMLのみで済むが、それでも骨が折れる）

静的サイトジェネレーターというのは、
**これらのホームページ作成に必要なソースを生成(generate)してくれるスグレモノ**
なのである。

流石に、無からホームページが作れるわけではないが、必要なものは単純化される。
大きく分けて以下の3つである。
- 記事
  - Markdownテキスト
- 画像
  - コンテンツ内に載せる画像
- テーマ(サイトの枠組み)
  - 主にサイトの見た目部分
  - https://themes.gohugo.io/ から選択できる

記事、画像のコンテンツさえ揃えれば、テーマに準じてサイトが生成されるという寸法である。

## Hugo概要のまとめ
Hugoとは、静的サイトジェネレーターである。

つまり、**閲覧者や条件に依存しないサイトの生成をしてくれるスゴいヤツ**なのである。

# 実施した工程
では、どうやってHugoを使って静的サイトを作成しているかについて紹介する。

## Hugoを使用するには
### 1. Hugoのインストール
ここにインストールの仕方が載っている。
https://gohugo.io/installation/

私は確かwingetで取った気がする

```
hugo version
```
とコマンドプロンプトに入力したとき、
```
'hugo' は、内部コマンドまたは外部コマンド、
操作可能なプログラムまたはバッチ ファイルとして認識されていません。
```
と出た場合はインストールできていないか、パスの設定がうまく行っていないかだと思われる。

### 2. 新規サイト作成
```
hugo new site (Name)
```
で入力すると、末尾に入力した文字列をディレクトリ名とするディレクトリが作成される。

成功時は、以下のメッセージが出る(パスをPath、ファイル名をNameに変更している)。
```
Congratulations! Your new Hugo site was created in 
(Path)\(Name).

Just a few more steps...

1. Change the current directory to (Path)\(Name).
2. Create or install a theme:
   - Create a new theme with the command "hugo new theme <THEMENAME>"
   - Or, install a theme from https://themes.gohugo.io/
3. Edit hugo.toml, setting the "theme" property to the theme name.
4. Create new content with the command "hugo new content <SECTIONNAME>\<FILENAME>.<FORMAT>".
5. Start the embedded web server with the command "hugo server --buildDrafts".

See documentation at https://gohugo.io/.
```

まぁこれに準じて進めていけば進むんだが、如何せん英語なので、

作成されるディレクトリの構成は以下の通り。

```
/(Name)
├── archetypes/
│ └── default.md
├── assets/
├── content/
├── data/
├── hugo.toml
├── i18n/
├── layouts/
├── static/
└── themes/
```

未だにわかってないディレクトリがあるが、とりあえず今のところ使ってるのは以下くらい。
- archetypes/default.md
  - 新規記事を作成したときのフォーマット
- content/
  - 記事を置いておくディレクトリ
  - content/post/配下に新規作成記事を置いている
- hugo.toml
  - configファイル
  - テーマの設定なんかもここで行う
- static/
  - 画像を置いておくディレクトリ
- themes/
  - テーマを置いておくディレクトリ

運用によっておそらく変わるので、2025年10月末現在はこんなとこ。

### 3. テーマの導入と設定
前述のthemeが置いてあるサイトから取得して、構成をそのままthemes/配下に配置する
https://themes.gohugo.io/

gitだったらtheme配下にCloneしてくることによって、容易に手元に持ってこれる。

gitで持って来る場合、submoduleにするかCloneするかという択があるが、Cloneで実施した。

理由は、themeの更新を追ってく必要がないので、ラクそうなCloneと考えたため。

### 4. ローカル開発サーバーの起動
```
hugo server -D
```
このサーバーが起動中は、コンテンツが更新された際には自動で静的サイトが完成する。

なお`-D`は草稿(Draft)の状態も表示するようなオプションである。
### 5. コンテンツ作成
```
hugo new posts/newPost.md
```
これをコマンドプロンプトに入力することで、content/配下にMarkdownファイルが作成される。

上記のケースでは、
content/posts/配下に
newPost.mdが作成される。

また、ここで作られるMarkdownファイルは、archetypes/default.mdの内容が入ってくる

デフォルトだと以下のようになっている。

```
+++
date = '{{ .Date }}'
draft = true
title = '{{ replace .File.ContentBaseName "-" " " | title }}'
+++
```

それぞれの項目を説明すると
- date : 日時
  - デフォだと作成日時
- draft : 草稿(true)/本記事(false)
  - デフォだと草稿(true)
- title : 記事タイトル
  - デフォだと多分ファイル名

ここで記事を作成すると、4. で起動したサーバーくんが頑張ってくれて、作成した記事が静的サイトに反映される。

完成！

# おわりに
Hugoでブログ作成したが、その際に得た知識と実施した工程を記述した。

次回はGitHub Actionくんについて説明したい。

前もってざっくり話すと、サーバー役を担ってもらうという仕組みである。

GitHubに更新した旨を伝えると
- 自動的にページを作って
- 公開してもらう

という便利なものである。

また、記事の見た目に関しては、まだまだ良くできることがあるので、記事を更新しつつエンハンスしていきたい。
