
;FOR LEGACY BOOT SYSTEMS ONLY

[BITS 16]
[ORG 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov ax , 0x0003 ; Set video mode to 80x25 text mode
    int 0x10

    call delay_short

    mov ax, 0x0600 
    mov bh, 0x07   ; Set attribute to light gray on black
    mov cx, 0x0000 
    mov dx, 0x184F 
    int 0x10     

    call delay_short  

    mov ah, 0x02 ;set cursor position
    mov bh, 0x00
    mov dx, 0x0000
    int 0x10

    mov si, boot_msg ;show boot message
    call print_string

    call load_second_stage ;call second stage

    mov si, load_error_msg
    call print_string
    jmp hang

delay_short:
    push cx
    mov cx, 0x1000      
.delay_loop:
    nop
    nop
    loop .delay_loop
    pop cx
    ret

;<---------------loading second stage from disk------------------------>
load_second_stage:
    mov si, loading_msg
    call print_string

    mov ah, 0x00
    mov dl, 0x80
    int 0x13  ; 0x13 calls bios disk services
    jc .disk_error

    mov ah, 0x02
    mov al, 4
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    mov dl, 0x80
    mov bx, 0x1000 ;load to 0x1000:0
    int 0x13
    jc .disk_error

    cmp word [0x1000], 0
    je .load_error

    mov si, success_msg2
    call print_string

    jmp 0x1000
    
.disk_error:
    mov si, disk_error_msg
    call print_string
    jmp hang

.load_error:
    mov si, verify_error_msg
    call print_string
    jmp hang

print_string:
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
.loop:
    lodsb ;load byte from si into al than increment si
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

hang:
    hlt
    jmp hang
    




boot_msg db 'MOS Bootloader Starting...', 13, 10, 0
verify_error_msg db 'Second stage verification failed!', 13, 10, 0
load_error_msg db "MOS bootloader v1.0", 13,10,0
loading_msg     db 'Loading second stage...', 13, 10, 0
disk_error_msg  db 'Disk read error!', 13, 10, 0
success_msg2     db 'Second stage loaded! Jumping...', 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55


