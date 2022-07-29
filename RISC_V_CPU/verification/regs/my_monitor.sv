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
   logic[1:0]  ena[$];
   logic[1:0]  ena_array[];
   logic[9:0]  waddr[$];
   logic[9:0]  waddr_array[];
   logic[9:0]  raddr[$];
   logic[9:0]  raddr_array[];
   logic[63:0] data[$];
   logic[63:0] data_array[];
   logic[31:0] jdata[$];
   logic[31:0] jdata_array[];
   int data_size;
   
   while(1) begin
      @(posedge vif.clk);
      if(vif.flag) break;
   end
   `uvm_info("my_monitor", "begin to collect one pkt", UVM_LOW);
   while(vif.flag) begin
      ena.push_back(vif.ena);
      waddr.push_back(vif.waddr);
      raddr.push_back(vif.raddr);
      data.push_back(vif.data);
      jdata.push_back(vif.jdata);
      @(posedge vif.clk);
   end
   data_size  = ena.size();   
   ena_array  =  new[data_size];
   waddr_array = new[data_size];
   raddr_array = new[data_size];
   data_array =  new[data_size];
   jdata_array = new[data_size];
   for ( int i = 0; i < data_size; i++ ) begin
      
      ena_array[i] =  ena[i];
      waddr_array[i] = waddr[i];
      raddr_array[i] = raddr[i];
      data_array[i] = data[i];
      jdata_array[i] = jdata[i];
   end
   tr.ena = new[data_size]; //da sa, e_type, crc
   tr.waddr = new[data_size];
   tr.raddr = new[data_size]; 
   tr.data = new[data_size];
   tr.jdata = new[data_size];
   tr.ena = ena_array;
   tr.waddr = waddr_array;
   tr.raddr = raddr_array;
   tr.data = data_array;
   tr.jdata = jdata_array;
   `uvm_info("my_monitor", "end collect one pkt", UVM_LOW);
endtask


`endif
