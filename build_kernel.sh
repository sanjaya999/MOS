#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Building MOS Kernel...${NC}"

mkdir -p build

if [ ! -f "boot/boot.asm" ]; then
    echo -e "${RED}Error: boot/boot.asm not found!${NC}"
    exit 1
fi

if [ ! -f "boot/boot2.asm" ]; then
    echo -e "${RED}Error: boot/boot2.asm not found!${NC}"
    exit 1
fi

if [ ! -f "boot/kernel_entry.asm" ]; then
    echo -e "${RED}Error: boot/kernel_entry.asm not found!${NC}"
    exit 1
fi

if [ ! -f "kernel/kernel.c" ]; then
    echo -e "${RED}Error: kernel/kernel.c not found!${NC}"
    exit 1
fi

if [ ! -f "kernel/linker.ld" ]; then
    echo -e "${RED}Error: kernel/linker.ld not found!${NC}"
    exit 1
fi

echo -e "${YELLOW}Building bootloader stage 1...${NC}"
nasm -f bin boot/boot.asm -o build/boot.bin
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to assemble boot.asm${NC}"
    exit 1
fi

echo -e "${YELLOW}Building bootloader stage 2...${NC}"
nasm -f bin boot/boot2.asm -o build/boot2.bin
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to assemble boot2.asm${NC}"
    exit 1
fi

echo -e "${YELLOW}Building kernel entry point...${NC}"
nasm -f elf32 boot/kernel_entry.asm -o build/kernel_entry.o
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to assemble kernel_entry.asm${NC}"
    exit 1
fi

echo -e "${YELLOW}Compiling C kernel...${NC}"
gcc -m32 -c kernel/kernel.c -o build/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -fno-pic -fno-pie
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to compile kernel.c${NC}"
    echo -e "${YELLOW}Try installing: sudo apt install gcc-multilib${NC}"
    exit 1
fi

echo -e "${YELLOW}Linking kernel...${NC}"
ld -m elf_i386 -T kernel/linker.ld -o build/kernel.bin build/kernel_entry.o build/kernel.o --oformat binary
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to link kernel${NC}"
    exit 1
fi

echo -e "${YELLOW}Creating disk image...${NC}"
dd if=/dev/zero of=build/disk.img bs=512 count=100 2>/dev/null

dd if=build/boot.bin of=build/disk.img bs=512 count=1 conv=notrunc 2>/dev/null

dd if=build/boot2.bin of=build/disk.img bs=512 seek=1 count=4 conv=notrunc 2>/dev/null

dd if=build/kernel.bin of=build/disk.img bs=512 seek=5 conv=notrunc 2>/dev/null

echo -e "${GREEN}Build complete!${NC}"

boot1_size=$(stat -c%s "build/boot.bin" 2>/dev/null || stat -f%z "build/boot.bin" 2>/dev/null)
boot2_size=$(stat -c%s "build/boot2.bin" 2>/dev/null || stat -f%z "build/boot2.bin" 2>/dev/null)  
kernel_size=$(stat -c%s "build/kernel.bin" 2>/dev/null || stat -f%z "build/kernel.bin" 2>/dev/null)

echo "File sizes:"
echo "  Bootloader Stage 1: ${boot1_size} bytes (should be 512)"
echo "  Bootloader Stage 2: ${boot2_size} bytes"
echo "  Kernel: ${kernel_size} bytes"

if [ "$boot1_size" -ne 512 ]; then
    echo -e "${RED}Warning: Stage 1 bootloader should be exactly 512 bytes!${NC}"
fi

echo -e "${YELLOW}Testing in QEMU...${NC}"
echo "Press Ctrl+Alt+G to release mouse, Ctrl+Alt+Q to quit QEMU"
qemu-system-i386 -hda build/disk.img