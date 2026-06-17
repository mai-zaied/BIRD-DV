`timescale 1ns/1ps
module bird_m3_remote_seqmix_tb;
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

    bird_input_driver   drv;
    bird_remote_monitor rmon;
    bird_remote_seq     gen;
    bird_remote_coverage cov;

    mailbox #(bit [31:0]) rword_mb;

    initial begin
        $fsdbDumpfile("waves.fsdb");
        $fsdbDumpvars(0, bird_m3_remote_seqmix_tb);
    end

    initial begin
        bird_fragment fa, fb;
        byte unsigned pa[]; byte unsigned pb[];
        bit [31:0] w;
        int got;

        rword_mb = new();
        drv  = new(bif.tb_drv_mp);
        rmon = new(bif.tb_mon_mp, rword_mb);
        gen  = new(1);            // SPEC mode: index on FRAG_NUM, SEQ_NUM is the packet id
        cov  = new();

        fork rmon.run(); join_none

        drv.apply_reset(3);

        // Start packet with SEQ_NUM = 5 (fragment position 1)
        // Then, mid-accumulation, send a fragment with a DIFFERENT SEQ_NUM = 6
        // Per spec: mismatched SEQ_NUM during accumulation -> drop
        pa = '{8'h11, 8'h22, 8'h33};
        pb = '{8'h44, 8'h55, 8'h66};

        fa = gen.make_fragment(pa, 1, 5, 8'hA0, 8'hA1);   // position 1, SEQ_NUM 5
        fb = gen.make_fragment(pb, 2, 6, 8'hB0, 8'hB1);   // position 2, SEQ_NUM 6 (mismatch!)

        drv.drive_fragment(fa);
        cov.sample_fragment(fa);
        drv.drive_fragment(fb);
        cov.sample_fragment(fb);
        cov.sample_packet(2, 0, 1, bird_remote_coverage::DROP_SEQ_MIX);

        repeat (60) @(bif.cb_drv);

        got = rword_mb.num();
        $display("[M3_SEQMIX] ---- remote output words ----");
        while (rword_mb.num() > 0) begin
            rword_mb.get(w);
            $display("[M3_SEQMIX] remote word = 0x%08h", w);
        end
        $display("[M3_SEQMIX] total remote words = %0d", got);
        $display("[M3_SEQMIX] DUT drop_cnt = %0d (spec expects a drop here)", bif.drop_cnt);

        repeat (10) @(bif.cb_drv);
        cov.report("bird_m3_remote_seqmix_tb");
        $finish;
    end
endmodule
