[BITS 16]
[ORG 0x7C00]

start:
    ; ===== inicjalizacja =====
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; ===== tekst startowy =====
    mov si, boot_msg
.print:
    lodsb
    cmp al, 0
    je load_kernel
    mov ah, 0x0E
    int 0x10
    jmp .print

; ===== ładowanie kernela =====
load_kernel:
    mov ah, 0x02      ; BIOS read
    mov al, 2         ; liczba sektorów kernela
    mov ch, 0
    mov cl, 2         ; kernel zaczyna się od sektora 2
    mov dh, 0
    mov dl, 0x00      ; pierwszy dysk
    mov bx, 0x1000    ; adres kernela

    xor ax, ax
    mov es, ax

    int 0x13
    jc disk_error

    ; ===== skok do kernela =====
    jmp 0x0000:0x1000

; ===== błąd dysku =====
disk_error:
    mov si, err_msg
.err:
    lodsb
    cmp al, 0
    je $
    mov ah, 0x0E
    int 0x10
    jmp .err

boot_msg db "NeutronOS booting...",13,10,0
err_msg  db "Disk error! Kernel not found.",0

times 510-($-$$) db 0
dw 0xAA55
