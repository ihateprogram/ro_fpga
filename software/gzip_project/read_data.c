#include "defines.h"

 /*
	read_data() loops until all data was indeed read, or exits in
   case of failure, except for EINTR. The way the EINTR condition is
   handled is the standard way of making sure the process can be suspended
   with CTRL-Z and then continue running properly.

   The function has no return value, because it always succeeds (or exits
   instead of returning).

   The function doesn't expect to reach EOF either.
*/
void read_data(int fd, void *buf, int *len)
{
	int rd_len,idx;

	rd_len = read(fd, buf , BLOCK_SIZE);
#ifdef PRINT_DEBUG
	printf("f length read = %d \n", rd_len);
	printf("read text: ");
	for(idx = 0; idx<rd_len; idx++)
		printf("%2x",((unsigned char*)buf)[idx]);
	printf("\n");
#endif

	if (rd_len < 0) {
	  perror("read_data() failed to read");
	  exit(1);
	}

	if (rd_len == 0) {
	  fprintf(stderr, "Reached read EOF.\n");
	  exit(0);
	}
	*len = rd_len;

}

/*
	read_data_from_addreess() reads a data buffer from a specific address in the file descriptor.
*/
void read_data_from_address(int fd,int address, void *buf, int len)
{
	if (lseek(fd, address, SEEK_SET) < 0)
	{
		printf("Failed to seek add %x \n", address);
		exit(1);
	}
	else
	{
#ifdef PRINT_DEBUG
	printf("reading a command\n");
#endif		
	}
	read(fd, buf , len);
}
