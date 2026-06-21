




class bird_seq_rand_weighted extends bird_seq_base;
    int num;
    function new(int num = 30); super.new("rand_weighted"); this.num = num; endfunction
    task body(bird_env env);
        bird_fragment f;
        for (int k = 0; k < num; k++) begin
            f = new();
            f.mode = bird_fragment::M_VALID;
            if (!f.randomize() with {
                    traffic == bird_fragment::LOCAL;
                    seq_num == 1;
                    n_payload dist { [2:4] := 70, [5:16] := 30 };
                })
                $fatal(1, "[rand_weighted] randomize failed");
            env.drive_fragment(f); env.settle();
        end
    endtask
endclass
