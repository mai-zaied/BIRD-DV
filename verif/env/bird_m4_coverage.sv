class bird_m4_coverage;

    typedef enum int {
        TRAFFIC_LOCAL  = 0,
        TRAFFIC_REMOTE = 1
    } traffic_e;

    typedef enum int {
        OUT_FORWARDED = 0,
        OUT_EMITTED   = 1,
        OUT_DROPPED   = 2
    } outcome_e;

    traffic_e tt;
    outcome_e oc;

    covergroup cg_traffic_outcome;



        option.per_instance = 0;

        cp_traffic : coverpoint tt {
            bins lcl = {TRAFFIC_LOCAL};
            bins rmt = {TRAFFIC_REMOTE};
        }

        cp_outcome : coverpoint oc {
            bins forwarded = {OUT_FORWARDED};
            bins emitted   = {OUT_EMITTED};
            bins dropped   = {OUT_DROPPED};
        }

        x_traffic_outcome : cross cp_traffic, cp_outcome {
            ignore_bins local_emit =
                binsof(cp_traffic.lcl) && binsof(cp_outcome.emitted);
            ignore_bins remote_fwd =
                binsof(cp_traffic.rmt) && binsof(cp_outcome.forwarded);
        }
    endgroup

    function new();
        cg_traffic_outcome = new();
    endfunction

    function void sample_outcome(traffic_e t, outcome_e o);
        tt = t;
        oc = o;
        cg_traffic_outcome.sample();
    endfunction

    function real get_cov();
        return cg_traffic_outcome.get_coverage();
    endfunction

    function void report(string test_name);
        $display("============================================================");
        $display("[M4_COV] Test: %s", test_name);
        $display("[M4_COV] traffic-type x outcome coverage = %0.2f%%", get_cov());
        $display("============================================================");
    endfunction
endclass
