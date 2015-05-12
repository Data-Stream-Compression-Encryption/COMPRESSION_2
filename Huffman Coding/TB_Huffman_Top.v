/*
Basic testbench for Huffman_Top module

Tests the literal instantiation by changing the enable inputs first
Ten tests all three modules with every possible data value
*/

`timescale 1ns/100ps

module TB_Huffman_Top();
  
  reg clock;
  
  always
    #10 clock = ~clock;
  
  reg [14:0] data;
  wire [17:0] lit_out, len_out, dist_out;
  wire [4:0] lit_bits, len_bits, dist_bits;
  reg lit_en, dist_en, len_en;
  Huffman_Top literal(clock, lit_en, dist_en, len_en, data[7:0], 14'b0, 9'b0, lit_out, lit_bits);
  Huffman_Top length(clock, 1'b0, 1'b0, 1'b1, 8'b0, 14'b0, data[8:0], len_out, len_bits);
  Huffman_Top distance(clock, 1'b0, 1'b1, 1'b0, 8'b0, data, 9'b0, dist_out, dist_bits);
  
  reg [15:0] i;
  
  initial begin
    clock = 0;
    
    //Checking that multiple enable inputs dont turn on the module, lit_out/lit_bits should be 0
    lit_en = 1;
    dist_en = 1;
    len_en = 0;
    #20;
    dist_en = 0;
    len_en = 1;
    #20;
    lit_en = 0;
    dist_en = 1;
    #20;
    lit_en = 1;
    #20;
    dist_en = 0;
    len_en = 0;
    lit_en = 1;
    #20
    
    //now testing all modules with every possible input
    for(i = 0; !i[15]; i = i + 1) begin
      #20 data = i;
    end
    
    $stop;
    
  end
  
  
endmodule