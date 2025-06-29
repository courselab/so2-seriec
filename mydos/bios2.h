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

#ifndef BIOS2_H
#define BIOS2_H

#include <stdint.h>
 
uint8_t disk_read(uint8_t drive,
		uint16_t cyl,
		uint16_t head,
		uint16_t sector,
		uint8_t count,
		void *buffer);

int __attribute__((fastcall)) kread(char *);
int __attribute__((fastcall)) putc(char);

void __attribute__((fastcall)) udelay(unsigned short);

#endif /* BIOS2_H  */
