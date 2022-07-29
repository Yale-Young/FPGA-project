//`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "regs.v"
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


regs   dut(
          .clk(clk),
          .rst(rst_n),
          .we_i(input_if.ena[1]),
          .waddr_i(input_if.waddr[9:5]),
          .wdata_i(input_if.data[63:32]),
          .jtag_we_i(input_if.ena[0]),
          .jtag_addr_i(input_if.waddr[4:0]),
          .jtag_data_i(input_if.data[31:0]),
          .raddr1_i(input_if.raddr[9:5]),
          .rdata1_o(output_if.data[63:32]),
          .raddr2_i(input_if.raddr[4:0]),
          .rdata2_o(output_if.data[31:0]),
          .jtag_data_o(output_if.jdata)      
    );
covergroup cov_counter @(posedge clk);
    
    ena : coverpoint  input_if.ena {
      bins p1  = {2'b00};
      bins p2   = {2'b01};
      bins p3  = {2'b10};
      bins p4   = {2'b10};
    }
    waddr: coverpoint input_if.waddr{
      bins all = {10'b0,10'b11_1111_1111};
    }
    raddr: coverpoint input_if.raddr{
      bins all = {10'b0,10'b11_1111_1111};
    }
    data: coverpoint input_if.data{
      bins all = {64'b0,64'hffff_ffff_ffff_ffff};
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
