
class bird_seq_local_valid extends bird_seq_base;
    function new(); super.new("local_valid"); endfunction
    task body(bird_env env);
        byte unsigned a[];
        a = '{8'h11,8'h22,8'h33,8'h44};
        env.drive_fragment(env.gen().make_local(1,1,a,8'hAB,8'hCD)); env.settle();
        a = '{8'hDE,8'hAD,8'hBE,8'hEF,8'h01};
        env.drive_fragment(env.gen().make_local(1,1,a,8'h12,8'h34)); env.settle();
        a = '{8'h99,8'h88,8'h77,8'h66,8'h55,8'h44};
        env.drive_fragment(env.gen().make_local(1,1,a,8'h56,8'h78)); env.settle();
    endtask
endclass
