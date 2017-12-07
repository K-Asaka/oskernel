%include "init.inc"

[org 0x10000]
[bits 16]

start:
        cld                             ; Advance = inc
        mov     ax, cs
        mov     ds, ax
        xor     ax, ax
        mov     ss, ax

        xor     ebx, ebx
        lea     eax, [tss1]             ; EAXにtss1の物理アドレスを入れる
        add     eax, 0x10000
        mov     [descriptor4 + 2], ax
        shr     eax, 16
        mov     [descriptor4 + 4], al
        mov     [descriptor4 + 7], ah

        lea     eax, [tss2]             ; EAXにtss2の物理アドレスを入れる
        add     eax, 0x10000
        mov     [descriptor5 + 2], ax
        shr     eax, 16
        mov     [descriptor5 + 4], al
        mov     [descriptor5 + 7], ah

        cli
        lgdt    [gdtr]

        mov     eax, cr0
        or      eax, 0x00000001
        mov     cr0, eax

        jmp     $ + 2
        nop
        nop

        jmp     dword   SysCodeSelector:PM_Start

[bits 32]

PM_Start:
        mov     bx, SysDataSelector
        mov     ds, bx
        mov     es, bx
        mov     fs, bx
        mov     gs, bx
        mov     ss, bx

        lea     esp, [PM_Start]

        mov     ax, TSS1Selector
        ltr     ax
        lea     eax, [process2]
        mov     [tss2_eip], eax
        mov     [tss2_esp], esp

        jmp     TSS2Selector:0
        ; 再びタスクスイッチングされるとここに戻る

        mov     edi, 80 * 2 * 9
        lea     esi, [msg_process1]
        call    printf
        jmp     $

;**********
; Subroutines
;**********
printf:
        push    eax
        push    es
        mov     ax, VideoSelector
        mov     es, ax
printf_loop:
        mov     al, byte [esi]
        mov     byte [es:edi], al
        inc     edi
        mov     byte [es:edi], 0x06
        inc     esi
        inc     edi
        or      al, al
        jz      printf_end
        jmp     printf_loop
printf_end:
        pop     es
        pop     eax
        ret

process2:
        mov     edi, 80 * 2 * 7
        lea     esi, [msg_process2]
        call    printf
        jmp     TSS1Selector:0

;*****
; Data Area
;*****

msg_process1    db  "This is System Process 1", 0
msg_process2    db  "This is System Process 2", 0

gdtr:
        dw      gdt_end - gdt - 1
        dd      gdt
gdt:
        dd      0, 0
        dd      0x0000FFFF, 0x00CF9A00
        dd      0x0000FFFF, 0x00CF9200
        dd      0x8000FFFF, 0x0040920B

descriptor4:
        dw      104
        dw      0
        db      0
        db      0x89
        db      0
        db      0

descriptor5:
        dw      104
        dw      0
        db      0
        db      0x89
        db      0
        db      0

gdt_end:

tss1:
        dw      0, 0            ; 以前のタスクへのback link
        dd      0               ; ESP0
        dw      0, 0            ; SS0, 使用なし
        dd      0               ; ESP1
        dw      0, 0            ; SS1, 使用なし
        dd      0               ; ESP2
        dw      0, 0            ; SS2, 使用なし
        dd      0, 0, 0         ; CR3, EIP, EFLAGS
        dd      0, 0, 0, 0      ; EAX, ECX, EDX, EBX
        dd      0, 0, 0, 0      ; ESP, EBP, ESI, EDI
        dw      0, 0            ; ES, 使用なし
        dw      0, 0            ; CS, 使用なし
        dw      0, 0            ; SS, 使用なし
        dw      0, 0            ; DS, 使用なし
        dw      0, 0            ; FS, 使用なし
        dw      0, 0            ; GS, 使用なし
        dw      0, 0            ; LDT, 使用なし
        dw      0, 0            ; デバッグ用のTビット, IO許可ビットマップ

tss2:
        dw      0, 0            ; 以前のタスクへのback link
        dd      0               ; ESP0
        dw      0, 0            ; SS0, 使用なし
        dd      0               ; ESP1
        dw      0, 0            ; SS1, 使用なし
        dd      0               ; ESP2
        dw      0, 0            ; SS2, 使用なし
        dd      0
tss2_eip:
        dd      0, 0            ; EIP, EFLAGS (EFLAGS=0x200 for ints)
        dd      0, 0, 0, 0
tss2_esp:
        dd      0, 0, 0, 0      ; ESP, EBP, ESI, EDI
        dw      SysDataSelector, 0  ; ES, 使用なし
        dw      SysCodeSelector, 0  ; CS, 使用なし
        dw      SysDataSelector, 0  ; SS, 使用なし
        dw      SysDataSelector, 0  ; DS, 使用なし
        dw      SysDataSelector, 0  ; FS, 使用なし
        dw      SysDataSelector, 0  ; GS, 使用なし
        dw      0, 0                ; LDT, 使用なし
        dw      0, 0                ; デバッグ用のTビット, IO許可ビットマップ

times   1024-($-$$) db  0