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
    mov $0x0e, %ah      # Seleciona a função de teletipo (TTY) da BIOS para saída de caractere
    mov %cl, %al        # Move o caractere (em %cl) para %al
    int $0x10           # Chama a interrupção de vídeo da BIOS (serviço 0x0e)
    ret                 # Retorna

get_convmem:
    int $0x12           # Chama a interrupção da BIOS para obter o tamanho da memória convencional (em KB)
    ret

get_rtc: 
    push %cx            # Salva %cx na pilha
    mov $0x02, %ah      # Seleciona a função para ler os minutos do RTC (Relógio em Tempo Real)
    int $0x1a           # Chama a interrupção da BIOS para RTC
    mov %cx, %ax        # Move o valor de %cx para %ax (resultado)
    pop %cx             # Restaura %cx
    ret
