`ifndef MY_SEQUENCE__SV
`define MY_SEQUENCE__SV

class my_sequence extends uvm_sequence #(my_transaction);//只有在sequencer的帮助下，sequence产生出的transaction才能最终送给driver
   my_transaction m_trans;

   function new(string name= "my_sequence");
      super.new(name);
   endfunction

   virtual task body();//启动后会自动执行body
      repeat (10) begin
         `uvm_do(m_trans)//①实例化m_trans；②将其随机化；③最终将其送给sequencer
         //还可使用start_item inish_item
      end
      #1000;
   endtask

   `uvm_object_utils(my_sequence)//注意：sequencer是一个object 当其中的trans发送完毕则生命周期结束 
endclass
`endif
