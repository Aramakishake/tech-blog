+++
date = '2025-11-16T22:06:23+09:00'
draft = false
title = 'Hugoでブログはじめましたpart2_20251116'
tags = ["CI/CD", "GitHub Actions"]
+++

# はじめに
この「Hugoでブログ始めました」シリーズは、本ブログを立ち上げる際に使用した技術をまとめるべく始めたものである。

前回の記事(part1)では静的サイトジェネレーターのHugoについてまとめた。

本記事ではCI/CDプラットフォームのGitHub Actionをまとめる。

まず、GitHub Actionsの概要を紹介しよう。

# GitHub Actionsについて
まず、GitHub Actionsとは、CI/CDプラットフォームである。詳細については以下。

## CI/CDとは
Continuous Integration/Continuous Delivery(or Deployment)の略である。

つまるところ、自動でテスト・ビルド・実行まで一貫してやってくれる仕組みである。

### CIとは
Continuous Integration(継続的統合)の略

開発者がコードを頻繁に統合し、自動でビルド・テストを実施することで、バグの早期発見と品質向上を図ること。

### CDとは
Continuous Delivery(継続的納品)

または

Continuous Deployment(継続的導入)の略

CIでテスト済のコードを自動で本番環境にリリース可能な状態にし、必要に応じて自動でデプロイ(※)まで実施すること。

デプロイ：ファイルを実際のWebサーバ上に配置して利用できる状態にすること

## GitHub Actionとは
名前の通り、GitHubのイチ機能である。

CI/CDプラットフォームなんて大層な説明をしたが、つまるところ、
- GitHubのブランチへのプッシュなどの更新操作や、
- ビルドからサーバーにアップロードして、動く状態にする展開操作

を自動的にやってくれるものだ。

やり方としては、GitHubのリポジトリ内にyamlファイル(設定ファイルに用いられるデータ記述フォーマット)に条件と処理を書き込むことで機能が使えるようになる。

# 実施した工程
ということで、GitHub ActionはCI/CDプラットフォーム、即ち、自動で更新操作や展開操作をやってくれるスグレモノであることを説明した。

次は、その使用方法についてまとめる。

といっても、このブログサービスをどのように実現しているか
## Github Actionを使用するには
### 1. レポジトリ内にディレクトリ作成
<br>リポジトリのルートに.githubディレクトリを作成し、
<br>その配下にworkflowsディレクトリを作成する。

### 2. 作成したディレクトリにyamlファイル格納
<br>次に、workflowsディレクトリ配下にyamlファイルを格納する。
<br>ファイル名は何でもいいので、自動化したい処理名をつければOK。
<br>ここまでの工程でやった結果以下のような構成になる。
```
root(GitHubのリポジトリ)
┣━.github
┃ ┗━workflows
┃  ┗━deploy.yaml
┣━content
┃ ┗━コンテンツ.md(MarkDownの記事)
┣━publish
┃ ┗━作成された静的サイト.html
┣━static
┃ ┣━デザイン.css
┃ ┗━画像.jpeg
┗━(その他のディレクトリ)
```

### 3. yamlファイルの中身の作り込み
<br>格納したyamlファイルの中身を作り込む。
<br>ここはやりたいことによって変わるので
<br>一例として、本サイトで使用しているyamlファイルを示す。

```
name: Deploy Hugo site to GitHub Pages

on:
  push:
    branches:
      - develop  # Hugoプロジェクトがあるブランチ

permissions:
  contents: write

jobs:
  build-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout source
        uses: actions/checkout@v3

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: 'latest'  # Hugoのバージョン（必要に応じて変更）

      - name: Build site
        run: hugo

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
          publish_branch: gh-pages

```

これは、
- developブランチにpushされた(=更新された)とき、
- developブランチににあるファイルをHugoに投げて、root/publish/配下に静的サイトを作成する。
- gh-pagesブランチに、作成したroot/publish/配下をpushする。

というもの。

### ついでに:GitHub Pagesでブランチ公開する方法
一応、上記のyamlではgh-pagesブランチにroot/publish/配下の内容をpushしてるだけなので、ページを公開しているというわけではない。

実際は特定のブランチ(今回だとgh-pagesブランチ)配下の内容を公開することによって、ページが参照可能になっている。

ここの手続きは比較的容易である。

[settings]->[Pages]->[Branch]から、Pageとして公開したいディレクトリを設定すればできる(下図参照)。

{{< img src="images/HowToSetGitHubPages.png" alt="GitHub Pagesでの公開設定" caption="GitHub Pagesでの公開設定" >}}

# おわりに
Part1でHugoでブログの静的サイトを作成する環境を整えた。
そして、本記事で静的サイトをGitHub Action上でHugoが動くように設定した。

また、その際に得た知識と実施した工程を記述した。

