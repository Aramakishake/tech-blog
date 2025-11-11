+++
date = '2025-11-02T07:28:30+09:00'
draft = true
title = 'Hugoでブログはじめましたpart2_20251102'
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

CI/CDプラットフォームなんて大層な説明をしたが、つまるところGitHubのブランチへのプッシュなどの操作を自動的にやってくれるものだ。

やり方としては、GitHubのリポジトリ内にYAMLファイル(設定ファイルに用いられるデータ記述フォーマット)に条件と処理を書き込むことで機能が使えるようになる。

# 実施した工程
## Github Actionを使用するには

# おわりに
Part1でHugoでブログの静的サイトを作成する環境を整えた。
そして、本記事で静的サイトをGitHub Action上でHugoが動くように設定した。

また、その際に得た知識と実施した工程を記述した。

