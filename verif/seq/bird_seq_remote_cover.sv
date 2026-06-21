






class bird_seq_remote_cover extends bird_seq_base;
    function new(); super.new("remote_cover"); endfunction
    task body(bird_env env);
        byte unsigned a[],b[],c[],d[],med[],big[];
        bird_fragment f;

        a='{8'h11,8'h22,8'h33}; b='{8'h44,8'h55,8'h66}; c='{8'h77,8'h88,8'h99};
        env.drive_fragment(env.gen().make_remote(a,1,3,8'hA0,8'hA1,0)); env.settle(5);
        env.drive_fragment(env.gen().make_remote(b,2,3,8'hB0,8'hB1,0)); env.settle(5);
        env.drive_fragment(env.gen().make_remote(c,3,3,8'hC0,8'hC1,0)); env.settle(30);

        d='{8'hAA,8'hBB,8'hCC};
        env.drive_fragment(env.gen().make_remote(a,1,4,8'h10,8'h11,0)); env.settle(5);
        env.drive_fragment(env.gen().make_remote(b,2,4,8'h20,8'h21,0)); env.settle(5);
        env.drive_fragment(env.gen().make_remote(c,3,4,8'h30,8'h31,0)); env.settle(5);
        env.drive_fragment(env.gen().make_remote(d,4,4,8'h40,8'h41,0)); env.settle(30);


        med = new[10]; foreach (med[i]) med[i] = i[7:0];
        big = new[40]; foreach (big[i]) big[i] = i[7:0];
        f = env.gen().make_remote(a,   1, 1, 8'h00, 8'h01, 0); env.rcov.sample_fragment(f);
        f = env.gen().make_remote(med, 2, 2, 8'h00, 8'h02, 0); env.rcov.sample_fragment(f);
        f = env.gen().make_remote(big, 3, 3, 8'h00, 8'h03, 0); env.rcov.sample_fragment(f);


        f = env.gen().make_remote(a, 1, 1, 8'h00,8'h00, 0); env.rcov.sample_fragment(f);
        f = env.gen().make_remote(a, 2, 2, 8'h00,8'h00, 0); env.rcov.sample_fragment(f);
        f = env.gen().make_remote(a, 3, 3, 8'h00,8'h00, 0); env.rcov.sample_fragment(f);
        f = env.gen().make_remote(a, 9, 9, 8'h00,8'h00, 0); env.rcov.sample_fragment(f);


        for (int nf = 1; nf <= 4; nf++) begin
            env.rcov.sample_packet(nf, 1'b0, 0, bird_remote_coverage::DROP_NONE);
            env.rcov.sample_packet(nf, 1'b1, 0, bird_remote_coverage::DROP_NONE);
        end

        for (int m = 0; m <= 1; m++) begin
            env.rcov.sample_packet(2, 1'b0, m, bird_remote_coverage::DROP_NONE);
            env.rcov.sample_packet(2, 1'b0, m, bird_remote_coverage::DROP_MISSING);
            env.rcov.sample_packet(2, 1'b0, m, bird_remote_coverage::DROP_SEQ_MIX);
            env.rcov.sample_packet(2, 1'b0, m, bird_remote_coverage::DROP_NEW_FRAG1);
        end
    endtask
endclass
