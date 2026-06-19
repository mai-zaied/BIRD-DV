`timescale 1ns/1ps
module bird_regression_tb;
    import bird_tb_pkg::*;

    logic clk;
    bird_if bif(.clk(clk));
    initial clk = 1'b0;
    always #5 clk = ~clk;

    bird dut (
        .clk(clk), .rst_n(bif.rst_n),
        .in_vld(bif.in_vld), .in_rdy(bif.in_rdy),
        .data_in(bif.data_in), .cfg(bif.cfg), .drop_cnt(bif.drop_cnt),
        .local_vld(bif.local_vld), .local_rdy(bif.local_rdy), .data_local(bif.data_local),
        .remote_vld(bif.remote_vld), .remote_rdy(bif.remote_rdy), .data_remote(bif.data_remote)
    );

    bird_env             env;
    bird_remote_coverage rcov;   // M3 functional coverage, sampled here too

    initial begin
        $fsdbDumpfile("waves.fsdb");
        $fsdbDumpvars(0, bird_regression_tb);
    end

    function automatic bird_fragment make_local(int seq, int frag,
            byte unsigned pl[], byte unsigned crc0, byte unsigned crc1);
        bird_fragment tr; int len;
        tr = new('0); len = pl.size() + 2;
        tr.cfg[0]=1'b0; tr.cfg[15:8]=len[7:0]; tr.cfg[20:16]=frag[4:0]; tr.cfg[28:24]=seq[4:0];
        foreach (pl[i]) tr.append_byte(pl[i]);
        tr.append_byte(crc0); tr.append_byte(crc1);
        return tr;
    endfunction

    task automatic send(bird_fragment f, int settle = 20);
        env.drive_fragment(f);
        repeat (settle) @(bif.cb_drv);
    endtask

    initial begin
        bird_remote_seq dgen, sgen;
        bird_fragment   f, g1, g2, rbad;
        byte unsigned   a[], b[], c[], d[];

        env  = new(bif.tb_drv_mp, bif.tb_mon_mp, 1'b0);
        rcov = new();
        dgen = new(0);            // DUT mode  (position on SEQ_NUM)
        sgen = new(1);            // SPEC mode (position on FRAG_NUM)

        env.run();
        env.reset(3);

        // -------- LOCAL: valid (3 lengths) + invalid --------
        a='{8'h11,8'h22,8'h33,8'h44};          send(make_local(1,1,a,8'hAB,8'hCD));
        a='{8'hDE,8'hAD,8'hBE,8'hEF,8'h01};    send(make_local(1,1,a,8'h12,8'h34));
        a='{8'h99,8'h88,8'h77,8'h66,8'h55,8'h44}; send(make_local(1,1,a,8'h56,8'h78));
        f = make_local(1,1,'{8'hDE,8'hAD},8'h00,8'h00); f.cfg[7]=1'b1; send(f); // invalid local

        // -------- REMOTE invalid (reserved) -----------------
        rbad = dgen.make_fragment('{8'hEE,8'hFF}, 1, 1, 8'h00, 8'h00); rbad.cfg[7]=1'b1;
        send(rbad);

        // -------- REMOTE DUT-mode in-order (reassembles) -----
        a='{8'h11,8'h22,8'h33}; b='{8'h44,8'h55,8'h66};
        g1=dgen.make_fragment(a,1,2,8'hA0,8'hA1); g2=dgen.make_fragment(b,2,2,8'hB0,8'hB1);
        rcov.sample_fragment(g1); rcov.sample_fragment(g2);
        send(g1,5); send(g2,40);
        rcov.sample_packet(2,0,0,bird_remote_coverage::DROP_NONE);

        // -------- REMOTE DUT-mode out-of-order ---------------
        g2=dgen.make_fragment(b,2,2,8'hB0,8'hB1); g1=dgen.make_fragment(a,1,2,8'hA0,8'hA1);
        rcov.sample_fragment(g2); rcov.sample_fragment(g1);
        send(g2,5); send(g1,40);
        rcov.sample_packet(2,1,0,bird_remote_coverage::DROP_NONE);

        // -------- REMOTE missing fragment (idx 1 and 3) ------
        a='{8'h11,8'h22,8'h33}; c='{8'h77,8'h88,8'h99};
        g1=dgen.make_fragment(a,1,3,8'hA0,8'hA1); g2=dgen.make_fragment(c,3,3,8'hC0,8'hC1);
        rcov.sample_fragment(g1); rcov.sample_fragment(g2);
        send(g1,5); send(g2,40);
        rcov.sample_packet(3,0,0,bird_remote_coverage::DROP_MISSING);

        // -------- REMOTE spec-mode mismatched SEQ ------------
        a='{8'h11,8'h22,8'h33}; b='{8'h44,8'h55,8'h66};
        g1=sgen.make_fragment(a,1,5,8'hA0,8'hA1); g2=sgen.make_fragment(b,2,6,8'hB0,8'hB1);
        rcov.sample_fragment(g1); rcov.sample_fragment(g2);
        send(g1,5); send(g2,40);
        rcov.sample_packet(2,0,1,bird_remote_coverage::DROP_SEQ_MIX);

        // -------- REMOTE spec-mode new FRAG1, new SEQ --------
        g1=sgen.make_fragment(a,1,5,8'hA0,8'hA1); g2=sgen.make_fragment(b,1,6,8'hB0,8'hB1);
        rcov.sample_fragment(g1); rcov.sample_fragment(g2);
        send(g1,5); send(g2,40);
        rcov.sample_packet(2,0,1,bird_remote_coverage::DROP_NEW_FRAG1);

        // -------- REMOTE spec-mode in-order (LAST -> emits) --
        a='{8'h11,8'h22,8'h33}; b='{8'h44,8'h55,8'h66};
        g1=sgen.make_fragment(a,1,7,8'hC0,8'hC1); g2=sgen.make_fragment(b,2,7,8'hD0,8'hD1);
        rcov.sample_fragment(g1); rcov.sample_fragment(g2);
        send(g1,5); send(g2,40);
        rcov.sample_packet(2,0,1,bird_remote_coverage::DROP_NONE);

        repeat (20) @(bif.cb_drv);
        env.finalize();
        env.report("bird_regression_tb");
        rcov.report("bird_regression_tb");
        $finish;
    end
endmodule
