// ============================================================
// vcs.f  --  single file list for the BIRD verification project
// Compile from the repo root:
//   vcs -full64 -sverilog -debug_access+all -timescale=1ns/1ps -f vcs.f -o simv
// Run:
//   ./simv                 (TEST_ID=0, all tests)
//   ./simv +TEST_ID=N      (single test, N = 1..22)
// ============================================================

-sverilog
-timescale=1ns/1ps

// include search paths (so the package can `include` from each dir)
+incdir+./verif/if
+incdir+./verif/cfg
+incdir+./verif/env
+incdir+./verif/seq
+incdir+./verif/tests
+incdir+./verif/tb

// design under test
./design/bird.sv

// interface
./verif/if/bird_if.sv

// package (pulls in cfg, env, seq, tests, harness via includes)
./verif/env/bird_pkg.sv

// top testbench
./verif/tb/bird_tb.sv
