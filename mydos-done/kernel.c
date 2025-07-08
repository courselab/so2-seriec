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

/* This source file implements the kernel entry function 'kmain' called
   by the bootloader, and the command-line interpreter. Other kernel functions
   were implemented separately in another source file for legibility. */

#include "kernel.h" /* Essential kernel functions.  */
#include "bios1.h"  /* For kwrite() etc.            */
#include "bios2.h"  /* For kread() etc.             */
#include "kaux.h"   /* Auxiliary kernel functions.  */

#include <stddef.h>  // For size_t

void *memset(void *s, int c, size_t n) {
  unsigned char *p = s;
  while (n--) *p++ = (unsigned char)c;
  return s;
}

void kputs(const char *str) {
  while (*str) {
    putc(*str);
    str++;
  }
}

void kprintint(int x) {
  if (!x) {
    putc('0');
    return;
  }

  int is_negative = 0;
  if (x < 0) {
    is_negative = 1;
    x = -x;
  }

  char buff[16];
  char *ptr = buff + sizeof(buff) - 1;
  *ptr = 0;
  while(x) {
    *--ptr = '0' + x % 10;
    x /= 10;
  }

  if (is_negative)
    *--ptr='-';

  kputs(ptr);
}


/* Kernel's entry function. */

void kmain(void)
{
  int i, j;

  register_syscall_handler(); /* Register syscall handler at int 0x21.*/

  splash(); /* Uncessary spash screen.              */

  shell(); /* Invoke the command-line interpreter. */

  halt(); /* On exit, halt.                       */
}

/* Tiny Shell (command-line interpreter). */

char buffer[BUFF_SIZE];
int go_on = 1;

void shell()
{
  int i;
  clear();
  kwrite("SerieC 1.0\n");

  while (go_on)
  {

    /* Read the user input.
       Commands are single-word ASCII tokens with no blanks. */
    do
    {
      kwrite(PROMPT);
      kread(buffer);
    } while (!buffer[0]);

    /* Check for matching built-in commands */

    i = 0;
    while (cmds[i].funct)
    {
      if (!strcmp(buffer, cmds[i].name))
      {
        cmds[i].funct();
        break;
      }
      i++;
    }

    /* If the user input does not match any built-in command name, just
       ignore and read the next command. If we were to execute external
       programs, on the other hand, this is where we would search for a
       corresponding file with a matching name in the storage device,
       load it and transfer it the execution. Left as exercise. */

    if (!cmds[i].funct)
      kwrite("Command not found\n");
  }
}

/* Array with built-in command names and respective function pointers.
   Function prototypes are in kernel.h. */

struct cmd_t cmds[] =
{
  {"help", f_help}, /* Print a help message.       */
  {"quit", f_quit}, /* Exit TyDOS.                 */
  {"list", f_list}, /* Execute an example program. */
  {"hello", f_hello}, /* Execute an example program. */
  {0, 0}};

/* Build-in shell command: help. */

void f_help()
{
  kwrite("...me, Obi-Wan, you're my only hope!\n\n");
  kwrite("   But we can try also some commands:\n");
  kwrite("      hello   (to run a sample user program)\n");
  kwrite("      list   (to list the files on the image)\n");
  kwrite("      quit    (to exit SerieC)\n");
}

void f_quit()
{
  kwrite("Program halted. Bye.\r\n");
  go_on = 0;
}

#define FS_SIGNATURE "\xeb\xety" /* File system signature.                   */
#define FS_SIGLEN 4              /* Signature length.                        */
/* The file header. */
void print_var(const char *label, int val) {
  kputs(label);
  kputs(": ");
  kprintint(val);
  kputs("\r\n");
}

struct fs_header_t {
  unsigned char signature[FS_SIGLEN];     /* The file system signature.              */
  unsigned short total_number_of_sectors; /* Number of 512-byte disk blocks.         */
  unsigned short number_of_boot_sectors;  /* Sectors reserved for boot code.         */
  unsigned short number_of_file_entries;  /* Maximum number of files in the disk.    */
  unsigned short max_file_size;           /* Maximum size of a file in blocks.       */
  unsigned int unused_space;              /* Remaining space less than max_file_size.*/
} __attribute__((packed));      /* Disable alignment to preserve offsets.  */

// If we want to be certain that read_disk will work on real machines we will want to get the
// disk parameters via BIOS
#define FLOPPY_HEADS_PER_CYLINDER 16
#define FLOPPY_SECTORS_PER_TRACK 63

extern unsigned char boot_drive;
#if 1
int read_disk(unsigned char *dest, unsigned int start_lba, unsigned int num_sectors) {
  unsigned char drive = boot_drive;  // First HDD

  for (int i = 0; i < num_sectors; i++) {
    unsigned int current_lba = start_lba + i;

    // Correct LBA-to-CHS conversion (using current_lba)
    unsigned char sector = (current_lba % FLOPPY_SECTORS_PER_TRACK) + 1;
    unsigned int temp = current_lba / FLOPPY_SECTORS_PER_TRACK;
    unsigned char head = temp % FLOPPY_HEADS_PER_CYLINDER;
    unsigned int cylinder = temp / FLOPPY_HEADS_PER_CYLINDER;

    int status = disk_read(drive, cylinder, head, sector, 1, dest + i * 512);
    if (status)
      return status;
  }
  return 0;
}
#endif

#define SECTOR_SIZE 512
#define DIR_ENTRY_LEN 32  /* Max file name length in bytes.           */
#define DIR_ENTRY_PER_SECTOR (SECTOR_SIZE / DIR_ENTRY_LEN)

void f_list()
{
  uint8_t buf[SECTOR_SIZE] __attribute__((aligned(16)));

  int status = read_disk(buf, 0, 1);
  if (status)
    goto error;

  struct fs_header_t *header = (struct fs_header_t *)buf;

  unsigned short number_of_file_entries = header->number_of_file_entries;
  int current_sector = header->number_of_boot_sectors - 1;

  for (int i = 0; i < number_of_file_entries; i++) {
    int di_in_sector = (i % DIR_ENTRY_PER_SECTOR);

    if (di_in_sector == 0) {
      current_sector += 1;
      int status = read_disk(buf, current_sector, 1);

      if (status)
        goto error;
    }

    char *file_name = (char*)buf + di_in_sector * DIR_ENTRY_LEN;
    if (file_name[0]) {
      for (int ci = 0; ci < DIR_ENTRY_LEN; ci++) {
        putc(file_name[ci]);
      }
      kputs("\r\n");
    }
  }

  return;
error:
  kwrite("ERROR READING FLOPPY\n");
  kputs("status:");
  kprintint(status);
  kputs("\r\n");
  return;
}
/* Built-in shell command: example.

   Execute an example user program which invokes a syscall.

   The example program (built from the source 'prog.c') is statically linked
   to the kernel by the linker script (tydos.ld). In order to extend the
   example, and load and external C program, edit 'f_exec' and 'prog.c' choosing
   a different name for the entry function, such that it does not conflict with
   the 'main' function of the external program.  Even better: remove 'f_exec'
   entirely, and suppress the 'example_program' section from the tydos.ld, and
   edit the Makefile not to include 'prog.o' and 'libtydos.o' from 'tydos.bin'.

*/

extern int main();
void f_hello()
{
  main(); /* Call the user program's 'main' function. */
}
