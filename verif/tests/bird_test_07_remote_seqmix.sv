



class bird_test_07_remote_seqmix extends bird_test_base;
    function new(virtual bird_if.tb_drv_mp d, virtual bird_if.tb_mon_mp m);
        super.new(d, m);
    endfunction
    function string test_name(); return "bird_test_07_remote_seqmix"; endfunction
    task scenario();
        bird_seq_remote_seqmix s;
        s = new();
        s.body(env);
    endtask
endclass
