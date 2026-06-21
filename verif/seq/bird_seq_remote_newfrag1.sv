
class bird_seq_remote_newfrag1 extends bird_seq_base;
    function new(); super.new("remote_newfrag1"); endfunction
    task body(bird_env env);
        bird_fragment g1,g2; byte unsigned a[],b[];
        a='{8'h11,8'h22,8'h33}; b='{8'h44,8'h55,8'h66};
        g1=env.gen().make_remote(a,1,5,8'hA0,8'hA1,1);
        g2=env.gen().make_remote(b,1,6,8'hB0,8'hB1,1);
        env.rcov.sample_fragment(g1); env.rcov.sample_fragment(g2);
        env.drive_fragment(g1); env.settle(5);
        env.drive_fragment(g2); env.settle(40);
        env.rcov.sample_packet(2,0,1,bird_remote_coverage::DROP_NEW_FRAG1);
    endtask
endclass
