//`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "accum.v"
`include "accum_if.sv"
`include "accum_transaction.sv"
`include "accum_sqr.sv"
`include "accum_driver.sv"
`include "accum_monitor.sv"
`include "accum_agent.sv"
`include "accum_predictor.sv"
`include "accum_scoreboard.sv"
`include "accum_seq.sv"
`include "accum_env.sv"
`include "base_test.sv"
`include "my_case1.sv"

module top_tb;

reg clk;
reg rst;

accum_if input_if(clk, rst);
accum_if output_if(clk,rst);


accum acc(.accum(output_if.data),
      .data(input_if.data),
      .ena(input_if.valid),
      .clk1(clk),
      .rst(rst));

initial begin
   clk = 0;
   forever begin
      #100 clk = ~clk;
   end
end

initial begin
   rst = 1'b1;
   #100;
   rst = 1'b0;
end

initial begin
   $display("my_casse1 开始运行");
   run_test("my_case1");
   //run_test("my_env");
end

initial begin
   $display("config vif 开始配置");
   uvm_config_db#(virtual accum_if)::set(null, "uvm_test_top.env.acc_agt.acc_drv", "acc_input_if", input_if);
   uvm_config_db#(virtual accum_if)::set(null, "uvm_test_top.env.acc_agt.acc_mon", "acc_input_if", input_if);
   uvm_config_db#(virtual accum_if)::set(null, "uvm_test_top.env.acc_agt.acc_mon", "acc_output_if", output_if);
end

endmodule
