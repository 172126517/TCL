set_attribute [all_macro_cells] is_fixed false
remove_placement -object_tybe all

set obj [get_cells {"I_CLOCK_GEN/I_PLL_PCI"} -all]
set_attribute -quiet $obj orientation  FN
set_attribute -quiet $obj origin {0000.000 0000.000}
set_attribute -quiet $obj is_fixed true
set_attribute -quiet $obj is_soft_fixed false
set_attribute -quiet $obj eco_status eco_reset

set obj [get_cells {"******"} -all]
set_attribute -quiet $obj orientation  **
set_attribute -quiet $obj origin {x y}
set_attribute -quiet $obj is_fixed true
set_attribute -quiet $obj is_soft_fixed false
set_attribute -quiet $obj eco_status eco_reset

set obj [get_cells {"******"} -all]
set_attribute -quiet $obj orientation  **
set_attribute -quiet $obj origin {x y}
set_attribute -quiet $obj is_fixed true
set_attribute -quiet $obj is_soft_fixed false
set_attribute -quiet $obj eco_status eco_reset

...