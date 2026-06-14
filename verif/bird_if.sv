`timescale 1ns/1ps

interface bird_if(input logic clk);
    logic        rst_n;

    logic        in_vld;
    logic        in_rdy;
    logic [7:0]  data_in;
    logic [31:0] cfg;

    logic        local_vld;
    logic        local_rdy;
    logic [7:0]  data_local;

    logic        remote_vld;
    logic        remote_rdy;
    logic [31:0] data_remote;

    logic [15:0] drop_cnt;

    clocking cb_drv @(posedge clk);
        default input #1step output #0;
        output rst_n, in_vld, data_in, cfg, local_rdy, remote_rdy;
        input  in_rdy, local_vld, data_local, remote_vld, data_remote, drop_cnt;
    endclocking

    clocking cb_mon @(posedge clk);
        default input #1step output #0;
        input rst_n, in_vld, in_rdy, data_in, cfg;
        input local_vld, local_rdy, data_local;
        input remote_vld, remote_rdy, data_remote;
        input drop_cnt;
    endclocking

    modport dut_mp (
        input  clk,
        input  rst_n,
        input  in_vld,
        output in_rdy,
        input  data_in,
        input  cfg,
        output local_vld,
        input  local_rdy,
        output data_local,
        output remote_vld,
        input  remote_rdy,
        output data_remote,
        output drop_cnt
    );

    modport tb_drv_mp (
        clocking cb_drv,
        input clk
    );

    modport tb_mon_mp (
        clocking cb_mon,
        input clk
    );

endinterface

