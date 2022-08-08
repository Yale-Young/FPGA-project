# Makefile For Verdi

all: compile simulate

genf: 
	find -name "*.sv">verif.f
	
comp: clean com
com:
	vcs -R -full64 +v2k -sverilog top_tb.sv -f l.f -debug_all -l vcs.log -timescale=1ns/1ps
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


