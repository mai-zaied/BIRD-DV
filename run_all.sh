#!/bin/bash
# ============================================================
# BIRD - full-team regression + merged coverage report
# Compiles and runs every member's testbench in turn (each is
# its own simv), collecting code+functional coverage into a
# per-test .vdb, then merges them into one URG report.
# ============================================================
set -e

CM="line+cond+tgl+fsm+branch"
VCS="vcs -full64 -sverilog -debug_access+all -kdb -cm $CM"

run_one () {
  top=$1; flist=$2; tag=$3
  echo "==================================================="
  echo " RUN: $top   ($flist)"
  echo "==================================================="
  $VCS -cm_dir cov_${tag}.vdb -f $flist -top $top -l compile_${tag}.log
  ./simv -cm $CM -cm_dir cov_${tag}.vdb -l run_${tag}.log
  echo "---- scoreboard / checker summary ($tag) ----"
  grep -E "\[SB\]|\[LOCAL_CHK\]|\[DROP_CHK\]|\[M3|\[M4|RESULT|coverage =" run_${tag}.log || true
}

# DUT-connected tests (these accumulate bird.sv code coverage)
run_one bird_m2_local_tb          flist_bird_m2.f      m2_local
run_one bird_m3_remote_tb         flist_m3_remote.f    m3_remote
run_one bird_m3_remote_ooo_tb     flist_m3_ooo.f       m3_ooo
run_one bird_m3_remote_missing_tb flist_m3_missing.f   m3_missing
run_one bird_m3_remote_seqmix_tb  flist_m3_seqmix.f    m3_seqmix
run_one bird_m3_remote_newfrag1_tb flist_m3_newfrag1.f m3_newfrag1
run_one bird_m4_top_tb            flist_bird_m4.f      m4_top


echo ""
echo "DONE."


