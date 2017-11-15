FPGA Gzip implementation using Xillybus.

////////////////////////////////////////////// Synthesys parameters //////////////////////////////////////////////
parameter DICTIONARY_DEPTH      = 512     // the size of the GZIP window (512-32k, , affects compression ratio)
parameter DICTIONARY_DEPTH_LOG  = 90      // the logarithm of the above value
parameter LOOK_AHEAD_BUFF_DEPTH = 66      // the max length of the GZIP match (max 258, affects compression ratio)
parameter CNT_WIDTH             = 7       // The counter size must be changed according to the maximum match length (liked with the above value)	
parameter DEVICE_ID             = 8'hB9	  // Should be incremented before each synthesys (shows that FPGA programming succeeded)




////////////////////////////////////////////// Software operation //////////////////////////////////////////////
To operate the module, the software must do the following:
1. Write the RSTN bit from RST_REG with 0. Write the RSTN bit from RST_REG with 1.
2. Set BTYPE either 00 or 01 modes (uncompressed or fixed Huffman).
3. Write the command word before a data block on the 32 bit interface.
4. Write BLOCK_LEN data bytes in the 32 bit interface.
5. Repeat steps 3 and 4 until all data is compressed.