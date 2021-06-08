run: all

all:
	irun -access +r -input shm.tcl ./includes/riscv_defines.svh ./includes/ctrl_typedefs.svh ./../tb/core_tb.sv core.sv if_stage.sv reg_bank.sv decoder.sv controller.sv control_unit.sv id_stage.sv alu.sv mdu.sv ex_stage.sv lsu_lite.sv wb_stage.sv if_to_id.sv id_to_ex.sv ex_to_wb.sv pcu.sv  -nowarn "NONPRT"

create:
	@echo "database -open waves -shm" >> shm.tcl
	@echo "probe -create  core_tb -depth all -all -memories -shm -database waves" >> shm.tcl
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

