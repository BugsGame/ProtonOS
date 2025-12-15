[BITS 16]
[ORG 0]

%define SCREEN_COLS 80

start:
    ; Krytyczne: ustaw DS=CS, ES=CS, SS=CS aby dane były widoczne dla lodsb
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7FFF

    ; Wyczyść ekran (scroll up cały 80x25, atrybut 0x07)
    mov ax, 0x0600
    mov bh, 0x07
    mov cx, 0
    mov dx, 0x184F
    int 0x10

    ; ===== Wyśrodkuj "ProtonOS" (czerwony) =====
    mov si, title
    call str_len            ; CX = długość napisu
    mov ax, SCREEN_COLS
    sub ax, cx
    shr ax, 1               ; AX = (80 - len) / 2
    mov dl, al              ; kolumna
    mov dh, 10              ; wiersz (około środka)
    mov bh, 0
    mov ah, 0x02
    int 0x10

    mov si, title
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x0C            ; jasnoczerwony
.print_title:
    lodsb
    test al, al
    jz print_author
    int 0x10
    jmp .print_title

print_author:
    ; ===== Wyśrodkuj "By Enlvis" (biały) poniżej =====
    mov si, author
    call str_len
    mov ax, SCREEN_COLS
    sub ax, cx
    shr ax, 1
    mov dl, al
    mov dh, 12
    mov bh, 0
    mov ah, 0x02
    int 0x10

    mov si, author
    mov ah, 0x0E
    mov bl, 0x0F            ; biały
.print_author_loop:
    lodsb
    test al, al
    jz hang
    int 0x10
    jmp .print_author_loop

hang:
    jmp hang

; ---- funkcja: długość ASCIIZ w SI -> CX ----
str_len:
    push si
    xor cx, cx
.len_loop:
    lodsb
    test al, al
    jz .done
    inc cx
    jmp .len_loop
.done:
    pop si
    ret

title  db "ProtonOS",0
author db "By Enlvis",0

; Padding: kernel = dokładnie 512B (1 sektor)
times 512-($-$$) db 0
