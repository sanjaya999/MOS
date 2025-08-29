#include "include/shell.h"
#include "include/screen.h"

char getchar() {
    volatile int i;
    for (i = 0; i < 10000000; i++);
    return 'y';
}

void delay() {
    volatile int i;
    for (i = 0; i < 10000000; i++) {
       
    }
}



void run_shell() {
    print("MOS> ");
    
    while (1) {
        char input = getchar();
        
        if (input == 'h') {
            print("\nAvailable commands:\n");
            print("  h - help\n");
            print("  c - clear screen\n");  
            print("  r - reboot\n");
            print("MOS> ");
        }
        else if (input == 'c') {
            clear_screen();
            print("MOS Kernel v1.0\n");
            print("Type 'h' for help\n");
            print("MOS> ");
        }
        else if (input == 'r') {
            print("\nRebooting...\n");
            // Simple reboot via keyboard controller
            asm volatile("mov $0xFE, %al; out %al, $0x64");
        }
        else {
            print("\nUnknown command. Type 'h' for help.\n");
            print("MOS> ");
        }
    }
}