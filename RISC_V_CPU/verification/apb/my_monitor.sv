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
   logic[2:0]  hold_q[$];
   logic[2:0]  hold_array[];
   logic       load[$];
   logic       load_array[];
   int data_size;
   
   while(1) begin
      @(posedge vif.clk);
      if(vif.flag) break;
   end
   `uvm_info("my_monitor", "begin to collect one pkt", UVM_LOW);
   while(vif.flag) begin
      data_q.push_back(vif.data);
      load.push_back(vif.load);
      hold_q.push_back(vif.hold);
      @(posedge vif.clk);
   end
   data_size  = data_q.size();   
   data_array = new[data_size];
   load_array = new[data_size];
   hold_array = new[data_size];
   for ( int i = 0; i < data_size; i++ ) begin
      data_array[i] = data_q[i];
      load_array[i] = load[i];
      hold_array[i] = hold_q[i];
   end
   tr.data = new[data_size]; //da sa, e_type, crc
   tr.load = new[data_size];
   tr.hold = new[data_size];
   tr.data = data_array;
   tr.load = load_array;
   tr.hold = hold_array;
   `uvm_info("my_monitor", "end collect one pkt", UVM_LOW);
endtask


`endif
