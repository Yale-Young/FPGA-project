`ifndef MY_IF__SV
`define MY_IF__SV

interface my_if(input clk, input rst_n);

   logic [31:0] data;
   logic [31:0] data2;
   logic [2:0]  op;
   logic [4:0]  addr;
   logic        sr;
   logic        busy;
   logic        flag;
endinterface

`endif
