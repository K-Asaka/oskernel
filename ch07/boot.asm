%include        "init.inc"

[org 0]
    jmp     07C0h:start

start:
    mov     ax, cs
    mov     ds, ax
    mov     es, ax

    mov     ax, 0xB800
    mov     es, ax
    mov     di, 0
    mov     ax, word [msgBack]
    mov     cx, 0x7FF

paint:
    mov     word[es:di], ax
    add     di, 2
    dec     cx
    jnz     paint

read:
    mov     ax, 0x1000          ; ES:BX = 1000:0000
    mov     es, ax
    mov     bx, 0

    mov     ah, 2               ; ディスクにあるデータをes:bxのアドレスに
    mov     al, 2               ; 2セクタを読む予定
    mov     ch, 0               ; 0番目のCylinder
    mov     cl, 2               ; 2番目のセクタから読み始める
    mov     dh, 0               ; Head=0
    mov     dl, 0               ; Drive=0A:ドライブ
    int     13h                 ; 読む

    jc      read                ; エラーが発生すれば、やり直し
    
    mov     dx, 0x3F2           ; フロッピーディスクドライブの
    xor     al, al              ; モーターの電源を切る
    out     dx, al

    cli

    mov     al, 0x11            ; PICの初期化
    out     0x20, al            ; マスターPIC
    dw      0x00eb, 0x00eb      ; jmp $+2, jmp $+2
    out     0xA0, al            ; スレーブPIC
    dw      0x00eb, 0x00eb

    mov     al, 0x20            ; マスターPIC割り込み番号のスタート地点
    out     0x21, al
    dw      0x00eb, 0x00eb
    mov     al, 0x28            ; スレーブ PIC割り込み番号のスタート地点
    out     0xA1, al
    dw      0x00eb, 0x00eb

    mov     al, 0x04            ; マスターPICのIRQ2番に
    out     0x21, al            ; スレーブPICが繋がっている
    dw      0x00eb, 0x00eb
    mov     al, 0x02            ; スレーブPICがマスターPICの
    out     0xA1, al            ; IRQ2番に繋がっている
    dw      0x00eb, 0x00eb

    mov     al, 0x01            ; 8086モードを使用する
    out     0x21, al
    dw      0x00eb, 0x00eb
    out     0xA1, al
    dw      0x00eb, 0x00eb

    mov     al, 0xFF            ; スレーブPICのすべての割り込みを
    out     0xA1, al            ; 防いでおく
    dw      0x00eb, 0x00eb
    mov     al, 0xFB            ; マスターPICのIRQ2番を除いた
    out     0x21, al            ; すべての割り込みを防いでおく

    jmp     0x1000:0000

msgBack db  '.', 0x67

times   510-($-$$)  db  0
    dw  0AA55h
