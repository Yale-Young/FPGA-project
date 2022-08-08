//`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "div.v"
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

    
div dut(.clk(clk),
        .rst(rst_n),
        .dividend_i(input_if.data),      // 被除数
        .divisor_i(input_if.data2),       // 除数
        .start_i(input_if.sr),                  // 开始信号，运算期间这个信号需要一直保持有效
        .op_i(input_if.op),                // 具体是哪一条指令
        .reg_waddr_i(input_if.addr), // 运算结束后需要写的寄存器
        .result_o(output_if.data),        // 除法结果，高32位是余数，低32位是商
        .ready_o(output_if.sr),                  // 运算结束信号
        .busy_o(output_if.busy),                  // 正在运算信号
        .reg_waddr_o(output_if.addr)  // 运算结束后需要写的寄存器
    );
covergroup cov_counter @(posedge clk);
    dividend : coverpoint input_if.data {
      bins all    = {32'b0,32'hffff_ffff};
      //bins high   = {13'b1_0000_0000_0000,13'b1_1111_1111_1111};
    }
    divisor : coverpoint  input_if.data2 {
      bins even  = {0};
      bins odd   = {1};
    }
    op :coverpoint input_if.op{
      bins not_hold = {3'b0};
      bins hold = {3'b001,3'b111};
    }
    addr: coverpoint input_if.addr{
    
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
