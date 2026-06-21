







class bird_seq_wrap extends bird_seq_base;
    function new(); super.new("drop_cnt_wrap"); endfunction


    task automatic one_drop(bird_env env);
        bird_fragment f;
        f = env.gen().make_remote('{8'h11, 8'h22}, 1, 1, 8'h00, 8'h01, 0);
        f.cfg[7] = 1'b1;
        env.drive_fragment(f);
    endtask

    task body(bird_env env);
        int target = 65535;
        for (int k = 0; k < target; k++) one_drop(env);
        env.settle(3);
        $display("[WRAP] drop_cnt after %0d drops = %0d", target, env.peek_drop_cnt());

        one_drop(env); env.settle(3);
        $display("[WRAP] drop_cnt after %0d drops = %0d  (expect 0: wrapped over 2^16)",
                 target + 1, env.peek_drop_cnt());

        one_drop(env); env.settle(3);
        $display("[WRAP] drop_cnt after %0d drops = %0d  (expect 1: counting resumes)",
                 target + 2, env.peek_drop_cnt());
    endtask
endclass
