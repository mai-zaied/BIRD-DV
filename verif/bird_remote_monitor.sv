class bird_remote_monitor;
    virtual bird_if.tb_mon_mp vif;
    mailbox #(bit [31:0]) word_mb;

    function new(virtual bird_if.tb_mon_mp vif,
                 mailbox #(bit [31:0]) word_mb);
        this.vif     = vif;
        this.word_mb = word_mb;
    endfunction

    task automatic run();
        bit          have_prev;
        bit [31:0]   prev_word;

        have_prev = 1'b0;
        prev_word = 32'h0;

        forever begin
            @(vif.cb_mon);

            if (!vif.cb_mon.rst_n) begin
                have_prev = 1'b0;
            end
            else if (vif.cb_mon.remote_vld && vif.cb_mon.remote_rdy) begin
                //skip only if it's an immediate exact repeat
                if (!(have_prev && (vif.cb_mon.data_remote == prev_word))) begin
                    word_mb.put(vif.cb_mon.data_remote);
                end
                prev_word = vif.cb_mon.data_remote;
                have_prev = 1'b1;
            end
            else begin
                have_prev = 1'b0; 
            end
        end
    endtask
endclass
