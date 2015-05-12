module TB_Compression_Top();
  
  reg clock, reset, stall, data_in_valid;
  reg [63:0] data_in;
  wire comp_rdy, dump;
  wire [7:0] valid_bits;
  wire [63:0] data_out;
  always #5 clock = ~clock;
  initial clock = 0;
  
  
  initial begin
    reset = 0;
    stall = 0;
    #10 reset = 1;
    #10 data_in_valid = 1;
    data_in = 64'h0011223344556677;
    #40 data_in = 64'd4382391029384719;
    #40 data_in = 64'd0;
    #20 data_in_valid = 0;
    #15000;
    $stop;
  end
  
  Compression_Top c
  (
    clock, reset, stall, data_in_valid,
    data_in, comp_rdy, dump, valid_bits, data_out    
  );
  
endmodule
