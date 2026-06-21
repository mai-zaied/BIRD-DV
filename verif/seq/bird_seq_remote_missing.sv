
class bird_seq_remote_missing extends bird_seq_base;
    function new(); super.new("remote_missing"); endfunction
    task body(bird_env env);
        bird_fragment g1,g2; byte unsigned a[],c[];
        a='{8'h11,8'h22,8'h33}; c='{8'h77,8'h88,8'h99};
        g1=env.gen().make_remote(a,1,3,8'hA0,8'hA1,0);
        g2=env.gen().make_remote(c,3,3,8'hC0,8'hC1,0);
        env.rcov.sample_fragment(g1); env.rcov.sample_fragment(g2);
        env.drive_fragment(g1); env.settle(5);
        env.drive_fragment(g2); env.settle(40);
        env.rcov.sample_packet(3,0,0,bird_remote_coverage::DROP_MISSING);
    endtask
endclass
