
class bird_seq_remote_spec_inorder extends bird_seq_base;
    function new(); super.new("remote_spec_inorder"); endfunction
    task body(bird_env env);
        bird_fragment g1,g2; byte unsigned a[],b[];
        a='{8'h11,8'h22,8'h33}; b='{8'h44,8'h55,8'h66};
        g1=env.gen().make_remote(a,1,7,8'hC0,8'hC1,1);
        g2=env.gen().make_remote(b,2,7,8'hD0,8'hD1,1);
        env.rcov.sample_fragment(g1); env.rcov.sample_fragment(g2);
        env.drive_fragment(g1); env.settle(5);
        env.drive_fragment(g2); env.settle(40);
        env.rcov.sample_packet(2,0,1,bird_remote_coverage::DROP_NONE);
    endtask
endclass
