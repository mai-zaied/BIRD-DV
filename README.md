# BIRD — Design Verification 
Verification environment for the **BIRD** (Birzeit Integrated Router Design)

## Build and run (Synopsys VCS / Verdi)
## Build and run (Synopsys VCS / Verdi)

```bash
# 1. compile with coverage instrumentation + KDB (for Verdi)
vcs -full64 -sverilog -debug_access+all -kdb \
    -cm line+cond+tgl+fsm+branch \
    -cm_dir cov.vdb \
    -timescale=1ns/1ps -f vcs.f -o simv

# 2. run all 22 tests into one coverage database (clean log via grep)
./simv +TEST_ID=0 -cm line+cond+tgl+fsm+branch -cm_dir cov.vdb \
    | grep -E '\[TEST\]|\[SB\]|\[M4_COV\]|\[M3_COV\]|\[BP\]|RESULT' | tee run_clean.log

# 3. build the HTML coverage report
urg -dir cov.vdb -report bird_cov_report
```

Open the report:

```bash
firefox bird_cov_report/dashboard.html &
```

To inspect coverage interactively in Verdi:

```bash
verdi -cov -covdir cov.vdb &
```
## Git history

All earlier commits are preserved on the
[`old_main_backup`](https://github.com/mai-zaied/BIRD-DV/tree/old_main_backup) branch.


