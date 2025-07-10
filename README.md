# Sistemas Operacionais II - Grupo SerieC
Este repositório contém os projetos desenvolvidos na disciplina de Sistemas Operacionais II, realizados pelo grupo **serieC**. Os projetos têm como foco a criação de sistemas mínimos e ambientes operacionais de baixo nível, utilizando Assembly e C, com toolchains personalizados.
Há dois projetos principais relacionados ao desenvolvimento de sistemas operacionais: `hello` e `mydos`. Cada pasta está equipada com seu próprio `README` contendo detalhes específicos, arquivos de código-fonte, arquivos de montagem, arquivos de link-edit e scripts de compilação.

## Integrantes
1. 12690500 - Arthur Grillo Queiroz Cabral
2. 11965988 - Carlos Henrique Hannas de Carvalho
3. 13677114 - Daniel Dias Silva Filho
4. 12547301 - Pedro Arthur do Prado Françoso

---

## Organização do Repositório

```plaintext
so2-seriec/
├── hello/          # Programa mínimo para execução bare-metal
│   ├── Makefile
│   ├── bintools.mk
│   ├── crt0.S
│   ├── hello.ld
│   ├── libc.S
│   ├── main.c
│   ├── stdio.h
│   └── README
│
├── mydos/          # Sistema operacional mínimo com suporte a arquivos
│   ├── Makefile
│   ├── bintools.mk
│   ├── build.mk
│   ├── *.S, *.h, *.c → arquivos do kernel, BIOS, bootloader e FS
│   ├── tydos.ld, prog.ld
│   ├── tyfsedit      # Utilitário para editar o sistema de arquivos
│   └── README
```

---

## Descrição das Pastas

### 📁 `hello/`

Um projeto bare-metal que demonstra os princípios básicos de inicialização e execução de um programa em C sobre um ambiente mínimo. Os arquivos incluem:

- `main.c`: Função principal do programa
- `crt0.S`: Código de inicialização em Assembly
- `libc.S`: Funções básicas da biblioteca C
- `hello.ld`: Script de linkagem
- `Makefile` e `bintools.mk`: Scripts de compilação

#### Compilação:
```bash
cd hello
make
```

#### Execução (exemplo com QEMU):
```bash
qemu-system-i386 -kernel hello
```

---

### 📁 `mydos/`

Um sistema operacional simples com funcionalidades de multitarefa, gerenciamento básico de arquivos e chamadas de sistema.

- `kernel.c`: Código principal do núcleo do sistema operacional
- `bootloader.c`: Bootloader responsável pela carga do sistema
- `bios*.S`, `bios*.h`: Simulações da BIOS em Assembly
- `syscall.c`: Implementação de chamadas de sistema
- `logo.c`: Tela gráfica inicial
- `tyfsedit`: Utilitário para edição do sistema de arquivos (tipo `mkfs`)
- `Makefile`, `build.mk`, `bintools.mk`: Scripts de construção

#### Compilação:
```bash
cd mydos
make disk.img
```

#### Execução:
```bash
make disk.img/run
```

É possivel adicionar arquivos ao `disk.img` usando o utiliatario tyfsedit

---

## Observações

- Cada pasta contém seu próprio `README` com detalhes técnicos adicionais e instruções específicas.

---

## Requisitos

- `gcc`, `make`, `nasm` (ou `as`)
- Emulador como `QEMU`
- Ambiente Linux
