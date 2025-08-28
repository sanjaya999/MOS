// kernel.c - Main kernel code

// Video memory starts at 0xB8000
#define VIDEO_MEMORY 0xB8000
#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 25

// Colors for terminal
#define WHITE_ON_BLACK 0x0F
#define GREEN_ON_BLACK 0x0A
#define RED_ON_BLACK   0x0C

// Terminal state
static char* video_memory = (char*)VIDEO_MEMORY;
static int cursor_x = 0;
static int cursor_y = 0;

// Clear the screen
void clear_screen() {
    int i;
    for (i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT * 2; i += 2) {
        video_memory[i] = ' ';     
        video_memory[i + 1] = WHITE_ON_BLACK;  
    }
    cursor_x = 0;
    cursor_y = 0;
}

// Print a single character
void putchar(char c) {
    if (c == '\n') { 
        cursor_x = 0;
        cursor_y++;
        if (cursor_y >= SCREEN_HEIGHT) {
            cursor_y = SCREEN_HEIGHT - 1;
            // Simple scroll: move everything up one line
            int i;
            for (i = 0; i < (SCREEN_HEIGHT - 1) * SCREEN_WIDTH * 2; i++) {
                video_memory[i] = video_memory[i + SCREEN_WIDTH * 2];
            }
            // Clear last line
            for (i = (SCREEN_HEIGHT - 1) * SCREEN_WIDTH * 2; 
                 i < SCREEN_HEIGHT * SCREEN_WIDTH * 2; i += 2) {
                video_memory[i] = ' ';
                video_memory[i + 1] = WHITE_ON_BLACK;
            }
        }
        return;
    }

    int position = (cursor_y * SCREEN_WIDTH + cursor_x) * 2;
    video_memory[position] = c;
    video_memory[position + 1] = WHITE_ON_BLACK;
    
    cursor_x++;
    if (cursor_x >= SCREEN_WIDTH) {
        cursor_x = 0;
        cursor_y++;
    }
}

// Print a string
void print(const char* str) {
    while (*str) {
        putchar(*str);
        str++;
    }
}

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

// Main kernel function - this is called from assembly
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
    
    
    // Should never reach here
    print("\nKernel exiting...\n");
    while(1) {
        asm volatile("cli; hlt");
    }
}