#!/bin/bash
set -xue

CC=/usr/local/opt/llvm/bin/clang
OBJCOPY=/opt/local/bin/llvm-objcopy-mp-9.0

CFLAGS="-std=c11 -O2 -g3 -Wall -Wextra -Werror \
  --target=riscv32-unknown-elf -march=rv32imac -mabi=ilp32 \
  -ffreestanding -nostdlib -fuse-ld=lld"

# shell をビルド
$CC $CFLAGS -Wl,-T,user.ld -Wl,-Map=shell.map -o shell.elf shell.c user.c common.c
$OBJCOPY --set-section-flags .bss=alloc,contents -O binary shell.elf shell.bin
$OBJCOPY -I binary -O elf32-littleriscv -B riscv:rv32 shell.bin shell.bin.o

# kernel をビルド
$CC $CFLAGS -Wl,-T,kernel.ld -Wl,-Map=kernel.map -o kernel.elf kernel.c common.c shell.bin.o

# 実行
qemu-system-riscv32 -machine virt -bios default -nographic -serial mon:stdio --no-reboot \
  -d unimp,guest_errors,int,cpu_reset -D qemu.log \
  -drive id=drive0,file=lorem.txt,format=raw,if=none \
  -device virtio-blk-device,drive=drive0,bus=virtio-mmio-bus.0 \
  -kernel kernel.elf
