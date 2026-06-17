#!/bin/bash
set -e

add_cov () {
  file=$1
  test=$2
  nfrags=$3
  ooo=$4
  mode=$5
  reason=$6
  fA=$7
  fB=$8

  grep -q "bird_remote_coverage cov" $file || sed -i '/bird_remote_seq/a\    bird_remote_coverage cov;' $file
  grep -q "cov  = new" $file || sed -i '/gen  = new/a\        cov  = new();' $file
  grep -q "cov.sample_fragment" $file || sed -i "/drv.drive_fragment($fA);/a\        cov.sample_fragment($fA);" $file
  grep -q "cov.sample_packet" $file || sed -i "/drv.drive_fragment($fB);/a\        cov.sample_fragment($fB);\n        cov.sample_packet($nfrags, $ooo, $mode, bird_remote_coverage::$reason);" $file
  grep -q "cov.report" $file || sed -i "/\\\$finish/i\        cov.report(\"$test\");" $file
}

add_cov verif/bird_m3_remote_missing_tb.sv bird_m3_remote_missing_tb 3 0 0 DROP_MISSING f1 f3
add_cov verif/bird_m3_remote_seqmix_tb.sv bird_m3_remote_seqmix_tb 2 0 1 DROP_SEQ_MIX fa fb
add_cov verif/bird_m3_remote_newfrag1_tb.sv bird_m3_remote_newfrag1_tb 2 0 1 DROP_NEW_FRAG1 fa fb

for t in missing seqmix newfrag1
do
  case $t in
    missing) top=bird_m3_remote_missing_tb; fl=flist_m3_missing.f ;;
    seqmix) top=bird_m3_remote_seqmix_tb; fl=flist_m3_seqmix.f ;;
    newfrag1) top=bird_m3_remote_newfrag1_tb; fl=flist_m3_newfrag1.f ;;
  esac

  echo "Running $top"
  vcs -sverilog -full64 -debug_access+all -f $fl -top $top -l compile_cov_${t}.log
  ./simv -l run_cov_${t}.log
  tail -20 run_cov_${t}.log
done
