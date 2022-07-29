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
   logic [63:0] datai =64'b0;
   logic [63:0] datao =64'b0;
   logic [31:0] jdata=32'b0;
   logic [9:0]  waddr=10'b0;
   logic [9:0]  raddr=10'b0;
   logic [1:0]  ena  =2'b0;
   int data_size;
   int d1,d2,d3,d4;
   logic[31:0]  regs[0:31];
   super.main_phase(phase);
   while(1) begin
      port.get(tr);
      new_tr = new("new_tr");
      data_size = tr.ena.size;
      new_tr.data  = new[data_size];
      new_tr.jdata = new[data_size];
      for(int i=0;i<data_size;i++)begin
        fork
        begin
          if ((ena[1] == 1'b1) && (waddr[9:5] != 5'b0)) begin
                d1=waddr[9:5];
                regs[d1] = datai[63:32];
            end else if ((ena[0] == 1'b1) && (waddr[4:0] != 5'b0)) begin
                d1=waddr[4:0];
                regs[d1] = datai[31:0];
            end
        end
        join
        ena  =  tr.ena[i]; 
        waddr =  tr.waddr[i];
        raddr =  tr.raddr[i];
        datai  =  tr.data[i];
        fork
        begin
          if (raddr[9:5] == 5'b0) begin
            datao[63:32] = 32'h0;
            // 如果读地址等于写地址，并且正在写操作，则直接返回写数据
            end else if (raddr[9:5] == waddr[9:5] && ena[1] == 1'b1) begin
              datao[63:32] = datai[63:32];
            end else begin
              d2=raddr[9:5];
              datao[63:32] = regs[d2];
        end
        end
        begin
          if (raddr[4:0] == 5'b0) begin
            datao[31:0] = 32'h0;
        // 如果读地址等于写地址，并且正在写操作，则直接返回写数据
        end else if (raddr[4:0] == waddr[9:5] && ena[1] == 1'b1) begin
            datao[31:0] = datai[63:32];
        end else begin
            d3=raddr[4:0];
            datao[31:0] = regs[d3];
        end
        end
        begin
          if (waddr[4:0] == 5'b0) begin
            jdata = 32'b0;
        end else begin
            d4=waddr[4:0];
            jdata = regs[d4];
        end
        end
        join
        
        new_tr.data[i] = datao;
        new_tr.jdata[i] = jdata;
        
      end
      
      //new_tr.copy(tr);
      `uvm_info("my_model", "get one transaction, copy and print it:", UVM_LOW)
      //new_tr.print();
      ap.write(new_tr);
      `uvm_info("my_model", "model has send a pakage", UVM_LOW)
   end
endtask
`endif
