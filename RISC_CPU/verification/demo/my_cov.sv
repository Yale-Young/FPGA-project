`ifndef GUARD_COVERAGE
`define GUARD_COVERAGE
 
class my_cov;
    virtual my_if vif;
 
    covergroup switch_coverage;
    addr : coverpoint vif.data {
      bins low    = {13'b0,13'b0_1111_1111_1111};
      bins high   = {13'b1_0000_0000_0000,13'b1_1111_1111_1111};
    }
    load : coverpoint  vif.load {
      bins even  = {0};
      bins odd   = {1};
    }
  endgroup
 
    function new();
        switch_coverage = new();
    endfunction : new
 
    task sample(my_if vif);
        this.vif = vif;
        switch_coverage.sample();
    endtask:sample
 
endclass
`endif
