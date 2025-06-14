#    SPDX-FileCopyrightText: 2021 Monaco F. J. <monaco@usp.br>
#    SPDX-FileCopyrightText: 2025 Arthur Grillo <arthurgrillo@riseup.net>
#   
#    SPDX-License-Identifier: GPL-3.0-or-later
#
#  This file is a derivative of SYSeg (https://gitlab.com/monaco/syseg)
#  and includes modifications made by the following author(s):
#  Arthur Grillo <arthurgrillo@riseup.net>

CC=gcc
MAKE=make

this: hello.bin

this: hello.bin

main.o : main.c
	gcc -m16 -Os -Wall -fno-pic -fno-asynchronous-unwind-tables -c $< -fno-builtin -nostdinc -I. -o $@ 

libc.o : libc.S
	gcc -m16 -Os -Wall -fno-pic -fno-asynchronous-unwind-tables -c $< -fno-builtin -o $@

crt0.o : crt0.S
	gcc -m16 -Os -Wall -fno-pic -fno-asynchronous-unwind-tables -c $< -fno-builtin -o $@

hello.bin : main.o libc.o | crt0.o hello.ld
	gcc -m16 -Os $^ -nostartfiles -nostdlib -T hello.ld -orphan-handling=discard -o $@




#
# Housekeeping
#

clean:
	rm -f  *.bin *.elf *.o *.s *.iso *.img *.i kh
	make clean-extra


# SYSeg's  convenience rules (not related to the example itself)
include bintools.mk
