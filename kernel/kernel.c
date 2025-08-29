// kernel.c - Main kernel code

#include "include/screen.h"
#include "include/shell.h"

void kernel_main() {
    // Clear screen and show welcome message
    clear_screen();
    
    print("Welcome to MOS Kernel v1.0!\n");
    print("Successfully transitioned from assembly to C!\n");
    print("Kernel loaded at: 0x2000\n");
    print("Video memory at: 0xB8000\n");
    print("\n");
    print("System Information:\n");
    print("- 32-bit protected mode: Active\n");
    print("- GDT: Loaded\n");
    print("- A20 line: Enabled\n");
    print("\n");
    
    // Start simple shell
    print("Starting command shell...\n");
    print("Type 'h' for help\n");
    
    
    print("\nKernel exiting...\n");
    while(1) {
        asm volatile("cli; hlt");
    }
}