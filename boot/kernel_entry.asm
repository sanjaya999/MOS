[BITS 32]
[EXTERN kernel_main]  ; Tell assembler this function is defined elsewhere 

global _start         

_start:
    ; Set up stack (kernel needs a proper stack)
    mov esp, 0x90000
    
    cld
    
    ; Call our C kernel
    call kernel_main
    
    ; If kernel returns, hang
    cli
    hlt
    jmp $                 