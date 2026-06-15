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
  // ============================================================
  bit          remote_active;
  int unsigned active_seq;                 // 1..31 (packet identifier)
  int unsigned active_max_frag;            // inferred N: max FRAG_NUM seen so far (1..31)
  bit          frag_seen   [1:31];
  u8_t         frag_payload[1:31][$];

  task automatic clear_remote_state();
    remote_active    = 0;
    active_seq       = 0;
    active_max_frag  = 0;
    for (int f = 1; f <= 31; f++) begin
      frag_seen[f] = 0;
      frag_payload[f].delete();
    end
  endtask

  task automatic drop_remote_packet_counted();
    // Drop currently-accumulated remote packet (if any) and count it as one dropped packet.
    if (remote_active) begin
      inc_drop_cnt();
    end
    clear_remote_state();
  endtask

  function automatic bit all_frags_ready(input int unsigned n);
    bit ok;
    ok = 1;
    for (int f = 1; f <= 31; f++) begin
      if (f <= n) begin
        if (!frag_seen[f]) ok = 0;
      end
    end
    return ok;
  endfunction

  task automatic build_and_queue_remote_output();
    u8_t merged[$];
    logic [15:0] crc;

    merged.delete();

    // Merge in order 1..N; if missing any => drop packet
    for (int f = 1; f <= active_max_frag; f++) begin
      if (!frag_seen[f]) begin
        drop_remote_packet_counted();
        return;
      end
      foreach (frag_payload[f][i]) merged.push_back(frag_payload[f][i]);
    end

    // Regenerate CRC over merged payload (cfg is not part of stream)
    crc = crc16_ccitt_bytes(merged);

    // Queue merged payload packed into 32-bit words, then CRC word
    pack_bytes_to_words(merged, remote_wq);
    remote_wq.push_back({16'h0000, crc});

    // Clear current remote packet state after queuing output (NOT a drop)
    clear_remote_state();
  endtask

    // ============================================================
    // RX fragment FSM
    // ============================================================
    typedef enum logic [1:0] {RX_IDLE, RX_PAYLOAD, RX_CRC} rx_state_e;
    rx_state_e rx_st;

    // Latched at start-of-fragment (first payload byte)
    bit          rx_is_remote;
    bit          rx_drop;

    int unsigned rx_seq;       /
    int unsigned rx_len;    
    int unsigned rx_frag;      

    // Counters for the remainder of t
    int unsigned payload_left;  // remaining payl
    int unsigned crc_left;      // rem

    // T
    u8_t cur_frag_payload[$];

    // ============================================================
    // Main sequential behavior
    // ============================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            $display("ssssssssssssssssss state moved to idle");
            rx_st <= RX_IDLE;

            local_q.delete();
            remote_wq.delete();
            cur_frag_payload.delete();

            drop_cnt <= 16'd0;

            clear_remote_state();

        end else begin
        if (in_vld && in_rdy) begin
            unique case (rx_st)

                // ----------------------------------------------------
                // RX_IDLE: first payload byte of a fragment arrives here
                // cfg sampled in SAME cycle as first payload byte.
      
                RX_IDLE: b
                    rx_drop 

                    rx_len       = cf
                    rx_frag      = cfg[20:16];
  

                    
                    cur_f

                    // Co

                    crc_le

                    // If 
                  
                        inc_drop_cnt();
 

                        // If this is a remote fragment for t
                        if (cfg[0] == 1
                            drop_re
         

                        // Valid cfg: handle 
                        if (!rx_is_remote) begin
                   
                            $display("pus
                            local_q.p
         
       
     

                                // if (rx_frag == 1) begi
       
                                    remote_active   =
                                    active_seq      = rx_seq;
   
                             
                                        frag_seen[f] = 0;
             
                                    end
                                    $display("====
                                  
                                end e

                                    in
                         
                         
                         
                                $displa
                       
                               
       
         

                                    // Start n
                                    //if (rx_frag == 1) begin
                              
                            
                     
       
                         
         

                                        end
                   
           
           
                                       
                       
                                  
         
       
              
             

                            end
                 
                   

                    

                    

                    end else begin
                      
                        rx_st <= RX_PAYLOAD;
       
                
             

                // -----------------
               
         
                RX_PAYLOAD: begin
                    rx_drop      = cfg
       

                    $display("Dropppppppppppppppppppppppppppp");
    
                    if (!rx_drop) be

                            // Local: forward payload bytes
       
                            local_q.push_ba
                        end else begin
  

                                $display("%t ====================3 Adding 
                         
         

                    end

                    if (payload_left > 0) 

                    /
                    if (payload_left == 3) begin
                  
                        rx_st <= RX_CRC;
                    end
     
                end



                // Local: forward CRC bytes unchanged on
                // -----------
                RX_CRC: b

                    if (crc_left

                    // Forw
                    if (!rx_dro

                        local_q.push_b
                    end

                    // E
                    if (crc_left == 1)

        
                            /

                                // Remote fragment without valid ac
                               
                                inc_drop_cnt();
                   
                                // rx_frag is guara
                         
                                if (rx_seq < 1 || rx_seq > rx_f
                             

                             
                               
                                    //

                              

                                 

                      
                                   
                               

                                    // Infer N as max FRAG_NUM seen so 
                                    $display("check if frag done");
     
                                    if (rx_seq > active_max_frag) a

     
                          
                            

                                end
 
                        end

                 
  

                    
                end

    

            endcase
     

    end

endmodule
