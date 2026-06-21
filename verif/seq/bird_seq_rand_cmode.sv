



class bird_seq_rand_cmode extends bird_seq_base;
    function new(); super.new("rand_cmode"); endfunction
    task body(bird_env env);
        bird_fragment f;
        int sizes[] = '{14, 16, 2};
        foreach (sizes[i]) begin
            f = new();
            f.mode = bird_fragment::M_VALID;
            f.c_npayload.constraint_mode(0);
            if (!f.randomize() with {
                    traffic   == bird_fragment::LOCAL;
                    seq_num   == 1;
                    n_payload == sizes[i];
                })
                $fatal(1, "[rand_cmode] randomize failed");
            env.drive_fragment(f); env.settle();
        end
    endtask
endclass
