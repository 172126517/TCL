# This script helps user insert a logo text to the  input layout file, with user specificed layer and user sepecific location.
#
#      SYNTAX 
#      calibredrv create_logo.tcl <input file > < x1 coordinates > < y1 coordinates > <width> <height> <charsize> < layer number > < logo_string > < output file >
#        

if { $argc != 9 } {  
	puts "Incorrect inputs calibredrv create_logo.tcl <input file > < x1 coordinates > < y1 coordinates > <width> <height> <charsize> < layer number > < logo_string > < output file >" 
	exit
}

set input [lindex $argv 0]


set L [layout create $input -dt_expand -preservePaths ]

set x1_coord [lindex $argv 1]
set y1_coord [lindex $argv 2]
set width [lindex $argv 3]
set height [lindex $argv 4]
set charsize [lindex $argv 5]
set layer [lindex $argv 6]
set logo_string [lindex $argv 7]

set output [lindex $argv 8]

$L units microns 1000
set cell [ $L topcell ]
$L create layer $layer

  
  set currY_um [expr $y1_coord * 0.1]
  set strobj [StringFeature wrd0 $x1_coord $currY_um $width $height $charsize "$logo_string" l]
  $strobj addToLayout $L $cell 1 $layer
  delete object wrd0


if { [$L format ] =="OASIS" } {
	$L oasisout $output
} else {
	$L gdsout $output
}

