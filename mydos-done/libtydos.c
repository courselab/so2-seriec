/*
 *    SPDX-FileCopyrightText: 2021 Monaco F. J. <monaco@usp.br>
 *    SPDX-FileCopyrightText: 2025 Arthur Grillo <arthurgrillo@riseup.net>
 *   
 *    SPDX-License-Identifier: GPL-3.0-or-later
 *
 *  This file is a derivative of SYSeg (https://gitlab.com/monaco/syseg)
 *  and includes modifications made by the following author(s):
 *  Arthur Grillo <arthurgrillo@riseup.net>
 */

/* This is a trivial user library that should be statically linked against
   programs meant for running on TyDOS. It provides some custom C functions
   that invoke system calls for trivial tasks. */

#include "tydos.h"

/* The syscall function.

   This function is not meant to be called directly by the user programs but,
   rahter, by the other library functions that need to invoke syscalls. */

int syscall(int number, int arg1, int arg2, int arg3)
{
  __asm__("pusha \n"); /* We'll mess up with GP registers. */

  /* Our syscall ABI uses regparm(3) calling convention (see the section on
     x86 function attributes in the GCC manual. */

  int register bx __asm__("bx") = number; /* Syscall number (handler). */
  int register ax __asm__("ax") = arg1;   /* First argument  in %ax.   */
  int register dx __asm__("dx") = arg2;   /* Second argument in %dx.   */
  int register cx __asm__("cx") = arg3;   /* Third argument in  %cx.   */

  __asm__(
      "int $0x21 \n"  /* Issue int $0x21.                    */
      "popa      \n " /* Restore GP registers.               */
  );
}

/*  Write the string 'str' on the screen.*/

void puts(const char *str)
{
  syscall(SYS_WRITE, (int)str, 0, 0);
}
