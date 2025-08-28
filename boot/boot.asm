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
    call load_kernel       ;load kernel too!

    mov si, load_error_msg
    call print_string
    jmp hang

delay_short:
    push cx
    mov cx, 0x5000      ; Increased delay to see messages
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
    int 0x13  ; Reset disk
    jc .disk_error

    ; Load second stage (sectors 2-5 to 0x1000)
    mov ah, 0x02
    mov al, 4          ; Load 4 sectors 
    mov ch, 0x00       ; Cylinder 0
    mov cl, 0x02       ; Start from sector 2
    mov dh, 0x00       ; Head 0
    mov dl, 0x80       ; Drive 0x80 (first hard disk)
    mov bx, 0x1000     ; Load to 0x1000:0
    int 0x13
    jc .disk_error

    cmp word [0x1000], 0
    je .load_error

    mov si, success_msg2
    call print_string
    call delay_short

    ret    ; Return instead of jumping - we need to load kernel too
    
.disk_error:
    mov si, disk_error_msg
    call print_string
    jmp hang

.load_error:
    mov si, verify_error_msg
    call print_string
    jmp hang

;<---------------loading kernel from disk------------------------->
load_kernel:
    mov si, loading_kernel_msg
    call print_string

    ; Load kernel (sectors 6-15 to 0x2000) 
    mov ah, 0x02
    mov al, 10         ; Load 10 sectors 
    mov ch, 0x00       ; Cylinder 0
    mov cl, 0x06       ; Start from sector 6 (after boot + stage2)
    mov dh, 0x00       ; Head 0
    mov dl, 0x80       ; Drive 0x80
    mov bx, 0x2000     ; Load to 0x2000:0
    int 0x13
    jc .kernel_disk_error

    cmp word [0x2000], 0
    je .kernel_load_error

    mov si, kernel_success_msg
    call print_string
    call delay_short

    ; Now jump to second stage
    jmp 0x1000
    
.kernel_disk_error:
    mov si, kernel_disk_error_msg
    call print_string
    jmp hang

.kernel_load_error:
    mov si, kernel_verify_error_msg
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

boot_msg                db 'MOS Bootloader Starting...', 13, 10, 0
verify_error_msg        db 'Second stage verification failed!', 13, 10, 0
load_error_msg          db "MOS bootloader v1.0", 13,10,0
loading_msg             db 'Loading second stage...', 13, 10, 0
disk_error_msg          db 'Disk read error!', 13, 10, 0
success_msg2            db 'Second stage loaded!', 13, 10, 0
loading_kernel_msg      db 'Loading kernel...', 13, 10, 0
kernel_success_msg      db 'Kernel loaded successfully!', 13, 10, 0
kernel_disk_error_msg   db 'Kernel disk read error!', 13, 10, 0
kernel_verify_error_msg db 'Kernel verification failed!', 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55