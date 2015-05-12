module TB_Stream_Binary();
  
  parameter size = 100000;
  reg [63:0] memory [size - 1:0] ;
  reg [7:0] char;
  integer i, j, file, file2;
  
  reg fileClosed;
  
  //read file into memory
  initial begin
    fileClosed = 0;
    file = $fopen("data-binary.txt", "r");
    file2 = $fopen("write.txt", "w");
    
    for(i = 0; i < size; i = i + 1) begin
      
      for(j = 0; j < 64; j = j + 1) begin
        char = $fgetc(file);
        //$display(char);
        memory[i] = memory[i] << 1;
        if(char == "1") memory[i][0] = 1'b1;
        else if(char == "0") memory[i][0] = 1'b0;
        else begin
          char = $fgetc(file);
          if(char == "1") memory[i][0] = 1'b1;
          else if(char == "0") memory[i][0] = 1'b0;
        end
      end
      
    end
    $fclose(file);
  end

  //Close out file2 and simulation after some time
  /*
  initial begin
    #200000;
    $fclose(file2);
    $stop;
  end
  */
  
  reg clock, reset, stall, data_in_valid;
  reg [63:0] data_in;
  wire comp_rdy, dump;
  wire [7:0] valid_bits;
  wire [63:0] data_out;
  
  //Setup clock
  always #5 clock = ~clock;
  initial clock = 0;
  
  //Setup Compression_Top
  integer cnt;
  
  initial begin
    reset = 0;
    stall = 0;
    cnt = 0;
    #10 reset = 1;
  end

  always@(posedge clock) begin
    if(comp_rdy) begin
      data_in_valid <= 1;
      data_in = memory[cnt];
      cnt <= cnt + 1;
    end
    else if(data_in_valid && !comp_rdy) begin
      cnt <= (!cnt) ? 0 : cnt - 1;
      data_in <= 0;
      data_in_valid <= 0;
    end
    else begin
      data_in_valid <= 0;
      data_in <= 0;
      cnt <= cnt;
    end
  end
  /*
  initial begin
    #500000;
    //#165500;
    $fclose(file2);
    $stop;
  end
  */
  
  always@(posedge clock) begin
    if(cnt == size - 1) begin
      #20480// wait for the module to dump
      $fclose(file2);
      $stop;
    end
  end
  
  
  Compression_Top 
  #(.Q_LENGTH(3000),.Q_BITS(14),
  .LA_LENGTH(100), .LA_BITS(7), 
  .START_COMPRESSING(20), .zero_detector_length(30), 
  .detector_results_length(100))
  c
  (
    clock, reset, stall, data_in_valid,
    data_in, comp_rdy, dump, valid_bits, data_out    
  );
  
  
  integer m;
  always@(posedge clock)
    case(valid_bits) 
      8'd1: $fwrite(file2, "%b", data_out[0:0]);
      8'd2: $fwrite(file2, "%b", data_out[1:0]);
      8'd3: $fwrite(file2, "%b", data_out[2:0]);
      8'd4: $fwrite(file2, "%b", data_out[3:0]);
      8'd5: $fwrite(file2, "%b", data_out[4:0]);
      8'd6: $fwrite(file2, "%b", data_out[5:0]);
      8'd7: $fwrite(file2, "%b", data_out[6:0]);
      8'd8: $fwrite(file2, "%b", data_out[7:0]);
      8'd9: $fwrite(file2, "%b", data_out[8:0]);
      8'd10: $fwrite(file2, "%b", data_out[9:0]);
      8'd11: $fwrite(file2, "%b", data_out[10:0]);
      8'd12: $fwrite(file2, "%b", data_out[11:0]);
      8'd13: $fwrite(file2, "%b", data_out[12:0]);
      8'd14: $fwrite(file2, "%b", data_out[13:0]);
      8'd15: $fwrite(file2, "%b", data_out[14:0]);
      8'd16: $fwrite(file2, "%b", data_out[15:0]);
      8'd17: $fwrite(file2, "%b", data_out[16:0]);
      8'd18: $fwrite(file2, "%b", data_out[17:0]);
      8'd20: $fwrite(file2, "%b", data_out[18:0]);
    endcase

 
endmodule

