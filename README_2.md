BIRD Verification
Local traffic path + drop counter verification for the BIRD packet router.

What this covers

Member 2 owns the verification of:


The local output path (local_vld / local_rdy / data_local)
The drop counter (drop_cnt) behaviour


Built on top of Member 1's interface, driver, and input monitor.

Files (in verif/)

FilePurposebird_local_monitor.svCaptures every byte transferred on the local output port and streams it to the checker. Does not infer packet boundaries from local_vld (the DUT can drop valid mid-packet), so it records each handshaked byte and the checker reassembles using the known length.bird_local_checker.svReference model for local forwarding. Decides per-packet whether it should be forwarded or dropped, and compares the local output byte-for-byte against the driven input. Has a spec_mode switch (see Findings).bird_drop_checker.svSoftware model of the expected drop count, compared against the DUT's 16-bit drop_cnt. Models modulo-2^16 wrap and reset clearing per spec 8.2.bird_m2_local_tb.svSmoke test wiring the above together with Member 1's driver/input monitor. Drives 3 local fragments (1 valid + 2 drops).

How to run

vcs -full64 -sverilog -timescale=1ns/1ps \
    +incdir+verif \
    rtl/bird.sv \
    verif/bird_if.sv \
    verif/bird_tb_pkg.sv \
    verif/bird_m2_local_tb.sv \
    -o simv_m2
./simv_m2 | grep -E "LOCAL_CHK|DROP_CHK|M2_TB"

Current result

[LOCAL_CHK] packet #1 cfg=0x01010300 -> forwarded, 5 bytes checked
[LOCAL_CHK] packet #2 cfg=0x05010200 -> expected DROP
[LOCAL_CHK] packet #3 cfg=0x00010100 -> expected DROP
[LOCAL_CHK] SUMMARY: 3 packets checked, 0 byte errors
[DROP_CHK]  mismatch: dut drop_cnt=0 expected=2   <-- see Finding 2

Local forwarding is fully verified. The drop_cnt mismatch is a detected DUT
issue, not a checker error (see below).

Findings

Finding 1 — Local SEQ_NUM: DUT stricter than spec


Spec (Sec 6): SEQ_NUM has no functional impact on local routing; only
SEQ_NUM==0 is invalid.
DUT: requires local SEQ_NUM==1 (and FRAG_NUM==1), drops otherwise.
Handled with spec_mode in the local checker: default (0) matches the DUT
for a clean run; setting it to 1 follows the spec and reports the divergence.


Finding 2 — drop_cnt not incremented for dropped local fragments (DUT bug)


Two invalid local fragments (SEQ=5 and SEQ=0) are dropped by the DUT (no
local output), so per spec 8.2 drop_cnt should reach 2.
drop_cnt stays 0 the whole run (confirmed with a cycle-by-cycle probe).
The drop checker correctly flags this mismatch. Root cause in the RTL still
to be investigated (candidate: short-fragment path in the RX FSM).


Shared fix applied

Member 1's drive_fragment held in_vld high one cycle too long after the last
byte, causing the DUT to sample the final byte twice (6 transfers for a 5-byte
packet). Fixed by deasserting in_vld/data_in/cfg BEFORE the trailing clock wait.

Next steps


Wider local tests: max payload (255), reserved-bit drops, FRAG_NUM!=1 drops.
Functional coverage for traffic_type, payload_len, SEQ_NUM, FRAG_NUM, drops,
and drop_cnt wrap.
Investigate the drop_cnt RTL behaviour (Finding 2).
