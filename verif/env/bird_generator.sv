









class bird_generator;

    function new();
    endfunction

    function automatic bird_fragment make_local(
        int seq, int frag,
        byte unsigned pl[],
        byte unsigned crc0, byte unsigned crc1
    );
        bird_fragment tr; int len;
        tr  = new('0);
        len = pl.size() + 2;
        tr.cfg[0]     = 1'b0;
        tr.cfg[15:8]  = len[7:0];
        tr.cfg[20:16] = frag[4:0];
        tr.cfg[28:24] = seq[4:0];
        foreach (pl[i]) tr.append_byte(pl[i]);
        tr.append_byte(crc0);
        tr.append_byte(crc1);
        return tr;
    endfunction

    function automatic bird_fragment make_remote(
        byte unsigned payload[],
        int idx, int pkt_id,
        byte unsigned crc0, byte unsigned crc1,
        int mode = 0
    );
        bird_fragment tr; int total_len; int seq_val; int frag_val;
        tr = new('0);
        total_len = payload.size() + 2;
        if (mode == 0) begin
            seq_val  = idx;  frag_val = pkt_id;
        end else begin
            seq_val  = pkt_id; frag_val = idx;
        end
        tr.cfg[0]     = 1'b1;
        tr.cfg[15:8]  = total_len[7:0];
        tr.cfg[20:16] = frag_val[4:0];
        tr.cfg[28:24] = seq_val[4:0];
        foreach (payload[i]) tr.append_byte(payload[i]);
        tr.append_byte(crc0);
        tr.append_byte(crc1);
        return tr;
    endfunction
endclass
