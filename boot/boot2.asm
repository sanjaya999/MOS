[BITS 16]
[ORG 0x1000]

second_stage_start:

    mov si , stage2_msg
    call print_string_16

    call enable_a20

    lgdt [gdt_descriptor] ;rule for 32 bit

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp CODE_SEG:protected_mode_start

print_string_16:
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

enable_a20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

[BITS 32]
protected_mode_start:
    MOV ax,  DATA_SEG
    MOV ds, ax
    MOV es, ax
    MOV fs, ax
    MOV gs, ax
    MOV ss, ax

    mov ebp, 0x90000
    mov esp, ebp

    mov esi, protected_msg
    call print_string_32

    mov esi, kernel_check_msg
    call print_string_32
    
    ; Check first few bytes at 0x2000
    mov eax, [0x2000]
    cmp eax, 0
    jne kernel_found
    
    ; Kernel not found!
    mov esi, kernel_missing_msg
    call print_string_32
    jmp halt_system

kernel_found:
    mov esi, kernel_found_msg
    call print_string_32
    
    ; Add a small delay before jumping
    mov ecx, 0x1000000
delay_loop:
    nop
    loop delay_loop
    
    mov esi, jumping_msg
    call print_string_32

    call 0x2000 ;kernel entry point

    mov esi, kernel_returned_msg
    call print_string_32

halt_system:
    cli 
    hlt
    jmp halt_system

print_string_32:
    pusha
    mov edx, 0xb8000   
.loop:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0F       
    mov [edx], ax
    add edx, 2
    jmp .loop
.done:
    popa
    ret

;Global Descriptor Table
gdt_start:
gdt_null:      ;null segment
    dd 0x0
    dd 0x0
gdt_code:      ;code segment
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10011010b 
    db 11001111b 
    db 0x0
gdt_data:      ;data segment
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10010010b 
    db 11001111b 
    db 0x0
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

stage2_msg          db 'Second stage loaded!', 13, 10, 0
protected_msg       db 'Entered 32-bit protected mode!', 0
kernel_check_msg    db 'Checking kernel at 0x2000...', 0
kernel_missing_msg  db 'ERROR: No kernel found at 0x2000!', 0
kernel_found_msg    db 'Kernel found! ', 0
jumping_msg         db 'Jumping to kernel...', 0
kernel_returned_msg db 'ERROR: Kernel returned unexpectedly!', 0

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

times 2048-($-$$) db 0