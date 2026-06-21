



class bird_test_13_backpressure extends bird_test_base;
    function new(virtual bird_if.tb_drv_mp d, virtual bird_if.tb_mon_mp m);
        super.new(d, m);
    endfunction
    function string test_name(); return "bird_test_13_backpressure"; endfunction
    task scenario();
        bird_seq_backpressure s;
        s = new();
        s.body(env);
    endtask
endclass
