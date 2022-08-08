`ifndef MY_TRANSACTION__SV
`define MY_TRANSACTION__SV

class my_transaction extends uvm_sequence_item;

   rand bit[31:0]      data[];
   rand bit[31:0]      data2[];
   rand bit[4:0]       addr[];
   rand bit[2:0]       op[];
   //rand bit            load[];
   //rand bit mode;
   

   constraint pload_cons{
      data.size >= 0;
      data.size <= 1500;
      data2.size == data.size;
      op.size == data.size;
      addr.size == data.size;
   }
   constraint holdc{
      foreach(op[i]){
          op[i] inside {3'b100};//,3'b111};
          
      }
      
     
   }
   

   `uvm_object_utils_begin(my_transaction)//注册后可直接调用copy print
      `uvm_field_array_int(data, UVM_ALL_ON)
      `uvm_field_array_int(data2, UVM_ALL_ON)
      `uvm_field_array_int(op, UVM_ALL_ON)
      `uvm_field_array_int(op, UVM_ALL_ON)
      //`uvm_field_int(mode, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "my_transaction");
      super.new();
      
   endfunction

endclass
`endif
