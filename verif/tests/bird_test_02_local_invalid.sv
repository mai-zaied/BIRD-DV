



class bird_test_02_local_invalid extends bird_test_base;
    function new(virtual bird_if.tb_drv_mp d, virtual bird_if.tb_mon_mp m);
        super.new(d, m);
    endfunction
    function string test_name(); return "bird_test_02_local_invalid"; endfunction
    task scenario();
        bird_seq_local_invalid s;
        s = new();
        s.body(env);
    endtask
endclass
