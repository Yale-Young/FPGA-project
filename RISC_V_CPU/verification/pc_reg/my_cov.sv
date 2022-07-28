`ifndef GUARD_COVERAGE
`define GUARD_COVERAGE
 
class my_cov;
    virtual my_if vif;
    logic clk,rst_n;
 
    covergroup cov_counter @(posedge clk);
    addr : coverpoint input_if.data {
      bins all    = {13'b0,13'b1_1111_1111_1111};
      //bins high   = {13'b1_0000_0000_0000,13'b1_1111_1111_1111};
    }
    load : coverpoint  input_if.load {
      bins even  = {0};
      bins odd   = {1};
    }
    rst  : coverpoint rst_n{
      bins one ={1};
      bins zero = {0};
    }
  endgroup
 
    function new();
        cov_counter = new();
    endfunction : new
 
    task sample(logic clk,logic rst_n,my_if vif);
        this.vif = vif;
        this.clk = clk;
        this.rst_n = rst_n;
        cov_counter.sample();
    endtask:sample
 
endclass
`endif
