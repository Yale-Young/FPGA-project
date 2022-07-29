`ifndef MY_IF__SV
`define MY_IF__SV

interface my_if(input clk, input rst_n);

   logic [1:0] ena;//{ex,jtag}
   logic [9:0] waddr;//{ex,jtag}
   logic [9:0] raddr;//{1,2}
   logic [63:0] data;//xie ex jtag  1,2
   logic [31:0] jdata;   
   logic flag;
endinterface

`endif
