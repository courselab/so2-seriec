/*
 *    SPDX-FileCopyrightText: 2024 Monaco F. J. <monaco@usp.br>
 *    SPDX-FileCopyrightText: 2025 Arthur Grillo <arthurgrillo@riseup.net>
 *   
 *    SPDX-License-Identifier: GPL-3.0-or-later
 *
 *  This file is a derivative of SYSeg (https://gitlab.com/monaco/syseg)
 *  and includes modifications made by the following author(s):
 *  Arthur Grillo <arthurgrillo@riseup.net>
 */

#ifndef KERNEL_H
#define KERNEL_H

/* This is kernel's entry function, which is called by the bootloader
   as soon as it loads the kernel from the this image. */

void kmain(void);

/* This is the command interpreter, which is invoked by the kernel as
   soon as the boot is complete.

   Our tiny command-line parser is too simple: commands are ASCII single words
   with no command line arguments (no blanks). */

void shell();        /* Command interpreter. */
#define BUFF_SIZE 64 /* Max command length.  */
#define PROMPT "> "  /* Command-line prompt. */

/* Built-in commands. */

void f_help();
void f_quit();
void f_hello();

extern struct cmd_t
{
  char name[32];
  void (*funct)();
} cmds[];

#endif /* KERNEL_H  */
