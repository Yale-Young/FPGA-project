`ifndef MY_IF__SV
`define MY_IF__SV

interface my_if(input clk, input rst);

   logic [31:0]  addr;
   logic [31:0] data;
   logic [31:0] pc;
   logic [1:0]  rw;//『请求，标志』
   logic flag;
endinterface

`endif
