class bird_env;

    virtual bird_if.tb_drv_mp drv_mp;   
    virtual bird_if.tb_mon_mp mon_mp;   


    bit strict;   

    bird_input_driver   drv;
    bird_input_monitor  in_mon;
    bird_local_monitor  loc_mon;
    bird_remote_monitor rmon;
    bird_scoreboard     sb;
    bird_m4_coverage    cov;

    mailbox #(bird_fragment) in_mb;
    mailbox #(byte unsigned) loc_byte_mb;
    mailbox #(bit [31:0])    rword_mb;

    function new(virtual bird_if.tb_drv_mp drv_mp,
                 virtual bird_if.tb_mon_mp mon_mp,
                 bit strict = 1'b0);
        this.drv_mp = drv_mp;
        this.mon_mp = mon_mp;
        this.strict = strict;
        build();
    endfunction

    function automatic void build();
        in_mb       = new();
        loc_byte_mb = new();
        rword_mb    = new();

        cov     = new();
        drv     = new(drv_mp);
        in_mon  = new(mon_mp, in_mb);
        loc_mon = new(mon_mp, loc_byte_mb);
        rmon    = new(mon_mp, rword_mb);
        sb      = new(mon_mp, in_mb, loc_byte_mb, rword_mb, strict, cov);
    endfunction

    task automatic run();
        fork
            in_mon.run();
            loc_mon.run();
            rmon.run();
            sb.run();
        join_none
    endtask

    task automatic reset(int cycles = 3);
        drv.apply_reset(cycles);
    endtask

    task automatic drive_fragment(bird_fragment tr);
        drv.drive_fragment(tr);
    endtask

    task automatic finalize();
        sb.finalize();
    endtask

    function void report(string test_name);
        sb.report(test_name);
        cov.report(test_name);
    endfunction
endclass
