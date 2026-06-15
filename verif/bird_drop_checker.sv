class bird_drop_checker;
    virtual bird_if.tb_mon_mp vif;
    int unsigned expected_drops;
    int unsigned errors;

    function new(virtual bird_if.tb_mon_mp vif);
        this.vif            = vif;
        this.expected_drops = 0;
        this.errors         = 0;
    endfunction

    function void expect_drop(); expected_drops++; endfunction
    function void clear();       expected_drops = 0; endfunction

    function void check_now();
        bit [15:0] exp16;
        exp16 = expected_drops[15:0];
        if (vif.cb_mon.drop_cnt !== exp16) begin
            errors++;
            $error("[DROP_CHK] mismatch: dut drop_cnt=%0d expected=%0d", vif.cb_mon.drop_cnt, exp16);
        end
        else begin
            $display("[DROP_CHK] OK drop_cnt=%0d matches expected", vif.cb_mon.drop_cnt);
        end
    endfunction

    function void report();
        $display("[DROP_CHK] SUMMARY: expected %0d drops total, %0d errors", expected_drops, errors);
    endfunction
endclass
