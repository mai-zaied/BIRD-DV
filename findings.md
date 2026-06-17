# BIRD - Spec vs DUT Findings (Member 3, Remote Path)

This document lists where the provided DUT (design.sv / bird.sv) deviates
from the functional specification. All deviations were observed in simulation
with Synopsys VCS.

---

## Finding 1: PAYLOAD_LEN interpretation

- Spec (Section 5): PAYLOAD_LEN is the payload length only (1-255 bytes);
  the CRC16 is transferred separately after the payload.
- DUT: treats PAYLOAD_LEN as the TOTAL fragment length on the wire,
  including the 2 CRC bytes. The real captured payload is PAYLOAD_LEN - 2.
- Impact: stimulus must drive PAYLOAD_LEN = payload + 2, not payload only.

## Finding 2: FSM hangs for PAYLOAD_LEN < 4

- Spec: PAYLOAD_LEN range is 1-255.
- DUT: the receive FSM only transitions to the CRC state when an internal
  counter reaches a fixed value, so fragments with PAYLOAD_LEN < 4 never
  complete and the FSM hangs (never returns to idle).
- Impact: every fragment must use PAYLOAD_LEN >= 4.

## Finding 3: Reassembly indexed by SEQ_NUM, not FRAG_NUM

- Spec (Section 7.1, 7.2): fragments of one packet share one SEQ_NUM;
  FRAG_NUM is the fragment position, and reassembly is ordered by FRAG_NUM.
- DUT: stores and orders fragments indexed by SEQ_NUM, not FRAG_NUM.
  To form an N-fragment packet, fragments must use SEQ_NUM = 1..N with a
  fixed FRAG_NUM, which is the reverse of the spec.

## Finding 4: Missing fragment does not cause a drop

- Spec (Section 8.1): "A required fragment for a packet is missing" -> packet dropped.
- DUT: when a fragment is missing, the DUT keeps waiting for it and does NOT
  increment drop_cnt. The packet stays pending indefinitely.
- Test: bird_m3_remote_missing_tb.sv (sent positions 1 and 3, position 2 missing)
  -> 0 remote words, drop_cnt = 0.

## Finding 5: Mismatched SEQ_NUM increments drop_cnt by 2

- Spec (Section 8.2): "The counter increments once per packet, regardless
  of the number of fragments received."
- DUT: when a mismatched SEQ_NUM arrives during accumulation, the DUT drops
  the packet (correct in principle) but increments drop_cnt by 2 instead of 1.
- Test: bird_m3_remote_seqmix_tb.sv -> 0 remote words, drop_cnt = 2.

---
