module Literal_Encoder(
  input [7:0] literal_data,
  input enable,
  output reg [17:0] encoded_literal,
  output reg [4:0] valid_bits
);

  always@* begin
    
    if(!enable) begin
      encoded_literal = 16'd0;
      valid_bits = 5'd0;
    end
    
    else if(literal_data < 8'd144) begin
      encoded_literal = literal_data + 8'd48;
      valid_bits = 5'd8;
    end 
      
    else begin
      encoded_literal = literal_data + 9'd256;
      valid_bits = 5'd9;
    end   
    
  end

endmodule