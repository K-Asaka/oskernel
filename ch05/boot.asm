%include "init.inc"

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
        mov     word [es:di], ax
        add     di, 2
        dec     cx
        jnz     paint

read:
        mov     ax, 0x1000      ; ES:BX = 1000:0000
        mov     es, ax
        mov     bx, 0

        mov     ah, 2           ; ディスクにあるデータをes:bxのアドレスに
        mov     al, 2           ; 2セクタを読む
        mov     ch, 0           ; 0番目のCylinder
        mov     cl, 2           ; 2番目のセクタから読み始める
        mov     dh, 0           ; Head = 0
        mov     dl, 0           ; Driver=0 A:ドライブ
        int     13h             ; 読む！

        jc      read            ; エラーになればやり直し

        mov     dx, 0x3F2       ; フロッピーディスクの
        xor     al, al          ; モーターの電源を切る
        out     dx, al

        jmp     0x1000:0000

msgBack db      '.', 0x67

times   510-($-$$)  db  0
        dw      0AA55h
