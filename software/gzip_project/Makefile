CFLAGS=-g -Wall -O3

APPLICATIONS=program
OBJECTS=*.o

program: main.o write_data.o read_data.o utils.o
	gcc -pthread -o program main.o write_data.o read_data.o utils.o
	rm -f $(OBJECTS)

main.o: main.c defines.h
	gcc -pthread -c main.c

write_data.o: write_data.c defines.h
	gcc -c write_data.c

read_data.o: read_data.c defines.h
	gcc -c read_data.c
	
utils.o: utils.c defines.h
	gcc -c utils.c

clean:
	rm -f *~ $(APPLICATIONS) $(OBJECTS) 
