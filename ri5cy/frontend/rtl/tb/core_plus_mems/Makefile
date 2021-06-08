run: all

all:
	irun -access +r -input shm.tcl ./../../src/includes/riscv_defines.svh ./../../src/includes/ctrl_typedefs.svh testbench.sv ./../../../../../mmc/frontend/rtl/src/mmc.sv ./../../../../../ram_inst/frontend/rtl/src/instr_mem.sv ./../../../../../ram_data/frontend/rtl/src/data_mem.sv ./../../src/core.sv ./../../src/if_stage.sv ./../../src/reg_bank.sv ./../../src/decoder.sv ./../../src/controller.sv ./../../src/control_unit.sv ./../../src/id_stage.sv ./../../src/alu.sv ./../../src/mdu.sv ./../../src/ex_stage.sv ./../../src/lsu.sv ./../../src/wb_stage.sv ./../../src/if_to_id.sv ./../../src/id_to_ex.sv ./../../src/ex_to_wb.sv ./../../src/pcu.sv  -nowarn "NONPRT"

create:
	@echo "database -open waves -shm" >> shm.tcl
	@echo "probe -create  testbench -depth all -all -memories -shm -database waves" >> shm.tcl
	@echo "run 18 ms -absolute" >> shm.tcl
	@echo "exit" >> shm.tcl
	
waves: 
	simvision waves.shm	

simulate: all 

synthesize:
	rc -f rtl.tcl

clean_reports:
	rm -r reports*
clean:
	rm -rf xcelium.d INCA_libs xrun.* *.shm *.dsn *.trn *.ucm ncvlog_*.err imc.key .simvision irun.* *.diag
	rm -r  mapped* rc* fv libscore_work script

