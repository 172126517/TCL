

set a_list [list 13 54 89  67 45 90 15 17 42 28 16 58 43]
set i 1
foreach a $a_list {
    set arr($i) $a
    incr i 1
}
parray arr
set N [expr $i - 1]
puts "########"
for {set n 1} {$n < $N} {incr n 1} {
    set m [expr $n + 1]
    while {$m < $N} {
        if {$arr($n) < $arr($m)} {
	    set x $arr($m)
	    for {set o $m} {$o > $i} {incr o -1} {
	        set arr($o) $arr([expr $o -1])
	    }
        }
	incr m 1
    }
}
parray arr
