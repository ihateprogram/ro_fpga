# FPGA Gzip implementation using Xillybus.

## Parameter Description

| Name                  | Default Value | Range     | Notes                                |
|:----------------------|:--------------|:----------|:-------------------------------------|
| DICTIONARY_DEPTH      | 512           | 512 - 32K | Affects compression ratio            |
| DICTIONARY_DEPTH_LOG  | 9             |           | The logarithm of the above value     |
| LOOK_AHEAD_BUFF_DEPTH | 66            | up to 258 | The maximum length of the GZIP match |
| CNT_WIDTH             | 7             |           | Logarithm ceiling of above value     |
| DEVICE_ID             | 8'hB9         |           | Build ID                             |

## Register Description

| Address | Name    | Default Value | Notes                                    |
|:--------|:--------|:--------------|:-----------------------------------------|
| 0       | RST_REG | 0             | Active-low core reset tied to RST_REG[0] |
| 4       | BTYPE   | 0             | Set to 1 to enable compression           |

## Software Operation

To operate the module, the software must do the following:
1. Reset the core by writing the LSB of RST_REG with 0 then with 1.
2. Set BTYPE either 00 or 01 modes (uncompressed or fixed Huffman).
3. Write the command word before a data block on the 32 bit interface.
4. Write BLOCK_LEN data bytes in the 32 bit interface.
5. Repeat steps 3 and 4 until all data is compressed.