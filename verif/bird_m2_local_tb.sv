`timescale 1ns/1ps
module bird_m2_local_tb;
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

    bird_input_driver  drv;
    bird_input_monitor in_mon;
    bird_local_monitor loc_mon;
    bird_drop_checker  drop_chk;
    bird_local_checker loc_chk;

    mailbox #(bird_fragment) in_mb;
    mailbox #(byte unsigned) loc_byte_mb;

    function automatic bird_fragment make_local(int seq, int frag, int len,
            byte unsigned pl[], byte unsigned crc0, byte unsigned crc1);
        bird_fragment tr; int i;
        tr = new('0);
        tr.cfg[0]     = 1'b0;
        tr.cfg[15:8]  = len[7:0];
        tr.cfg[20:16] = frag[4:0];
        tr.cfg[28:24] = seq[4:0];
        foreach (pl[i]) tr.append_byte(pl[i]);
        tr.append_byte(crc0);
        tr.append_byte(crc1);
        return tr;
    endfunction

    initial begin
        bird_fragment t1, t2, t3;
        byte unsigned p1[]; byte unsigned p2[]; byte unsigned p3[];

        in_mb       = new();
        loc_byte_mb = new();
        drv      = new(bif.tb_drv_mp);
        in_mon   = new(bif.tb_mon_mp, in_mb);
        loc_mon  = new(bif.tb_mon_mp, loc_byte_mb);
        drop_chk = new(bif.tb_mon_mp);
        loc_chk  = new(in_mb, loc_byte_mb, drop_chk);

        fork in_mon.run(); loc_mon.run(); loc_chk.run(); join_none

        drv.apply_reset(3);
        drop_chk.clear();

        p1 = '{8'h11, 8'h22, 8'h33, 8'h44}; t1 = make_local(1, 1, 6, p1, 8'hAB, 8'hCD);
        p2 = '{8'hDE, 8'hAD, 8'hBE, 8'hEF, 8'h01}; t2 = make_local(1, 1, 7, p2, 8'h12, 8'h34);
        p3 = '{8'h99, 8'h88, 8'h77, 8'h66, 8'h55, 8'h44}; t3 = make_local(1, 1, 8, p3, 8'h56, 8'h78);

        drv.drive_fragment(t1); repeat (15) @(bif.cb_drv);
        drv.drive_fragment(t2); repeat (15) @(bif.cb_drv);
        drv.drive_fragment(t3); repeat (30) @(bif.cb_drv);

        repeat (40) @(bif.cb_drv);
        drop_chk.check_now();
        loc_chk.report();
        drop_chk.report();
        $display("[M2_TB] Done. DUT drop_cnt = %0d", bif.drop_cnt);
        $finish;
    end
endmodule
