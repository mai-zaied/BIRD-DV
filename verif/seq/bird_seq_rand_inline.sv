


class bird_seq_rand_inline extends bird_seq_base;
    int num;
    function new(int num = 6); super.new("rand_inline"); this.num = num; endfunction
    task body(bird_env env);
        bird_fragment f;
        for (int k = 0; k < num; k++) begin
            f = new();
            f.mode = bird_fragment::M_VALID;
            if (!f.randomize() with {
                    traffic  == bird_fragment::REMOTE;
                    seq_num  == 7;
                    frag_num inside {[1:3]};
                    n_payload == 3;
                })
                $fatal(1, "[rand_inline] randomize failed");
            env.drive_fragment(f); env.settle();
        end
    endtask
endclass
