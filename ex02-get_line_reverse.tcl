# 文本处理-把文本A里的行，行序反向输出到B文本。
proc line_reorder {A B} {
	if {[file exists A]} {
		set file1 [open A r]
		set a_list [read $file1]
		puts "The file $A:\n$a_list"
		set b_list [lreverse $a_list]
		puts "The file $B:\n$b_list"
		set file2 [open B w]
		
		foreach new_line $b_list {
			puts $file2 "$new_line"
		}
		close $file1
		close $file2
	}
}
