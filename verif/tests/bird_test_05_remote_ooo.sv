



class bird_test_05_remote_ooo extends bird_test_base;
    function new(virtual bird_if.tb_drv_mp d, virtual bird_if.tb_mon_mp m);
        super.new(d, m);
    endfunction
    function string test_name(); return "bird_test_05_remote_ooo"; endfunction
    task scenario();
        bird_seq_remote_ooo s;
        s = new();
        s.body(env);
    endtask
endclass
