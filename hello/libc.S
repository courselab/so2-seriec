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

.section .text

putc:	
	mov $0x0e, %ah
	mov %cl, %al
	int $0x10
	ret

	ret
