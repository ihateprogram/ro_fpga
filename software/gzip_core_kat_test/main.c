#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>

//#include "xilly_debug.h"

//#include "crypto_ovi.h"
//#include "test_vectors.h"
#include "fpga_functions.h"
#include "global_defines.h"


#define PRINT_DEBUG 1


// These global variables are used to count all tests and their results
volatile uint32_t test_count = 0;
volatile uint32_t success_count = 0;
volatile uint32_t error_count = 0;


/* Function to convert a decinal number to binary number */
long decimalToBinary(long n) {
    int remainder; 
    long binary = 0, i = 1;
  
    while(n != 0) {
        remainder = n%2;
        n = n/2;
        binary= binary + (remainder*i);
        i = i*10;
    }
    return binary;
}


// Function used to concatenate 2 strings
char* concat(const char *s1, const char *s2)
{
    char *result = malloc(strlen(s1)+strlen(s2)+1);//+1 for the zero-terminator
    //in real code you would check for errors in malloc here
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}


void write_mem_array_data(uint32_t data, uint32_t address)
{
    int fd;
    void * map_addr;
    int size = 256;
    fd = open("/dev/uio0", O_RDWR);
    if(fd < 0) {
        perror("Failed to open devfile");
        exit(1);
    }

    map_addr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if(map_addr == MAP_FAILED) {
        perror("Failed to mmap");
        exit(1);
    }

    printf("\nRegister Write data = %ld at address = %d", decimalToBinary(data), address);

    int offset = address/4;
    volatile unsigned int * pointer = map_addr;
    pointer[offset] = data;

    close(fd);
}

void check_mem_array_data(uint32_t  expected_val, uint32_t address)
{
    int fd;
    void * map_addr;
    int size = 256;
    fd = open("/dev/uio0", O_RDWR);
    if(fd < 0) {
        perror("Failed to open devfile");
        exit(1);
    }

    map_addr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if(map_addr == MAP_FAILED) {
        perror("Failed to mmap");
        exit(1);
    }

    printf("\nRegister Read from address = %d", address);

    int offset = address/4;
    volatile unsigned int * pointer = map_addr;
    uint32_t data = pointer[offset];

   if (data == expected_val)
   {
      printf("\nCORRECT - Read data = %d, Expected data = %d at ADDRESS = %d", data, expected_val, address);
      success_count = success_count + 1;
   }
   else
   {
      printf("\nERROR - Read data = %d, Expected data = %d at ADDRESS = %d", data, expected_val, address);
      error_count = error_count + 1;
   }

   close(fd);
}


void check_compressed_data(uint8_t * data_in, uint8_t * expected_data, int len)
{
   test_count = test_count + 1;

   if (memcmp(data_in, expected_data, len) == 0)
   {
      printf("\nCORRECT - Compressed Read data equal with Expected data ");
      success_count = success_count + 1;
   }
   else
   {
      printf("\nERROR - Compressed Read data DIFFERENT than Expected data");
      error_count = error_count + 1;
   }
}


void send_data_to_fpga(int fd, char* data_buff, uint32_t len_override, uint8_t bfinal, uint8_t ignore_payload)
{
   uint8_t command_word[4];
   //uint8_t data_remainder[] = "0000";
   uint32_t i;
   uint8_t* concatenate;
   uint8_t remainder;
   uint32_t len;

   // If we don't want to use the actual length of data it means we are running a debug test
   if(ignore_payload)
      len = len_override;
   else
      len = strlen(data_buff);
        
    
   command_word[3] = len & 0xFF; 
   command_word[2] = (len & (0xFF << 8)) >> 8; 
   command_word[1] = (len & (0xFF << 16)) >> 16; 
   command_word[0] = bfinal; 
   
   printf("\nCOMMAND_WORD = %x %x %x %x", command_word[0], command_word[1], command_word[2], command_word[3]);
   //printf("\nCOMMAND_WORD = %d", command_word);
   allwrite(fd, command_word, 4);      // insert the command word

   // If we want to send only the header (COMMDAND )
   if (!ignore_payload)
   {
      remainder = len % 4; 
      //len_div4 = len - remainder;
      //printf("\n Trimit payload");
      //printf("\n lungimea_calculata = %d", strlen(data_buff));
      //allwrite(fd, data_buff, len_div4);      // insert the command word
      //allwrite(fd, data_buff, len);      // insert the command word
      
      //printf("\n len_div4 = %d", (int)len_div4);
      //printf("\n restul = %d", (int) remainder);
      // make zero padding according to len mod 4
      switch(remainder)
      {
      case(1): 
              concatenate = (uint8_t *) concat(data_buff, "000");
              break;
      case(2): 
              concatenate = (uint8_t *) concat(data_buff, "00");
              break;
      case(3): 
              concatenate = (uint8_t *) concat(data_buff, "0");
              break;
      default: 
              concatenate = (uint8_t *) concat(data_buff, "");
              break;
      }

      //printf("\n restul2 = %d", strlen(concatenate));
      allwrite(fd, concatenate , strlen((char *)concatenate));
      //printf("\n gzip_data_in = %s,  lungimea = %d", concatenate, strlen(concatenate));
      allwrite(fd, NULL, 0);              // Make Flush
      free(concatenate);
   }

   return;
}


/*char* concat(const char *s1, const char *s2)
{
    char *result = malloc(strlen(s1)+strlen(s2)+1);//+1 for the zero-terminator
    //in real code you would check for errors in malloc here
    strcpy(result, s1);
    strcat(result, s2);
    return result;
} */

uint8_t* read_data_from_fpga(int fd, uint32_t rd_len)
{
   uint8_t *read_data = malloc(rd_len);
   int i;

   if (fd < 0) 
   {
      if (errno == ENODEV)
         fprintf(stderr, "(Maybe %d a write-only file?)\n", fd);
         perror("Failed to open devfile");
         exit(1);
   }
  
   //printf("\n******** lung_read_data = %d ", strlen(read_data));
   allread(fd, read_data, rd_len);

   //strcpy(data_out, read_data);
#if PRINT_DEBUG
   printf("\n******** Receiving data from FPGA\n");
   for(i=0; i < rd_len; i++)
   {           
      printf("\nread_data[%d] = %x ",i ,read_data[i]);
   }
#endif PRINT_DEBUG

   return read_data;

}


void display_test_result ()
{
   printf("\n\n\n=========================== KAT STATISTICS ==========================\n");
   printf("\nTEST_COUNT = %d", (int) test_count);
   printf("\nSUCCESS_COUNT = %d", (int) success_count);
   printf("\nERROR_COUNT = %d", (int) error_count);
   if (test_count == success_count)
      printf("\n====================== TEST SUCCESS ==========================\n");
   else
      printf("\n====================== TEST FAILED ==========================\n");
}

//#define skip_me

int main() 
{
   uint8_t test_in[] = "1234";  // 128 bit of data which will be sent to the FPGA
   uint8_t *data_received;
   int i;
   int fdr, fdw;

   printf("\n**************************************************************************\n");
   printf("\t\tGZIP FPGA Known Answer Test");  
   printf("\n\t\t\t\t\t\tAuthor: Ovidiu PLUGARIU");  
   printf("\n**************************************************************************\n");

   // Toggle the RESET and enable the core
   printf("\n\nCheck DEVICE_ID");   
   check_mem_array_data(DEV_ID, DEBUG_REV_REG);
       

   printf("\n\n******************** TEST 1 - BSIZE_ERR for NO_COMPRESSION  ********************\n");
   printf("\tBLOCK_SIZE = 65537\n");
   write_mem_array_data(BTYPE_NO_COMPRESSION, BTYPE_REG);
   write_mem_array_data(RESET_EN, RESET_REG);
   write_mem_array_data(RESET_DIS, RESET_REG);
   check_mem_array_data(RESET_DIS, RESET_REG);
       
   fdw = open("/dev/xillybus_write_32",O_WRONLY);
   send_data_to_fpga(fdw, test_in, 65537, BFINAL1, IGNORE_PAYLOAD);
   close(fdw);                                   
 
   check_mem_array_data(BSIZE_ERR, STATUS_REG);
   

   printf("\n\n******************** TEST 2 - BSIZE_ERR for FIXED_HUFFMAN  ********************\n");
   printf("\tBLOCK_SIZE = 32769\n");
   write_mem_array_data(BTYPE_FIXED_HUFFMAN, BTYPE_REG);
   write_mem_array_data(RESET_EN, RESET_REG);
   write_mem_array_data(RESET_DIS, RESET_REG);
   check_mem_array_data(RESET_DIS, RESET_REG);   // check if the RESET bit is SET
       
   fdw = open("/dev/xillybus_write_32",O_WRONLY);
   send_data_to_fpga(fdw, test_in, 32769, BFINAL1, IGNORE_PAYLOAD);
   close(fdw);                                   
 
   check_mem_array_data(BSIZE_ERR, STATUS_REG);

   printf("\n\n******************** TEST 3 - BTYPE_ERR  ********************\n");
   printf("\tBTYPE = DYNAMIC_HUFFMAN\n");
   write_mem_array_data(RESET_EN, RESET_REG);
   write_mem_array_data(RESET_DIS, RESET_REG);
   check_mem_array_data(RESET_DIS, RESET_REG);
   write_mem_array_data(BTYPE_DYNAMIC_HUFFMAN, BTYPE_REG);  // Check that the register is read/write
   check_mem_array_data(BTYPE_DYNAMIC_HUFFMAN, BTYPE_REG);
   write_mem_array_data(BTYPE_UNDEFINED, BTYPE_REG);
   check_mem_array_data(BTYPE_UNDEFINED, BTYPE_REG);
       
   fdw = open("/dev/xillybus_write_32",O_WRONLY);
   send_data_to_fpga(fdw, test_in, 3, BFINAL1, IGNORE_PAYLOAD);
   close(fdw);                                   
 
   check_mem_array_data(BTYPE_ERR, STATUS_REG); 


   printf("\n\n******************** TEST 5 - CRC Integrity  ********************\n");
   printf("Check CRC integrity \n");
   uint8_t expected_data0[] = {0x1 , 0x4, 0x0, 0xfb, 0xff, 0x30, 0x30, 0x30, 0x31, 0xe4, 0xf4, 0x9c, 0x7b, 0x4 , 0x0 , 0x0};

 
   //uint8_t expected_data1[] = {0x1, 0x0};    
   write_mem_array_data(BTYPE_NO_COMPRESSION, BTYPE_REG);
   check_mem_array_data(BTYPE_NO_COMPRESSION, BTYPE_REG);

   write_mem_array_data(RESET_EN, RESET_REG);
   write_mem_array_data(RESET_DIS, RESET_REG);
   check_mem_array_data(RESET_DIS, RESET_REG);
       
   fdw = open("/dev/xillybus_write_32",O_WRONLY);
   fdr = open("/dev/xillybus_read_32", O_RDONLY);    // open the file descriptors
   send_data_to_fpga(fdw, "0001", 0, BFINAL1, PROCESS_PAYLOAD);
   //printf("\n******** lungimea %d\n", strlen((char *)data_received));
  // printf("\n Concatenate = %s", data_received);
   data_received = read_data_from_fpga(fdr, 16);
     
   check_compressed_data(data_received, expected_data0, 16);
   
   check_mem_array_data(RESET_DIS, RESET_REG);

   // Check that BLOCK_LEN[24:0] is 4;
   check_mem_array_data(0x4, BLOCK_LEN_REG);

   // Check that CRC[31:0] ix 0x7B9CF4E4
   check_mem_array_data(0x7B9CF4E4, CRC_REG);

   free(data_received); 

   close(fdw);                                   
   close(fdr);                                       // close the file descriptors
   check_mem_array_data(GZIP_DONE, STATUS_REG);        // check for the GZIP_DONE bit to be set




   printf("\n\n******************** TEST 4 - NO COMPRESSION  ********************\n");
   printf("BTYPE = NO_COMPRESSION  \n");
   uint8_t expected_data1[] = { 0x1 , 0x20, 0x0 , 0xdf, 0xff, 0x54, 0x65, 0x73, 0x74, 0x20, 0x47, 0x5a, 0x49, 0x50, 0x20, 0x63, 0x6f, 0x6d, 0x70, 0x72, 0x65, 0x73, 0x73, 0x69, 0x6f, 0x6e, 0x20, 0x63, 0x6f, 0x72, 0x65, 0x20, 0x54, 0x65, 0x73, 0x74, 0x2e, 0xe8, 0xb2, 0xab, 0x5a, 0x20, 0x0 , 0x0};

   //uint8_t expected_data1[] = {0x1, 0x0};    
   write_mem_array_data(BTYPE_NO_COMPRESSION, BTYPE_REG);
   check_mem_array_data(BTYPE_NO_COMPRESSION, BTYPE_REG);

   write_mem_array_data(RESET_EN, RESET_REG);
   write_mem_array_data(RESET_DIS, RESET_REG);
   check_mem_array_data(RESET_DIS, RESET_REG);
       
   fdw = open("/dev/xillybus_write_32",O_WRONLY);
   fdr = open("/dev/xillybus_read_32", O_RDONLY);    // open the file descriptors
   send_data_to_fpga(fdw, "Test GZIP compression core Test.", 0, BFINAL1, PROCESS_PAYLOAD);
   //printf("\n******** lungimea %d\n", strlen((char *)data_received));
  // printf("\n Concatenate = %s", data_received);
   data_received = read_data_from_fpga(fdr, 44);
     
   check_compressed_data(data_received, expected_data1, 44);
   
   free(data_received); 

   close(fdw);                                   
   close(fdr);                                       // close the file descriptors
   check_mem_array_data(GZIP_DONE, STATUS_REG);        // check for the GZIP_DONE bit to be set
    


   printf("\n\n******************** TEST 5 - STATIC HUFFMAN COMPRESSION  ********************\n");
   printf("BTYPE = BTYPE_FIXED_HUFFMAN \n");
   uint8_t expected_data2[] = { 0xb , 0x49, 0x2d, 0x2e, 0x51, 0x70, 0x8f, 0xf2, 0xc , 0x50, 0x48, 0xce, 0xcf, 0x2d, 0x28, 0x4a, 0x2d, 0x2e, 0xce, 0xcc, 0xcf, 0x3 , 0xb2, 0x8b, 0x52, 0x15, 0xe0, 0x52, 0x0 , 0x46, 0x91, 0x10, 0xa0, 0x24, 0x0 , 0x0 };

   write_mem_array_data(BTYPE_FIXED_HUFFMAN, BTYPE_REG);
   check_mem_array_data(BTYPE_FIXED_HUFFMAN, BTYPE_REG);

   write_mem_array_data(RESET_EN, RESET_REG);
   write_mem_array_data(RESET_DIS, RESET_REG);
   check_mem_array_data(RESET_DIS, RESET_REG);

   fdw = open("/dev/xillybus_write_32",O_WRONLY);
   fdr = open("/dev/xillybus_read_32", O_RDONLY);    // open the file descriptors
   send_data_to_fpga(fdw, "Test GZIP compression core Test GZIP", 0, BFINAL1, PROCESS_PAYLOAD);
   //printf("\n******** lungimea %d\n", strlen((char *)data_received));
  // printf("\n Concatenate = %s", data_received);
   data_received = read_data_from_fpga(fdr, 36);
     
   check_compressed_data(data_received, expected_data2, 36);
   
   free(data_received); 

   close(fdw);                                   
   close(fdr);                                       // close the file descriptors
#ifdef skip_me   
#endif

   display_test_result ();

   return 0;
}
