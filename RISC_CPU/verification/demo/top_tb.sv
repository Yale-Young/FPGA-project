//`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "counter.v"
`include "my_if.sv"
`include "my_transaction.sv"
`include "my_sequencer.sv"
`include "my_driver.sv"
`include "my_monitor.sv"
`include "my_agent.sv"
`include "my_model.sv"
`include "my_scoreboard.sv"
`include "my_sequence.sv"
`include "my_env.sv"
`include "base_test.sv"
`include "my_case0.sv"
`include "my_case1.sv"

module top_tb;

reg clk;
reg rst_n;

my_if input_if(clk, rst_n);
my_if output_if(clk, rst_n);

counter dut(.pc_addr(output_if.data),
            .ir_addr(input_if.data),
            .load(input_if.load),
            .clock(clk),
            .rst(rst_n));

covergroup cov_counter @(posedge clk);
    addr : coverpoint input_if.data {
      bins all    = {13'b0,13'b1_1111_1111_1111};
      //bins high   = {13'b1_0000_0000_0000,13'b1_1111_1111_1111};
    }
    load : coverpoint  input_if.load {
      bins even  = {0};
      bins odd   = {1};
    }
    rst  : coverpoint rst_n{
      bins one ={1};
      bins zero = {0};
    }
  endgroup
cov cc = new();
initial begin
   clk = 0;
   forever begin
      #10 clk = ~clk;
   end
end
assign output_if.flag = input_if.flag;//tr 标志位
initial begin
   rst_n = 1'b1;
   #30 rst_n = 1'b0;
end

initial begin
   run_test("my_case1");
   //run_test("my_env");
end

initial begin
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.drv", "vif", input_if);
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.mon", "vif", input_if);
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.o_agt.mon", "vif", output_if);
end

endmodule
