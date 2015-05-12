module Distance_Encoder(
  input [14:0] distance_data,
  input enable,
  output reg [17:0] encoded_distance,
  output reg [4:0] valid_bits
);

  always@* begin
    
    if(!enable || distance_data == 15'd0) begin
      encoded_distance = 16'd0;
      valid_bits = 5'd0;
    end
    
    //Encoded with 0 extra bits
    else if(distance_data < 15'd5) begin
      valid_bits = 5'd5;
      encoded_distance = distance_data - 1'b1;
    end
    
    //Encoded with 1 extra bit
    else if(distance_data < 15'd9) begin
      
      valid_bits = 5'd6;
      if(distance_data < 15'd7)
        encoded_distance = {5'd4, !distance_data[0]};
      else
        encoded_distance = {5'd5, !distance_data[0]};
    end
    
    //Encoded with 2 extra bits
    else if(distance_data < 15'd17) begin
      
      valid_bits = 5'd7;
      if(distance_data < 15'd13) 
        encoded_distance = {5'd6, distance_data[1:0] - 1'b1};
      else
        encoded_distance = {5'd7, distance_data[1:0] - 1'b1};
        
    end
    
    //Encoded with 3 extra bits
    else if(distance_data < 15'd33) begin
      
      valid_bits = 5'd8;
      if(distance_data < 15'd25)
        encoded_distance = {5'd8, distance_data[2:0] - 1'b1};
      else
        encoded_distance = {5'd9, distance_data[2:0] - 1'b1};
        
    end
    
    //Encoded with 4 extra bits
    else if(distance_data < 15'd65) begin
      
      valid_bits = 5'd9;
      if(distance_data < 15'd49)
        encoded_distance = {5'd10, distance_data[3:0] - 1'b1};
      else
        encoded_distance = {5'd11, distance_data[3:0] - 1'b1};
        
    end
    
    //Encoded with 5 extra bits
    else if(distance_data < 15'd129) begin
      
      valid_bits = 5'd10;
      if(distance_data < 15'd97)
        encoded_distance = {5'd12, distance_data[4:0] - 1'b1};
      else
        encoded_distance = {5'd13, distance_data[4:0] - 1'b1};
        
    end
    
    //Encoded with 6 extra bits
    else if(distance_data < 15'd257) begin
      
      valid_bits = 5'd11;
      if(distance_data < 15'd193)
        encoded_distance = {5'd14, distance_data[5:0] - 1'b1};
      else
        encoded_distance = {5'd15, distance_data[5:0] - 1'b1};
        
    end
    
    //Encoded with 7 extra bits
    else if(distance_data < 15'd513) begin
      
      valid_bits = 5'd12;
      if(distance_data < 15'd385)
        encoded_distance = {5'd16, distance_data[6:0] - 1'b1};
      else
        encoded_distance = {5'd17, distance_data[6:0] - 1'b1};
        
    end
    
    //Encoded with 8 extra bits
    else if(distance_data < 15'd1025) begin
      
      valid_bits = 5'd13;
      if(distance_data < 15'd769)
        encoded_distance = {5'd18, distance_data[7:0] - 1'b1};
      else
        encoded_distance = {5'd19, distance_data[7:0] - 1'b1};
        
    end
    
    //Encoded with 9 extra bits
    else if(distance_data < 15'd2049) begin
      
      valid_bits = 5'd14;
      if(distance_data < 15'd1537)
        encoded_distance = {5'd20, distance_data[8:0] - 1'b1};
      else
        encoded_distance = {5'd21, distance_data[8:0] - 1'b1};
        
    end
    
    //Encoded with 10 extra bits
    else if(distance_data < 15'd4097) begin
      
      valid_bits = 5'd15;
      if(distance_data < 15'd3073)
        encoded_distance = {5'd22, distance_data[9:0] - 1'b1};
      else
        encoded_distance = {5'd23, distance_data[9:0] - 1'b1};
        
    end
    
    //Encoded with 11 extra bits
    else if(distance_data < 15'd8193) begin
      
      valid_bits = 5'd16;
      if(distance_data < 15'd6145)
        encoded_distance = {5'd24, distance_data[10:0] - 1'b1};
      else
        encoded_distance = {5'd25, distance_data[10:0] - 1'b1};
        
    end
    
    //Encoded with 12 extra bits
    else if(distance_data < 15'd16385) begin
      
      valid_bits = 5'd17;
      if(distance_data < 15'd12289)
        encoded_distance = {5'd26, distance_data[11:0] - 1'b1};
      else
        encoded_distance = {5'd27, distance_data[11:0] - 1'b1};
        
    end
    
    //Encoded with 13 extra bits
    else begin
      
      valid_bits = 5'd18;
      if(distance_data < 15'd24577)
        encoded_distance = {5'd28, distance_data[12:0] - 1'b1};
      else
        encoded_distance = {5'd29, distance_data[12:0] - 1'b1};
        
    end  
    
  end
  
endmodule