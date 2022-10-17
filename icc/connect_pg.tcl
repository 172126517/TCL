## global connection
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}                      #创建给STD cell供电的power net
#derive_pg_connection -power_net VDD33 -ground_net VSS -power_pin VDD33 -ground_pin VSSA33                 #创建一个3.3v的digital 供电
#derive_pg_connection -power_net VDDA33 -ground_net VSSA33 -power_pin VDDA33 -ground_pin VSSA33      #创建一个3.3v的analog 供电

##io pad  
derive_pg_connection -power_net VDDH -power_pin VDDH -ground_net VSSH -ground_pin VSSH                     #创建给PAD供电的power net
                
 ## u_ana_ldo
derive_pg_connection -power_net VDDA33 -ground_net VSSA33 -power_pin VDDA50 -ground_pin GNDA50 -cells {uo_ana_wrap/u_ana_ldo}
derive_pg_connection -power_net VDD -power_pin VDDA15 -cells {uo_ana_wrap/u_ana_ldo}
#derive_pg_connection -power_net VDD15 -ground_net GND15 -power_pin VDDA15 -ground_pin GNDA50 -cells {uo_ana_wrap/u_ana_ldo}

## u_ana_pdr_bor
derive_pg_connection -power_net VDDH -ground_net VSSH -power_pin VDD -ground_pin GND5P0 -cells {uo_ana_wrap/u_ana_bor}
derive_pg_connection -power_net VDD -ground_net VSS -power_pin VDD1P5 -ground_pin GND1P5 -cells {uo_ana_wrap/u_ana_bor}

## u_ana_rcmf
derive_pg_connection -power_net VDD -ground_net VSS -power_pin VDDA15 -ground_pin GND15 -cells {uo_ana_wrap/u_ana_rcmf}

## u_ana_pll
derive_pg_connection -power_net VDD -ground_net VSS -power_pin VDDA15 -ground_pin GND15 -cells {uo_ana_wrap/u_ana_pll}




