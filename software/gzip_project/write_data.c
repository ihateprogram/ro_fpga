#include "defines.h"

/*
   write_data() loops until all data was indeed written, or exits in
   case of failure, except for EINTR.
   The way the EINTR condition is handled is the standard way of making sure the process can be suspended
   with CTRL-Z and then continue running properly.

   The function has no return value, because it always succeeds (or exits
   instead of returning).

   The function doesn't expect to reach EOF either.
*/

void write_data(int fd, void *buf, int len)
{
	int sent = 0;
	int mod4;
	int wr_len;
	mod4 = (4 - (len % 4)) % 4;
#ifdef PRINT_DEBUG
	printf("length to be wrote= %d \n", len );
	if(mod4)
		printf("   padding %d\n", mod4);
#endif
	if(len == 0) //dummy flush write
		write(fd, NULL, len);
	while (sent < len)
	{
		wr_len = write(fd, buf + sent, (len - sent + mod4));
#ifdef PRINT_DEBUG
	printf("length wrote = %d \n", wr_len);
#endif
		if ((wr_len < 0) && (errno == EINTR))
		  continue;

		if (wr_len < 0) {
		  perror("write_data() failed to write");
		  exit(1);
		}

		if (wr_len == 0) {
		  fprintf(stderr, "Reached write EOF (?!)\n");
		  exit(1);
		}

		sent += wr_len;
	}
}

/*
	write_data_at_addreess() writes a data buffer at a specific address in the file descriptor.
*/
void write_data_at_address(int fd,int address, void *buf, int len)
{
	if (lseek(fd, address, SEEK_SET) < 0)
	{
		perror("Failed to seek");
		exit(1);
	}
	else
	{
#ifdef PRINT_DEBUG
	printf("writing a command\n");
#endif		
	}

	write(fd, buf, len);
}


