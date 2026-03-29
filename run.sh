#!/bin/bash
set -xue

CC=/usr/local/opt/llvm/bin/clang

$CC -std=c11 -O2 -g3 -Wall -Wextra -Werror --target=riscv32-unknown-elf -march=rv32imac -mabi=ilp32 \
    -ffreestanding -nostdlib -fuse-ld=lld -Wl,-T,kernel.ld -o kernel.elf kernel.c common.c

qemu-system-riscv32 -machine virt -bios default -nographic -serial mon:stdio \
    -kernel kernel.elf
