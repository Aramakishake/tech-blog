# tech-blog-prepare
技術ブログ準備用レポジトリ

## 使い方
### 新しい記事作成
```
hugo new post/記事名.md
hugo new memo/記事名.md
```
指定したディレクトリに記事名.mdのファイルを作成
現状
- post/ → 投稿するディレクトリ
- memo/ → 草稿のディレクトリ
という運用を想定

### draftの公開
また、デフォルトでは、記事のヘッダがdraft:trueになっており、表示されない。
公開するには、draft:falseにすることで公開できる。