FPGA Gzip implementation using Xillybus.


To operate the module, the software must do the following:
1. Write the RSTN bit from RST_REG with 0. Write the RSTN bit from RST_REG with 1.
2. Set BTYPE either 00 or 01 modes (uncompressed or fixed Huffman).
3. Write the command word before a data block on the 32 bit interface.
4. Write BLOCK_LEN data bytes in the 32 bit interface.
5. Repeat steps 3 and 4 until all data is compressed.