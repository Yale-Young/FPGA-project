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
   logic[31:0]  data[$];
   logic[31:0]  data_array[];
   logic[31:0]  pc[$];
   logic[31:0]  pc_array[];
   logic[31:0]   addr[$];
   logic[31:0]   addr_array[];
   logic[1:0]   rw[$];
   logic[1:0]   rw_array[];
   int data_size;
   
   while(1) begin
      @(posedge vif.clk);
      if(vif.flag) break;
   end
   `uvm_info("my_monitor", "begin to collect one pkt", UVM_LOW);
   while(vif.flag) begin
      data.push_back(vif.data);
      pc.push_back(vif.pc);
      addr.push_back(vif.addr);
      rw.push_back(vif.rw);
      @(posedge vif.clk);
   end
   data_size  = data.size();   
   data_array = new[data_size];
   pc_array = new[data_size];
   addr_array = new[data_size];
   rw_array = new[data_size];
   for ( int i = 0; i < data_size; i++ ) begin
      data_array[i] = data[i];
      pc_array[i] = pc[i];
      addr_array[i] = addr[i];
      rw_array[i]   = rw[i];
   end
   tr.data = new[data_size]; //da sa, e_type, crc
   tr.pc = new[data_size];
   tr.addr = new[data_size];
   tr.rw   = new[data_size];
   tr.data = data_array;
   tr.pc = pc_array;
   tr.addr = addr_array;
   tr.rw   = rw_array;
   `uvm_info("my_monitor", "end collect one pkt", UVM_LOW);
endtask


`endif
