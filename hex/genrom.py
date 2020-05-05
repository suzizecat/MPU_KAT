#rom = bytearray([x for x in range(0,2**16)])

opcodes = {
    "cjmpl": "18",      # conditional jump litteral
    "jmpl" : "10",      # jump litteral > addr
    "cjmpc": "19 0000",
    "jmpc" : "11 0000",
    "cjmpr": "1A",
    "jmpr" : "12",
    "sca"  : "20",
    "wcl"  : "21",
    "wcr"  : "22 000",
    "ctr"  : "23 000",
    "wrl"  : "3",
    "eqr"  : "42",
    "neqr" : "43",
    "sumr" : "48",
    "atr"  : "4F 000" ,
    "nop"  : "00 0000"
}


source = """
nop
nop
sca 0001
wcl 0010
wrl0 000F
wrl1 0001
sumr 00 01
atr2
sca 0002
wcr2

sca 0001
ctr0
sca 0002
ctr1
eqr 00 01
cjmpl 0000
"""

assembled = source
for kword, val in opcodes.items() :
    assembled = assembled.replace(kword,val)

compressed = "".join(assembled.strip().split())

print(assembled)
print(len(compressed),"words of 4 data bits")

romstr = []
for i in range(0,(2**8)-len(compressed)):
    romstr.append(f"{0:06x}")
compressed += "".join(romstr)
print(len(compressed)," words of 4 memory bits")
rom = bytearray.fromhex(compressed + (" ".join(romstr)))


with open("rom.hex","wb") as f:
    f.write(rom)

print("Done.")