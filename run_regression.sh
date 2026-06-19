set -e
CM="line+cond+tgl+fsm+branch"

echo "==== compiling bird_regression_tb ===="
vcs -full64 -sverilog -debug_access+all -kdb -cm $CM -cm_dir cov_reg.vdb \
    -f flist_bird_regression.f -top bird_regression_tb -l compile_reg.log

echo "==== running ===="
./simv -cm $CM -cm_dir cov_reg.vdb -l run_reg.log

echo "==== generating coverage report ===="
urg -dir cov_reg.vdb -report bird_cov_report

echo ""
echo "DONE."
echo "Coverage report : bird_cov_report/dashboard.html"
echo "Scoreboard / coverage summary:"
grep -E "\[SB\]|\[M4_COV\]|\[M3_COV\]|RESULT|coverage =" run_reg.log || true
