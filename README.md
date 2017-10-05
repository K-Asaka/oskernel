# OSカーネル学習用

OSカーネル学習記録を残すためのリポジトリ。

## アセンブル
nasm -f bin -o [出力ファイル名].bin [ソースファイル]

## フロッピーディスクへの書き込み
dd if=[対象ファイル] of=[フロッピーディスクデバイス] bs=512 count=1 seek=0 conv=sync

手元の環境ではHyper-Vの仮想フロッピーディスクを用意し、bash on Ubuntu on Windowsのddを使って書き込んだ。
ofには/mnt/ドライブ名/仮想フロッピーディスクへのパスを指定。
