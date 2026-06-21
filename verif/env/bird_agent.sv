






class bird_agent;
    virtual bird_if.tb_drv_mp drv_mp;
    virtual bird_if.tb_mon_mp mon_mp;

    bird_input_driver   drv;
    bird_input_monitor  in_mon;
    bird_local_monitor  loc_mon;
    bird_remote_monitor rmon;
    bird_generator      gen;

    mailbox #(bird_fragment) in_mb;
    mailbox #(byte unsigned) loc_byte_mb;
    mailbox #(bit [31:0])    rword_mb;

    function new(virtual bird_if.tb_drv_mp drv_mp,
                 virtual bird_if.tb_mon_mp mon_mp);
        this.drv_mp = drv_mp;
        this.mon_mp = mon_mp;
        build();
    endfunction

    function automatic void build();
        in_mb       = new();
        loc_byte_mb = new();
        rword_mb    = new();
        gen     = new();
        drv     = new(drv_mp);
        in_mon  = new(mon_mp, in_mb);
        loc_mon = new(mon_mp, loc_byte_mb);
        rmon    = new(mon_mp, rword_mb);
    endfunction

    task automatic run();
        fork
            in_mon.run();
            loc_mon.run();
            rmon.run();
        join_none
    endtask

    task automatic reset(int cycles = 3);
        drv.apply_reset(cycles);
    endtask

    task automatic drive_fragment(bird_fragment tr);
        drv.drive_fragment(tr);
    endtask

    task automatic set_backpressure(bit local_bp, bit remote_bp);
        drv.set_backpressure(local_bp, remote_bp);
    endtask

    task automatic settle(int n);
        drv.settle(n);
    endtask
endclass
