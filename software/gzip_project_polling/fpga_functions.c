// These are basic functions for the FPGA communication.
// Tey are used by higher level functions
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


/*
   Plain write() may not write all bytes requested in the buffer, so
   allwrite() loops until all data was indeed written, or exits in
   case of failure, except for EINTR. The way the EINTR condition is
   handled is the standard way of making sure the process can be suspended
   with CTRL-Z and then continue running properly.

   The function has no return value, because it always succeeds (or exits
   instead of returning).

   The function doesn't expect to reach EOF either.
*/

void allwrite(int fd, unsigned char *buf, int len) {
  int sent = 0;
  int rc;

  while (sent < len) {
    rc = write(fd, buf + sent, len - sent);

    if ((rc < 0) && (errno == EINTR))
      continue;

    if (rc < 0) {
      perror("allwrite() failed to write");
      exit(1);
    }

    if (rc == 0) {
      fprintf(stderr, "Reached write EOF (?!)\n");
      exit(1);
    }

    sent += rc;
  }
}



/*
   Plain read() may not read all bytes requested in the buffer, so
   allread() loops until all data was indeed read, or exits in
   case of failure, except for EINTR. The way the EINTR condition is
   handled is the standard way of making sure the process can be suspended
   with CTRL-Z and then continue running properly.

   The function has no return value, because it always succeeds (or exits
   instead of returning).

   The function doesn't expect to reach EOF either.
*/

void allread(int fd, unsigned char *buf, int len) {
  int received = 0;
  int rc;
  
  while (received < len) {
    rc = read(fd, buf + received, len - received);
 
    if ((rc < 0) && (errno == EINTR))
      continue;

    if (rc < 0) {
      perror("allread() failed to read");
      exit(1);
    }

    if (rc == 0) {
      fprintf(stderr, "Reached read EOF (?!)\n");
      exit(1);
    }

    received += rc;
  }
}

/*  Used to check the register space of the gzip core */

void check_mem_array_data(int fd ,unsigned char  expected_val, unsigned char address)
{
   unsigned char data = 0;

   if (lseek(fd, address, SEEK_SET) < 0)
   {
      perror("Failed to seek");
      exit(1);
   }

   allread(fd, &data, 1);

   if (data == expected_val)
   {
     // printf("\nCORRECT - Read data = %x, Expected data = %x at ADDRESS = %d\n", data, expected_val, address);
   }
   else
   {
      printf("\nERROR - Read data = %x, Expected data = %x at ADDRESS = %d\n", data, expected_val, address);
      exit(1);
   }
}

/* Function used to write at a specific address in the gzip core register space  */

void write_mem_array_data(int fd, unsigned char address, unsigned char data)
{
   int fdw;

   printf("Write data = %x at address = %d\n", data, address);

   if (fdw < 0) {
   if (errno == ENODEV)
      fprintf(stderr, "(Maybe %c a read-only file?)\n", fdw);

      perror("Failed to open xillybus_mem_8");
      exit(1);
   }

   if (lseek(fdw, address, SEEK_SET) < 0) {
      perror("Failed to seek");
      exit(1);
   }
   allwrite(fdw,  &data , 1);
}


/* Function used to read data from one the gzip core register space */
unsigned char read_mem_array_data(int fdr, unsigned char address)
{
   unsigned char data = 0;

   if (fdr < 0)
   {
      if (errno == ENODEV) {
         fprintf(stderr, "(Maybe %d a write-only file?)\n", fdr);
         }
         perror("Failed to open xillybus_mem_8");
         exit(1);
   }

   if (lseek(fdr, address, SEEK_SET) < 0)
   {
      perror("Failed to seek");
      exit(1);
   }

   allread(fdr, &data, 1);

   printf("Read data = %x at address = %d\n", data, address);
   return data;
}
