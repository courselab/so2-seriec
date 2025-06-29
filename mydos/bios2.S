#    SPDX-FileCopyrightText: 2021 Monaco F. J. <monaco@usp.br>
#    SPDX-FileCopyrightText: 2025 Arthur Grillo <arthurgrillo@riseup.net>
#   
#    SPDX-License-Identifier: GPL-3.0-or-later
#
#  This file is a derivative of SYSeg (https://gitlab.com/monaco/syseg)
#  and includes modifications made by the following author(s):
#  Arthur Grillo <arthurgrillo@riseup.net>

	/* This source file implements a few low-level functions which are
	   easier to write directly in assembly. They are mostly BIOS service
           invocations and other machine-level procedures. Other low-leveel
           functions that complement those in this file are implemented in a
           separate source (bios1.S) which contains only the functions needed
           by the bootloader (so as to respect the 512-byte length limit).*/

	.code16gcc
	.global kread, udelay, register_syscall_handler, sys_write

	.section .text

	# int kread(char* buffer)
	# Reads from the keyboard into the buffer.
	# Returns the number of bytes read.

kread:
        pusha                   /* Save all GP registers.                     */

        mov %cx, %bx            /* Argument received in %cx.                  */
        mov $0x0, %si           /* Initialize buffer index.                   */

kread_loop:
        mov $0x0, %ax           /* BIOS keyboard service (blocking read).     */
        int $0x16               /* Call BIOS keyboard service.                */

        cmp $0xb, %si           /* End reading if more than 10 characters.    */
        je kread_trunc

        mov %al, %es:(%bx,%si)  /* Add ASCII to the buffer.                   */
        inc %si                 /* Increment the buffer index.                */

kread_trunc:
        mov $0xe, %ah           /* Echo the ascii onto the screen.            */
        int $0x10

        cmp $0xd, %al           /* End reading if character is CR.            */
        je kread_end

        jmp kread_loop         /* Keep reading.                              */

kread_end:
        mov $0xe, %ah           /* Echo a newline.                            */
        mov $0xa, %al
        int $0x10

        movb $0x0, -1(%bx,%si)  /* Remove trailing CR.                        */

	mov %esi, %eax		/* Update %ax in the stack (see note 2)       */
	dec %eax		/* so that popa gets the computed value.      */
	mov %eax, 28(%esp)

        popa                    /* Restore all GP registers.                  */
        ret


	# void delay (short t)
	# Delay t milliseconds.

udelay:
        pusha                    /* Save all GP registers.                            */
        mov %cx, %bx             /* Argument already in %cx (fastcall).               */
        mov $0, %cx              /* BIOS in 15h delay is of %cx:%dx microsseconds:    */
        mov $0x0001, %dx         /* 0000:0001 for 1 us, 0000:03e8 for 1ms.            */
udelay_loop:                     /* We'll delay 1ms, t times                          */
        test %bx, %bx            /* Loop until t==0.                                  */
        jz udelay_end            /* On zero, return                                   */
        movb $0x86, %ah          /* %ah = 0x86 (BIOS function for waiting).           */
        int $0x15                /* Call BIOS interrupt 0x15, function AH=0x86.       */
        dec %bx                  /* t = t-1                                           */
        jmp udelay_loop          /* Repeat loop.                                      */
udelay_end:
        popa                     /* Restore all GP registers.                         */
	ret

	## void register_syscall_handler()
	##
	## Register the syscall hanlder function in the IVT, at position 21h..

register_syscall_handler:
	.equ int21hoffset, 0x21 * 4  /* The 0x21 entry in the IVT*/
	pusha
	cli
	/* movw $syscall_handler, int21hoffset  */
	/* movw $0x0, int21hoffset + 2	     */
	movl $syscall_handler, int21hoffset
	sti
	popa
	ret


	## void syscall_handler()
	##
	## Handler syscall.
	##
	## Calling convention: syscall number in %bx and
	## arguments in %ax, %dx, %cx

syscall_handler:
	pusha
	shlw $2, %bx		 /* Array of ints (see note 2).             */
	mov %bx, %si		 /* %si is the index of the syscall.        */
	call *syscall_table(%si) /* Array of function pointers.             */
	popa
	iret			 /* Returning from an interrupt. (note 3). */


	## The syscall table is an array of function pointers.
	##
	## (See note 2).

syscall_table:
	.long sys_invalid	/* Syscall 0: invalid.   */
	.long sys_exit		/* Syscall 1: exit.      */
	.long sys_write		/* Syscall 2: write      */

	/* Read-only data. */

	.section .rodata
	.align 4


msg_err_lprg:
	.string "Error loading program\n"
msg_err_read:
	.string "Drive read error\n"


     /* Notes.

    (1) When coding in assembly for 16-bit, the directive .code16 instructs
	the assembly to generate 16-bit object code. Symbol addresses are
	2-byte long, and instructions such as push, pop and ret save and
	restore 2-byte values from the stack.

	All goes well until we try to mix hand made asm with assembly
	generated by GCC. The GCC compiler flag -m16 does nothing but
	adding the directive .code16gcc into the asm file. Both .code16
	and .code16gcc are almost identical, except that push, pop, ret and
	other instructions manipulate 32-bit addresses (gcc  automatically adds
	address size prefixes when necessary).

	The proble is that if we call a function implemented in an asm file
	that uses .code16 from a C file compiled with GCC, the caller will
	push 4 bytes onto the stack, but the callee will consume 2 bytes
	upon return.

	To avoid this, we're using .code16gcc also in the hancrafted asm.

	Another consequence is that we have to define the syscall table as
	an array of ints (because adresses are 32-bits now). Accordingly,
	the syscall number in the function syscall_handler(), has to be
	multiplied by 4 (and not 2) to account for the pointer arithments.

    (2) We're using pusha and popa to preserve the values of the registers
	for the caller. This is straightforward when the callee is void.
	On the other hand, for non-void functions, returning in %ax is
	complicated by the last popa, that overwrites %ax before returning.
	One possible workaround is to modify the value of %ax saved in the
	stack.

	The instruction pusha pushes onto the stack %ax, %cx, %dx, %bx, %sp,
	%bp, %si, and %di, i.e. 8 2-byte registers in .code16. As we're
	using .cod16gcc, though, we have 8 * 4-byte = 32 bytes. We can modify
	the value of %ax in the stack by making

	    mov %eax, 28(%esp)         # 32-4 = 28

	Then, popa will restore the desired value into %eax.

    (3) The instruction 'call' pushes the return address onto the stack; the
	instruction 'ret' pops it. When we call a function as result of an
	interrupt, the instruction 'int' actually pushes more stuff onto the
	stack (the flags register); we need the instruction 'iret' to pop
	out everything.

*/

