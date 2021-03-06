#include "defines.h"

pthread_t tid[2];

#ifdef MEASURE_TIME
int first_time;
struct timeval  tv_start, tv_stop, duration;
#endif

/* provide help for command options */
void help(void)
{
    fprintf (stderr,
          "\n  \
          program version %d \n \
          Usage:\n      \
          \n            \
            program [-n[f]h] input_path output_path\n \
          \n \
              -n   no compression\n \
              -f   static code lengths (comments or not)\n \
              -h   display help \n \
          \n ",
          (int)SW_VERSION);
}

void* read_thread(void *arg)  //read from file and send to xillybus
{
#ifdef PRINT_DEBUG
    printf("read_thread \n");
#endif
    thread_args_t thread_args = *((thread_args_t*)arg);
    int read_len;
    int    total_read_len = 0;
    int frame_command;
    int i, tmp_cmd;
    char command;
    struct stat  read_file_status;    
    
    /* get file status */
    fstat(thread_args.fd_read, &read_file_status); 
#ifdef PRINT_DEBUG
    printf("size of input file is %d \n", (int)read_file_status.st_size);
#endif    

    //exit reset fpga core
    command = RESET;
    write_data_at_address(thread_args.fd_mem, RESET_ADD, &command , SIZE_OF_CHAR);
#ifdef PRINT_DEBUG
    close(thread_args.fd_mem);
    printf("1 \n");
    system("hexdump -C -v -n 32 /dev/xillybus_mem_8");
    thread_args.fd_mem = open("/dev/xillybus_mem_8", O_RDWR);
#endif    
    
    while ((total_read_len < (int)read_file_status.st_size))
    {
        read_len = read(thread_args.fd_read, (unsigned char *)thread_args.buff, thread_args.buffer_size);
        total_read_len += read_len;
        frame_command = read_len;
        if ((read_len < 0) && (errno == EINTR))
          continue;

        if (read_len < 0) {
          perror("allread() failed to read");
          exit(1);
        }

        if ((read_len < thread_args.buffer_size) || (total_read_len == (int)read_file_status.st_size)) 
        {
#ifdef PRINT_DEBUG
printf("Reached read_thread EOF len= %d   cond %d \n\n", total_read_len, total_read_len < (int)read_file_status.st_size );
#endif    
            frame_command |= LAST_BLOCK;
        }
        //invert frame command;
        tmp_cmd = frame_command;
        for(i=0; i<SIZE_OF_INT; i++)
            ((unsigned char*)(&frame_command))[i] = ((unsigned char*)(&tmp_cmd))[SIZE_OF_INT - i - 1];
#ifdef PRINT_DEBUG
        printf("text: %s \n", (unsigned char *)thread_args.buff);
#endif

#ifdef MEASURE_TIME
		if(first_time == 0)
		{
			first_time = 1;
			gettimeofday(&tv_start, NULL);			
		}
#endif

        write_data(thread_args.fd_write, (unsigned char *)&frame_command,SIZE_OF_INT);
        write_data(thread_args.fd_write, (unsigned char *)thread_args.buff,read_len);
        
        if(frame_command | 0x1) //if last block, give another byte
        {
            command = 0;
            write_data(thread_args.fd_write, &command,0);
#ifdef PRINT_DEBUG
printf("end of file dummy write \n" );
#endif    
        }

    }
#ifdef PRINT_DEBUG
printf("end read_thread \n\n" );
#endif        

    return NULL;
}

void* write_thread(void *arg)  //read from xillybus and send to file
{
#ifdef PRINT_DEBUG
    printf("write_thread \n");
#endif
    thread_args_t thread_args = *((thread_args_t*)arg);
    int wr_len;
    int rv;
    fd_set set;
    struct timeval timeout;
    FD_ZERO(&set); /* clear the set */
    FD_SET(thread_args.fd_read, &set); /* add our file descriptor to the set */
    int tmp;
    
    timeout.tv_sec = 1;
    timeout.tv_usec = 10000;  
    
  while (1)
  {
        rv = select(thread_args.fd_read + 1, &set, NULL, NULL, &timeout);
        if(rv == -1)
            perror("select"); /* an error accured */
        else 
            if(rv == 0)
            {   
#ifdef PRINT_DEBUG
    printf("\n         timeout \n"); /* a timeout occured */
    
    close(thread_args.fd_mem);
    
    printf("2 \n");
    system("hexdump -C -v -n 32 /dev/xillybus_mem_8");
    thread_args.fd_mem = open("/dev/xillybus_mem_8", O_RDWR);
    
    read_data_from_address(thread_args.fd_mem, ISIZE_ADD, (unsigned char *)&tmp , SIZE_OF_INT);
    printf("size processed %x \n", tmp);
    read_data_from_address(thread_args.fd_mem, CRC_ADD, (unsigned char *)&tmp , SIZE_OF_INT);
    printf("CRC  %x \n", tmp);
#endif        
            
                break;
            }
            else
            {
#ifdef MEASURE_TIME
                gettimeofday(&tv_stop, NULL);
#endif
                read_data(thread_args.fd_read, thread_args.buff, &wr_len);
                write(thread_args.fd_write, (unsigned char*)thread_args.buff, wr_len);
            }
  }
#ifdef PRINT_DEBUG
printf("end write_thread \n\n" );
#endif      
    return NULL;
}


/* Subtract the ‘struct timeval’ values X and Y,
   storing the result in RESULT.
   Return 1 if the difference is negative, otherwise 0. */

int
timeval_subtract (struct timeval *result, struct timeval *x, struct timeval *y)
{
  /* Perform the carry for the later subtraction by updating y. */
  if (x->tv_usec < y->tv_usec) {
    int nsec = (y->tv_usec - x->tv_usec) / 1000000 + 1;
    y->tv_usec -= 1000000 * nsec;
    y->tv_sec += nsec;
  }
  if (x->tv_usec - y->tv_usec > 1000000) {
    int nsec = (x->tv_usec - y->tv_usec) / 1000000;
    y->tv_usec += 1000000 * nsec;
    y->tv_sec -= nsec;
  }

  /* Compute the time remaining to wait.
     tv_usec is certainly positive. */
  result->tv_sec = x->tv_sec - y->tv_sec;
  result->tv_usec = x->tv_usec - y->tv_usec;

  /* Return 1 if result is negative. */
  return x->tv_sec < y->tv_sec;
}

int main(int argc, char *argv[]) {
    char *arg;
    char *input_path = NULL;
    char *output_path = NULL;
    int fd_read, fd_write, fd_mem;
    int    thr_idx;
    int fd_xillybus_rd;
    int fd_xillybus_wr;
    unsigned char buf[2][BLOCK_SIZE];
    gzip_header_t  gzip_file_header = { 0x1F, 0x8B, 8, 0, 0x00000000, 0x0, 0x00};
    int err;
    char command;
    char compress_mode = BTYPE_NO_COMP;
    thread_args_t thread_args[2];
    long long milliseconds_start, milliseconds_stop;

    //analyze command line
    while (--argc) {
        arg = *++argv;
        if (*arg++ != '-') {
            if (input_path != NULL)
                if (output_path != NULL)
                    fprintf (stderr,"only one input file permitted (%s) \n", arg - 1);
                else //output_path
                output_path = arg - 1;
            else //input_path
                input_path = arg - 1;
            continue;
        }
        while (*arg)
            switch (*arg++) {
            case 'n': 
                {
                    compress_mode = BTYPE_NO_COMP;
                    break;
                }
            case 'f':  
                {
                    compress_mode = BTYPE_FIX_HUFF;
                    break;
                }
            case 'h':  
                {
                    help();          
                    return 0;
                }
            default:
                {
                    printf("invalid option '%c' (type program for help) \n", *--arg);
                    return 0;
                }
            }
    }
    if ((input_path == NULL) || (output_path == NULL)) 
        {
            help();
            return 0;
        }       

    
    fd_read = open(input_path, O_RDONLY);

    if (fd_read < 0)
    {
        if (errno == ENODEV)
          fprintf(stderr, "(Maybe %s a write-only file?)\n", argv[1]);

        perror("Failed to open devfile read");
        exit(1);
    }


    fd_xillybus_rd = open("/dev/xillybus_read_32", O_RDONLY);

    if (fd_xillybus_rd < 0)
    {
        if (errno == ENODEV)
          fprintf(stderr, "(Maybe %s a write-only file?)\n", "/dev/xillybus_read_8");

        perror("Failed to open devfile xillybus read");
        exit(1);
    }

    fd_write = open(output_path, O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR  | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH );

    if (fd_write < 0)
    {
        if (errno == ENODEV)
          fprintf(stderr, "(Maybe %s a read-only file?)\n", argv[2]);

        perror("Failed to open devfile write");
        exit(1);
    }

    fd_xillybus_wr = open("/dev/xillybus_write_32", O_WRONLY);

    if (fd_xillybus_wr < 0)
    {
        if (errno == ENODEV)
          fprintf(stderr, "(Maybe %s a read-only file?)\n", "/dev/xillybus_write_8");

        perror("Failed to open devfile xillybus write");
        exit(1);
    }    
    
    fd_mem = open("/dev/xillybus_mem_8", O_RDWR);

    if (fd_mem < 0)
    {
        if (errno == ENODEV)
          fprintf(stderr, "(Maybe %s a read-only file?)\n", "/dev/xillybus_write_8");

        perror("Failed to open devfile xillybus write");
        exit(1);
    }
    
     //reset fpga core
    command = 0;
    write_data_at_address(fd_mem, RESET_ADD, &command , SIZE_OF_CHAR);
            
    // set BTYPE
    write_data_at_address(fd_mem, BTYPE_ADD, &compress_mode , SIZE_OF_CHAR);      
    
#ifdef PRINT_DEBUG    
    close(fd_mem);
    printf("3 \n");
    system("hexdump -C -v -n 32 /dev/xillybus_mem_8");
    fd_mem = open("/dev/xillybus_mem_8", O_RDWR);
#endif

    if (fd_mem < 0)
    {
        if (errno == ENODEV)
          fprintf(stderr, "(Maybe %s a read-only file?)\n", "/dev/xillybus_write_8");

        perror("Failed to open devfile xillybus write");
        exit(1);
    }
    /* write gzip_file_header */
    write(fd_write, &gzip_file_header, GZIP_HEADER_MANDATORY);
    //to be completed with flags
    

    thread_args[0].fd_read      = fd_read;
    thread_args[0].fd_write     = fd_xillybus_wr;
    thread_args[0].fd_mem       = fd_mem;
    thread_args[0].buff         = &buf[0][0] ;
    thread_args[0].buffer_size  = BLOCK_SIZE ;
    
    
    err = pthread_create(&(tid[0]), NULL, &read_thread, &thread_args[0]);
    if (err != 0)
        printf("\ncan't create thread :[%s]", strerror(err));
    else
    {
#ifdef PRINT_DEBUG
        printf("\n Thread created successfully\n");                    
#endif
    }
    thread_args[1].fd_read      = fd_xillybus_rd;
    thread_args[1].fd_write     = fd_write;
    thread_args[1].fd_mem       = fd_mem;
    thread_args[1].buff         = &buf[1][0] ;
    thread_args[1].buffer_size  = BLOCK_SIZE ;
    
    
    err = pthread_create(&(tid[1]), NULL, &write_thread, &thread_args[1]);
    if (err != 0)
        printf("\ncan't create thread :[%s]", strerror(err));
    else
    {
#ifdef PRINT_DEBUG
        printf("\n Thread created successfully\n");                    
#endif
    }
#ifdef PRINT_DEBUG
    printf(" all threads created \n");
#endif    
    for (thr_idx = 0; thr_idx < 2; thr_idx++)
       pthread_join(tid[thr_idx], NULL);

#ifdef MEASURE_TIME
    timeval_subtract(&duration, &tv_stop, &tv_start);
    printf("duration: %lld sec %lld us\n", duration.tv_sec, duration.tv_usec);
#endif    
    
    //reset fpga core
    command = RESET;
    write_data_at_address(fd_mem, RESET_ADD, &command , SIZE_OF_CHAR);   
   
#ifdef PRINT_DEBUG
    printf(" all threads finished \n");
#endif        
    close(fd_read);
    close(fd_xillybus_rd);
    close(fd_write);
    close(fd_xillybus_wr);
    close(fd_mem);
#ifdef PRINT_DEBUG    
    printf("4 \n");
    system("hexdump -C -v -n 32 /dev/xillybus_mem_8");
#endif
#ifdef PRINT_DEBUG
    printf("exit main() \n");
#endif
    exit(0);
    return 1;
}
