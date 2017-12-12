// Defines which are used in all software functions

   #ifndef _GLOBAL_DEFINES_
   #define _GLOBAL_DEFINES_

typedef unsigned char uint8_t;
typedef long int      uint32_t;

#define DEV_ID              0xBA

// Register addresses
#define RESET_REG           0x0
#define BTYPE_REG           0x4
#define STATUS_REG          0x8

#define DEBUG_REV_REG       0x18

#define ISIZE_REG           0x0C
#define CRC_REG             0x10
#define BLOCK_LEN_REG       0x14


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
