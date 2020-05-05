GHDL_FLAGS= --std=08 --workdir=work

.PONY: run_tb_counter cleanwd

cleanwd : 
	rm -f work/*
	rm -f *.o
	rm -f sim/*.ghw

work/counter.o : rtl/counter.vhdl
	ghdl -a $(GHDL_FLAGS) rtl/counter.vhdl
work/tb_counter.o : tb/tb_counter.vhdl work/counter.o
	ghdl -a $(GHDL_FLAGS) tb/tb_counter.vhdl
work/tb_counter : work/tb_counter.o
	ghdl -e $(GHDL_FLAGS) tb_counter
	@mv tb_counter work/
sim/tb_counter.ghw : work/tb_counter
	work/tb_counter --wave=sim/tb_counter.ghw

run_tb_counter: sim/tb_counter.ghw
	gtkwave sim/tb_counter.ghw


hex/rom.hex hex/rom_expl.txt hex/rom_translate.txt : hex/rom.s
	python3 ~/Projets/VHDL/tools/katasm/katasm.py hex/rom.s hex/rom.hex --fill-instr 256 -e hex/rom_expl.txt -t hex/rom_translate.txt


work/rom.o : rtl/rom.vhdl hex/rom.hex hex/rom_expl.txt hex/rom_translate.txt
	ghdl -a $(GHDL_FLAGS) rtl/rom.vhdl
work/tb_rom.o : tb/tb_rom.vhdl work/rom.o
	ghdl -a $(GHDL_FLAGS) tb/tb_rom.vhdl
work/tb_rom : work/tb_rom.o
	ghdl -e $(GHDL_FLAGS) tb_rom
	@mv tb_rom work/
sim/tb_rom.ghw : work/tb_rom
	work/tb_rom --wave=sim/tb_rom.ghw || rm -f sim/tb_rom.ghw
	@cat sim/tb_rom.ghw > /dev/null || echo "Simulation Failure, Waveform deleted"
	#sim/tb_rom.ghw > /dev/null
	
	

run_tb_rom: sim/tb_rom.ghw
	gtkwave sim/tb_rom.ghw


work/ram.o : rtl/ram.vhdl
	ghdl -a $(GHDL_FLAGS) rtl/ram.vhdl


work/alu.o : rtl/alu.vhdl
	ghdl -a $(GHDL_FLAGS) rtl/alu.vhdl
work/tb_alu.o : tb/tb_alu.vhdl work/alu.o
	ghdl -a $(GHDL_FLAGS) tb/tb_alu.vhdl
work/tb_alu : work/tb_alu.o
	ghdl -e $(GHDL_FLAGS) tb_alu
	@mv tb_alu work/
sim/tb_alu.ghw : work/tb_alu
	work/tb_alu --wave=sim/tb_alu.ghw || rm -f sim/tb_alu.ghw
	cat sim/tb_alu.ghw > /dev/null

run_tb_alu: sim/tb_alu.ghw
	gtkwave sim/tb_alu.ghw



work/mpu.o : rtl/mpu.vhdl work/rom.o work/counter.o work/ram.o work/alu.o
	ghdl -a $(GHDL_FLAGS) rtl/mpu.vhdl
work/tb_mpu.o : tb/tb_mpu.vhdl work/mpu.o
	ghdl -a $(GHDL_FLAGS) tb/tb_mpu.vhdl
work/tb_mpu : work/tb_mpu.o
	ghdl -e $(GHDL_FLAGS) tb_mpu
	@mv tb_mpu work/
sim/tb_mpu.ghw : work/tb_mpu
	work/tb_mpu --wave=sim/tb_mpu.ghw || rm -f sim/tb_mpu.ghw
	@cat sim/tb_mpu.ghw > /dev/null 2> /dev/null || echo "[MAKEFILE] Simulation stopped with non-zero status, Waveform deleted"
	@cat sim/tb_mpu.ghw > /dev/null 2> /dev/null

run_tb_mpu: sim/tb_mpu.ghw
	gtkwave sim/tb_mpu.ghw sim/mpu.gtkw



