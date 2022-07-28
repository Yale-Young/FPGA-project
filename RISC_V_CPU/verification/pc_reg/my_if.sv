`ifndef MY_IF__SV
`define MY_IF__SV

interface my_if(input clk, input rst_n);

   logic [31:0] data;
   logic load;
   logic [2:0] hold;
   logic  ss;
   logic flag;
endinterface

`endif
