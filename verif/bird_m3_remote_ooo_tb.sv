`timescale 1ns/1ps
module bird_m3_remote_ooo_tb;
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
        $fsdbDumpvars(0, bird_m3_remote_ooo_tb);
    end

    initial begin
        bird_fragment f1, f2;
        byte unsigned p1[]; byte unsigned p2[];
        bit [31:0] w;

        rword_mb = new();
        cov  = new();
        drv  = new(bif.tb_drv_mp);
        rmon = new(bif.tb_mon_mp, rword_mb);
        gen  = new(0);            // DUT mode

        fork rmon.run(); join_none

        drv.apply_reset(3);

        // same packet, but sent OUT OF ORDER: fragment idx 2 first, then idx 1
        p1 = '{8'h11, 8'h22, 8'h33};   // belongs to position 1
        p2 = '{8'h44, 8'h55, 8'h66};   // belongs to position 2

        f2 = gen.make_fragment(p2, 2, 2, 8'hB0, 8'hB1);   // position 2
        f1 = gen.make_fragment(p1, 1, 2, 8'hA0, 8'hA1);   // position 1
        cov.sample_fragment(f2);

        cov.sample_fragment(f1);
        drv.drive_fragment(f2);    // send position 2 FIRST
        cov.sample_packet(2, 1, 0, bird_remote_coverage::DROP_NONE);
        drv.drive_fragment(f1);    // then position 1

        repeat (40) @(bif.cb_drv);

        $display("[M3_OOO] ---- remote output words ----");
        while (rword_mb.num() > 0) begin
            rword_mb.get(w);
            $display("[M3_OOO] remote word = 0x%08h", w);
        end
        $display("[M3_OOO] DUT drop_cnt = %0d", bif.drop_cnt);

        repeat (10) @(bif.cb_drv);
        cov.report("bird_m3_remote_ooo_tb");
        $finish;
    end
endmodule
