# OSカーネル学習用

OSカーネル学習記録を残すためのリポジトリ。

## アセンブル
nasm -f bin -o [出力ファイル名].bin [ソースファイル]

## フロッピーディスクへの書き込み
dd if=[対象ファイル] of=[フロッピーディスクデバイス] bs=512 count=1 seek=0 conv=sync


***
手元の環境ではHyper-Vの仮想フロッピーディスクを用意し、bash on Ubuntu on Windowsのddを使って書き込んだ。
そのままの手順ではHyper-Vがvfdファイルを認識できなかったので、以下の手順でvfdファイルを作成した。Windowsのbashからddで書き込むと、作成したvfdの容量が1,440KBにならなかったので、これが原因なの？

`dd if=/dev/zero of=./pad bs=512 count=2879 seek=0`

padは環境に合わせ、パスを指定して作成する。
ここではアセンブルしたファイルと同じ位置を想定している。
これはブートコード分の512バイトを除いたファイル。

先頭にアセンブルしたブートコードを結合して、ブート用のvfdを作成。

`cat [対象ファイル] pad > boot.vfd`


***
Chapter02からはkernel.bin分の容量も減らしてkpadという調整用のファイルを準備した。

`dd if=/dev/zero of=./kpad bs=5 count=294793 seek=0`

