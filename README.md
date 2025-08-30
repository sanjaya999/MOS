*This project is designed for educational purposes to understand low-level system programming and OS development concepts.*

## (Mini Kernel)

A simple 32-bit bootloader and kernel written in C and Assembly. This is a basic kernel implementation with a two-stage bootloader, protected mode transition, and minimal shell interface - the foundation for building a full operating system.


##  Features

- **Custom Bootloader**: Two-stage bootloader written in x86 assembly
- **32-bit Protected Mode**: Full transition from 16-bit real mode to 32-bit protected mode
- **Modular Kernel**: Clean separation of concerns with dedicated modules for screen and shell

##  Project Structure

```
├── boot/                   # Bootloader components
│   ├── boot.asm           # Stage 1 bootloader (512 bytes, loaded by BIOS)
│   ├── boot2.asm          # Stage 2 bootloader (protected mode transition)
│   └── kernel_entry.asm   # Kernel entry point (C runtime setup)
├── kernel/                 # Kernel source code
│   ├── include/           # Header files
│   │   ├── screen.h       # Display function declarations
│   │   ├── shell.h        # Shell function declarations
│   │   └── types.h        # System constants and definitions
│   ├── kernel.c           # Main kernel logic
│   ├── screen.c           # VGA text mode display functions
│   ├── shell.c            # Command shell implementation
│   └── linker.ld          # Kernel linker script
├── build/                  # Build output directory
├── build_kernel.sh        # Automated build script
└── README.md              # This file
```

##  Prerequisites

### Required Tools
- **NASM**: Netwide Assembler for x86 assembly code
- **GCC**: GNU Compiler Collection with 32-bit support
- **LD**: GNU Linker
- **QEMU**: System emulator for testing (qemu-system-i386)

### Installation (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install nasm gcc-multilib qemu-system-x86
```

## Building

The project includes an automated build script that handles all compilation steps:

```bash
./build_kernel.sh
```

### Build Process Details

1. **Stage 1 Bootloader**: Assembles `boot.asm` into a 512-byte boot sector
2. **Stage 2 Bootloader**: Assembles `boot2.asm` for protected mode transition
3. **Kernel Entry**: Assembles `kernel_entry.asm` for C runtime setup
4. **Kernel Modules**: Compiles C source files with 32-bit target
5. **Linking**: Links all object files using custom linker script
6. **Disk Image**: Creates bootable disk image with proper sector layout



##  Architecture

### Boot Process
1. **BIOS**: Loads first 512 bytes to 0x7C00 and jumps to it
2. **Stage 1**: Sets up basic environment, loads stage 2 and kernel from disk
3. **Stage 2**: Enables A20 line, sets up GDT, switches to protected mode
4. **Kernel Entry**: Sets up stack, calls C kernel main function
5. **Kernel**: Initializes display system and starts interactive shell

### Kernel Modules
- **kernel.c**: Main kernel initialization and control flow
- **screen.c**: VGA text mode display functions with scrolling support
- **shell.c**: Interactive command processor with basic commands


