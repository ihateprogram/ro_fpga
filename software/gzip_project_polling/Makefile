#CFLAGS=-g -Wall -O3
CFLAGS=-I.

APPLICATIONS=program deflate_core_lib
OBJECTS=*.o

CC=gcc

program: main.o write_data.o read_data.o fpga_functions.o utils.o crc32.o zutil.o adler32.o trees.o deflate.o
	$(CC) $(CFLAGS) -pthread -o program main.o write_data.o fpga_functions.o read_data.o utils.o crc32.o zutil.o trees.o adler32.o deflate.o
	rm -f $(OBJECTS)

main.o: main.c defines.h
	$(CC) $(CFLAGS) -pthread -c main.c 

write_data.o: write_data.c defines.h
	$(CC) $(CFLAGS) -c write_data.c

read_data.o: read_data.c defines.h
	$(CC) $(CFLAGS) -c read_data.c

fpga_functions.o: fpga_functions.c defines.h
	$(CC) $(CFLAGS) -c fpga_functions.c

zutil.o: zutil.c zutil.h
	$(CC) $(CFLAGS) -c zutil.c

trees.o: trees.c trees.h
	$(CC) $(CFLAGS) -c trees.c

crc32.o: crc32.c crc32.h
	$(CC) $(CFLAGS) -c crc32.c

deflate.o: deflate.c zconf.h deflate.h
	$(CC) $(CFLAGS) -c deflate.c
	
utils.o: utils.c deflate.h defines.h
	$(CC) $(CFLAGS) -c utils.c

adler32.o: adler32.c
	$(CC) $(CFLAGS) -c adler32.c

deflate_core.o:
	$(CC) $(CFLAGS) -c deflate_core.c

deflate_core_lib: deflate_core.o
	$(CC) -shared -o lib_deflate_core.so deflate_core.o
	

clean:
	rm -f *~ $(APPLICATIONS) $(OBJECTS) 
