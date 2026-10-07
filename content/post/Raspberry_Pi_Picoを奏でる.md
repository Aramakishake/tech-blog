+++
date = '2026-10-04T10:22:21+09:00'
draft = true
title = 'Raspberry Pi Picoで奏でる'
tags = ["電子工作", "雑談"]
+++

# はじめに
私は、SNSやYoutubeのソーシャルメティアの負の側面を蛇蝎のように嫌っている。
ここで言う負の側面は「ユーザーを画面に釘付けにすることに技術の粋を集めている」ことを表す。
資本家が金を稼ぐために、賢い人間が動員され、賢くない人間の生産的な時間を空費させるのは、
眼前のホールケーキをドブに沈められるが如きもどかしさ、悔しさがある。

しかしここまで嫌えども、賢くない側の私がソーシャルメディアやめられない。
それは正の側面があるからだ。
例えばYoutubeの正の側面として、「あまり知らないジャンルの情報にアクセスできる」というものがある。
あまり知らない(知らなかった)ジャンルの情報は例えば以下の通り。

* 知らない学問を平易に噛み砕いた動画
* アナログ放送の風味の画を用いたホラー動画
* 「音鉄」と呼ばれる、鉄道全般の音を収録する鉄オタ

このような野生のタモリ倶楽部が、このYoutube Shortなる電子ドラッグ蔓延るスラム街に燦然と輝いている。

さて、今回の本題は、音鉄の方がアップロードした動画について電子工作欲を惹起された話である。

特に、群馬県にある心臓血管センター(すごい名前！)の列車接近音の「オリビアを聴きながら」の音がかなり好みであった。

あまりにも良かったのでこちらの手元でも奏でたいと思い、マイコンと圧電ブザーを使用した工作を行おうと決意するのであった。
# 「オリビアを聴きながら」を鳴らしたい
## 今回使うもの
主な登場人物は以下の通り
- 物理的な実体を持つ連中
  - マイコン(Raspberry Pi Pico)
    - (はんだ必要) https://akizukidenshi.com/catalog/g/g116132/
    - (すぐ使える) https://akizukidenshi.com/catalog/g/g118085/
    - だいたい1000円いかないくらい
  - 圧電ブザー
    - 今回の主役、音が出る
  - ブレッドボード
    - 組み換え可能な基板
    - 詳細はいずれ書く
- 概念的な連中
  - Arduino IDE
    - 開発環境
    - 詳細はいずれ書く
## 圧電ブザーとは
- 超ざっくり言うと：音が出る電子部品
- 詳細：
  - 電圧を印加すると変形する性質を持つ圧電素子からなる
  - 圧電素子に対し、一定の周波数で高圧/低圧を交互に印加して振動させ、音を出力する電子部品

# Mr.Yobikomiのコードを流用する
## Tone.hを使った過去の実装
以前、呼び込みくんのメロディに傾倒していた時期があり、その際に作成したソースがMr.Yobikomiである。
これはマイコン(Aruduino Uno)を用いて2つの圧電ブザーから呼び込みくんのメロディとベースを鳴らすというもの。

gitのディレクトリ
https://github.com/Aramakishake/Mr.Yobikomi/tree/main/Mr_Yobikomi

一応公開しているが、中を見て読むほどではないひどいコードである。
ざっくりと要約すると、
- 2つの圧電ブザーを用いて「呼び込みくん」のメロディとベースを流してハモらせるもの
- Toneという既存のライブラリを使用して鳴らしている
- もがきの痕として、振動の周波数がdefineでベタ書きされている
  - が、Toneライブラリの導入で不要になった

というもの。

## Raspberry Pi Picoで使えなかった理由
回路をブレッドボードで組んで、過去のMr.Yobikomiを鳴らそうとしたら、コンパイルエラーとなった。
このコンパイルエラーをCopilotに投げると「ToneライブラリはAVR専用やで」とのこと。

[Toneライブラリのリポジトリ](https://github.com/bhagman/Tone/tree/master)を確認。
ToneライブラリはAVR専用だと明に記載されていないが、コンパイルエラーでToneライブラリのPathが出てきている。
READMEの絵を見てみると、Aruduinoを想定してるっぽい。

ということで、Toneライブラリの対象マイコンではなかったため、Raspberry Pi Picoでは使えないことが分かった。
## toneライブラリを自作する
そこで、自作Tone(Raspberry Pi Pico用)を作ってしまおうと思い至った。

圧電ブザーの原理の部分で述べたが、所定の周波数でON/OFFを繰り返すことができれば決めた音程で音を奏でられる。
それを実現する技術として、PWMというものがある。
ON/OFF信号(Pulse)の時間幅(Width)を変化(Modulation)させるという意味である。

時間幅、というより周期といったほうが個人的にはしっくり来る。
ON/OFFの周期が短いほど時間幅が短くなり、ブザーは音が高くなる。

音を奏でるためにはかなり高速でON/OFFを繰り返す必要がある。
具体的な音で述べると、A4(ラ)は440[Hz]であり、1秒間に440回ON/OFFを繰り返している。

このPWMの仕組みを用いて、toneライブラリを作成した。
具体的には、以下の2つを作成した。
* 周波数定義
* PWMを使用したブザーを鳴らす関数

### toneライブラリの構成要素1：周波数の定義

toneライブラリの構成要素の1つとして、音と周波数の対応がある。
具体的なコードで言うと、`#define NOTE_A4 440`がそれにあたる。

これはあくまでNOTE_A4を440として扱うだけなので、なぜそのような迂遠なことをするかと思うかもしれない。
楽譜を書いていると、ドレミファソラシドの音階で色々考えるため、周波数は意識したくない。
そこで音階で考えるために、音階と周波数の対応を作っておくことで解決しているというもの。

でｈあ、どうやってこれを求めているか説明しよう。
例えば、440だとA4(ラ)だが、B4(シ)は494[Hz]である。

計算としてはこんな感じ。
$440\times\sqrt[12]{2}^2\simeq494[\textrm{Hz}]$

これは、平均律(ピアノとかで使われている音階の分け方)に依るもので、
* 1オクターブ上は周波数が2倍になる
* 半音上がると周波数が定数倍になる
  * 半音上がる：ピアノの白黒含めて右隣の音
* 1オクターブは12半音上がったもの

これらを満足するような周波数テーブルが、平均律になっている。
半音上がると$\sqrt[12]{2}$倍になり、ラとシの関係としては、ラ→ラ#→シと2つ半音上がっている。
そのため、シの周波数のような計算になったのである。

つまり、シを表現したいのに、このような計算を一々やるのはクソ面倒くさいので、周波数定義を書いた。

[作成した周波数定義](https://github.com/Aramakishake/Mr.Yobikomi/blob/main/Mr_Yobikomi_for_RaspberryPiPico/MusicDefs.h)

### toneライブラリの構成要素2：tone関数

tone関数はブザーを鳴らす関数である。
tone関数はArduino IDEにあり、これも同様に音が奏でられるものの、複数のブザーを鳴らすことができない。
参考：https://nobita-rx7.hatenablog.com/entry/28248243

今回、複数のブザーをハモらせたい(メロディとベース)という欲求から、このtone関数を大人しく使うことを拒んだ。
ということで、PWM関数を駆使して、ブザーを奏でる関数を作成した。
実際のソースとしてはこの部分。

いくつか階層になっているので、分けて解説する。
まず楽譜データに関して。
```
// 【データ部】
// Note構造体
struct Note {
  uint melodyFreq;  // メロディの音程[Hz]
  uint bassFreq;    // ベースの音程[Hz]
  uint duration;    // 鳴らす時間[ms]
};

// score配列(楽譜)
Note score[] = {
  // ララーシラファ#ラ (D)
  {NOTE_A4  , NOTE_D3  , OEIGHTH },
  {NOTE_A4  , NOTE_A3  , OEIGHTH },
  {NOTE_A4  , NOTE_FS3 , OEIGHTH },
  {NOTE_B4  , NOTE_A3  , OEIGHTH },
  {NOTE_A4  , NOTE_D3  , OEIGHTH },
  {NOTE_FS4 , NOTE_A3  , OEIGHTH },
  {NOTE_A4  , NOTE_FS3 , OEIGHTH },
  {NOTE_A4  , NOTE_A3  , OEIGHTH },
}
```
Note構造体は楽譜における一部を表現している。
「どの音(メロディ・ベース)をどの時間鳴らすか」というのがNoteである。
また、その配列(複数の集まり)がscore(楽譜)である。

関数部が作れていれば、scoreを書いて使い回すことができる。

次に、関数部について説明する。こちらも仕事が大きい順に関数を書いている。
上にある関数が下にある関数を読んでいる。
関数の構造としてはこう。
```
playMrYobikomiPWM()
┗playNote()
 ┗setPWMTone()
```
ソースの中身をコメント付きで書くとこんな感じ。
```
// 【関数部】

// score配列の長さを取得
const int scoreLength = sizeof(score) / sizeof(score[0]);

// scoreを演奏する関数
void playMrYobikomiPWM() {
  for (int i = 0; i < scoreLength; i++) {
    playNote(score[i]);
  }
}

// Noteを演奏する関数
void playNote(const Note& note)
{
    setPWMTone(PIEZO,  note.melodyFreq);
    setPWMTone(PIEZO2, note.bassFreq);
    delay(note.duration);
}

// Noteを演奏停止する関数
void stopPWMTone(uint pin)
{
    uint slice = pwm_gpio_to_slice_num(pin);
    pwm_set_enabled(slice, false);
    // 念のためLOWに戻す
    digitalWrite(pin, LOW);
}

// 圧電ブザーをPWMで鳴らす関数
void setPWMTone(uint pin, uint freq)
{
  // 指定したGPIOピンが属するPWMスライス番号を取得
  uint slice = pwm_gpio_to_slice_num(pin);

  // スライス内のA/Bどちらのチャネルかを取得
  uint channel = pwm_gpio_to_channel(pin);

  // GPIOを通常の入出力ではなくPWM機能に切り替える
  gpio_set_function(pin, GPIO_FUNC_PWM);

  // 周波数0HzならPWM停止
  if (freq == 0) {
      pwm_set_enabled(slice, false);
      return;
  }

  // PicoのPWM元クロック(125MHz)
  uint32_t clock = 125000000;

  // PWMクロックを16分周する
  uint32_t divider = 16;

  // PWM周期を決定するカウンタ上限値(wrap)
  // wrapまで数えたら0に戻る
  uint32_t wrap = clock / divider / freq;

  // PWMクロック分周比を設定
  pwm_set_clkdiv(slice, divider);

  // PWM周期(カウンタ上限値)を設定
  pwm_set_wrap(slice, wrap);

  // デバッグ表示
  Serial.print("slice=");
  Serial.println(slice);

  // Duty比50%に設定
  // wrap/2 でON時間
}
```
## メロディデータを用意する

## Q.車輪の再発明だったのか

A.はい
ただ、それでいいとも思っている。
というのも、労働など利益を求める集団においては無駄な工数だが、これは個人的に楽しみのためにやっている。
また、この記事を書く種にもなり、またPWMに関して学習することができたので良いんじゃないかと思っている。

# おわりに
## まとめ
- 今回はYoutubeにて発掘した「オリビアを聴きながら」の列車接近音のメロディから、電子工作しようと思い至った。
- かつて作成したMr.Yobikomiプロジェクトを流用したが、使用していたライブラリがAVR(Aruduino Unoなどのマイコン)でしか動かないと分かった。
- Raspberry Pi Pico用にライブラリで使用していた処理や定数を自作する必要があったため自作した。
- 改めて顧みるとこれは車輪の再発明であったが、学びとしては良いんじゃない？という考え

## 所感
- 机が狭い中で電子工作をすると、はんだごてが結構怖い位置に置かれるため、新しい机を買いたい。
  - 机の端っこにはんだごて台と先端が370℃のはんだごてが置かれる。
- 部品が散逸しているので、仕分けを行っていく必要があるなと思った。
