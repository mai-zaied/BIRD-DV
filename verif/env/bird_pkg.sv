




`timescale 1ns/1ps

package bird_tb_pkg;


    `include "bird_pkt_cfg.sv"


    `include "bird_fragment.sv"


    `include "bird_drop_checker.sv"
    `include "bird_local_monitor.sv"
    `include "bird_local_checker.sv"
    `include "bird_remote_monitor.sv"


    `include "bird_remote_coverage.sv"
    `include "bird_m4_coverage.sv"


    `include "bird_generator.sv"
    `include "bird_driver.sv"
    `include "bird_monitor.sv"


    `include "bird_checker.sv"


    `include "bird_agent.sv"
    `include "bird_env.sv"


    `include "bird_seq_base.sv"
    `include "bird_seq_local_valid.sv"
    `include "bird_seq_local_invalid.sv"
    `include "bird_seq_remote_invalid.sv"
    `include "bird_seq_remote_inorder.sv"
    `include "bird_seq_remote_ooo.sv"
    `include "bird_seq_remote_missing.sv"
    `include "bird_seq_remote_seqmix.sv"
    `include "bird_seq_remote_newfrag1.sv"
    `include "bird_seq_remote_spec_inorder.sv"
    `include "bird_seq_drop_seq0.sv"
    `include "bird_seq_drop_frag0.sv"
    `include "bird_seq_drop_len0.sv"
    `include "bird_seq_backpressure.sv"
    `include "bird_seq_remote_cover.sv"
    `include "bird_seq_rand_valid.sv"
    `include "bird_seq_rand_weighted.sv"
    `include "bird_seq_rand_inline.sv"
    `include "bird_seq_rand_cmode.sv"
    `include "bird_seq_rand_rmode.sv"
    `include "bird_seq_rand_solve.sv"
    `include "bird_seq_rand_cyclic.sv"
    `include "bird_seq_rand_invalid.sv"
    `include "bird_seq_wrap.sv"


    `include "bird_test_base.sv"
    `include "bird_test_01_local_valid.sv"
    `include "bird_test_02_local_invalid.sv"
    `include "bird_test_03_remote_invalid.sv"
    `include "bird_test_04_remote_inorder.sv"
    `include "bird_test_05_remote_ooo.sv"
    `include "bird_test_06_remote_missing.sv"
    `include "bird_test_07_remote_seqmix.sv"
    `include "bird_test_08_remote_newfrag1.sv"
    `include "bird_test_09_remote_spec_inorder.sv"
    `include "bird_test_10_drop_seq0.sv"
    `include "bird_test_11_drop_frag0.sv"
    `include "bird_test_12_drop_len0.sv"
    `include "bird_test_13_backpressure.sv"
    `include "bird_test_14_remote_cover.sv"
    `include "bird_test_15_rand_valid.sv"
    `include "bird_test_16_rand_weighted.sv"
    `include "bird_test_17_rand_inline.sv"
    `include "bird_test_18_rand_cmode.sv"
    `include "bird_test_19_rand_rmode.sv"
    `include "bird_test_20_rand_solve.sv"
    `include "bird_test_21_rand_cyclic.sv"
    `include "bird_test_22_rand_invalid.sv"
    `include "bird_test_23_drop_wrap.sv"

    `include "bird_test_harness.sv"

endpackage
