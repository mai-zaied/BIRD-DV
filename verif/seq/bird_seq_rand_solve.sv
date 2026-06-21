




class bird_seq_rand_solve extends bird_seq_base;
    int num;
    function new(int num = 40); super.new("rand_solve"); this.num = num; endfunction
    task body(bird_env env);
        bird_fragment f;
        int short_cnt = 0;
        for (int k = 0; k < num; k++) begin
            f = new();
            f.mode = bird_fragment::M_VALID;
            if (!f.randomize() with { traffic == bird_fragment::LOCAL; seq_num == 1; })
                $fatal(1, "[rand_solve] randomize failed");
            if (f.n_payload == 2) short_cnt++;
            env.drive_fragment(f); env.settle();
        end
        $display("[rand_solve] solve pick_short before n_payload -> %0d/%0d items had minimum payload",
                 short_cnt, num);
    endtask
endclass
