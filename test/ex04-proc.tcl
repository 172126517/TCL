proc P1 {} {
    global P1_a                 ;# proc 定义了一个全局变量 P1_a
    set P1_a 123                ;# 给变量 P1_a 赋值。
}

proc P2 {} {
    global P1_a                   ;# 调用全局变量 P1_a，该变量由 proc P1定义。
    P1                            ;# 调用proc P1
    puts "P2: P1_a = $P1_a"       ;# 打印变量 P1_a
}

proc P3 {} {
    P1
    puts "P3: P1_a = $::P1_a"
}

P2                               ;# 调用proc P2
P3                               ;# 调用proc P3
