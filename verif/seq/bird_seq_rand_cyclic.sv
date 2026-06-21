




class bird_id_rc;
    randc bit [4:0] id;
    constraint c_range { id inside {[1:8]}; }
endclass

class bird_seq_rand_cyclic extends bird_seq_base;
    function new(); super.new("rand_cyclic"); endfunction
    task body(bird_env env);
        bird_id_rc    rc;
        bird_fragment f;
        int ids[$];
        int idv;
        rc = new();
        for (int k = 0; k < 8; k++) begin
            if (!rc.randomize()) $fatal(1, "[rand_cyclic] randc failed");
            idv = rc.id;
            ids.push_back(idv);
            f = new();
            f.mode = bird_fragment::M_VALID;
            if (!f.randomize() with {
                    traffic == bird_fragment::LOCAL;
                    seq_num == 1;
                    payload.size() >= 1;
                    payload[0] == idv;
                })
                $fatal(1, "[rand_cyclic] randomize failed");
            env.drive_fragment(f); env.settle();
        end
        $display("[rand_cyclic] randc id order (no repeats within the cycle): %p", ids);
    endtask
endclass
