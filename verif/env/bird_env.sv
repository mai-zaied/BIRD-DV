







class bird_env;
    virtual bird_if.tb_drv_mp drv_mp;
    virtual bird_if.tb_mon_mp mon_mp;

    bird_pkt_cfg         cfg;
    bird_agent           agent;
    bird_scoreboard      sb;
    bird_m4_coverage     cov;
    bird_remote_coverage rcov;

    function new(virtual bird_if.tb_drv_mp drv_mp,
                 virtual bird_if.tb_mon_mp mon_mp,
                 bird_pkt_cfg cfg = null);
        this.drv_mp = drv_mp;
        this.mon_mp = mon_mp;
        if (cfg == null) this.cfg = new(); else this.cfg = cfg;
        build();
    endfunction

    function automatic void build();
        cov   = new();
        rcov  = new();
        agent = new(drv_mp, mon_mp);
        sb    = new(mon_mp, agent.in_mb, agent.loc_byte_mb,
                    agent.rword_mb, cfg.strict, cov);
    endfunction


    function automatic bird_generator gen();
        return agent.gen;
    endfunction

    task automatic run();
        agent.run();
        fork sb.run(); join_none
    endtask

    task automatic reset(int cycles = -1);
        agent.reset((cycles < 0) ? cfg.reset_cycles : cycles);
    endtask

    task automatic drive_fragment(bird_fragment tr);
        agent.drive_fragment(tr);
    endtask

    task automatic set_backpressure(bit local_bp, bit remote_bp);
        agent.set_backpressure(local_bp, remote_bp);
    endtask



    task automatic assert_local_stable(int cycles);
        bit [7:0] d0; bit v0; bit ok;
        @(mon_mp.cb_mon);
        v0 = mon_mp.cb_mon.local_vld;
        d0 = mon_mp.cb_mon.data_local;
        ok = 1'b1;
        repeat (cycles) begin
            @(mon_mp.cb_mon);
            if ((mon_mp.cb_mon.local_vld !== v0) ||
                (v0 && (mon_mp.cb_mon.data_local !== d0))) ok = 1'b0;
        end
        if (ok)
            $display("[BP] stability OK: local output held stable (vld=%0b data=0x%02h) for %0d cycles under backpressure (spec 3.2)",
                     v0, d0, cycles);
        else
            $display("[BP] stability VIOLATION: local output changed while local_rdy=0");
    endtask

    task automatic settle(int n = -1);
        agent.settle((n < 0) ? cfg.settle : n);
    endtask


    function automatic bit [15:0] peek_drop_cnt();
        return mon_mp.cb_mon.drop_cnt;
    endfunction

    task automatic finalize();
        sb.finalize();
    endtask

    function void report(string test_name);
        sb.report(test_name);
        cov.report(test_name);
        rcov.report(test_name);
    endfunction
endclass
