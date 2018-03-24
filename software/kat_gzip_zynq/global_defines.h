// Defines which are used in all software functions

   #ifndef _GLOBAL_DEFINES_
   #define _GLOBAL_DEFINES_

typedef unsigned char uint8_t;
typedef long int      uint32_t;

#define CORE_VERSION        0xB9

#define NREGISTERS          8

#define INIT_OK             0
#define INIT_ERR_MMAP       1
#define INIT_ERR_VERSION    2
#define INIT_ERR_WRITE      3
#define INIT_ERR_XILLY      4

// Register addresses for Zynq - 32 bit registers
#define RESET_REG           0
#define BTYPE_REG           1
#define STATUS_REG          2
#define ISIZE_REG           3
#define CRC32_REG           4
#define BLOCK_SIZE_REG      5
#define OUT_STRM_SIZE_REG   6
#define DEVICE_ID_REG       7

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
#define REV_ENDIANESS         1<<2

#define GZIP_DONE             1<<2
#define BTYPE_ERR             1<<1
#define BSIZE_ERR             1<<0

#define BFINAL1               0x01
#define BFINAL0               0x00

#define PROCESS_PAYLOAD       0
#define IGNORE_PAYLOAD        1

   #endif
