#!/bin/bash
set -e

run_one () {
  top=$1
  flist=$2
  tag=$3

  echo "===================================="
  echo "Running $top"
  echo "===================================="

  vcs -sverilog -full64 -debug_access+all \
    -cm line+cond+tgl+fsm+branch+assert \
    -cm_dir cov_${tag}.vdb \
    -f $flist \
    -top $top \
    -l compile_${tag}.log

  ./simv \
    -cm line+cond+tgl+fsm+branch+assert \
    -cm_dir cov_${tag}.vdb \
    -l run_${tag}.log
}

run_one bird_m3_remote_tb          flist_m3_remote.f   m3_remote
run_one bird_m3_remote_ooo_tb      flist_m3_ooo.f      m3_ooo
run_one bird_m3_remote_missing_tb  flist_m3_missing.f  m3_missing
run_one bird_m3_remote_seqmix_tb   flist_m3_seqmix.f   m3_seqmix
run_one bird_m3_remote_newfrag1_tb flist_m3_newfrag1.f m3_newfrag1

urg -dir cov_m3_remote.vdb cov_m3_ooo.vdb cov_m3_missing.vdb cov_m3_seqmix.vdb cov_m3_newfrag1.vdb \
    -dbname m3_remote_merged.vdb \
    -report m3_remote_cov_report

echo "DONE."
echo "Open report:"
echo "m3_remote_cov_report/dashboard.html"
