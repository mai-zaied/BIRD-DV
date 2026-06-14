`timescale 1ns/1ps

module bird_m1_smoke_tb;
    import bird_tb_pkg::*;

    logic clk;
    bird_if bif(.clk(clk));

    bird_input_driver  drv;
    bird_input_monitor mon;
    mailbox #(bird_fragment) in_mb;

    initial clk = 1'b0;
    always #5 clk = ~clk;
    assign bif.in_rdy = 1'b1;
    task automatic build_local_fragment(output bird_fragment tr);
        tr = new(32'h0000_0300);
        tr.cfg[0]     = 1'b0;
        tr.cfg[15:8]  = 8'd3;
        tr.cfg[20:16] = 5'd1;
        tr.cfg[28:24] = 5'd0;

        tr.append_byte(8'h11);
        tr.append_byte(8'h22);
        tr.append_byte(8'h33);
        tr.append_byte(8'hAB);
        tr.append_byte(8'hCD);
    endtask

    initial begin
        bird_fragment tx;
        bird_fragment rx;

        in_mb = new();
        drv = new(bif.tb_drv_mp);
        mon = new(bif.tb_mon_mp, in_mb);

        fork
            mon.run();
        join_none

        drv.apply_reset(3);
        build_local_fragment(tx);
        drv.drive_fragment(tx);

        in_mb.get(rx);
        $display("[M1_SMOKE] Captured input fragment cfg=0x%08h size=%0d",
                 rx.cfg, rx.bytes.size());

        if (rx.cfg !== tx.cfg || rx.bytes.size() != tx.bytes.size()) begin
            $error("[M1_SMOKE] FAIL: captured fragment mismatch");
        end else begin
            $display("[M1_SMOKE] PASS: driver/monitor input path is working");
        end

        #20;
        $finish;
    end

endmodule

