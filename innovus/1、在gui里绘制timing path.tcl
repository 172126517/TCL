proc hq_draw_timing_path {path} {	
	set tps [get_property $path timing_points]
	set pins [get_property [get_property $tps pin] dbObject]
	
	foreach pin1 [lrange $pins 0 end-1] pin2 [lrange $pins 1 end] {
		if {[dbGet $pin1.objType] eq "hTerm"} {
			set pin1 $pin1.term
		}
		if {[dbGet $pin2.objType] eq "hTerm"} {
			set pin2 $pin2.term
		}
		set pt1 [join [dbGet -e $pin1.pt]];
		set pt2 [join [dbGet -e $pin2.pt]];
		set line [concat $pt1 $pt2]
		add_gui_shape -line $line -layer my_layer_red -arrow
	}
	setLayerPreference my_layer_red -color red -lineWidth 2 -isVisible 1 -stipple None
}
# method 1:
# hq_draw_timing_path [report_timing -collection]
#
# method 2:
# set path [report_timing -from x -to y -collection]
# hq_draw_timing_path $path
#