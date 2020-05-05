$LIM = 2
$CNT = 1
$TOT = 0
$MTO = 3
nop
wrl $TOT 0
wrl $CNT 0
wrl $LIM 2
wrl $MTO 3
:mstart
    :start
        wrl $LIM 2
        incr $CNT
        atr  $CNT
        nger $CNT $LIM
    cjmpl :start
    wrl $LIM 0
    :part2
        decr $CNT
        atr  $CNT
        gtr  $CNT $LIM
    cjmpl :part2
    incr $TOT
    atr $TOT
    ger $TOT $MTO
    cjmpl :end
jmpl :mstart
:end
halt
nop 