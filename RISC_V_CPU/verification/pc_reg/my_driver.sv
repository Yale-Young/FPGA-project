
`ifndef MY_DRIVER__SV
`define MY_DRIVER__SV
class my_driver extends uvm_driver#(my_transaction);//参数化 添加参数选择驱动的transaction类型 则可使用req(获得的参数 此处为my_transaction)

   virtual my_if vif;
   //my_cov cov;

   `uvm_component_utils(my_driver)
   function new(string name = "my_driver", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      //cov = new();
      if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
         `uvm_fatal("my_driver", "virtual interface must be set for vif!!!")
   endfunction
   

   extern task main_phase(uvm_phase phase);
   extern task drive_one_pkt(my_transaction tr);
endclass

task my_driver::main_phase(uvm_phase phase);
   vif.data <= 32'b0;
   vif.load <= 1'b0;
   vif.hold <= 3'b0;
   while(!vif.rst_n)
      @(posedge vif.clk);
   while(1) begin
      //seq_item_port.get_next_item(req);//向sequencer阻塞申请新的transaction 还可以使用try_next_item 需要判断是否有内容
      seq_item_port.try_next_item(req);
      if(req==null)
        #1;//@(posedge vif.clk or negedge vif.clk);
      else begin
        `uvm_info("my_driver", "get a transaction", UVM_LOW);
        drive_one_pkt(req);
        seq_item_port.item_done();//通知sequencer已经完成驱动，sequencer会删除上一个transaction  {握手机制} sequence 结束uvm_do
        `uvm_info("my_driver", "done a transaction", UVM_LOW);
      end
   end
endtask

task my_driver::drive_one_pkt(my_transaction tr);
   logic [31:0]     data_q[];
   logic            load[];
   logic [2:0]      hold[];
   int  data_size;
   logic[31:0]   r;
   
   data_size = tr.data.size; 
   data_q = new[data_size];
   load   = new[data_size];
   hold   = new[data_size];
   data_q = tr.data;
   load   = tr.load;
   hold   = tr.hold;
   `uvm_info("my_driver", "begin to drive one pkt", UVM_LOW);
   repeat(1) @(posedge vif.clk);
   for ( int i = 0; i < data_size; i++ ) begin
      @(posedge vif.clk);
      vif.flag <= 1'b1;
      vif.data <= data_q[i];
      vif.load <= load[i]; 
      vif.hold <= hold[i];
      r= {$random} % 100;
      vif.ss <=r[0];
      //cov.sample(vif);
   end
   @(posedge vif.clk);
   vif.flag <= 1'b0;
   `uvm_info("my_driver", "end drive one pkt", UVM_LOW);
endtask


`endif
