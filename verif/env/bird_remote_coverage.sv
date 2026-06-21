class bird_remote_coverage;

    typedef enum int {
        DROP_NONE      = 0,
        DROP_MISSING   = 1,
        DROP_SEQ_MIX   = 2,
        DROP_NEW_FRAG1 = 3
    } drop_reason_e;

    int unsigned payload_len;
    int unsigned frag_num;
    int unsigned seq_num;
    int unsigned num_frags;
    bit          out_of_order;
    int unsigned index_mode;
    drop_reason_e drop_reason;

    covergroup remote_cg;
        option.per_instance = 0;

        cp_payload_len : coverpoint payload_len {
            bins len_5 = {5};
            bins len_small = {[4:7]};
            bins len_medium = {[8:31]};
            bins len_large = {[32:255]};
        }

        cp_frag_num : coverpoint frag_num {
            bins frag_1 = {1};
            bins frag_2 = {2};
            bins frag_3 = {3};
            bins frag_4_to_31 = {[4:31]};
        }

        cp_seq_num : coverpoint seq_num {
            bins seq_1 = {1};
            bins seq_2 = {2};
            bins seq_3 = {3};
            bins seq_4_to_31 = {[4:31]};
        }

        cp_num_frags : coverpoint num_frags {
            bins one = {1};
            bins two = {2};
            bins three = {3};
            bins four_to_31 = {[4:31]};
        }

        cp_order : coverpoint out_of_order {
            bins in_order = {0};
            bins out_of_order = {1};
        }

        cp_index_mode : coverpoint index_mode {
            bins dut_mode  = {0};
            bins spec_mode = {1};
        }

        cp_drop_reason : coverpoint drop_reason {
            bins no_drop   = {DROP_NONE};
            bins missing   = {DROP_MISSING};
            bins seq_mix   = {DROP_SEQ_MIX};
            bins new_frag1 = {DROP_NEW_FRAG1};
        }

        cross cp_num_frags, cp_order;
        cross cp_drop_reason, cp_index_mode;

    endgroup

    function new();
        payload_len  = 0;
        frag_num     = 0;
        seq_num      = 0;
        num_frags    = 0;
        out_of_order = 0;
        index_mode   = 0;
        drop_reason  = DROP_NONE;
        remote_cg = new();
    endfunction

    function void sample_fragment(bird_fragment tr);
        payload_len = tr.cfg[15:8];
        frag_num    = tr.cfg[20:16];
        seq_num     = tr.cfg[28:24];
        remote_cg.sample();
    endfunction

    function void sample_packet(
        int unsigned nfrags,
        bit          is_ooo,
        int unsigned mode,
        drop_reason_e reason
    );
        num_frags    = nfrags;
        out_of_order = is_ooo;
        index_mode   = mode;
        drop_reason  = reason;
        remote_cg.sample();
    endfunction

    function real get_cov();
        return remote_cg.get_coverage();
    endfunction

    function void report(string test_name);
        $display("========================================");
        $display("[M3_COV] Test: %s", test_name);
        $display("[M3_COV] Remote functional coverage = %0.2f%%", get_cov());
        $display("========================================");
    endfunction

endclass
