`ifndef MY_MONITOR__SV
`define MY_MONITOR__SV
class my_monitor extends uvm_monitor;

   virtual my_if vif;

   uvm_analysis_port #(my_transaction)  ap;
   
   `uvm_component_utils(my_monitor)
   function new(string name = "my_monitor", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
         `uvm_fatal("my_monitor", "virtual interface must be set for vif!!!")
      ap = new("ap", this);
   endfunction

   extern task main_phase(uvm_phase phase);
   extern task collect_one_pkt(my_transaction tr);
endclass

task my_monitor::main_phase(uvm_phase phase);
   my_transaction tr;
   while(1) begin
      tr = new("tr");
      collect_one_pkt(tr);
      $display("mon tr");
      tr.print();
      ap.write(tr);
   end
endtask

task my_monitor::collect_one_pkt(my_transaction tr);
   logic[31:0] data_q[$];
   logic[31:0] data_array[];
   logic[31:0] data2_q[$];
   logic[31:0] data2_array[];
   logic[2:0]  op_q[$];
   logic[2:0]  op_array[];
   logic[4:0]  addr_q[$];
   logic[4:0]  addr_array[];
   int data_size;
   
   while(1) begin
      @(posedge vif.clk);
      if(vif.flag) break;
   end
   `uvm_info("my_monitor", "begin to collect one pkt", UVM_LOW);
   while(vif.flag) begin
      data_q.push_back(vif.data);
      data2_q.push_back(vif.data2);
      op_q.push_back(vif.op);
      addr_q.push_back(vif.addr);
      @(posedge vif.clk);
   end
   data_size  = data_q.size();   
   data_array = new[data_size];
   data2_array = new[data_size];
   op_array = new[data_size];
   addr_array = new[data_size];
   for ( int i = 0; i < data_size; i++ ) begin
      data_array[i] = data_q[i];
      data2_array[i] = data2_q[i];
      op_array[i] = op_q[i];
      addr_array[i] = addr_q[i];
   end
   tr.data = new[data_size]; //da sa, e_type, crc
   tr.data2 = new[data_size];
   tr.op = new[data_size];
   tr.addr = new[data_size];
   tr.data = data_array;
   tr.data2 = data2_array;
   tr.op   = op_array;
   tr.addr = addr_array;
   `uvm_info("my_monitor", "end collect one pkt", UVM_LOW);
endtask


`endif
