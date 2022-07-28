`ifndef MY_TRANSACTION__SV
`define MY_TRANSACTION__SV

class my_transaction extends uvm_sequence_item;

   rand bit[12:0]      data[];
   rand bit            load[];
   

   constraint pload_cons{
      data.size >= 46;
      data.size <= 1500;
      load.size == data.size;
   }
   

   `uvm_object_utils_begin(my_transaction)//注册后可直接调用copy print
      `uvm_field_array_int(data, UVM_ALL_ON)
      `uvm_field_array_int(load, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "my_transaction");
      super.new();
      
   endfunction

endclass
`endif
