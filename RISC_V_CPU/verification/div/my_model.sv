`ifndef MY_MODEL__SV
`define MY_MODEL__SV

class my_model extends uvm_component;
   
   uvm_blocking_get_port #(my_transaction)  port;
   uvm_analysis_port #(my_transaction)  ap;

   extern function new(string name, uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern virtual  task main_phase(uvm_phase phase);

   `uvm_component_utils(my_model)
endclass 

function my_model::new(string name, uvm_component parent);
   super.new(name, parent);
endfunction 

function void my_model::build_phase(uvm_phase phase);
   super.build_phase(phase);
   port = new("port", this);
   ap = new("ap", this);
endfunction

task my_model::main_phase(uvm_phase phase);
   my_transaction tr;
   my_transaction new_tr;
   logic [31:0] pc=32'd8;
   logic [31:0] addr;
   logic [2:0]  hold=3'b000;
   logic load=0;
   int data_size;
   super.main_phase(phase);
   while(1) begin
      port.get(tr);
      new_tr = new("new_tr");
      /*data_size = tr.data.size;
      new_tr.data=new[data_size];
      new_tr.load = new[data_size];
      for(int i=0;i<data_size;i++)begin
        if(load) pc=addr;
        else if(hold>=3'b001) pc=pc;
        else pc=pc+4;
        new_tr.data[i] = pc;
        load = tr.load[i];
        addr = tr.data[i];
        hold = tr.hold[i];
      end
      new_tr.load = tr.load;
      new_tr.hold = tr.hold;*/
      `uvm_info("my_model", "get one transaction, copy and print it:", UVM_LOW)
      //new_tr.print();
      new_tr.copy(tr);
      ap.write(new_tr);
      `uvm_info("my_model", "model has send a pakage", UVM_LOW)
   end
endtask
`endif
