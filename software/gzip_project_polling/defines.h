#ifndef DEFINES_H
#define DEFINES_H

#if defined(MSDOS) || defined(OS2) || defined(WIN32) || defined(__CYGWIN__)
#  include <fcntl.h>
#  include <io.h>
#  define SET_BINARY_MODE(file) setmode(fileno(file), O_BINARY)
#else
#  define SET_BINARY_MODE(file)
#endif

#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <deflate.h>

/*********************************************************************
 *                                                                   *
 *                 D E C L A R A T I O N S                           *
 *                                                                   *
 *********************************************************************/
 
//#define PRINT_DEBUG
//#define PRINT_DEBUG_READ
#define PRINT_DEBUG_WRITE
//#define MEASURE_TIME
#define BLOCK_SIZE 512

//versions
#define SW_VERSION 1.2
//addresses
#define RESET_ADD		0
#define BTYPE_ADD		1
#define INFO_ADD		2
#define ISIZE_ADD		3
#define CRC_ADD			7
#define BLOCK_SIZE_ADD          11
#define OUT_SIZE_ADD            14
#define DEV_ID_ADD		18

//commands & masks
#define RESET_EN		0x00
#define RESET_DIS		0x01
#define BTYPE_NO_COMP 	        0x00
#define BTYPE_FIX_HUFF  	0x01
#define BTYPE_DIN_HUFF  	0x02
#define GZIP_DONE		0x04
#define BTYPE_ERROR		0x02
#define BSIZE_ERROR		0x01
#define DEVICE_ID               0xC7
#define LAST_BLOCK 		0x01000000


/* Return codes for the compression/decompression functions. Negative values
 * are errors, positive values are used for special but normal events.
 */
#define Z_OK            0
#define Z_STREAM_END    1
#define Z_NEED_DICT     2
#define Z_ERRNO        (-1)
#define Z_STREAM_ERROR (-2)
#define Z_DATA_ERROR   (-3)
#define Z_MEM_ERROR    (-4)
#define Z_BUF_ERROR    (-5)
#define Z_VERSION_ERROR (-6)
#define Z_MEM_ARRAY_ERROR (-7)
#define Z_XILLY_PIPE_ERROR (-8)

// Filt descriptors
    int fd_xillybus_rd;
    int fd_xillybus_wr;
    int fd_read, fd_write, fd_mem;
    //char compress_level = BTYPE_NO_COMP;



typedef unsigned char  uch;
typedef unsigned short ush;
typedef unsigned long  ulg;

typedef unsigned char uint8_t;
typedef long int      uint32_t;


#define SIZE_OF_INT sizeof(int)
#define SIZE_OF_CHAR sizeof(char)

typedef struct{
	unsigned char ID1;// = 0x1F;
	unsigned char ID2;// = 0x8B;
	unsigned char CM;//  = 8; 	//CM = 8 denotes the "deflate"
	unsigned char FLG;// = 0;
	           /*
			   bit 0   FTEXT
               bit 1   FHCRC
               bit 2   FEXTRA
               bit 3   FNAME
               bit 4   FCOMMENT
               bit 5   reserved
               bit 6   reserved
               bit 7   reserved
			   */
	unsigned int MTIME;// = 0;
	unsigned char XFL;// = 0;
	unsigned char OS;// = 0;
	unsigned char *XLEN; 	//if FLG.FEXTRA set
	char *file_name; 		//if FLG.FNAME set
	char *file_comment; 	//if FLG.FCOMMENT set
	unsigned char CRC16;// = 0; 	//if FLG.FHCRC set
} gzip_header_t ;


#define GZIP_HEADER_MANDATORY 10
/* gzip flag byte */
#define FTEXT		0x01 /* bit 0 set: file probably ascii text */
#define FHCRC		0x02 /* bit 1 set: CRC16 for the gzip header */
#define FEXTRA  	0x04 /* bit 2 set: extra field present */
#define FNAME    	0x08 /* bit 3 set: original file name present */
#define FCOMMENT    0x10 /* bit 4 set: file comment present */
#define RESERVED	0xE0 /* bit 5,6,7: reserved */


//thread args structure
typedef struct {
	int fd_read;
	int fd_write;
	int fd_mem;
	void *buff;
	int buffer_size;
} thread_args_t;

/*********************************************************************
 *                                                                   *
 *                   P R O T O T Y P E S                             *
 *                                                                   *
 *********************************************************************/
 
 
 extern void write_data(int fd, void *buf, int len);
 
 extern void read_data(int fd, void *buf, int *len);
 
 extern void write_data_at_address(int fd,int address, void *buf, int len);
 
 extern void read_data_from_address(int fd,int address, void *buf, int len);
 
 extern void allwrite(int fd, unsigned char *buf, int len); // OPL

 extern void allread (int fd, unsigned char *buf, int len); // OPL
 
 extern void check_mem_array_data(int fd ,unsigned char expected_val, unsigned char address); // OPL

 extern void write_mem_array_data(int fd, unsigned char address, unsigned char data); // OPL

 extern unsigned char read_mem_array_data(int fdr, unsigned char address); // OPL

 extern ulg updcrc(uch *s,unsigned n);

 extern uint32_t _bswap32(uint32_t a);
 
 extern unsigned int _roundTo(unsigned int value, unsigned int roundTo);

 extern int gzipCoreInit(uint8_t compress_level);

 extern int gzipCoreReset(int fd_mem);

 extern int deflateCoreInit2_ (z_streamp strm, int  level, int  method,
                                  int windowBits, int memLevel,
                                  int strategy, const char *version,
                                  int stream_size);


#endif //DEFINES_H
