#    SPDX-FileCopyrightText: 2025 Arthur Grillo <arthurgrillo@riseup.net>
#   
#    SPDX-License-Identifier: GPL-3.0-or-later
#
#  This file is a derivative of SYSeg (https://gitlab.com/monaco/syseg)
#  and includes modifications made by the following author(s):
#  Arthur Grillo <arthurgrillo@riseup.net>

/* Suppose we receive the argument in %cx. */
.code16gcc
.global printf

.section .text

printf:	
	mov   %cx, %bx

	mov   $0x0e, %ah
	mov   $0x0, %si
loop:
	mov   (%bx, %si), %al
	cmp   $0x0, %al
	je    end
	int   $0x10
	add   $0x1, %si
	jmp   loop
end:
	mov %si, %ax
	ret
