




class bird_seq_rand_invalid extends bird_seq_base;
    int num;
    function new(int num = 18); super.new("rand_invalid"); this.num = num; endfunction
    task body(bird_env env);
        bird_fragment f;
        bird_fragment::gen_mode_e modes[3];
        modes[0] = bird_fragment::M_INV_RESERVED;
        modes[1] = bird_fragment::M_INV_SEQ0;
        modes[2] = bird_fragment::M_INV_FRAG0;
        for (int k = 0; k < num; k++) begin
            f = new();
            f.mode = modes[$urandom_range(0,2)];
            if (!f.randomize())
                $fatal(1, "[rand_invalid] randomize failed");
            env.drive_fragment(f); env.settle();
        end
    endtask
endclass
