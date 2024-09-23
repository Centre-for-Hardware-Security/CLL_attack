set DESIGN c2670_xor_ant

set var {g8816__6783}

set list {G311 G150}

set keys_PSLL {keyinput64 keyinput65 keyinput66 keyinput67 keyinput68 keyinput69 keyinput70 keyinput71 keyinput72 keyinput73 keyinput74 keyinput75 keyinput76 keyinput77 keyinput78 keyinput79 keyinput80 keyinput81 keyinput82 keyinput83 keyinput84 keyinput85 keyinput86 keyinput87 keyinput88 keyinput89 keyinput90 keyinput91 keyinput92 keyinput93 keyinput94 keyinput95 keyinput96 keyinput97 keyinput98 keyinput99 keyinput100 keyinput101 keyinput102 keyinput103 keyinput104 keyinput105 keyinput106 keyinput107 keyinput108 keyinput109 keyinput110 keyinput111 keyinput112 keyinput113 keyinput114 keyinput115 keyinput116 keyinput117 keyinput118 keyinput119 keyinput120 keyinput121 keyinput122 keyinput123 keyinput124 keyinput125 keyinput126 keyinput127 keyinput128 keyinput129 keyinput130 keyinput131 keyinput132 keyinput133 keyinput134 keyinput135 keyinput136 keyinput137 keyinput138 keyinput139 keyinput140 keyinput141 keyinput142 keyinput143 keyinput144 keyinput145 keyinput146 keyinput147 keyinput148 keyinput149 keyinput150 keyinput151 keyinput152 keyinput153 keyinput154 keyinput155 keyinput156 keyinput157 keyinput158 keyinput159 keyinput160 keyinput161 keyinput162 keyinput163 keyinput164 keyinput165 keyinput166 keyinput167 keyinput168 keyinput169 keyinput170 keyinput171 keyinput172 keyinput173 keyinput174 keyinput175 keyinput176 keyinput177 keyinput178 keyinput179 keyinput180 keyinput181 keyinput182 keyinput183 keyinput184 keyinput185 keyinput186 keyinput187 keyinput188 keyinput189 keyinput190 keyinput191}

set_db information_level 0

set init_verilog ../netlist/${DESIGN}.v

set init_lib {/folder/file.lib}

set init_hdl_search_path ../rtl/
set init_lib_search_path /folder/

set_db hdl_error_on_latch true

read_libs ${init_lib}

read_hdl ${init_verilog}

set_dont_use *SDF*
set_dont_use *SEDF*
set_dont_use LH*
set_dont_use LN*
set_dont_use CK*
set_dont_use HA*
set_dont_use *FA1D*
set_dont_use *HA1D* 
set_dont_use *BENCD* 
set_dont_use *HICIND* 
set_dont_use *HICOND* 
set_dont_use *FICIND* 
set_dont_use *FICOND* 
set_dont_use *HICOND* 
set_dont_use *FIICOND* 
set_dont_use *CMPE42D*
set_dont_use *HCOSCIND* 
set_dont_use *HCOSCOND* 
set_dont_use *FCSICIND* 
set_dont_use *FCSICOND* 
set_dont_use *DFCND*
set_dont_use *SDFCNQ*
set_dont_use *AOI3*
set_dont_use *AOI2*
set_dont_use *OAI3*
set_dont_use *OAI2*
set_dont_use *OA3*
set_dont_use *OA2*
set_dont_use *AO3*
set_dont_use *AO2*
set_dont_use *NR4*
set_dont_use *NR3*
set_dont_use *ND4*
set_dont_use *ND3*
set_dont_use *OR4*
set_dont_use *OR3*
set_dont_use MUX*
set_dont_use XOR3*
set_dont_use XOR4*
set_dont_use AN3*
set_dont_use AN4*

# Elaborate the top level
elaborate $DESIGN
check_design -unresolved

dc::set_time_unit -picoseconds
dc::create_clock -name "clk_name" -period 2

#*Synthesis
#
# GENERIC SYNTHESIS ###
set_db syn_generic_effort low
syn_generic

# MAPPING ###
set_db syn_map_effort low
syn_map

#set_db syn_opt_effort high
#syn_opt
set outputports [all_outputs]
set b [sizeof_collection $outputports]
set output [get_object_name $outputports]
set search "*port*"
set vartmp ""
set num 0
set finish 0
set done1 0
set done2 0
set com1 0 
set com2 0
set com 0

report_timing -from [lindex $keys_PSLL 0] -to [lindex $list [llength $list]-1] -unconstrained > report_timing.txt

set file [open "|cat report_timing.txt"]


while {[gets $file line] != -1} {
	if {[llength $line] != 11} {
		continue
	}
	foreach {var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11} $line {
		if {$var5 == "(port)" || $var5 == "(arrival)"} {
			continue
		} else {
			set var [lindex [split $var1 /] 0]
			puts $var
			set var_input  [lindex [split $var3 ->] 0]
			if {$finish == 1} { # use the var1 and var5, if var5 is port remove from list
				#puts "Same port -> '$var12'"
			} else {
				for {set h 0} {$h < [llength $keys_PSLL]} {incr h} {
					report_timing -from [lindex $keys_PSLL $h] -to [lindex $list 0] -unconstrained -nworst 100 > test.txt
					set file1 [open "| cat test.txt"]
					set file2 [open "|tac test.txt"]
					set file_norm [open "file_norm.txt" w+]
					set file_vers [open "file_vers.txt" w+]
					
					while {[gets $file1 line1] != -1 && $done1 == 0} {
						if {[string match "*port*" $line1]} {
							puts $file_norm $line1
							set done1 1
						} else {
							puts $file_norm $line1
						}
					}
					close $file1
					close $file_norm

					while {[gets $file2 line2] != -1 && $done2 == 0} {
						if {[string match "*arrival*" $line2]} {
							puts $file_vers $line2
							set done2 1
						} else {
							puts $file_vers $line2
						}
					}
					close $file2
					close $file_vers
					
					set file_norm [open "| cat file_norm.txt"]
					set file_vers [open "| tac file_vers.txt"]					

					while {[gets $file_norm line] != -1} {
						if {[string match *$var* $line]} {
							incr com1
						}
					}
					close $file_norm
					
					while {[gets $file_vers lineV] != -1} {
						if {[string match *$var* $lineV]} {
							incr com2
						}
					}
					close $file_vers
					
					rm -rf file_norm.txt
					rm -rf file_vers.txt
					set done1 0
					set done2 0					
					
				}
				
				set com [expr $com1 + $com2]
				
				if {$com == 2*[llength $keys_PSLL]} {
					puts "Intersection path for all keys"
					set last_gate $var1
					puts $last_gate
					set finish 1
				} else {
					set com 0
					set com1 0
					set com2 0
				}
			}
		}
	}
}
close $file

for {set i 0} {$i < [llength $output]} {incr i} {
	edit_netlist disconnect [lindex $output $i]
}
edit_netlist disconnect $last_gate

edit_netlist connect $last_gate [lindex $output 0]

delete_unloaded_undriven -all $DESIGN
# OPT ###
set_db syn_opt_effort high
syn_opt
syn_opt -incr

delete_unloaded_undriven -all $DESIGN

write_hdl -mapped >  ../netlist/${DESIGN}_restore.v

set inputsports [all_inputs]
set c [sizeof_collection $inputsports]
set inputs [get_object_name $inputsports]

set keyports [get_ports key*]
set a [sizeof_collection $keyports]
set keys [get_object_name $keyports]

foreach item $inputs {
    if {$item ni $keys} {
        lappend input $item
    }
}

echo inputs: $input >> removal_list.log

exit

