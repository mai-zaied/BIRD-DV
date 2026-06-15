// ============================================================
// Birzeit University
// Faculty of Engineering and Technology
// Department of Electrical and Computer Engineering
// Second Semester 2025/2026
// Course: Chip Design Verification (ENCS5337)
// Instructor : Elias Khalil
// ============================================================
// Course project: Birzeit Integrated Router Design (BIRD)
// BIRD Behavioral SystemVerilog Model (NON-synthesizable)
// Design is build as behavioral model just for DV purposes
// ============================================================

module bird (
  input  logic        clk,
  input  logic        rst_n,

  // Input interface
  input  logic        in_vld,
  output logic        in_rdy,
  input  logic [7:0]  data_in,
  input  logic [31:0] cfg,

  // Status output
  output logic [15:0] drop_cnt,

  // Local output interface
  output logic        local_vld,
  input  logic        local_rdy,
  output logic [7:0]  data_local,

  // Remote output interface
  output logic        remote_vld,
  input  logic        remote_rdy,
  output logic [31:0] data_remote
);

  // ----------------------------
  // Types
  // ----------------------------
  typedef byte unsigned u8_t;

  // ============================================================
  // Drop counter helper (wrap-around by natural 16-bit overflow)
  // ============================================================
  task automatic inc_drop_cnt();
    drop_cnt <= drop_cnt + 16'd1;
  endtask

  // ----------------------------
  // cfg validity (per latest rules)
  // ----------------------------
  function automatic bit cfg_invalid(input logic [31:0] c);
    bit inv;
    inv = 0;

    // Reserved bits must be 0
    if (c[7:1]   != 7'd0) inv = 1;
    if (c[23:21] != 3'd0) inv = 1;
    if (c[31:29] != 3'd0) inv = 1;

    // PAYLOAD_LEN must be 1..255 (0 invalid)
    if (c[15:8] == 8'd0) inv = 1;

    if (c[0] == 1'b0) begin
      // LOCAL: must be SEQ_NUM==1 and FRAG_NUM==1
      if (c[28:24] != 5'd1) inv = 1;
      if (c[20:16] != 5'd1) inv = 1;
    end else begin
      // REMOTE: SEQ_NUM and FRAG_NUM must be non-zero
      if (c[28:24] == 5'd0) inv = 1;
      if (c[20:16] == 5'd0) inv = 1;
    end

    return inv;
  endfunction

  // ----------------------------
  // CRC16-CCITT (poly 0x1021, init 0xFFFF) over byte queue
  // ----------------------------
  function automatic logic [15:0] crc16_ccitt_bytes(input u8_t bytes[$]);
    logic [15:0] crc;
    crc = 16'hFFFF;
    foreach (bytes[i]) begin
      crc ^= {bytes[i], 8'h00};
      for (int b = 0; b < 8; b++) begin
        if (crc[15]) crc = (crc << 1) ^ 16'h1021;
        else         crc = (crc << 1);
      end
    end
    return crc;
  endfunction

  // ----------------------------
  // Pack bytes into 32-bit words (little-endian within word)
  // ----------------------------
  function automatic void pack_bytes_to_words(input u8_t bytes[$], inout logic [31:0] wq[$]);
    int i;
    i = 0;
    while (i < bytes.size()) begin
      logic [31:0] w;
      w = 32'h0;
      for (int k = 0; k < 4; k++) begin
        if (i < bytes.size()) begin
          w[8*k +: 8] = bytes[i];
          i++;
        end
      end
      wq.push_back(w);
    end
  endfunction

  // ----------------------------
  // Input ready (behavioral model is always ready)
  // ----------------------------
  always_comb begin
    in_rdy = 1'b1;
  end

  // ----------------------------
  // Output queues (hold stable under backpressure by not popping)
  // ----------------------------
  u8_t         local_q[$];
  logic [31:0] remote_wq[$];

  // Drive outputs + pop on handshake
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      local_vld  <= 1'b0;
      data_local <= 8'h00;

      remote_vld  <= 1'b0;
      data_remote <= 32'h0;
    end else begin
      local_vld  = (local_q.size() != 0);
      data_local = (local_q.size() != 0) ? local_q[0] : 8'h00;
      if (local_vld && local_rdy) begin
        void'(local_q.pop_front());
      end

      remote_vld  <= (remote_wq.size() != 0);
      data_remote <= (remote_wq.size() != 0) ? remote_wq[0] : 32'h0;
      if (remote_vld && remote_rdy) begin
        void'(remote_wq.pop_front());
      end
    end
  end

  // ============================================================
  // Remote accumulation state (one packet at a time)
  // ===========================================================
  bit          remote_active;
  int unsigned active_seq;
 
  bit          frag_seen   [1:31];
  u8_t         frag_pay

  task automatic clear_remote_state();
    remote_active  
    active_seq       = 0;
    active_max_frag  = 0;
    for (in

      frag_pa
    end
  endtask

  task 
    if (remote_active) begin

    end
    clear_re
  endtask

  function automat
    bit ok;
    ok = 1;
    f
      if (f <= n) begin
      
      end
    end
    retu


  task automatic 
    u8_t merged[$];
    logic [

    merged.delete();

    f
      if (!frag_seen[f]) begin
 
        return;
      end
      
    end

    crc = crc16_ccitt_by

    pack_bytes_to_words(merg
    remote_wq.push_back({16'h0000

    clear_remote_state();
  endt

  // ===========================
  

  typedef enum logic [1:0] {RX_ID
  rx_state

  bit          rx_is_remote;
  b
  int unsigned rx_seq;
  int 

  int unsigned payload_left;
  int unsigned crc_left;

  u8_t cur

  // ===========================================================
  // Main sequential behavior
  // ==============================
  always_ff @(posedge clk or neg
    if (!rst_n) begin
      rx_st

      lo

      cur_frag_payload.delete();

      drop_cnt <= 16'd0;

      clea

    end else begin
      if (in_
        unique case (rx_st)

          RX_IDLE: begin
     
            
            

            rx_seq       = cfg

            cur_frag_payload.dele

            payload_left = (cfg[1
            crc_left     = 2;

   

              if (cfg[0] == 1'b1 && remote_ac
                drop_remote_packe

            end else begin

                local_q.push_back(data_in);
      
                if (!remote_active) 
                  if (rx_seq <= rx_f
                  
                    active_seq      = rx_seq;
        
                    for (int f = 1; 
                      frag_seen[f] =
       

               
             

                  end
           
                  if (rx_seq > rx_frag) begin
             
                    if (rx_seq ==
                      remote_active   = 1;
                      active_s
                     
                   
                        frag
                        frag_pa
                      end
             
                    end else begin
              
                    end
              
         
       
               
             


            if (((cfg[15:8] > 0)
              rx_st <= RX_CRC;
            end else begin
   
            end
          end

  
            rx_drop = cfg_invalid(cfg);
            if ((!rx_is_remote && remote_active) || (
          
          
            if (!rx_drop) begin
  
                local
              en
                if (remote_active && (r
                  cur_frag_payload.
                end
             
            en

          

        
              rx_st <=
       
          end

          RX_CRC: begin
         

            if (!rx_drop && !rx_is_remote) begin
 
            end

            if (
              if (!
                if
     

                  if (rx_seq < 1 
                    drop_remote_packet_counted();
                
                    frag_seen[rx_
                    frag_p
                    foreach 

                    end
             
                    if (rx_seq > active_max_frag)
                    i
                      bui
                    end
  

              end
        
            end
          e

          default

        endcase
      end
    end
  end

endmodule
