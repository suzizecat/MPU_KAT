wrl 0 2
wrl 1 0
wrl 2 3

:start
    sumr 0 2
    incr 1
    atr  1
    neqr 1 2
cjmpl :start
wrl 2 0
:part2
    decr 1
    atr  1
    neqr 1 2
cjmpl :part2
halt
nop