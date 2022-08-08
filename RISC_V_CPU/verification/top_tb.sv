//`timescale 1ns/1ps




module top_tb;

reg clk;
reg rst;
int int_i=0;
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
            .rib_ex_addr_o(rib_ex_addr_o),        // 读、写外设的地址
            .rib_ex_data_i(rib_ex_data_i),        // 从外设读取的数据
            .rib_ex_data_o(rib_ex_data_o),        // 写入外设的数据
            .rib_ex_req_o(rib_ex_req_o),          // 访问外设请求
            .rib_ex_we_o(rib_ex_we_o),            // 写外设标志
            .rib_pc_addr_o(rib_pc_addr_o),        // 取指地址
            .rib_pc_data_i(rib_pc_data_i),        // 取到的指令内容
            .jtag_reg_addr_i(jtag_reg_addr_i),    // jtag模块读、写寄存器的地址
            .jtag_reg_data_i(jtag_reg_data_i),    // jtag模块写寄存器数据
            .jtag_reg_we_i(jtag_reg_we_i),        // jtag模块写寄存器标志
            .jtag_reg_data_o(jtag_reg_data_o),    // jtag模块读取到的寄存器数据
            .rib_hold_flag_i(rib_hold_flag_i),    // 总线暂停标志
            .jtag_halt_flag_i(jtag_halt_flag_i),  // jtag暂停标志
            .jtag_reset_flag_i(jtag_reset_flag_i),// jtag复位PC标志
            .int_i(int_i)                         // 中断信号
    );


always @*begin
    if(rib_ex_we_o)
      ram[rib_ex_addr_o[31:0]]<=rib_ex_data_o;
    rib_pc_data_i = rom[rib_pc_addr_o[31:2]];
    rib_ex_data_i = ram[rib_ex_addr_o[31:2]];
    ram[rib_ex_addr_o[31:2]]=rib_ex_data_o;
end

initial begin
   clk = 0;
   forever begin
      #10 clk = ~clk;
   end
end

initial begin
   $readmemh("rom.data",rom);
   rst = 1'b0;
   #30 rst = 1'b1;
   #500 $finish;
end

initial begin
   
end



endmodule
