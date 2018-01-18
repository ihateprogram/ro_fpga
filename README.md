# FPGA Gzip implementation using Xillybus.

The internal structure and performance of the compressor circuit is described [in our paper](http://ecai.ro/VOLUME%202017/ECAI-2016%20VOLUMES/YOUNG/ECAI-2017_paper_80.pdf). 
If our code is useful to your research, please cite our work. To cite this paper in Bibtex, use the following snippet:

```
@inproceedings{plugariu17gzip,
  title={FPGA systolic array GZIP compressor},
  author={PLUGARIU, Ovidiu and GEGIU, Alexandru Dumitru and PETRICA, Lucian},
  booktitle={Proceedings of the International Conference on Electronics, Computers, and Artificial Intelligence},
  year={2017}
}
```

## Parameter Description

| Name                  | Default Value | Range     | Notes                                |
|:----------------------|:--------------|:----------|:-------------------------------------|
| DICTIONARY_DEPTH      | 512           | 512 - 32K | Affects compression ratio            |
| DICTIONARY_DEPTH_LOG  | 9             |           | The logarithm of the above value     |
| LOOK_AHEAD_BUFF_DEPTH | 66            | up to 258 | The maximum length of the GZIP match |
| CNT_WIDTH             | 7             |           | Logarithm ceiling of above value     |
| DEVICE_ID             | 8'hB9         |           | Build ID                             |

## Register Description

| Address | Name    | Default Value | Notes                                                                 |
|:--------|:--------|:--------------|:----------------------------------------------------------------------|
| 0x00       | RST_REG | 0             | Active-low core reset tied to RST_REG[0]                           |
| 0x04       | CONFIG  | 0             | CONFIG[1:0] maps to BTYPE, CONFIG[2] to REND, CONFIG[3] to IRQEN   |
| 0x08       | STATUS  | 0             | 29 zeros at MSB, then GZIP_DONE, BTYPE_ERROR, and BLOCK_SIZE_ERROR |
| 0x0C       | ISIZE   | 0             | Input (uncompressed) data size, modulo 2^32                        |
| 0x10       | CRC32   | 0             | Computed CRC (ISO 3309 and ITU-T V.42 compliant)                   |
| 0x14       | BSIZE   | 0             | Size of the current input data block                               |
| 0x18       | OSIZE   | 0             | Size of the generated DEFLATE stream, in bits; NOTE: core pads with zeros up to an integer multiple of 64 bits on AXI output |
| 0x1C       | ID      | B9            | Version ID of the current GZIP build                               |

## Command Word Description

Input to the GZIP core consists of data blocks 
A 32-bit command word must precede each data block on the input AXI Stream interface. 
The command word indicates the length of the data block following it and indicates if it is the last block.
The fields of the command word are as follows:

| Bit Range | Name     | Notes                                        |
|:----------|:-------- |:---------------------------------------------|
| [31:25]   | RESERVED | Reserved bits, set to 0                      |
| [24]      | BFINAL   | Set to 1 if last block of input, otherwise 0 |
| [23:0]    | BSIZE    | Number of data bytes in the block            |

## Software Operation

To operate the module, the software must do the following:
1. Reset the core by writing the LSB of RST_REG with 0 then with 1.
2. Set BTYPE either 00 or 01 modes (uncompressed or fixed Huffman respectively).
3. Set REND the desired endianness, 0 for LittleEndian or 1 for BigEndian.
4. Set IRQEN to 1 to enable interrupts or 0 to disable them.
5. Write the command word before a data block on the 32 bit interface.
6. Write BLOCK_LEN data bytes in the 32 bit interface.
7. Repeat steps 3 and 4 until all data is compressed.

## Core Output

The GZIP IP produces RFC1951-compliant DEFLATE streams in noncompressed or fixed Huffman modes (depending on the setting of BTYPE). 
The DEFLATE streams are appended with the CRC32 and ISIZE fields of the GZIP file format, described in RFC1952.
To obtain a valid GZIP file, software must write the GZIP header and append the core output.


