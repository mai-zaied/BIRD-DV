class bird_remote_seq;

    // index_mode = 0 | DUT mode 
    // index_mode = 1 | SPEC mode 
    int index_mode;

    function new(int index_mode = 0);
        this.index_mode = index_mode;
    endfunction

    function automatic bird_fragment make_fragment(
        byte unsigned payload[],
        int idx,
        int pkt_id,
        byte unsigned crc0,
        byte unsigned crc1
    );
        bird_fragment tr;
        int total_len;
        int seq_val;
        int frag_val;

        tr = new('0);

        // PAYLOAD_LEN = total bytes on wire = payload + 2 CRC (DUT convention)
        total_len = payload.size() + 2;

        if (index_mode == 0) begin
            //. position goes on SEQ_NUM, FRAG_NUM is fixed
            seq_val  = idx;
            frag_val = pkt_id;
        end
        else begin
            // position goes on FRAG_NUM, SEQ_NUM is shared
            seq_val  = pkt_id;
            frag_val = idx;
        end

        tr.cfg[0]     = 1'b1;                 // remote traffic
        tr.cfg[15:8]  = total_len[7:0];       // PAYLOAD_LEN (total incl CRC)
        tr.cfg[20:16] = frag_val[4:0];        // FRAG_NUM
        tr.cfg[28:24] = seq_val[4:0];         // SEQ_NUM

        foreach (payload[i]) tr.append_byte(payload[i]);
        tr.append_byte(crc0);
        tr.append_byte(crc1);

        return tr;
    endfunction

endclass
