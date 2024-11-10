create_library_set -name LIBSET_TC -timing [list /users/ee500x/e1323337/riscv2/scs130ms_tt_1.80v_25C.lib]
create_library_set -name LIBSET_BC -timing [list /users/ee500x/e1323337/riscv2/scs130ms_ff_1.65v_-40C.lib]
create_library_set -name LIBSET_WC -timing [list /users/ee500x/e1323337/riscv2/scs130ms_ss_1.44v_-40C.lib]


create_rc_corner -name rc_best \
	-preRoute_res 1 \
	-postRoute_res 1 \
	-preRoute_cap 1 \
	-postRoute_cap 1 \
	-postRoute_xcap 1 \
	-postRoute_clkres 0 \
	-postRoute_clkcap 0 \

create_rc_corner -name rc_worst \
	-preRoute_res 1 \
	-postRoute_res 1 \
	-preRoute_cap 1 \
	-postRoute_cap 1 \
	-postRoute_xcap 1 \
	-postRoute_clkres 0 \
	-postRoute_clkcap 0 \

create_rc_corner -name rc_typical \
	-preRoute_res 1 \
	-postRoute_res 1 \
	-preRoute_cap 1 \
	-postRoute_cap 1 \
	-postRoute_xcap 1 \
	-postRoute_clkres 0 \
	-postRoute_clkcap 0 \

create_delay_corner -name WC_dc -library_set LIBSET_WC  -opcond_library "wc"  -rc_corner rc_worst

create_delay_corner -name BC_dc -library_set LIBSET_BC  -opcond_library "bc"  -rc_corner rc_best

create_delay_corner -name TC_dc -library_set LIBSET_TC  -opcond_library "tc"  -rc_corner rc_typical

create_constraint_mode -name CM -sdc_files [list /users/ee500x/e1323337/riscv2/TOP_RISCV.sdc] 


create_analysis_view -name AV_WC_RCWORST -constraint_mode CM -delay_corner WC_dc
create_analysis_view -name AV_BC_RCBEST   -constraint_mode CM -delay_corner BC_dc
create_analysis_view -name AV_TC_RCTYPICAL   -constraint_mode CM -delay_corner TC_dc

set_analysis_view -setup "AV_TC_RCTYPICAL" -hold "AV_TC_RCTYPICAL AV_WC_RCWORST AV_BC_RCBEST"



