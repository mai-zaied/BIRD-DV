



class bird_test_12_drop_len0 extends bird_test_base;
    function new(virtual bird_if.tb_drv_mp d, virtual bird_if.tb_mon_mp m);
        super.new(d, m);
    endfunction
    function string test_name(); return "bird_test_12_drop_len0"; endfunction
    task scenario();
        bird_seq_drop_len0 s;
        s = new();
        s.body(env);
    endtask
endclass
