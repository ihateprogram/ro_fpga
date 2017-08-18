
XCO_FILES=$(shell ls *.xco)
V_FILES=$(patsubst %.xco,%.v,$(XCO_FILES)) 

all: $(V_FILES)

%.v: %.xco
	coregen -p coregen.cgp -b $*.xco
