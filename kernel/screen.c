#include "include/screen.h"
#include "include/types.h"

static char* video_memory = (char*)VIDEO_MEMORY;
static int cursor_x = 0;
static int cursor_y = 0;

void clear_screen() {
    int i;
    for (i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT * 2; i += 2) {
        video_memory[i] = ' ';     
        video_memory[i + 1] = WHITE_ON_BLACK;  
    }
    cursor_x = 0;
    cursor_y = 0;
}

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

void print(const char* str) {
    while (*str) {
        putchar(*str);
        str++;
    }
}