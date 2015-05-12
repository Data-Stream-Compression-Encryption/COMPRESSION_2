/*

Author: Clarke Austin
Date: 2/2/2015

This module implements the static Huffman Trees for the DEFLATE algorithm.

Static Tables used are based off of DEFLATE algorithm description in 4th edition
of "Data Compression, The Complete Reference" pg. 233, 234

User requests one of literal, length, or distance parts of LZ77 pair to be encoded and the
result is output at the next clock cycle. If multiple or no parts are requested the output is set 
to all zeros.

Inputs:
literal - encode literal_data and move to data_out at next clock cycle
length - encode length_data and move to data_out at next clock cycle
distance - encode distance_data and move to data_out at next clock cycle
literal_data - literal from output of LZ77 algorithm
length_data - length from output of LZ77 algorithm
distance_data -  distance from output of LZ77 algorithm

Outputs:
data_out - will store encoded data for one clock cycle after literal, length, or distance is high
valid_bits - how many bits of data_out should be used, will be 0 if no encoding took place

*/

module Huffman_Top(
  input clock, literal, distance, length,
  input [7:0] literal_data,
  input [14:0] distance_data,
  input [8:0] length_data,
  output reg [63:0] data_out,
  output reg [7:0] valid_bits
);

  reg enable_literal, enable_length, enable_distance;
  wire [17:0] encoded_literal, encoded_length, encoded_distance;
  wire [4:0] valid_bits_literal, valid_bits_length, valid_bits_distance;
  
  //Update output registers every clock cycle
  always@(posedge clock) 
  begin
    if(enable_literal) begin
      data_out <= encoded_literal | 0;
      valid_bits <= valid_bits_literal | 0;
    end
    else if(enable_length) begin
      data_out <= encoded_length | 0;
      valid_bits <= valid_bits_length | 0;
    end
    else if(enable_distance) begin
      data_out <= encoded_distance | 0;
      valid_bits <= valid_bits_distance | 0;
    end
    else begin
      data_out = 64'b0;
      valid_bits = 8'b0;
    end
  end
  
  Literal_Encoder lit(literal_data, enable_literal, encoded_literal, valid_bits_literal);
  
  Distance_Encoder dist(distance_data, enable_distance, encoded_distance, valid_bits_distance);
  
  Length_Encoder len(length_data, enable_length, encoded_length, valid_bits_length);
  
  always@* begin
    
    enable_literal = (literal && !length && !distance);
    enable_length = (!literal && length && !distance);
    enable_distance = (!literal && !length && distance);
    
  end
  
endmodule
