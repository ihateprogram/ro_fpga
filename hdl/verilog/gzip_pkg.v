/*
   Author: Ovidiu Plugariu
   Description: This package contains all parameters used in the GZIP compressor. 
*/

//package gzip_pkg;
`ifndef _parameters_lz77_
`define _parameters_lz77_
   // 
   parameter DATA_WIDTH = 8;
   parameter INPUT_BUFFER_DEPTH = 3;
   parameter SEARCH_BUFFER_DEPTH = 8; 
   
`endif //_parameters_lz77_   

   
//endpackage