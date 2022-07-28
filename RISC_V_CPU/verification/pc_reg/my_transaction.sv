`ifndef MY_TRANSACTION__SV
`define MY_TRANSACTION__SV

class my_transaction extends uvm_sequence_item;

   rand bit[31:0]      data[];
   rand bit[2:0]       hold[];
   rand bit            load[];
   //rand bit mode;
   

   constraint pload_cons{
      data.size >= 46;
      data.size <= 1500;
      load.size == data.size;
      hold.size == data.size;
   }
   constraint holdc{
      foreach(hold[i]){
          hold[i] dist{ 3'b000:= 50, [3'b001:3'b111]:=30};
          
          /*mode == 1 -> hold[i] == 3'b000;
          mode == 0 -> hold[i] >=3'b001;
          mode dist {1:=1,0:=1};*/
      }
      
     
   }
   

   `uvm_object_utils_begin(my_transaction)//注册后可直接调用copy print
      `uvm_field_array_int(data, UVM_ALL_ON)
      `uvm_field_array_int(load, UVM_ALL_ON)
      `uvm_field_array_int(hold, UVM_ALL_ON)
      //`uvm_field_int(mode, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "my_transaction");
      super.new();
      
   endfunction

endclass
`endif
