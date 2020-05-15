# MPU_KAT
A wobbly MPU thinggy
Developped in VHDL-08 with GHDL

# Run instruction
In order to run a simulation, you need a working setup on `ghdl` and `gtkwave`.
You will also need the `katasm` utility to generate a ROM from an assembly file.

In a quick step, you can run :
```
git clone git@github.com:suzizecat/MPU_KAT.git
git clone git@github.com:suzizecat/katasm.git
git clone git@github.com:suzizecat/genericparser.git katasm/parser/genericparser
```

Then edit `MPU_KAT/Makefile` to specify the correct path for `katasm` using the `KATASM_PATH` variable.
Then simply run 
```
mkdir work
make run_tb_mpu
```

To create run the MPU testbench.

GHDL flags used are `--std=08 --workdir=work` by default.
