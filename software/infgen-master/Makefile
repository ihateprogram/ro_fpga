CFLAGS=-g -Wall -O3

APPLICATIONS=infgen
OBJECTS=*.o

infgen: infgen.o
	gcc -pthread -o infgen infgen.o
	rm -f $(OBJECTS)

inflate.o: inflate.c
	gcc -c inflate.c

infgen.o: infgen.c
	gcc -c infgen.c
	
clean:
	rm -f *~ $(APPLICATIONS) $(OBJECTS) 
