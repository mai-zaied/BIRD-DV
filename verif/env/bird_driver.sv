



class bird_input_driver;
    virtual bird_if.tb_drv_mp vif;

    function new(virtual bird_if.tb_drv_mp vif);
        this.vif = vif;
    endfunction

    task automatic drive_idle();
        vif.cb_drv.in_vld     <= 1'b0;
        vif.cb_drv.data_in    <= '0;
        vif.cb_drv.cfg        <= '0;
        vif.cb_drv.local_rdy  <= 1'b1;
        vif.cb_drv.remote_rdy <= 1'b1;
    endtask

    task automatic apply_reset(int cycles = 3);
        drive_idle();
        vif.cb_drv.rst_n <= 1'b0;
        repeat (cycles) @(vif.cb_drv);
        vif.cb_drv.rst_n <= 1'b1;
        @(vif.cb_drv);
    endtask


    task automatic set_backpressure(bit local_bp, bit remote_bp);
        vif.cb_drv.local_rdy  <= ~local_bp;
        vif.cb_drv.remote_rdy <= ~remote_bp;
        @(vif.cb_drv);
    endtask

    task automatic settle(int n);
        repeat (n) @(vif.cb_drv);
    endtask

    task automatic drive_fragment(bird_fragment tr);
        int i;
        bit accepted;
        int wait_cycles;

        if (tr.bytes.size() != tr.total_len_bytes()) begin
            $warning("drive_fragment: bytes size (%0d) != payload+crc size (%0d)",
                     tr.bytes.size(), tr.total_len_bytes());
        end

        for (i = 0; i < tr.bytes.size(); i++) begin
            accepted = 1'b0;
            wait_cycles = 0;
            vif.cb_drv.in_vld  <= 1'b1;
            vif.cb_drv.cfg     <= tr.cfg;
            vif.cb_drv.data_in <= tr.bytes[i];

            while (!accepted) begin
                @(vif.cb_drv);
                accepted = vif.cb_drv.in_rdy;
                wait_cycles++;
                if (wait_cycles > 2000) begin
                    $fatal(1, "drive_fragment timeout waiting for in_rdy on byte %0d", i);
                end
            end
        end

        vif.cb_drv.in_vld  <= 1'b0;
        vif.cb_drv.data_in <= '0;
        vif.cb_drv.cfg     <= '0;
        @(vif.cb_drv);
    endtask
endclass
