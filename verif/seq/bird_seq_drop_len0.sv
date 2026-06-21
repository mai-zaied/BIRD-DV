
class bird_seq_drop_len0 extends bird_seq_base;
    function new(); super.new("drop_len0"); endfunction
    task body(bird_env env);
        bird_fragment f;
        f = env.gen().make_remote('{8'h11,8'h22,8'h33}, 1, 1, 8'hA0, 8'hA1, 1);
        f.cfg[15:8] = 8'd0;
        env.drive_fragment(f); env.settle();
    endtask
endclass
