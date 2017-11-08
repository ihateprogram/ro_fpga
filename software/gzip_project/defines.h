#ifndef DEFINES_H
#define DEFINES_H

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

/*********************************************************************
 *                                                                   *
 *                 D E C L A R A T I O N S                           *
 *                                                                   *
 *********************************************************************/
 
//#define PRINT_DEBUG
#define MEASURE_TIME
#define BLOCK_SIZE 512

//versions
#define SW_VERSION 1.0 
//addresses
#define RESET_ADD		0x00000000
#define BTYPE_ADD		0x00000001
#define INFO_ADD		0x00000002
#define ISIZE_ADD		0x00000003
#define CRC_ADD			0x00000007

//commands & masks
#define RESET 			0x01
#define BTYPE_NO_COMP 	0x00
#define BTYPE_FIX_HUFF 	0x01
#define BTYPE_DIN_HUFF 	0x02
#define GZIP_DONE		0x04
#define BTYPE_ERROR		0x02
#define BSIZE_ERROR		0x01

#define LAST_BLOCK 		0x01000000

typedef unsigned char  uch;
typedef unsigned short ush;
typedef unsigned long  ulg;
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
 
 extern ulg updcrc(uch *s,unsigned n);
 



#endif //DEFINES_H
