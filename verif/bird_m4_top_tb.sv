`timescale 1ns/1ps
module bird_m4_top_tb;
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


    bird_env env;


    initial begin
        $fsdbDumpfile("waves.fsdb");
        $fsdbDumpvars(0, bird_m4_top_tb);
    end


    function automatic bird_fragment make_local(int seq, int frag,
            byte unsigned pl[], byte unsigned crc0, byte unsigned crc1);
        bird_fragment tr;
        int len;
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

    initial begin
        bird_remote_seq rgen_dut, rgen_spec;
        bird_fragment   lf, lbad, rbad, s1f, s2f;
        byte unsigned   lp[], dp[], rp[], sp1[], sp2[];

        env       = new(bif.tb_drv_mp, bif.tb_mon_mp, 1'b0);  
        rgen_dut  = new(0);           
        rgen_spec = new(1);            

        env.run();
        env.reset(3);

        $display("\n[M4_TOP] === 1: LOCAL valid ===");
        lp = '{8'h11, 8'h22, 8'h33, 8'h44};
        lf = make_local(1, 1, lp, 8'hAB, 8'hCD);
        env.drive_fragment(lf);
        repeat (20) @(bif.cb_drv);

        $display("\n[M4_TOP] === 2: LOCAL invalid (reserved) ===");
        dp   = '{8'hDE, 8'hAD};
        lbad = make_local(1, 1, dp, 8'h00, 8'h00);
        lbad.cfg[7] = 1'b1;            
        env.drive_fragment(lbad);
        repeat (20) @(bif.cb_drv);

        $display("\n[M4_TOP] === 3: REMOTE invalid (reserved) ===");
        rp   = '{8'hEE, 8'hFF};
        rbad = rgen_dut.make_fragment(rp, 1, 1, 8'h00, 8'h00); 
        rbad.cfg[7] = 1'b1;           
        env.drive_fragment(rbad);
        repeat (20) @(bif.cb_drv);

        $display("\n[M4_TOP] === 4: REMOTE spec-mode in-order ===");
        sp1 = '{8'h11, 8'h22, 8'h33};
        sp2 = '{8'h44, 8'h55, 8'h66};
        s1f = rgen_spec.make_fragment(sp1, 1, 7, 8'hC0, 8'hC1); 
        s2f = rgen_spec.make_fragment(sp2, 2, 7, 8'hD0, 8'hD1); 
        env.drive_fragment(s1f);
        env.drive_fragment(s2f);
        repeat (40) @(bif.cb_drv);

        repeat (20) @(bif.cb_drv);
        env.finalize();
        env.report("bird_m4_top_tb");
        $finish;
    end
endmodule
