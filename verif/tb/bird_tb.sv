








`timescale 1ns/1ps
module bird_tb;
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

    int    test_id;
    bit    verbose;

    initial begin
        $fsdbDumpfile("waves.fsdb");
        $fsdbDumpvars(0, bird_tb);
    end

    initial begin
        if (!$value$plusargs("TEST_ID=%d", test_id)) test_id = 0;
        verbose = $test$plusargs("VERBOSE");
        $display("\n[BIRD_TB] TEST_ID=%0d  VERBOSE=%0b", test_id, verbose);

        bird_test_harness::run(test_id, bif.tb_drv_mp, bif.tb_mon_mp);

        repeat (20) @(bif.cb_drv);
        $display("[BIRD_TB] all done, finishing.");
        $finish;
    end


    initial begin
        #20_000_000;
        $display("[BIRD_TB] WATCHDOG timeout");
        $finish;
    end
endmodule
