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
.global wait_key_and_reboot
.global key_pressed
.global reboot

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

wait_key_and_reboot:
    int $0x16           # espera uma tecla ser pressionada
    int $0x19           # reboot
    ret

key_pressed:
    mov $0x01, %ah      # Função 01h: Checa se tecla foi pressionada
    int $0x16           # BIOS Keyboard Service
    jz no_key           # Se ZF=1, nenhuma tecla
    mov $1, %ax         # Retorna 1 (tecla pressionada)
    ret
no_key:
    xor %ax, %ax        # Retorna 0 (nenhuma tecla)
    ret

reboot:
    int $0x19           # interrupção de reboot