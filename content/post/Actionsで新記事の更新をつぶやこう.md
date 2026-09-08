+++
date = '2026-09-02T20:50:33+09:00'
draft = true
title = 'Actionsで新記事の更新をつぶやこう_20260902'
tags = ["CI/CD", "GitHub Actions"]
+++

# はじめに
最近、通勤の合間を縫って、技術ブログを綴っている。
「技術」といっても、高尚な内容ではなく、ひねった文章を書くために、技術的な部分の考察を行うという営みだ。

その際に、「新記事投稿時にXで自動投稿してくれたら便利やろ」と思い設定しようと試みた。

結論から言うと、準備はできたものの、自動投稿の仕組みを使わないと判断した。

その判断も含め、備忘のために記事として残しておく。

# 本題
## 前提（GitHub Pages）
まず、当ブログはGitHub Pagesという、GitHubでホームページを管理し、公開できる仕組みを用いている。

これは、
* リポジトリにホームページのhtmlやCSS, javascriptを配置する
* 公開元として指定したブランチ(gh-pagesなど)にpushする
* GitHub側がそのファイル群を検知して、配信開始
* https://ユーザー名.github.io/リポジトリ名/ でアクセス可能になる

という流れでホームページが公開される。

かつて利用していた
* FFFTP（FTPで送信するツール）
* お名前ドットコム（ドメインとレンタルサーバーの会社、なんか評判悪いらしいっすね）
を利用しなくてもホームページが用意できるのである！！！しかも無料！！！

## GitHub Actionsとは？
端的に言えば、GitHubのCI/CDツール。

また、CI/CDは何かを超ざっくりというと、
「自動でテストしたり、自動ですぐ使えるファイル（.exeとか.htmlとか）にしてくれたら、手間が省けるね」というもの。

プログラマーの美徳の1つとして怠惰（手間を省くために手間をかける）を体現したツールである。

## 今回話したいこと
ここで本題、GitHub Actionsを用いて、新たに記事を作成・公開した旨を皆に知らせるポストを自動投稿したい！
と考え、仕組みを作成しようと試み、(Xに金を払いたくなくて)断念した。

その際に分かったことについて記載する。

カスだけどやめられないSNSことXに放流して、誰が見るかと思うかもしれないが(実際誰も見てないと思っている)、
どちらかというと他者というより未来の自分宛てが目的である。

未来の自分が過去ポストを掘り出しているときに「書いたな、こんな記事」と復習することを狙いとしている。

## 自動投稿までの流れ
[GitHubページ](https://github.com/Aramakishake/tech-blog/tree/develop/.github/workflows)にあるdeploy.ymlが本体。
大まかな流れとしては、
* 前回との差分を取る
* 記事が非公開から公開になったタイミングを検知
* 記事タイトルを取得
* 記事URLを取得
* Xに投稿

という流れである。

このymlファイルでは記事の反映も行っているが、
この辺については、かつて書いた[Hugoに関する記事](https://aramakishake.github.io/tech-blog/post/hugo%E3%81%A7%E3%83%96%E3%83%AD%E3%82%B0%E3%81%AF%E3%81%98%E3%82%81%E3%81%BE%E3%81%97%E3%81%9Fpart2/)
が詳しいため、気になった方はそちらを参照されたい。

それでは大まかな流れのそれぞれについてどのような処理をしているか触れていこう

### 前回の記事との差分を取る

Actionsのスクリプトでやってるのはこの辺(以下コードブロック)。

コメントでやってることを記載した。
```
# 現在のコミットと1つ前のコミットでの差分(ファイル名)を取得
FILES=$(git diff --name-only HEAD^ HEAD)

# 取得したファイル名を1つずつ見る
for file in $FILES
do
    # post配下のmarkdownだけ見る
    if [[ "$file" != content/post/*.md ]]; then
        continue
    fi

    # コミット前後のdraft状態を取得
    OLD_DRAFT=$(git show HEAD^:"$file" 2>/dev/null | grep "^draft =" || true)
    NEW_DRAFT=$(grep "^draft =" "$file" || true)

```

なお、それぞれの要素を説明すると、

```
FILES=$(git diff --name-only HEAD^ HEAD)
```
- FILES=$(...)：(...)内コマンドの実行結果をFILESという変数で受け取る
- git diff A B：AとBの差分を取る
- --name-only ：ファイル名のみ抽出
- HEAD        ：A = 現在のコミット
- HEAD^       ：B = 1つ前のコミット

```
for file in $FILES
do
    if [[ "$file" != content/post/*.md ]]; then
        continue
    fi
```
- for file in \$FILES do：変更のあるファイル群(\$FILES)から1つずつ\$fileという変数に取り出してdo配下を実行
- if ... fiで囲まれた部分が条件分岐
- "$file" != content/post/*.md：変更のあるファイルが"content/post/"配下のMarkdownファイルでない場合trueでcontinue(そのファイルを飛ばす)

```
# コミット前後のdraft状態を取得
OLD_DRAFT=$(git show HEAD^:"$file" 2>/dev/null | grep "^draft =" || true)
NEW_DRAFT=$(grep "^draft =" "$file" || true)
```
- `XXX=$(...)`：...内の出力をXXXという変数に代入
- `git show HEAD^:"\$file"`：1つ前のコミット(HEAD^)にある、\$fileの内容を出力する
- `2>/dev/null`：エラーメッセージを捨てる(非表示とする)
- `| grep "^draft ="`：出力された内容から、"draft ="で始まる行を取得
  - grep(Global Regular Expression Print)なので正規表現
  - 正規表現において、キャレット(^)は行頭を表す
- `|| true`：grepが見つからずとも、コマンド全体を成功扱いにする(スクリプトを終了させないため)
- `grep "^draft =" "\$file"`：現在の\$fileにおける"draft ="で始まる行を取得

### 記事が非公開から公開になったタイミングを検知
```
do(差分のあるFILEごとのループ)
     if [[ "$OLD_DRAFT" == *"true"* ]] &&
        [[ "$NEW_DRAFT" == *"false"* ]]; then
        (中略)
        echo "NEW_POST=true" >> $GITHUB_ENV
        (中略)
        NEW_POST=true
        (中略)
        break
    fi
done

if [ "$NEW_POST" = false ]; then
    echo "NEW_POST=false" >> $GITHUB_ENV
fi
```
- if文
  - OLD_DRAFT(コミット前のdraftが記載されている行)にtrueという文字列が含まれる。
  - NEW_DRAFT(コミット後のdraftが記載されている行)にfalseという文字列が含まれる。
  - この双方を満たす場合、if文処理が行われる。
    - つまり、非公開→公開に変更した場合のみこの条件を満たす。
- 条件を満たすときの処理
  - `echo "NEW_POST=true" >> $GITHUB_ENV`：後続ステップでもNEW_POSTという変数(グローバル変数)がtrueになる。
  - `NEW_POST=true`：このステップではNEW_POSTという変数(ローカル変数)がtrueになる。
  - `break`：doループから抜ける
- ループ終了時
  - `if [ "$NEW_POST" = false ]; then echo "NEW_POST=false" >> $GITHUB_ENV fi`：ループを経てもNEW_POSTのローカル変数がfalseである場合、グローバル変数のNEW_POSTがtrueになる。

### 記事タイトルを取得
```
TITLE=$(grep "^title =" "$file" \
    | head -n1 \
    | cut -d'=' -f2 \
    | tr -d '"' \
    | tr -d "'" \
    | xargs)

echo "POST_TITLE=$TITLE" >> $GITHUB_ENV
```
- `grep "^title =" "$file" `：現在の$fileにおける"title ="で始まる行を取得
- `head -n1`：("title ="で始まる)先頭1行を取得
- `-cut -d'=' -f2`：区切り文字(-d)を=に設定し、区切ったうちの2番目のフィールド(-f2)を取得
- `tr -d '"'`：ダブルクオート(")を削除
- `tr -d "'"`：シングルクオート(')を削除
- `xargs`：前後の余分な空白やタブを削除し、連続する空白も整理
### 記事URLを取得

### Xに投稿

### 細かい部分の調整

上記を実施する中で、うまくいかない部分があった。
具体的にはすべてASCIIのファイル名の場合は、差分のあるファイルの取得できるが、日本語名ファイルだと差分のあるファイル取得ができず、記事の公開をしても公開と判定されないというもの。

# おわりに
とどのつまり、

カスのSNSをつけあがらせないために、プログラマーの美徳の1つである怠惰を黙らせている。
