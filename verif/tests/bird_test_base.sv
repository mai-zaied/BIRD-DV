





virtual class bird_test_base;
    virtual bird_if.tb_drv_mp drv_mp;
    virtual bird_if.tb_mon_mp mon_mp;
    bird_pkt_cfg cfg;
    bird_env     env;

    function new(virtual bird_if.tb_drv_mp drv_mp,
                 virtual bird_if.tb_mon_mp mon_mp);
        this.drv_mp = drv_mp;
        this.mon_mp = mon_mp;
        cfg = new();
        configure();
    endfunction

    virtual function void configure(); endfunction
    virtual function string test_name(); return "bird_test_base"; endfunction
    virtual task scenario(); endtask

    task automatic run();
        $display("\n============================================================");
        $display("[TEST] starting %0s", test_name());
        cfg.summary(test_name());
        env = new(drv_mp, mon_mp, cfg);
        env.run();
        env.reset();
        scenario();
        env.settle(20);
        env.finalize();
        env.report(test_name());
        $display("[TEST] finished %0s", test_name());
    endtask
endclass
