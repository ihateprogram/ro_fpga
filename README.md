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
| 0x04       | CONFIG  | 0             | CONFIG[1:0] corresponds to BTYPE, CONFIG[2] to REND                |
| 0x08       | STATUS  | 0             | 29 zeros at MSB, then GZIP_DONE, BTYPE_ERROR, and BLOCK_SIZE_ERROR |
| 0x0C       | ISIZE   | 0             | Input (uncompressed) data size, modulo 2^32                        |
| 0x10       | CRC32   | 0             | Computed CRC (ISO 3309 and ITU-T V.42 compliant)                   |
| 0x14       | BSIZE   | 0             | Size of the current input data block                               |
| 0x18       | ID      | B9            | Version ID of the current GZIP build                               |

## Software Operation

To operate the module, the software must do the following:
1. Reset the core by writing the LSB of RST_REG with 0 then with 1.
2. Set BTYPE either 00 or 01 modes (uncompressed or fixed Huffman respectively).
3. Set REND the desired endianness, 0 for LittleEndian or 1 for BigEndian
4. Write the command word before a data block on the 32 bit interface.
5. Write BLOCK_LEN data bytes in the 32 bit interface.
6. Repeat steps 3 and 4 until all data is compressed.

