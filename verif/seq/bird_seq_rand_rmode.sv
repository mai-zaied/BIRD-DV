




class bird_seq_rand_rmode extends bird_seq_base;
    int num;
    function new(int num = 8); super.new("rand_rmode"); this.num = num; endfunction
    task body(bird_env env);
        bird_fragment f;
        for (int k = 0; k < num; k++) begin
            f = new();
            f.mode = bird_fragment::M_VALID;
            f.n_payload.rand_mode(0);
            f.n_payload = 6;
            if (!f.randomize() with { traffic == bird_fragment::LOCAL; seq_num == 1; })
                $fatal(1, "[rand_rmode] randomize failed");
            env.drive_fragment(f); env.settle();
        end
    endtask
endclass
