
class bird_seq_local_invalid extends bird_seq_base;
    function new(); super.new("local_invalid"); endfunction
    task body(bird_env env);
        bird_fragment f;
        f = env.gen().make_local(1,1,'{8'hDE,8'hAD},8'h00,8'h00);
        f.cfg[7] = 1'b1;
        env.drive_fragment(f); env.settle();
    endtask
endclass
