





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
