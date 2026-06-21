
class bird_seq_remote_invalid extends bird_seq_base;
    function new(); super.new("remote_invalid"); endfunction
    task body(bird_env env);
        bird_fragment f;
        f = env.gen().make_remote('{8'hEE,8'hFF}, 1, 1, 8'h00, 8'h00, 0);
        f.cfg[7] = 1'b1;
        env.drive_fragment(f); env.settle();
    endtask
endclass
