//`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "pc_reg.v"
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



pc_reg  dut(.clk(clk),
            .rst(rst_n),
            .jump_flag_i(input_if.load),    // 跳转标志
            .jump_addr_i(input_if.data),   // 跳转地址32
            .hold_flag_i(input_if.hold), // 流水线暂停标志 3
            .jtag_reset_flag_i(1'b0),           // 复位标志
            .pc_o(output_if.data)           // PC指针

    );
covergroup cov_counter @(posedge clk);
    addr : coverpoint input_if.data {
      bins all    = {32'b0,32'hffff_ffff};
      //bins high   = {13'b1_0000_0000_0000,13'b1_1111_1111_1111};
    }
    load : coverpoint  input_if.load {
      bins even  = {0};
      bins odd   = {1};
    }
    hold :coverpoint input_if.hold{
      bins not_hold = {3'b0};
      bins hold = {3'b001,3'b111};
    }
    rst  : coverpoint rst_n{
      bins one ={1};
      bins zero = {0};
    }
  endgroup
cov_counter cov_count = new();
initial begin
   clk = 0;
   forever begin
      #10 clk = ~clk;
   end
end
assign output_if.flag = input_if.flag;//tr 标志位
initial begin
   rst_n = 1'b0;
   #30 rst_n = 1'b1;
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
