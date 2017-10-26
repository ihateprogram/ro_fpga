
SOURCES = $(wildcard ../hdl/verilog/*.v) $(wildcard ./*.v) sim.prj
TESTBENCHES = $(wildcard ./*.v)
EXECUTABLES = $(patsubst %.v,%.exec,$(TESTBENCHES))

all: $(EXECUTABLES)

%.exec: %.v
	make -C ../netlist
	fuse work.$* work.glbl -incremental -prj sim.prj -L unisims_ver -L unimacro_ver -L xilinxcorelib_ver -o $@ > /dev/null

clean:
	-git clean -xfd
