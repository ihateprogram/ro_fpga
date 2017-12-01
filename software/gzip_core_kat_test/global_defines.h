// Defines which are used in all software functions

   #ifndef _GLOBAL_DEFINES_
   #define _GLOBAL_DEFINES_

typedef unsigned char uint8_t;
typedef long int      uint32_t;

#define DEV_ID              0xBA

// Register addresses
#define RESET_REG           0
#define BTYPE_REG           1
#define DEBUG_REG1          2

#define DEBUG_REG2          3
#define DEBUG_REG3          4
#define DEBUG_REG4          5
#define DEBUG_REG5          6
#define DEBUG_REG6          7
#define DEBUG_REG7          8
#define DEBUG_REG8          9
#define DEBUG_REG9         10

#define CRC_31_24          DEBUG_REG6
#define CRC_23_16          DEBUG_REG7
#define CRC_15_8           DEBUG_REG8
#define CRC_7_0            DEBUG_REG9

#define DEBUG_REV_REG      14


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
