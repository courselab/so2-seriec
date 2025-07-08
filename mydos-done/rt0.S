#    SPDX-FileCopyrightText: 2021 Monaco F. J. <monaco@usp.br>
#    SPDX-FileCopyrightText: 2025 Arthur Grillo <arthurgrillo@riseup.net>
#   
#    SPDX-License-Identifier: GPL-3.0-or-later
#
#  This file is a derivative of SYSeg (https://gitlab.com/monaco/syseg)
#  and includes modifications made by the following author(s):
#  Arthur Grillo <arthurgrillo@riseup.net>

	.code16gcc		/* Select 16-bit code.                    */
	.global _start		/* This will be the program entry point.  */
	.global boot_drive	/* The drive where stage1 was loaded from.*/
	.text

	jmp _start		/* Provision for BIOSes that assume the   */
	. = . + 60		/* media is FAT and has a BBP in the MBR. */

_start:

	cli			/* Disable interruptions.                 */
        ljmp $0x0,$init0	/* Canonicalize %cs:%ip to 0000:7c000     */
init0:
        xorw %ax, %ax		/* Zero all other segement registers.     */
        movw %ax, %ds
        movw %ax, %es
        movw %ax, %fs
        movw %ax, %gs
        movw %ax, %ss
        mov $_END_STACK, %sp   	/* Set the stack right bellow the program.*/
	mov %dl, boot_drive	/* Save boot drive nunver for later.      */
        sti			/* Reenable interruptions.                */
        call boot		/* Call main().                           */
halt:				/* Upon main()'s return, halt.            */
        hlt
        jmp halt

	/* Notes.

	1) On boot, BIOS leave in %dl the number of the driver where the
	   bootstrap program was read from. We save it for later use by the
	   function that loads the next stage.

	2) Here we explore one useful feature of the linker. The symbol
	   _END_STACK is defined at the linker script.

	*/

	.section .data

boot_drive:
	.byte 0x0
