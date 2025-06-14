#    SPDX-FileCopyrightText: 2025 Arthur Grillo <arthurgrillo@riseup.net>
#   
#    SPDX-License-Identifier: GPL-3.0-or-later
#
#  This file is a derivative of SYSeg (https://gitlab.com/monaco/syseg)
#  and includes modifications made by the following author(s):
#  Arthur Grillo <arthurgrillo@riseup.net>

/* Suppose we receive the argument in %cx. */
.code16gcc
.global putc
.global get_convmem
.global get_rtc

.section .text

putc:	
	mov $0x0e, %ah
	mov %cl, %al
	int $0x10
	ret

get_convmem:
	int $0x12
	ret

get_rtc: 
	push %cx
	mov $0x02, %ah
	int $0x1a
	mov %cx, %ax
	pop %cx
	ret
