# Makefile For Verdi

all: compile simulate

genf: 
	find -name "*.sv">verif.f
	
comp: clean com
com:
	vcs -R -full64 +v2k -fsdb +define+FSDB -sverilog -ntb_opts uvm-1.1 top_tb.sv -debug_all -l vcs.log -timescale=1ns/1ps	-cm line+cond+fsm+branch+tgl
cov:
	dve -covdir simv.vdb&
simulate:
	./simv -l sim.log                

dve:
	dve \
	-vpd *.vpd &                     

verdi:
	verdi \
	-f verif.f \                     
	-nologo \
	-ssf *.fsdb &                    

clean:
	@rm -rf csrc DVEfiles simv simv.daidir ucli.key VCS* *.vdb
	@rm -rf *.log *.vpd *.ddc *.svf *.SDF *Synth *Netlist* *.h
	@rm -rf alib-52 work
	@rm -rf *.conf *.rc *.fsdb verdiLog


