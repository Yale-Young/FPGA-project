`ifndef MY_TRANSACTION__SV
`define MY_TRANSACTION__SV

class my_transaction extends uvm_sequence_item;

   rand logic [1:0]  ena[];//{ex,jtag}
   rand logic [9:0]  waddr[];//{ex,jtag}
   rand logic [9:0]  raddr[];//{1,2}
   rand logic [63:0] data[];//xie ex jtag  1,2
   rand logic [31:0] jdata[];
   

   constraint pload_cons{
      ena.size   >= 0;
      ena.size   <= 1500;
      waddr.size == ena.size;
      raddr.size == ena.size;
      data.size  == ena.size;
      jdata.size == ena.size;
   }
   
   

   `uvm_object_utils_begin(my_transaction)//注册后可直接调用copy print
      `uvm_field_array_int(ena, UVM_ALL_ON)
      `uvm_field_array_int(waddr, UVM_ALL_ON)
      `uvm_field_array_int(raddr, UVM_ALL_ON)
      `uvm_field_array_int(data, UVM_ALL_ON)
      `uvm_field_array_int(jdata, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "my_transaction");
      super.new();
      
   endfunction

endclass
`endif
