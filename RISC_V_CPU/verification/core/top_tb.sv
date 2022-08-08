//`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "tinyriscv.v"
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
reg rst;

my_if input_if(clk, rst);
my_if output_if(clk, rst);

logic [7:0] int_i;
reg rib_ex_req_o,
     rib_ex_we_o,
     jtag_reg_we_i,
     rib_hold_flag_i,
     jtag_halt_flag_i,
     jtag_reset_flag_i;
reg[4:0] jtag_reg_addr_i;
reg[31:0] rib_ex_addr_o, 
          rib_ex_data_i, 
          rib_ex_data_o, 
          rib_pc_addr_o, 
          rib_pc_data_i, 
          jtag_reg_data_i,
          jtag_reg_data_o;
logic[31:0] rom [0:1023];
logic[31:0] ram [0:1023];


    
tinyriscv dut(
            .clk(clk),
            .rst(rst),
            .rib_ex_addr_o(output_if.addr),        // 读、写外设的地址
            .rib_ex_data_i(input_if.data),        // 从外设读取的数据
            .rib_ex_data_o(output_if.data),        // 写入外设的数据
            .rib_ex_req_o(output_if.rw[1]),          // 访问外设请求
            .rib_ex_we_o(output_if.rw[0]),            // 写外设标志
            .rib_pc_addr_o(output_if.pc),        // 取指地址
            .rib_pc_data_i(input_if.pc),        // 取到的指令内容
            .jtag_reg_addr_i(jtag_reg_addr_i),    // jtag模块读、写寄存器的地址
            .jtag_reg_data_i(jtag_reg_data_i),    // jtag模块写寄存器数据
            .jtag_reg_we_i(jtag_reg_we_i),        // jtag模块写寄存器标志
            .jtag_reg_data_o(jtag_reg_data_o),    // jtag模块读取到的寄存器数据
            .rib_hold_flag_i(rib_hold_flag_i),    // 总线暂停标志
            .jtag_halt_flag_i(jtag_halt_flag_i),  // jtag暂停标志
            .jtag_reset_flag_i(jtag_reset_flag_i),// jtag复位PC标志
            .int_i(int_i)                         // 中断信号
    );
    
    
covergroup cov_counter @(posedge clk);
    data: coverpoint input_if.data {
      bins all    = {32'b0,32'hffff_ffff};
      //bins high   = {13'b1_0000_0000_0000,13'b1_1111_1111_1111};
    }
    inst_type : coverpoint  input_if.pc[6:0] {
      bins R_type  = {7'b0110011};
      bins I_type   = {7'b0000011,7'b0010011,7'b0001111,7'b1110011};
      bins S_type  = {7'b0100011};
      bins B_type   = {7'b1100011};
      bins U_type  = {7'b0110111,7'b0010111};
      bins J_type   = {7'b1101111,7'b1100111};
    }
endgroup
  
cov_counter cov_count = new();
assign output_if.flag = input_if.flag;//tr 标志位

/**always @*begin
    if(rib_ex_we_o) ram[rib_ex_addr_o[31:0]]<=rib_ex_data_o;
    rib_pc_data_i = rom[rib_pc_addr_o[31:2]];
    rib_ex_data_i = ram[rib_ex_addr_o[31:2]];
    ram[rib_ex_addr_o[31:2]]=rib_ex_data_o;
end*/

initial begin
   clk = 0;
   forever begin
      #10 clk = ~clk;
   end
end

initial begin
   //$readmemh("rom.data",rom);
   rst = 1'b0;
   #30 rst = 1'b1;
   #300 rst = 1'b0;
   #40 rst = 1'b1;
end
always@(posedge clk) begin
    rib_hold_flag_i=(input_if.data<=100);
    jtag_reg_we_i=(input_if.data[1]);
    jtag_halt_flag_i=(input_if.data[31:6]<=100);
    jtag_reset_flag_i=(input_if.data[31:4]<=100);
    jtag_reg_addr_i=input_if.data[31:27];
    jtag_reg_data_i={input_if.data[31:16],input_if.pc[15:0]};
end
initial begin
    int_i = 0;
    #450 int_i = 4;
    #40 int_i =0;
end


initial begin
   run_test("my_case1");
end

initial begin
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.drv", "vif", input_if);
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.mon", "vif", input_if);
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.o_agt.mon", "vif", output_if);
end



endmodule
