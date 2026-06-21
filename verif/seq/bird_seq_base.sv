






virtual class bird_seq_base;
    string name;
    function new(string name = "seq");
        this.name = name;
    endfunction
    pure virtual task body(bird_env env);
endclass
