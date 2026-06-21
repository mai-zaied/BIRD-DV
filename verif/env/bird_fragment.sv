















class bird_fragment;

    typedef enum bit  {LOCAL = 1'b0, REMOTE = 1'b1} traffic_e;
    typedef enum int  {M_VALID, M_INV_RESERVED, M_INV_SEQ0,
                       M_INV_FRAG0, M_INV_LEN0}      gen_mode_e;


    bit [31:0]     cfg;
    byte unsigned  bytes[$];


    rand traffic_e     traffic;
    rand bit [4:0]     seq_num;
    rand bit [4:0]     frag_num;
    rand int unsigned  n_payload;
    rand byte unsigned payload[];
    rand byte unsigned crc0, crc1;
    rand bit           pick_short;


    gen_mode_e mode = M_VALID;


    constraint c_npayload  { n_payload inside {[2:16]}; }
    constraint c_plsize    { payload.size() == n_payload; }


    constraint c_seq_rng   { (mode != M_INV_SEQ0)  -> seq_num  inside {[1:31]}; }
    constraint c_frag_rng  { (mode != M_INV_FRAG0) -> frag_num inside {[1:31]}; }

    constraint c_seq0      { (mode == M_INV_SEQ0)  -> seq_num  == 0; }
    constraint c_frag0     { (mode == M_INV_FRAG0) -> frag_num == 0; }

    constraint c_local_fr  { (mode == M_VALID && traffic == LOCAL) -> frag_num == 1; }



    constraint c_solve     { solve pick_short before n_payload;
                             (mode == M_VALID && pick_short) -> n_payload == 2; }

    function new(bit [31:0] cfg_word = '0);
        cfg = cfg_word;
    endfunction


    function void append_byte(byte unsigned b); bytes.push_back(b); endfunction
    function int  payload_len();      return cfg[15:8]; endfunction
    function int  total_len_bytes();  return payload_len(); endfunction


    function void post_randomize();
        int len;
        bytes.delete();
        foreach (payload[i]) bytes.push_back(payload[i]);
        bytes.push_back(crc0);
        bytes.push_back(crc1);

        len  = (mode == M_INV_LEN0) ? 0 : (n_payload + 2);
        cfg            = '0;
        cfg[0]         = (traffic == REMOTE);
        cfg[15:8]      = len[7:0];
        cfg[20:16]     = frag_num;
        cfg[28:24]     = seq_num;
        if (mode == M_INV_RESERVED) cfg[7] = 1'b1;
    endfunction

    function string convert2str();
        return $sformatf("%s seq=%0d frag=%0d len=%0d npl=%0d mode=%s cfg=%08h",
            traffic.name(), seq_num, frag_num, cfg[15:8], n_payload, mode.name(), cfg);
    endfunction
endclass
