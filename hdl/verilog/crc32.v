/*  
Title:            CRC32 - ISO 3309 and ITU-T V.42 compliant, used in GZIP
Author:                                                                  Ovidiu Plugariu

Description:  The CRC module implements the polynomial P(x) = x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1 .
            The CRC of a new character C is given by the ' P(x) mod C ' operation. Since the hardware polynomial division is done sequentially using
            LSFRs, to increase speed it is more efficient to precompute all the 256 remainder of P(x) to all 8 bit values.
            We will obtain a 256x32 LUT. By doing this we will consume more area, but the CRC-32 result is obtained in 1 clock cyle.
            Test vectors will be generated using the online CRC32 calculator below.
            This variant of CRC-32 uses LSB-first order, sets the initial CRC to 32'hFFFFFFFF, and complements the final CRC.			
			
            The C code for processing 1 character (8bit ASCII value) is:
		        crc = (crc >> 8) ^ table[(crc & 0xff) ^ octet];		
		
Links:
    CRC32 calculator used for generating test vectors:
	    https://www.lammertbies.nl/comm/info/crc-calculation.html
		http://www.theasciicode.com.ar/extended-ascii-code/copyright-symbol-ascii-code-184.html
	CRC32 C code for analysis:
	    https://rosettacode.org/wiki/CRC-32#C
		https://tools.ietf.org/html/rfc1952	

*/

module crc32
    (
    // Module inputs
	input clk,
	input rst_n,
	input [7:0] crc32_in,
    input crc32_valid_in,

	// Module outputs
	output [31:0] crc32_out             // 32 bit value of the CRC
    );
 	
	// Module registers
	reg [31:0] crc32_out_buff;
	reg [31:0] crc32_table;
	
	// Combiational logic 
	wire [7:0] crc32_lut_in;
	
    // Declare a 32x256 LUT for the CRC remainder table	
	// Construct the "table[(crc & 0xff) ^ octet]" operation
	assign crc32_lut_in = crc32_out_buff[7:0] ^ crc32_in;
	
    always @(*)
	begin
        case ( crc32_lut_in )
	        8'd0   : crc32_table = 32'h0;
	        8'd1   : crc32_table = 32'h77073096;
	        8'd2   : crc32_table = 32'hee0e612c;
	        8'd3   : crc32_table = 32'h990951ba;
	        8'd4   : crc32_table = 32'h76dc419;
	        8'd5   : crc32_table = 32'h706af48f;
	        8'd6   : crc32_table = 32'he963a535;
	        8'd7   : crc32_table = 32'h9e6495a3;
	        8'd8   : crc32_table = 32'hedb8832;
	        8'd9   : crc32_table = 32'h79dcb8a4;
	        8'd10  : crc32_table = 32'he0d5e91e;
	        8'd11  : crc32_table = 32'h97d2d988;
	        8'd12  : crc32_table = 32'h9b64c2b;
	        8'd13  : crc32_table = 32'h7eb17cbd;
	        8'd14  : crc32_table = 32'he7b82d07;
	        8'd15  : crc32_table = 32'h90bf1d91;
	        8'd16  : crc32_table = 32'h1db71064;
	        8'd17  : crc32_table = 32'h6ab020f2;
	        8'd18  : crc32_table = 32'hf3b97148;
	        8'd19  : crc32_table = 32'h84be41de;
	        8'd20  : crc32_table = 32'h1adad47d;
	        8'd21  : crc32_table = 32'h6ddde4eb;
	        8'd22  : crc32_table = 32'hf4d4b551;
	        8'd23  : crc32_table = 32'h83d385c7;
	        8'd24  : crc32_table = 32'h136c9856;
	        8'd25  : crc32_table = 32'h646ba8c0;
	        8'd26  : crc32_table = 32'hfd62f97a;
	        8'd27  : crc32_table = 32'h8a65c9ec;
	        8'd28  : crc32_table = 32'h14015c4f;
	        8'd29  : crc32_table = 32'h63066cd9;
	        8'd30  : crc32_table = 32'hfa0f3d63;
	        8'd31  : crc32_table = 32'h8d080df5;
	        8'd32  : crc32_table = 32'h3b6e20c8;
	        8'd33  : crc32_table = 32'h4c69105e;
	        8'd34  : crc32_table = 32'hd56041e4;
	        8'd35  : crc32_table = 32'ha2677172;
	        8'd36  : crc32_table = 32'h3c03e4d1;
	        8'd37  : crc32_table = 32'h4b04d447;
	        8'd38  : crc32_table = 32'hd20d85fd;
	        8'd39  : crc32_table = 32'ha50ab56b;
	        8'd40  : crc32_table = 32'h35b5a8fa;
	        8'd41  : crc32_table = 32'h42b2986c;
	        8'd42  : crc32_table = 32'hdbbbc9d6;
	        8'd43  : crc32_table = 32'hacbcf940;
	        8'd44  : crc32_table = 32'h32d86ce3;
	        8'd45  : crc32_table = 32'h45df5c75;
	        8'd46  : crc32_table = 32'hdcd60dcf;
	        8'd47  : crc32_table = 32'habd13d59;
	        8'd48  : crc32_table = 32'h26d930ac;
	        8'd49  : crc32_table = 32'h51de003a;
	        8'd50  : crc32_table = 32'hc8d75180;
	        8'd51  : crc32_table = 32'hbfd06116;
	        8'd52  : crc32_table = 32'h21b4f4b5;
	        8'd53  : crc32_table = 32'h56b3c423;
	        8'd54  : crc32_table = 32'hcfba9599;
	        8'd55  : crc32_table = 32'hb8bda50f;
	        8'd56  : crc32_table = 32'h2802b89e;
	        8'd57  : crc32_table = 32'h5f058808;
	        8'd58  : crc32_table = 32'hc60cd9b2;
	        8'd59  : crc32_table = 32'hb10be924;
	        8'd60  : crc32_table = 32'h2f6f7c87;
	        8'd61  : crc32_table = 32'h58684c11;
	        8'd62  : crc32_table = 32'hc1611dab;
	        8'd63  : crc32_table = 32'hb6662d3d;
	        8'd64  : crc32_table = 32'h76dc4190;
	        8'd65  : crc32_table = 32'h1db7106;
	        8'd66  : crc32_table = 32'h98d220bc;
	        8'd67  : crc32_table = 32'hefd5102a;
	        8'd68  : crc32_table = 32'h71b18589;
	        8'd69  : crc32_table = 32'h6b6b51f;
	        8'd70  : crc32_table = 32'h9fbfe4a5;
	        8'd71  : crc32_table = 32'he8b8d433;
	        8'd72  : crc32_table = 32'h7807c9a2;
	        8'd73  : crc32_table = 32'hf00f934;
	        8'd74  : crc32_table = 32'h9609a88e;
	        8'd75  : crc32_table = 32'he10e9818;
	        8'd76  : crc32_table = 32'h7f6a0dbb;
	        8'd77  : crc32_table = 32'h86d3d2d;
	        8'd78  : crc32_table = 32'h91646c97;
	        8'd79  : crc32_table = 32'he6635c01;
	        8'd80  : crc32_table = 32'h6b6b51f4;
	        8'd81  : crc32_table = 32'h1c6c6162;
	        8'd82  : crc32_table = 32'h856530d8;
	        8'd83  : crc32_table = 32'hf262004e;
	        8'd84  : crc32_table = 32'h6c0695ed;
	        8'd85  : crc32_table = 32'h1b01a57b;
	        8'd86  : crc32_table = 32'h8208f4c1;
	        8'd87  : crc32_table = 32'hf50fc457;
	        8'd88  : crc32_table = 32'h65b0d9c6;
	        8'd89  : crc32_table = 32'h12b7e950;
	        8'd90  : crc32_table = 32'h8bbeb8ea;
	        8'd91  : crc32_table = 32'hfcb9887c;
	        8'd92  : crc32_table = 32'h62dd1ddf;
	        8'd93  : crc32_table = 32'h15da2d49;
	        8'd94  : crc32_table = 32'h8cd37cf3;
	        8'd95  : crc32_table = 32'hfbd44c65;
	        8'd96  : crc32_table = 32'h4db26158;
	        8'd97  : crc32_table = 32'h3ab551ce;
	        8'd98  : crc32_table = 32'ha3bc0074;
	        8'd99  : crc32_table = 32'hd4bb30e2;
	        8'd100 : crc32_table = 32'h4adfa541;
	        8'd101 : crc32_table = 32'h3dd895d7;
	        8'd102 : crc32_table = 32'ha4d1c46d;
	        8'd103 : crc32_table = 32'hd3d6f4fb;
	        8'd104 : crc32_table = 32'h4369e96a;
	        8'd105 : crc32_table = 32'h346ed9fc;
	        8'd106 : crc32_table = 32'had678846;
	        8'd107 : crc32_table = 32'hda60b8d0;
	        8'd108 : crc32_table = 32'h44042d73;
	        8'd109 : crc32_table = 32'h33031de5;
	        8'd110 : crc32_table = 32'haa0a4c5f;
	        8'd111 : crc32_table = 32'hdd0d7cc9;
	        8'd112 : crc32_table = 32'h5005713c;
	        8'd113 : crc32_table = 32'h270241aa;
	        8'd114 : crc32_table = 32'hbe0b1010;
	        8'd115 : crc32_table = 32'hc90c2086;
	        8'd116 : crc32_table = 32'h5768b525;
	        8'd117 : crc32_table = 32'h206f85b3;
	        8'd118 : crc32_table = 32'hb966d409;
	        8'd119 : crc32_table = 32'hce61e49f;
	        8'd120 : crc32_table = 32'h5edef90e;
	        8'd121 : crc32_table = 32'h29d9c998;
	        8'd122 : crc32_table = 32'hb0d09822;
	        8'd123 : crc32_table = 32'hc7d7a8b4;
	        8'd124 : crc32_table = 32'h59b33d17;
	        8'd125 : crc32_table = 32'h2eb40d81;
	        8'd126 : crc32_table = 32'hb7bd5c3b;
	        8'd127 : crc32_table = 32'hc0ba6cad;
	        8'd128 : crc32_table = 32'hedb88320;
	        8'd129 : crc32_table = 32'h9abfb3b6;
	        8'd130 : crc32_table = 32'h3b6e20c;
	        8'd131 : crc32_table = 32'h74b1d29a;
	        8'd132 : crc32_table = 32'head54739;
	        8'd133 : crc32_table = 32'h9dd277af;
	        8'd134 : crc32_table = 32'h4db2615;
	        8'd135 : crc32_table = 32'h73dc1683;
	        8'd136 : crc32_table = 32'he3630b12;
	        8'd137 : crc32_table = 32'h94643b84;
	        8'd138 : crc32_table = 32'hd6d6a3e;
	        8'd139 : crc32_table = 32'h7a6a5aa8;
	        8'd140 : crc32_table = 32'he40ecf0b;
	        8'd141 : crc32_table = 32'h9309ff9d;
	        8'd142 : crc32_table = 32'ha00ae27;
	        8'd143 : crc32_table = 32'h7d079eb1;
	        8'd144 : crc32_table = 32'hf00f9344;
	        8'd145 : crc32_table = 32'h8708a3d2;
	        8'd146 : crc32_table = 32'h1e01f268;
	        8'd147 : crc32_table = 32'h6906c2fe;
	        8'd148 : crc32_table = 32'hf762575d;
	        8'd149 : crc32_table = 32'h806567cb;
	        8'd150 : crc32_table = 32'h196c3671;
	        8'd151 : crc32_table = 32'h6e6b06e7;
	        8'd152 : crc32_table = 32'hfed41b76;
	        8'd153 : crc32_table = 32'h89d32be0;
	        8'd154 : crc32_table = 32'h10da7a5a;
	        8'd155 : crc32_table = 32'h67dd4acc;
	        8'd156 : crc32_table = 32'hf9b9df6f;
	        8'd157 : crc32_table = 32'h8ebeeff9;
	        8'd158 : crc32_table = 32'h17b7be43;
	        8'd159 : crc32_table = 32'h60b08ed5;
	        8'd160 : crc32_table = 32'hd6d6a3e8;
	        8'd161 : crc32_table = 32'ha1d1937e;
	        8'd162 : crc32_table = 32'h38d8c2c4;
	        8'd163 : crc32_table = 32'h4fdff252;
	        8'd164 : crc32_table = 32'hd1bb67f1;
	        8'd165 : crc32_table = 32'ha6bc5767;
	        8'd166 : crc32_table = 32'h3fb506dd;
	        8'd167 : crc32_table = 32'h48b2364b;
	        8'd168 : crc32_table = 32'hd80d2bda;
	        8'd169 : crc32_table = 32'haf0a1b4c;
	        8'd170 : crc32_table = 32'h36034af6;
	        8'd171 : crc32_table = 32'h41047a60;
	        8'd172 : crc32_table = 32'hdf60efc3;
	        8'd173 : crc32_table = 32'ha867df55;
	        8'd174 : crc32_table = 32'h316e8eef;
	        8'd175 : crc32_table = 32'h4669be79;
	        8'd176 : crc32_table = 32'hcb61b38c;
	        8'd177 : crc32_table = 32'hbc66831a;
	        8'd178 : crc32_table = 32'h256fd2a0;
	        8'd179 : crc32_table = 32'h5268e236;
	        8'd180 : crc32_table = 32'hcc0c7795;
	        8'd181 : crc32_table = 32'hbb0b4703;
	        8'd182 : crc32_table = 32'h220216b9;
	        8'd183 : crc32_table = 32'h5505262f;
	        8'd184 : crc32_table = 32'hc5ba3bbe;
	        8'd185 : crc32_table = 32'hb2bd0b28;
	        8'd186 : crc32_table = 32'h2bb45a92;
	        8'd187 : crc32_table = 32'h5cb36a04;
	        8'd188 : crc32_table = 32'hc2d7ffa7;
	        8'd189 : crc32_table = 32'hb5d0cf31;
	        8'd190 : crc32_table = 32'h2cd99e8b;
	        8'd191 : crc32_table = 32'h5bdeae1d;
	        8'd192 : crc32_table = 32'h9b64c2b0;
	        8'd193 : crc32_table = 32'hec63f226;
	        8'd194 : crc32_table = 32'h756aa39c;
	        8'd195 : crc32_table = 32'h26d930a;
	        8'd196 : crc32_table = 32'h9c0906a9;
	        8'd197 : crc32_table = 32'heb0e363f;
	        8'd198 : crc32_table = 32'h72076785;
	        8'd199 : crc32_table = 32'h5005713;
	        8'd200 : crc32_table = 32'h95bf4a82;
	        8'd201 : crc32_table = 32'he2b87a14;
	        8'd202 : crc32_table = 32'h7bb12bae;
	        8'd203 : crc32_table = 32'hcb61b38;
	        8'd204 : crc32_table = 32'h92d28e9b;
	        8'd205 : crc32_table = 32'he5d5be0d;
	        8'd206 : crc32_table = 32'h7cdcefb7;
	        8'd207 : crc32_table = 32'hbdbdf21;
	        8'd208 : crc32_table = 32'h86d3d2d4;
	        8'd209 : crc32_table = 32'hf1d4e242;
	        8'd210 : crc32_table = 32'h68ddb3f8;
	        8'd211 : crc32_table = 32'h1fda836e;
	        8'd212 : crc32_table = 32'h81be16cd;
	        8'd213 : crc32_table = 32'hf6b9265b;
	        8'd214 : crc32_table = 32'h6fb077e1;
	        8'd215 : crc32_table = 32'h18b74777;
	        8'd216 : crc32_table = 32'h88085ae6;
	        8'd217 : crc32_table = 32'hff0f6a70;
	        8'd218 : crc32_table = 32'h66063bca;
	        8'd219 : crc32_table = 32'h11010b5c;
	        8'd220 : crc32_table = 32'h8f659eff;
	        8'd221 : crc32_table = 32'hf862ae69;
	        8'd222 : crc32_table = 32'h616bffd3;
	        8'd223 : crc32_table = 32'h166ccf45;
	        8'd224 : crc32_table = 32'ha00ae278;
	        8'd225 : crc32_table = 32'hd70dd2ee;
	        8'd226 : crc32_table = 32'h4e048354;
	        8'd227 : crc32_table = 32'h3903b3c2;
	        8'd228 : crc32_table = 32'ha7672661;
	        8'd229 : crc32_table = 32'hd06016f7;
	        8'd230 : crc32_table = 32'h4969474d;
	        8'd231 : crc32_table = 32'h3e6e77db;
	        8'd232 : crc32_table = 32'haed16a4a;
	        8'd233 : crc32_table = 32'hd9d65adc;
	        8'd234 : crc32_table = 32'h40df0b66;
	        8'd235 : crc32_table = 32'h37d83bf0;
	        8'd236 : crc32_table = 32'ha9bcae53;
	        8'd237 : crc32_table = 32'hdebb9ec5;
	        8'd238 : crc32_table = 32'h47b2cf7f;
	        8'd239 : crc32_table = 32'h30b5ffe9;
	        8'd240 : crc32_table = 32'hbdbdf21c;
	        8'd241 : crc32_table = 32'hcabac28a;
	        8'd242 : crc32_table = 32'h53b39330;
	        8'd243 : crc32_table = 32'h24b4a3a6;
	        8'd244 : crc32_table = 32'hbad03605;
	        8'd245 : crc32_table = 32'hcdd70693;
	        8'd246 : crc32_table = 32'h54de5729;
	        8'd247 : crc32_table = 32'h23d967bf;
	        8'd248 : crc32_table = 32'hb3667a2e;
	        8'd249 : crc32_table = 32'hc4614ab8;
	        8'd250 : crc32_table = 32'h5d681b02;
	        8'd251 : crc32_table = 32'h2a6f2b94;
	        8'd252 : crc32_table = 32'hb40bbe37;
	        8'd253 : crc32_table = 32'hc30c8ea1;
	        8'd254 : crc32_table = 32'h5a05df1b;
	        8'd255 : crc32_table = 32'h2d02ef8d;
            default: crc32_table = 32'h0;			
	    endcase;
	end


	// Construct the code part " crc = (crc >> 8) ^ table[(crc & 0xff) ^ octet]; " 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
		    crc32_out_buff  <= 32'hFFFFFFFF; 
        end		
        else if (crc32_valid_in) begin 
      		crc32_out_buff  <= (crc32_out_buff >> 8) ^ crc32_table;
		end
    end
	 
	assign crc32_out = ~crc32_out_buff; 
	 
endmodule