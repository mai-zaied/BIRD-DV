








class bird_seq_backpressure extends bird_seq_base;
    function new(); super.new("backpressure"); endfunction
    task body(bird_env env);
        byte unsigned a[];
        a = '{8'h11,8'h22,8'h33,8'h44};
        env.sb.skip_local_check = 1'b1;
        env.set_backpressure(1'b1, 1'b1);
        env.drive_fragment(env.gen().make_local(1,1,a,8'hAB,8'hCD));
        env.assert_local_stable(6);
        env.set_backpressure(1'b0, 1'b0);
        env.settle(20);
    endtask
endclass
