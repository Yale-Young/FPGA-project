`ifndef MY_CASE1__SV
`define MY_CASE1__SV
class case1_sequence extends uvm_sequence #(accum_transaction);
   accum_transaction m_trans;

   
   function  new(string name= "case1_sequence");
      super.new(name);
   endfunction 

   virtual task body();
      `uvm_info("case1_sequence","case1_sequence body",UVM_LOW);
      //$display("%h",starting_phase);
      if(starting_phase != null) 
         starting_phase.raise_objection(this);
      repeat (5) begin
         $display("start uvm do");
         `uvm_do(m_trans)
         `uvm_info("case1_sequence","m_trans do",UVM_LOW);
         m_trans.print();
      end
      #100;
      if(starting_phase != null) 
         starting_phase.drop_objection(this);
   endtask

   `uvm_object_utils(case1_sequence)
endclass

class my_case1 extends base_test;
  
   function new(string name = "my_case1", uvm_component parent = null);
      super.new(name,parent);
   endfunction 
   
   extern virtual function void build_phase(uvm_phase phase); 
   `uvm_component_utils(my_case1)
endclass


function void my_case1::build_phase(uvm_phase phase);
   super.build_phase(phase);
   `uvm_info("my_case1","build phase",UVM_LOW);
   uvm_config_db#(uvm_object_wrapper)::set(this, 
                                           "env.acc_agt.acc_sqr", 
                                           "default_sequence", 
                                           accum_base_seq::type_id::get());
   `uvm_info("my_case1","sequence -> sequencer",UVM_LOW);
                                           
endfunction

`endif
