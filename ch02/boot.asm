[org 0x7C00]
[bits 16]
;        jmp 0x07C0:start        ; far jmpする

start:
        mov ax, cs              ; csには0x07C0が入っている
        mov ds, ax              ; dsをcsと同じくする

        mov ax, 0xB800          ; ビデオメモリのセグメントを
        mov es, ax              ; esレジスタに入れる。
        mov di, 0               ; 一番上の頭の部分から書く
        mov ax, word[msgBack]   ; 書く予定のデータのアドレスを指定する
        mov cx, 0x7FF           ; 画面全体に書くためには
                                ; 0x7FF(10進数 2047)個のWORDが必要
    
paint:
        mov word[es:di], ax     ; ビデオメモリに書く
        add di, 2               ; 1つのWORDを書いたら2を加える
        dec cx                  ; 1つのWORDを書いたらCXの値を1つ引く
        jnz paint               ; CXが0じゃないとpaintにジャンプし残りを書く

        mov edi, 0              ; 一番上の頭の部分に書く
        mov byte[es:edi], 'B'   ; ビデオメモリに書く
        inc edi                 ; 1つのBYTEを書いたら1を加える
        mov byte[es:edi], 0x06  ; 背景色を書く
        inc edi                 ; 1つのBYTEを書いたら1を加える
        mov byte[es:edi], 'o'
        inc edi
        mov byte[es:edi], 0x06
        inc edi
        mov byte[es:edi], 'o'
        inc edi
        mov byte[es:edi], 0x06
        inc edi
        mov byte[es:edi], 't'
        inc edi
        mov byte[es:edi], 0x06
        inc edi

        jmp $                   ; ここで無限ループに入る

msgBack db  '.', 0x67           ; 背景に使う文字

times   510-($-$$)  db  0       ; ここから509番地まで0で詰める
        dw  0xAA55              ; 510番地に0x55、511番地に0xAAを入れる
