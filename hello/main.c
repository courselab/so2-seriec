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

#include <stdio.h>

void puts(const char *str) {
	while (*str) {
		putc(*str);
		str++;
	}
}

void printint(int x) {
	if (!x) {
		putc('0');
		return;
	}

	char buff[8];
	char *ptr = buff + sizeof(buff) - 1;
	*ptr = 0;
	while(x) {
		*--ptr = '0' + x % 10;
		x /= 10;
	}
	puts(ptr);
}

int main(void) {
	puts("Hello World!\r\n");

	puts("Conventional memory size(KB): ");
	unsigned short conv_mem = get_convmem();
	printint(conv_mem);
	puts("\r\n");
	return 0;
}
