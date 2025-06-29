#    SPDX-FileCopyrightText: 2021 Monaco F. J. <monaco@usp.br>
#    SPDX-FileCopyrightText: 2025 Arthur Grillo <arthurgrillo@riseup.net>
#   
#    SPDX-License-Identifier: GPL-3.0-or-later
#
#  This file is a derivative of SYSeg (https://gitlab.com/monaco/syseg)
#  and includes modifications made by the following author(s):
#  Arthur Grillo <arthurgrillo@riseup.net>

	/* This source file implements a few low-level functions needed by
	   the bootloader, which are easier to write directly in assembly.
	   They are mostly procedures that invoke the BIOS services. Since
	   the machine code corresponding to both the bootloader and this are
	   subject to the 512-byte length limit, other low-level functions
	   not strictly required during the boot were set apart and
	   implemented in another source file (asm2.S) */


	.code16gcc
	.global clear, kwrite, fatal, load_kernel, halt, set_cursor

	.section .text

	## void clear(void)
	##
	## Clear the screen.

clear:
	pusha			/* Save all GP registers.              */
	mov $0x0600, %ax	/* Video service: scroll up.           */
	mov $0x07, %bh		/* Attribute (background/foreground).  */
	mov $0x00, %cx		/* Upper-left corner:   (0,0).         */
	mov $0x184f, %dx	/* Botton-right corner: (24,79).       */
	int $0x10		/* Call BIOS video service.            */

	mov $0x2, %ah		/* Video service: set cursor position. */
	mov $0x0, %bh		/* Select page number 0.               */
	mov $0x0, %dx		/* Set position (0,0).                 */
	int $0x10		/* Call BIOS video service.            */

	popa			/* Restore all GP-registers.           */
	ret

set_cursor:
	pusha
	/* and $0x0f, %cx */
	/* and $0x0f, %dx */
	movb %cl, %dh


	mov $0x2, %ah		/* Video service: set cursor position. */
	mov $0x0, %bh		/* Select page number 0.               */
	int $0x10		/* Call BIOS video service.            */
	popa
	ret

	## void kwrite(const char* msg)
	##
	## Print 'msg' onto the screen.

kwrite:
        pusha			/* Save all GP registers.              */

	mov %cx, %si		/* Get the start of the buffer in %si. */
        mov $0x0e, %ah          /* BIOS video service: TTY mode.       */
	mov $0x0, %bh		/* Select page 0.                      */
kwrite_loop:

	mov (%si), %al		/* Get each ASCII character.           */
        cmp $0x0, %al		/* End writing on 0.                   */
        je kwrite_end
        int $0x10		/* Call BIOS video service.            */

	cmp $0xa, %al		/* Automatically convert LF into CR+LF.*/
	jne kwrite_cont
	mov $0xd, %al
	int $0x10
kwrite_cont:

        inc %si			/* Point to the next character.        */
        jmp kwrite_loop
kwrite_end:
        popa			/* Restore all GP registers.           */
        ret

kwrite_crlf:
	pusha
	popa

	## void fatal(const char* msg)
	##
	## Prints 'msg' and halts.
fatal:
	pusha
	push %cx
	lea fatal_msg, %cx
	call kwrite
	pop %cx
	call kwrite
	call halt
fatal_halt:
	hlt
	jmp fatal_halt
	popa

	## void halt(void)
	##
	## Halts the system

halt:
	hlt
	jmp halt

	## void load_kernel(void)
	##
	## Boot's second stage.

load_kernel:
	pusha			/* Save all GP registers.              */

	/* Compute the kernel size in sectors.  */

	xor %dx, %dx		/* Will divide %dx:%ax by %cx.         */
	mov $_KERNEL_SIZE, %ax	/* Kernel size in bytes (from boot.ld).*/
	mov $512, %cx		/* Disk sector is 512 bytes.           */
	div %cx			/* Integher division.                  */
	add $1, %ax		/* Result in %ax.                      */
	mov %ax, kernel_size	/* Store in RAM for later use.         */

	/* Reset the floppy just for the case.  */

	mov $0x0, %ah		/* BIOS service 0x13: test operation.  */
	mov boot_drive, %dl	/* Select the boot drive (from rt0.o). */
	int $0x13		/* Call BIOS disk service 0x13.        */
	jnc load_kernel_read	/* On error (CF),                      */
	mov $err_reset, %cx	/* load error message and              */
	call fatal		/* report fatal error.                 */

load_kernel_read:
	mov boot_drive, %dl	/* Select the boot drive (from rt0.o). */
	mov $0x2, %ah		/* BIOS disk service: op. read sector. */
	mov kernel_size, %al	/* Number of sectors to read.          */
	mov $0x0, %ch		/* Cylinder coordinate (starts at 0).  */
	mov $0x2, %cl		/* Sector coordinate   (starts at 1).  */
	mov $0x0, %dh		/* Head coordinage     (starts at 0).  */
	mov $_KERNEL_ADDR, %bx	/* Where to load the kernel (rt0.o).   */
	int $0x13		/* Call BIOS disk service 0x13.        */
	mov $err_load, %cx	/* On error (CF), report and halt.     */
	jc fatal

	popa			/* Restore all GP registers.           */
	ret			/* Retur to the caller.                */


	##
	## Read-only data
	##

	.section .rodata
	.align 4		/* Try removing this to see what happens. */



fatal_msg:
	.string "Fatal error: "

err_reset:
	.string "Can't reset drive"
err_load:
	.string "Can't load kernel"

	##
	## Read/Write global data
	##

	.section .data
	.align 4

kernel_size:
	.byte 0x0		/* Computed by load_kernel.            */
