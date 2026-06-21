







class bird_test_harness;
    static const int NUM_TESTS = 23;

    static task automatic run_one(int id,
                                  virtual bird_if.tb_drv_mp drv_mp,
                                  virtual bird_if.tb_mon_mp mon_mp);
        case (id)
            1 : begin bird_test_01_local_valid         t; t=new(drv_mp,mon_mp); t.run(); end
            2 : begin bird_test_02_local_invalid       t; t=new(drv_mp,mon_mp); t.run(); end
            3 : begin bird_test_03_remote_invalid      t; t=new(drv_mp,mon_mp); t.run(); end
            4 : begin bird_test_04_remote_inorder      t; t=new(drv_mp,mon_mp); t.run(); end
            5 : begin bird_test_05_remote_ooo          t; t=new(drv_mp,mon_mp); t.run(); end
            6 : begin bird_test_06_remote_missing      t; t=new(drv_mp,mon_mp); t.run(); end
            7 : begin bird_test_07_remote_seqmix       t; t=new(drv_mp,mon_mp); t.run(); end
            8 : begin bird_test_08_remote_newfrag1     t; t=new(drv_mp,mon_mp); t.run(); end
            9 : begin bird_test_09_remote_spec_inorder t; t=new(drv_mp,mon_mp); t.run(); end
            10: begin bird_test_10_drop_seq0           t; t=new(drv_mp,mon_mp); t.run(); end
            11: begin bird_test_11_drop_frag0          t; t=new(drv_mp,mon_mp); t.run(); end
            12: begin bird_test_12_drop_len0           t; t=new(drv_mp,mon_mp); t.run(); end
            13: begin bird_test_13_backpressure        t; t=new(drv_mp,mon_mp); t.run(); end
            14: begin bird_test_14_remote_cover        t; t=new(drv_mp,mon_mp); t.run(); end
            15: begin bird_test_15_rand_valid          t; t=new(drv_mp,mon_mp); t.run(); end
            16: begin bird_test_16_rand_weighted       t; t=new(drv_mp,mon_mp); t.run(); end
            17: begin bird_test_17_rand_inline         t; t=new(drv_mp,mon_mp); t.run(); end
            18: begin bird_test_18_rand_cmode          t; t=new(drv_mp,mon_mp); t.run(); end
            19: begin bird_test_19_rand_rmode          t; t=new(drv_mp,mon_mp); t.run(); end
            20: begin bird_test_20_rand_solve          t; t=new(drv_mp,mon_mp); t.run(); end
            21: begin bird_test_21_rand_cyclic         t; t=new(drv_mp,mon_mp); t.run(); end
            22: begin bird_test_22_rand_invalid        t; t=new(drv_mp,mon_mp); t.run(); end
            23: begin bird_test_23_drop_wrap           t; t=new(drv_mp,mon_mp); t.run(); end

            default: $display("[HARNESS] unknown TEST_ID=%0d (valid 1..%0d)", id, NUM_TESTS);
        endcase
    endtask

    static task automatic run(int test_id,
                              virtual bird_if.tb_drv_mp drv_mp,
                              virtual bird_if.tb_mon_mp mon_mp);
        if (test_id == 0) begin
            $display("[HARNESS] TEST_ID=0 -> running all %0d tests in order", NUM_TESTS);
            for (int i = 1; i <= NUM_TESTS; i++) run_one(i, drv_mp, mon_mp);
        end else begin
            run_one(test_id, drv_mp, mon_mp);
        end
    endtask
endclass
