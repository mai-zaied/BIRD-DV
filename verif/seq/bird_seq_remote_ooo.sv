
class bird_seq_remote_ooo extends bird_seq_base;
    function new(); super.new("remote_ooo"); endfunction
    task body(bird_env env);
        bird_fragment g1,g2; byte unsigned a[],b[];
        a='{8'h11,8'h22,8'h33}; b='{8'h44,8'h55,8'h66};
        g2=env.gen().make_remote(b,2,2,8'hB0,8'hB1,0);
        g1=env.gen().make_remote(a,1,2,8'hA0,8'hA1,0);
        env.rcov.sample_fragment(g2); env.rcov.sample_fragment(g1);
        env.drive_fragment(g2); env.settle(5);
        env.drive_fragment(g1); env.settle(40);
        env.rcov.sample_packet(2,1,0,bird_remote_coverage::DROP_NONE);
    endtask
endclass
