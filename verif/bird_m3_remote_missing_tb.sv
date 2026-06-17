`timescale 1ns/1ps
module bird_m3_remote_missing_tb;
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
        $fsdbDumpvars(0, bird_m3_remote_missing_tb);
    end

    initial begin
        bird_fragment f1, f3;
        byte unsigned p1[]; byte unsigned p3[];
        bit [31:0] w;
        int got;

        rword_mb = new();
        drv  = new(bif.tb_drv_mp);
        rmon = new(bif.tb_mon_mp, rword_mb);
        gen  = new(0);            // DUT mode
        cov  = new();

        fork rmon.run(); join_none

        drv.apply_reset(3);

        // packet that should have 3 fragments, but we send only index 1 and 3
        // (index 2 is MISSING -> packet must NOT complete)
        p1 = '{8'h11, 8'h22, 8'h33};
        p3 = '{8'h77, 8'h88, 8'h99};

        f1 = gen.make_fragment(p1, 1, 3, 8'hA0, 8'hA1);   // index 1, pkt_id 3
        f3 = gen.make_fragment(p3, 3, 3, 8'hC0, 8'hC1);   // index 3, pkt_id 3

        drv.drive_fragment(f1);
        cov.sample_fragment(f1);
        drv.drive_fragment(f3);
        cov.sample_fragment(f3);
        cov.sample_packet(3, 0, 0, bird_remote_coverage::DROP_MISSING);

        repeat (60) @(bif.cb_drv);

        got = rword_mb.num();
        $display("[M3_MISS] ---- remote output words ----");
        while (rword_mb.num() > 0) begin
            rword_mb.get(w);
            $display("[M3_MISS] remote word = 0x%08h", w);
        end
        $display("[M3_MISS] total remote words = %0d (expected 0 if dropped/incomplete)", got);
        $display("[M3_MISS] DUT drop_cnt = %0d", bif.drop_cnt);

        repeat (10) @(bif.cb_drv);
        cov.report("bird_m3_remote_missing_tb");
        $finish;
    end
endmodule
