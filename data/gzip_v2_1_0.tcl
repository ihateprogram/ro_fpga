
proc generate_fifos {mhsinst} {
    set pcoredir [xget_hw_pcore_dir $mhsinst]
    set ngcfolder $pcoredir../netlist
    puts $ngcfolder
    set verilogfolder $pcoredir../hdl/verilog
    puts $verilogfolder
    set cgpfile $ngcfolder/coregen.cgp
    set fifo32_ngc $ngcfolder/fifo_32x512.ngc
    set fifo32_v $ngcfolder/fifo_32x512.v
    set fifo32_xco $ngcfolder/fifo_32x512.xco
    set fifo32_exists [file exists $fifo32_ngc]
    set stub32_exists [file exists $fifo32_v]
    set fifo64_ngc $ngcfolder/fifo_64x256.ngc
    set fifo64_v $ngcfolder/fifo_64x256.v
    set fifo64_xco $ngcfolder/fifo_64x256.xco
    set fifo64_exists [file exists $fifo64_ngc]
    set stub64_exists [file exists $fifo64_v]
    if {$fifo32_exists != 1} {
        puts "GZIP: Generating 32-bit FIFO netlist using Coregen\n"
        set result [catch {exec coregen -p $cgpfile -b $fifo32_xco -intstyle xflow}]
    }
    if {$stub32_exists != 1} {
        puts "GZIP: Moving 32-bit FIFO Verilog stub to the HDL folder\n"
        set result [catch {exec cp $fifo32_v $verilogfolder}]
    }
    if {$fifo64_exists != 1} {
        puts "GZIP: Generating 64-bit FIFO netlist using Coregen\n"
        set result [catch {exec coregen -p $cgpfile -b $fifo64_xco -intstyle xflow}]
    }
    if {$stub64_exists != 1} {
        puts "GZIP: Moving 64-bit FIFO Verilog stub to the HDL folder\n"
        set result [catch {exec cp $fifo64_v $verilogfolder}]
    }
}
