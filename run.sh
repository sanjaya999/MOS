#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building bootloader...${NC}"
cd boot

# Build first stage
if [ ! -f "boot.asm" ]; then
    echo -e "${RED}Error: boot.asm not found!${NC}"
    exit 1
fi

nasm -f bin boot.asm -o boot.bin
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to assemble boot.asm${NC}"
    exit 1
fi

# Build second stage
if [ ! -f "boot2.asm" ]; then
    echo -e "${RED}Error: boot2.asm not found!${NC}"
    exit 1
fi

nasm -f bin boot2.asm -o boot2.bin
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to assemble boot2.asm${NC}"
    exit 1
fi

echo -e "${GREEN}Both stages built successfully${NC}"

# Create complete disk image
echo -e "${YELLOW}Creating disk image...${NC}"
dd if=/dev/zero of=disk.img bs=512 count=20 2>/dev/null

# Write first stage (bootloader) to sector 1
dd if=boot.bin of=disk.img bs=512 count=1 conv=notrunc 2>/dev/null

# Write second stage to sectors 2-5 (where your bootloader expects it)  
dd if=boot2.bin of=disk.img bs=512 seek=1 count=4 conv=notrunc 2>/dev/null

echo -e "${GREEN}Complete bootloader created: disk.img${NC}"

# Check file sizes
boot1_size=$(stat -c%s "boot.bin" 2>/dev/null || stat -f%z "boot.bin" 2>/dev/null)
boot2_size=$(stat -c%s "boot2.bin" 2>/dev/null || stat -f%z "boot2.bin" 2>/dev/null)

echo "Stage 1 size: ${boot1_size} bytes (should be 512)"
echo "Stage 2 size: ${boot2_size} bytes (should be ≤ 2048)"

if [ "$boot1_size" -ne 512 ]; then
    echo -e "${RED}Warning: Stage 1 should be exactly 512 bytes!${NC}"
fi

echo -e "${YELLOW}Testing in QEMU...${NC}"
echo "Press Ctrl+Alt+G to release mouse, Ctrl+Alt+Q to quit"

# Use disk image instead of just boot.bin
qemu-system-i386 -hda disk.img