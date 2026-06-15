class bird_local_monitor;
    virtual bird_if.tb_mon_mp vif;
    mailbox #(byte unsigned)  byte_mb;

    function new(virtual bird_if.tb_mon_mp vif,
                 mailbox #(byte unsigned) byte_mb);
        this.vif     = vif;
        this.byte_mb = byte_mb;
    endfunction

    task automatic run();
        forever begin
            @(vif.cb_mon);
            if (vif.cb_mon.rst_n && vif.cb_mon.local_vld && vif.cb_mon.local_rdy) begin
                byte_mb.put(vif.cb_mon.data_local);
            end
        end
    endtask
endclass
