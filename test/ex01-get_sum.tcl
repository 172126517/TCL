# 求三位数中三个数字相加等于 23 的数. 
#
set target_num 23
set a_list [list]
for {set i 100} { $i < 1000 } {incr i 1} {
    set b_list [split $i {}]
    foreach {x y z} $b_list {
        set sum [expr $x + $y + $z]
        if { $sum == $target_num } {
	    lappend a_list $i
        }
    }
}
puts $a_list
	


