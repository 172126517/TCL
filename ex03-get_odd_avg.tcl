proc get_odd_avg {num} {
	set b_list [list]
	if {[regexp {^\d+$} $num]} {
		for {set i 1} {$i<=$num} {incr i 1} {
			if {[expr $i%2]==1} {
				lappend b_list $i
			}
		}
		set sum 0
		foreach c $b_list {
			set sum [expr $sum+$c]
		}
	} else {
		puts "error: The input is not positive integer!"
	}
	puts "1~$num All odd numbers:$b_list"
	puts "Average value :[expr $sum/[llength $b_list]]"
}

get_odd_avg 78

