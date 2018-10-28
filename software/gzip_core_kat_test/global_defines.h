// Defines which are used in all software functions

   #ifndef _GLOBAL_DEFINES_
   #define _GLOBAL_DEFINES_

typedef unsigned char uint8_t;
typedef long int      uint32_t;

#define DEV_ID              0xC7

// Register addresses
#define RESET_REG           0
#define BTYPE_REG           1
#define DEBUG_REG1          2

#define DEBUG_REV_REG      18

#define ISIZE_31_24        3
#define ISIZE_23_16        4
#define ISIZE_15_8         5
#define ISIZE_7_0          6

#define CRC_31_24          7
#define CRC_23_16          8
#define CRC_15_8           9
#define CRC_7_0            10

#define BLOCK_LEN_23_16    11
#define BLOCK_LEN_15_8     12
#define BLOCK_LEN_7_0      13


// Define bit values
#define RESET_DIS             0x01
#define RESET_EN              0x00

#define BTYPE_NO_COMPRESSION  0x0
#define BTYPE_FIXED_HUFFMAN   0x1
#define BTYPE_DYNAMIC_HUFFMAN 0x2
#define BTYPE_UNDEFINED       0x3

#define GZIP_DONE             1<<2
#define BTYPE_ERR             1<<1
#define BSIZE_ERR             1<<0

#define BFINAL1               0x01
#define BFINAL0               0x00

#define PROCESS_PAYLOAD       0
#define IGNORE_PAYLOAD        1

   #endif
