#include <stdint.h>
#include <zlib.h>

int ZEXPORT deflateInit2_(strm, level, method, windowBits, memLevel, strategy,
                  version, stream_size)
    z_streamp strm;
    int  level;
    int  method;
    int  windowBits;
    int  memLevel;
    int  strategy;
    const char *version;
    int stream_size;
{

}

int ZEXPORT deflate (strm, flush)
    z_streamp strm;
    int flush;
{

}

int ZEXPORT deflateSetDictionary (strm, dictionary, dictLength)
    z_streamp strm;
    const Bytef *dictionary;
    uInt  dictLength;
{

}

int ZEXPORT deflateReset (strm)
    z_streamp strm;
{

}

int ZEXPORT deflateEnd (strm)
    z_streamp strm;
{

}
