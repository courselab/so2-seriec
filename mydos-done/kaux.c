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

#include "kaux.h"  /* For ROWS and COLS. */
#include "bios2.h" /* For udelay().      */

/* Video RAM as 2D matrix: short vram[row][col]. */

short (*vram)[COLS] = (short (*)[COLS])0xb8000;

char character_color = 0x02; /* Default fore/background character color.*/

/* Write 'string' starting at the position given by 'row' and 'col'.
   Text is wrapped around both horizontally and vertically.

   The implementation manipulates the video-RAM rather than BIOS services.
*/

void writexy(unsigned char row, unsigned char col, const char *string)
{
  int k = 0;

  while (string[k])
  {

    col = col % COLS;
    row = row % ROWS;

    vram[row][col] = color_char(string[k]);
    col++;
    k++;
  }
}

/* Clear the entire screen

   The implementation manipulates the video-RAM rather than BIOS services.

 */

void clearxy()
{
  int i, j;

  for (j = 0; j < ROWS; j++)
    for (i = 0; i < COLS; i++)
      vram[j][i] = color_char(' ');
}

/* A not-that-impressive splash screen that is entirely superfluous. */

extern const char logo[];
void splash(void)
{
  int i, j, k;

  clearxy();

  for (i = 0; i < COLS; i++)
  {
    for (j = 0; j < ROWS; j += 2)
    {
      vram[j][i] = color_char(logo[j * COLS + i]);
      vram[j + 1][COLS - i] = color_char(logo[(j + 1) * COLS + (COLS - i)]);
      udelay(1);
    }
  }

  udelay(500);
  clearxy();
}

/* Return 0 is string 's1' and 's2' are equal; return non-zero otherwise.*/

int strcmp(const char *s1, const char *s2)
{
  while (*s1 && *s2 && *s1 == *s2)
  {
    s1++;
    s2++;
  }
  return (*s1 - *s2);
}
