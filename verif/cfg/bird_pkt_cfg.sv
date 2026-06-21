





class bird_pkt_cfg;
    bit  strict       = 1'b0;
    int  reset_cycles = 3;
    int  settle       = 20;
    bit  enable_cov   = 1'b1;

    function new();
    endfunction

    function void summary(string who);
        $display("[CFG][%0s] strict=%0b reset_cycles=%0d settle=%0d enable_cov=%0b",
                 who, strict, reset_cycles, settle, enable_cov);
    endfunction
endclass
