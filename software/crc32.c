#include <stdio.h>
#include <stdlib.h>


/* Table of CRCs of all 8-bit messages. */
unsigned long crc_table[256];

/* Flag: has the table been computed? Initially false. */
int crc_table_computed = 0;

/* Make the table for a fast CRC. */
void make_crc_table(void)
{
   unsigned long c;

   int n, k;
    for (n = 0; n < 256; n++) {
        c = (unsigned long) n;
        for (k = 0; k < 8; k++) {
        if (c & 1) {
            c = 0xedb88320L ^ (c >> 1);
        } else {
            c = c >> 1;
        }
        }
        crc_table[n] = c;
        printf("\n\tcrc_table[%d] = %32x", n, (int) crc_table[n]);
    }
    crc_table_computed = 1;
}


int main()
{
    printf("Hello world!\n");
    make_crc_table();
    //printf("\n\tcrc_table[%d] = %x", 1, crc_table[1]);
    printf("S-a terminat tabelul\n");
    return 0;
}

