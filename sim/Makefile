
SOURCES = $(wildcard ../hdl/verilog/*.v) $(wildcard ./*.v) sim.prj
TESTBENCHES = $(wildcard ./*.v)
EXECUTABLES = $(patsubst %.v,%.exec,$(TESTBENCHES))

all: $(EXECUTABLES)

%.exec: %.v
	git submodule update --init AXI4Utils
	fuse work.$* -incremental -prj sim.prj -o $@ > /dev/null

clean:
	git submodule deinit -f -- AXI4Utils
	-git clean -xfd
