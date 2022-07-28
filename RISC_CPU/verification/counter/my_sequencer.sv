`ifndef MY_SEQUENCER__SV
`define MY_SEQUENCER__SV

class my_sequencer extends uvm_sequencer #(my_transaction);//参数化的类 参数是my trans
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(my_sequencer)//注册in factory
endclass

`endif
