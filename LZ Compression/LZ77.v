module LZ77
  #(parameter Q_LENGTH = 800, parameter Q_BITS = 10,
  parameter LA_LENGTH = 100, parameter LA_BITS = 7,
  parameter START_COMPRESSING = 10, parameter zero_detector_length = 50, 
  parameter detector_results_length = 16
)
  (
    input clock, reset, stall,
    input [63:0] bytes_in,
    input bytes_in_valid,
    output buffer_ready, 
    output reg [Q_BITS:0] distance, 
    output reg [LA_BITS:0] length,
    output reg [7:0] literal,
    output reg output_valid,
    output reg dumping_finished
  );

  reg [7:0] queue [Q_LENGTH - 1:0];
  reg [7:0] queue_next [Q_LENGTH - 1:0];
  reg [7:0] buffer [LA_LENGTH - 1:0];
  reg [7:0] buffer_next [LA_LENGTH - 1:0];
  
  integer l, m, n, o;
  reg upd_finished;
  reg comp_finished;
  reg [LA_BITS:0] check_num, check_num_next;
  reg [Q_BITS:0] first_match, first_match_next;
  
  reg [Q_BITS:0] q_size, q_size_next;
  reg [LA_BITS:0] la_size, la_size_next;
  reg [LA_BITS:0] transfer_n_bytes, transfer_n_bytes_next;
  reg [3:0] start_pos, start_pos_next;
  reg [1:0] state, state_next;
  reg [Q_BITS:0] distance_next; 
  reg [LA_BITS:0] length_next;
  reg [7:0] literal_next;
  reg output_valid_next;
  reg dumping, dumping_next, dumping_finished_next;

  /*
  IDLE - waiting to get input to fill LA buffer 
  UPDATING - shifting data from LA_BUFFER to QUEUE
  COMPRESSING - busy compressing data
  */
  parameter IDLE = 2'd0, UPDATING = 2'd1, COMPRESSING = 2'd2;
  
  always@(posedge clock) begin
    if(!reset) begin
      state <= IDLE;
      la_size <= 0;
      q_size <= 0;
      start_pos <= 0;
      transfer_n_bytes <= 0;
      literal <= 0;
      length <= 0;
      distance <= 0;
      output_valid <= 0;
      first_match <= 0;
      dumping <= 0;
      dumping_finished <= 0;
    end
    
    else begin
      state <= state_next;
      la_size <= la_size_next;
      q_size <= q_size_next;
      start_pos <= start_pos_next;
      transfer_n_bytes <= transfer_n_bytes_next;
      literal <= literal_next;
      length <= length_next;
      distance <= distance_next;
      output_valid <= output_valid_next;
      first_match <= first_match_next;
      dumping <= dumping_next;
      dumping_finished <= dumping_finished_next;
    end
  end
  
  
  //Update the queue and buffer
  integer i, j;
  always@(posedge clock) begin
    for(i = 0; i < Q_LENGTH; i = i + 1) 
      queue[i] <= queue_next[i];
  end
  always@(posedge clock) begin
    for(j = 0; j < LA_LENGTH; j = j + 1) 
      buffer[j] <= buffer_next[j];
  end
  
  //Input buffer can accept more data if 8 bytes are ready and not updating
  assign buffer_ready = (la_size_next <= LA_LENGTH - 8) && state_next != UPDATING;
  
  //update look ahead buffer and queue + relevant variables
  always@* begin
    transfer_n_bytes_next = 0;
    la_size_next = la_size;
    q_size_next = q_size;
    start_pos_next = start_pos;
    upd_finished = 0;
    output_valid_next = 0;
    literal_next = 0;
    length_next = 0; 
    distance_next = 0;
    dumping_next = dumping;
    dumping_finished_next = 0;
    for(l = 0; l < Q_LENGTH; l = l + 1)
      queue_next[l] = queue[l];
    for(m = 0; m < LA_LENGTH; m = m + 1) 
      buffer_next[m] = buffer[m];
    
    if(state != UPDATING && bytes_in_valid) begin
      if(la_size <= LA_LENGTH - 8) begin
        if(!bytes_in)
          dumping_next = 1;
        la_size_next = la_size + 8;
        buffer_next[la_size + 7] = bytes_in[7:0];
        buffer_next[la_size + 6] = bytes_in[15:8];
        buffer_next[la_size + 5] = bytes_in[23:16];
        buffer_next[la_size + 4] = bytes_in[31:24];
        buffer_next[la_size + 3] = bytes_in[39:32];
        buffer_next[la_size + 2] = bytes_in[47:40];
        buffer_next[la_size + 1] = bytes_in[55:48];
        buffer_next[la_size + 0] = bytes_in[63:56];
      end
    end
    //Update LA Buffer and Queue after compression
    else if(state == UPDATING) begin
      //send over 8 bytes to queue if needed
      if(transfer_n_bytes > start_pos) begin
        transfer_n_bytes_next = transfer_n_bytes - 8;
        q_size_next = q_size + 8 > Q_LENGTH ? Q_LENGTH : q_size + 8;
        la_size_next = la_size - 8;
        if(transfer_n_bytes <= 8)
          start_pos_next = 8 + start_pos - transfer_n_bytes;
        
        for(n = 0; n < Q_LENGTH - 8; n = n + 1)
          queue_next[n + 8] = queue[n];
        
        for(o = 0; o < LA_LENGTH - 8; o = o + 1)
          buffer_next[o] = buffer[o + 8];
        
        queue_next[7] = buffer[0];
        queue_next[6] = buffer[1];
        queue_next[5] = buffer[2];
        queue_next[4] = buffer[3];
        queue_next[3] = buffer[4];
        queue_next[2] = buffer[5];
        queue_next[1] = buffer[6];
        queue_next[0] = buffer[7];       
        
        if(!{buffer[0],buffer[1],buffer[2],
          buffer[3],buffer[4],buffer[5],buffer[6],buffer[7]})
          dumping_finished_next = 1;
      end
      else
        start_pos_next = start_pos - transfer_n_bytes;
      
      if(transfer_n_bytes <= 8)
        upd_finished = 1;
              
    end
    
    if(state  == COMPRESSING) begin
      transfer_n_bytes_next = (check_num > 4) ? check_num - 2 : 1;
      if(comp_finished) begin
        output_valid_next = 1;
        literal_next = (start_pos == 0) 
          ? buffer[0] : queue[start_pos - 1];
        length_next = transfer_n_bytes_next;
        distance_next = check_num + first_match - start_pos - 3;
      end
    end
      
    if(dumping_finished) begin
      la_size_next = 0;
      q_size_next = 0;
      output_valid_next = 0;
    end
      
  end  
  
  
  //update state
  always@* begin
    
    state_next = state;
    if(state == IDLE) begin
      if(la_size >= START_COMPRESSING && !stall)
        state_next = COMPRESSING;
    end
    else if(state == UPDATING) begin
      if(upd_finished)
        if(la_size_next >= START_COMPRESSING)
          state_next = COMPRESSING;
        else 
          state_next = IDLE;
    end
    else if(state == COMPRESSING) begin
      if(comp_finished)
        state_next = UPDATING;
    end
    
    if(dumping_finished)
      state_next = IDLE;
    
  end
  
  //State Machine when Main FSM is in compression
  reg comp_state, comp_state_next;
  reg [Q_LENGTH - 1:0] queue_check, queue_check_next;
  parameter COMP_IDLE = 1'd0, COMP_RUNNING = 1'd1;
  always@(posedge clock) begin
    if(!reset) begin
      comp_state <= COMP_IDLE;
      check_num <= 0;
    end
    else begin
      comp_state <= comp_state_next;
      check_num <= check_num_next;
    end
  end

  always@* begin
    comp_state_next = comp_state;
    
    if(state == COMPRESSING) begin
      if(comp_finished)
        comp_state_next = COMP_IDLE;
      else 
        comp_state_next = COMP_RUNNING;
    end
    else if(state_next == COMPRESSING)
      comp_state_next = COMP_RUNNING;
    
  end
  
  integer a, b, c, d, e, f, g, h, aa, bb;
  reg [7:0] check_literal;
  reg [Q_BITS:0] detector_results [detector_results_length - 1:0];
  reg [Q_BITS:0] detector_results_next [detector_results_length - 1:0];
  
  
  always@(posedge clock) begin
    for(d = 0; d < Q_LENGTH; d = d + 1)
      queue_check[d] <= queue_check_next[d];
    for(e = 0; e < detector_results_length; e = e + 1)
      detector_results[e] <= detector_results_next[e];
  end
  
  always@* begin
    a = 0; b = 0; c = 0; f = 0; g = 0; h = 0; aa = 0; bb = 0;
    comp_finished = 0;
    check_num_next = check_num;
    first_match_next = 0;//first_match;
    check_literal = (start_pos <= check_num) 
        ? buffer[check_num - start_pos] : queue[start_pos - check_num - 1];
        
    for(a = 0; a < Q_LENGTH; a = a + 1)
      queue_check_next[a] = queue_check[a];
    for(aa  = 0; aa < detector_results_length; aa = aa + 1)
      detector_results_next[aa] = 0;
    
    if(comp_state == COMP_IDLE) begin
      check_num_next = 0;
    end
    else begin //comp_state == COMP_RUNNING
      check_num_next = check_num + 1;
      for(b = 0; b < Q_LENGTH - 1; b = b + 1)
        if(b >= start_pos && b < q_size)
          queue_check_next[b] = (check_num) ? 
            	 queue_check[b + 1] &&  queue[b] == check_literal : queue[b] == check_literal;
        else
          queue_check_next[b] = 0;
        
        for(f = 0; f < detector_results_length; f = f + 1) begin
          if(!first_match_next && detector_results[f])
            first_match_next = detector_results[f];
            
            
          for(g = 0; g < zero_detector_length; g = g + 1) 
            if(!detector_results_next[f] && queue_check[g + f * zero_detector_length])
              detector_results_next[f] = g + 1 + f * zero_detector_length;
        end
        
        if(check_num > 1 && !first_match_next)
          comp_finished = 1;
                       
    end

  end
  
  
endmodule

