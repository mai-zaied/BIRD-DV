`timescale 1ns/1ps

package bird_tb_pkg;

    class bird_fragment;
        bit [31:0] cfg;
        byte unsigned bytes[$];

        function new(bit [31:0] cfg_word = '0);
            cfg = cfg_word;
        endfunction

        function void append_byte(byte unsigned b);
            bytes.push_back(b);
        endfunction

        function int payload_len();
            return cfg[15:8];
        endfunction

        function int total_len_bytes();
            return payload_len() + 2;
        endfunction
    endclass

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

            @(vif.cb_drv);
            vif.cb_drv.in_vld  <= 1'b0;
            vif.cb_drv.data_in <= '0;
            vif.cb_drv.cfg     <= '0;
        endtask
    endclass

    class bird_input_monitor;
        virtual bird_if.tb_mon_mp vif;
        mailbox #(bird_fragment) observed_mb;

        function new(virtual bird_if.tb_mon_mp vif,
                     mailbox #(bird_fragment) observed_mb);
            this.vif = vif;
            this.observed_mb = observed_mb;
        endfunction

        task automatic run();
            bird_fragment tr;
            int expected_bytes;
            int count_bytes;
            bit collecting;

            collecting = 1'b0;
            expected_bytes = 0;
            count_bytes = 0;

            forever begin
                @(vif.cb_mon);
                if (!vif.cb_mon.rst_n) begin
                    collecting = 1'b0;
                    expected_bytes = 0;
                    count_bytes = 0;
                    tr = null;
                end else if (vif.cb_mon.in_vld && vif.cb_mon.in_rdy) begin
                    if (!collecting) begin
                        tr = new(vif.cb_mon.cfg);
                        expected_bytes = tr.total_len_bytes();
                        count_bytes = 0;
                        collecting = 1'b1;
                    end

                    tr.append_byte(vif.cb_mon.data_in);
                    count_bytes++;

                    if (count_bytes == expected_bytes) begin
                        observed_mb.put(tr);
                        collecting = 1'b0;
                    end
                end
            end
        endtask
    endclass

endpackage

