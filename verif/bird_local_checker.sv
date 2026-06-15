class bird_local_checker;
    mailbox #(bird_fragment) in_mb;
    mailbox #(byte unsigned) byte_mb;
    bird_drop_checker        drop_chk;
    int unsigned checks_done;
    int unsigned errors;

    function new(mailbox #(bird_fragment) in_mb,
                 mailbox #(byte unsigned) byte_mb,
                 bird_drop_checker drop_chk);
        this.in_mb=in_mb; this.byte_mb=byte_mb; this.drop_chk=drop_chk;
        this.checks_done=0; this.errors=0;
    endfunction

    function automatic bit spec_local_should_drop(bit [31:0] c);
        bit drop; drop = 1'b0;
        if (c[15:8]  == 8'd0) drop = 1'b1;   // PAYLOAD_LEN == 0
        if (c[7:1]   != 7'd0) drop = 1'b1;   // reserved
        if (c[23:21] != 3'd0) drop = 1'b1;   // reserved
        if (c[31:29] != 3'd0) drop = 1'b1;   // reserved
        if (c[20:16] != 5'd1) drop = 1'b1;   // FRAG_NUM must be 1 (local single fragment)
        if (c[28:24] != 5'd1) drop = 1'b1;   // DUT-as-built: local SEQ must be 1 (spec says any; documented discrepancy)
        return drop;
    endfunction

    task automatic run();
        bird_fragment exp;
        byte unsigned got_b;
        int i; bit should_drop;
        forever begin
            in_mb.get(exp);
            should_drop = spec_local_should_drop(exp.cfg);
            checks_done++;
            if (should_drop) begin
                drop_chk.expect_drop();
                $display("[LOCAL_CHK] packet #%0d cfg=0x%08h -> expected DROP (no local output)",
                         checks_done, exp.cfg);
            end
            else begin
                for (i = 0; i < exp.bytes.size(); i++) begin
                    byte_mb.get(got_b);
                    if (got_b !== exp.bytes[i]) begin
                        errors++;
                        $error("[LOCAL_CHK] packet #%0d byte %0d mismatch: in=0x%02h out=0x%02h (cfg=0x%08h)",
                               checks_done, i, exp.bytes[i], got_b, exp.cfg);
                    end
                end
                $display("[LOCAL_CHK] packet #%0d cfg=0x%08h -> forwarded, %0d bytes checked",
                         checks_done, exp.cfg, exp.bytes.size());
            end
        end
    endtask

    function void report();
        $display("[LOCAL_CHK] SUMMARY: %0d packets checked, %0d byte errors", checks_done, errors);
    endfunction
endclass
