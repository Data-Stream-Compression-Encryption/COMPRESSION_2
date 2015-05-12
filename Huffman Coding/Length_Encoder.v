module Length_Encoder(
  input [8:0] length_data,
  input enable,
  output reg [17:0] encoded_length,
  output reg [4:0] valid_bits  
);
  
  
  always@* begin

    //If module is not enabled or value is too small output zeros
    if(!enable || length_data < 9'd3) begin
      encoded_length = 16'd0;
      valid_bits = 5'd0;
    end

    //Encoded with 0 extra bits
    else if(length_data < 9'd11) begin
      encoded_length = length_data[6:0] - 6'd2;
      valid_bits = 5'd7;
    end
    
    //Encoded with 1 extra bit
    else if(length_data < 9'd19) begin
      
     valid_bits = 5'd8;
      
      if(length_data < 9'd13)
        encoded_length = {7'd9, !length_data[0]};
      
      else if(length_data < 9'd15)
        encoded_length = {7'd10, !length_data[0]};
      
      else if(length_data < 9'd17)
        encoded_length = {7'd11, !length_data[0]};
      
      else 
        encoded_length = {7'd12, !length_data[0]};

    end
    
    //Encoded with 2 extra bits
    else if(length_data < 9'd35) begin
      
     valid_bits = 5'd9;
      
      if(length_data < 9'd23)
        encoded_length = {7'd13, length_data[1:0] + 2'd1};
        
      else if(length_data < 9'd27)
        encoded_length = {7'd14, length_data[1:0] + 2'd1};

      else if(length_data < 9'd31)
        encoded_length = {7'd15, length_data[1:0] + 2'd1};

      else
        encoded_length = {7'd16, length_data[1:0] + 2'd1};
        
    end
    
    //Encoded with 3 extra bits
    else if(length_data < 9'd67) begin
      
     valid_bits = 5'd10;
            
      if(length_data < 9'd43) 
        encoded_length = {7'd17, length_data[2:0] + 3'd5};
        
      else if(length_data < 9'd51)
        encoded_length = {7'd18, length_data[2:0] + 3'd5};
        
      else if(length_data < 9'd59)
        encoded_length = {7'd19, length_data[2:0] + 3'd5};
        
      else
        encoded_length = {7'd20, length_data[2:0] + 3'd5};

    end
    
    //Encoded with 4 extra bits
    else if(length_data < 9'd131) begin
      
     valid_bits = 5'd11;
            
      if(length_data < 9'd83) 
        encoded_length = {7'd21, length_data[3:0] + 4'd13};
        
      else if(length_data < 9'd99)
        encoded_length = {7'd22, length_data[3:0] + 4'd13};
        
      else if(length_data < 9'd115)
        encoded_length = {7'd23, length_data[3:0] + 4'd13};
        
      else begin
        valid_bits = 5'd12;
        encoded_length = {8'd192, length_data[3:0] + 4'd13};
      end

    end
    
    //Encoded with 5 extra bits
    else if(length_data < 9'd258) begin
      
     valid_bits = 5'd13;
            
      if(length_data < 9'd163) 
        encoded_length = {8'd193, length_data[5:0] + 5'd29};
        
      else if(length_data < 9'd195)
        encoded_length = {8'd194, length_data[5:0] + 5'd29};
        
      else if(length_data < 9'd227)
        encoded_length = {8'd195, length_data[5:0] + 5'd29};
        
      else
        encoded_length = {8'd196, length_data[5:0] + 5'd29};

    end
    
    //Maximum length value
    else if(length_data == 9'd258) begin
      valid_bits = 5'd8;
      encoded_length = 8'd197;
    end
    
    //Length_data is too large
    else begin
      encoded_length = 16'd0;
      valid_bits = 5'd0;
    end
       
  end
  
  
endmodule