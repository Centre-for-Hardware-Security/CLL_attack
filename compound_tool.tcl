set DESIGN c2670_xor_ant

set_db information_level 0

set init_verilog ../netlist/${DESIGN}.v

set init_lib {/export/designkits/tsmc/tsmc65/ip/msrflp/STDCELL/tcbn65lp_220a/FE/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn65lp_220a/tcbn65lptc.lib}

set init_hdl_search_path ../rtl/
set init_lib_search_path /export/designkits/tsmc/tsmc65/ip/msrflp/STDCELL/tcbn65lp_220a/FE/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn65lp_220a/

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

# ###############synthesize -to_mapped
set keyports [get_ports key*]
set a [sizeof_collection $keyports]
set keys [get_object_name $keyports]

set outputports [all_outputs]
set b [sizeof_collection $outputports]
set output [get_object_name $outputports]

set inputsports [all_inputs]
set c [sizeof_collection $inputsports]
set inputs [get_object_name $inputsports]

set search "Cell"

set diff_output {}
set item {}
set inputs {}

set result [open file.txt w+]

# Report all the paths between keys and all outputs
for {set t 0} {$t < $a} {incr t} {
	#lappend item [lindex $input $t]
	set count($t) 0
	for {set w 0} {$w < $b} {incr w} {
		report_timing -from [lindex $keys $t] -to [lindex $output $w] -unconstrained > report.txt
		set file [open report.txt]
		while {[gets $file line] != -1} {
			if {[string match *[string toupper $search]* [string toupper $line]]} {
				lappend item [lindex $output $w]
				incr count($t) 
			} else {
			}
		}
	close $file
	}

	lappend item $count($t)
	lappend diff_output $item
	set item {}

	puts $result "Key $t has arrived in $count($t) outputs!"
}

close $result


for {set c 0} {$c < $t} {incr c} {
	if {$count(0) != $count($c)} {
		set c $t
		set num_tech 1
	} else {
		set num_tech 0
	}
}

if {$num_tech == 0} {
	puts "The design has only one technique"
} else {
	puts "The design has more than one technique"
}	

# Return all the outputs for the same number of outputs arrived by a key
set unique [lsort -unique $diff_output]
set newcnt 0    
foreach f $unique {
    set cnt 0
    foreach item $diff_output {
        if {$item == $f} {
            incr cnt
        }
    }
	if {$cnt > $newcnt} {
		set newcnt $cnt
		set list $f
	}
}


set d 0
set keyinputs {}

foreach c $diff_output {
	if {$c == $list} {
		puts "keyinput$d"
		lappend keyinputs [lindex $keys $d]
		incr d
	} else {
		incr d
	}
}
#List of keyinputs that is not part of the keyinputs 
#This will be my keyprove
set provekey {}

foreach item $keys {
    if {$item ni $keyinputs} {
        lappend provekey $item
    }
}

set keysRLL2output {}
set psll_keys {}
set rll_keys {}
set psll_final {}
set rll_final {}
set path {}
set pathPSLL {}
set pathRLL {}
set vartmp12 ""
set num_psll 0
set num_rll 0


for {set g 0} {$g < [llength $provekey]} {incr g} {
	report_timing -from [lindex $provekey $g] -to [lindex $list 0] -unconstrained > report_key.txt
	set filekeyRLL [open report_key.txt]
	while {[gets $filekeyRLL linePin] != -1} {
		if {[string match *[string toupper $search]* [string toupper $linePin]]} {
			lappend keysRLL2output [lindex $provekey $g]
		}
	}
	close $filekeyRLL
}

set finishRLL 0
set numRLL 0

if {[llength $keysRLL2output] != 0} {
	set keysAll [lappend keyinputs $keysRLL2output]
	set keysAll [join $keysAll]
	set keysRLL2output [lsort -dictionary -unique $keysAll]
	report_timing -from [lindex $keysRLL2output 0] -to [lindex $list 0] -unconstrained > gateRll.txt
	set gateRll [open "|cat gateRll.txt"]
	while {[gets $gateRll lineGateRLL] != -1 && $finishRLL != 1} {
		if {[llength $lineGateRLL] != 11} {
			#puts "Incorrect format in the line -> '$line'"
			continue
		} else {
			foreach {var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11} $lineGateRLL {
				if {$var5 == "(port)" || $var5 == "(arrival)"} {
					#puts "Incorrect format in the gate -> '$var5'"
					continue
				} else {
					set var [lindex [split $var1 /] 0]
					puts $var
					lappend pathRLL $var
				}
				for {set i 0} {$i < [llength $keysRLL2output]} {incr i} {
					report_timing -from [lindex $keysRLL2output $i] -through $var -to [lindex $list 0] -unconstrained > gateCommomPathRLL.txt
					set gateCommomPathRLL [open gateCommomPathRLL.txt]
					while {[gets $gateCommomPathRLL lineRLL] != -1} {
						if {[string match *[string toupper $search]* [string toupper $lineRLL]]} {
							incr numRLL
						}
					}
					close $gateCommomPathRLL
				
					if {$numRLL == [llength $keysRLL2output]} {
						puts "This is the commom gate between RLL techniques: $var"
						set commomGateRLL $var
						set finishRLL 1
					}
				}
				set numRLL 0
			}
		}
	}
	close $gateRll
} else {
	set commomGateRLL ""
	set pathRLL {}
}
puts $commomGateRLL

set finishPSLL 0
set numPSLL 0

report_timing -from [lindex $keyinputs 0] -to [lindex $list 0] -unconstrained > gate.txt
set gate [open "|cat gate.txt"]
while {[gets $gate lineGate] != -1 && $finishPSLL != 1} {
	if {[llength $lineGate] != 11} {
		#puts "Incorrect format in the line -> '$line'"
		continue
	} else {
		foreach {var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11} $lineGate {
			if {$var5 == "(port)" || $var5 == "(arrival)"} {
				#puts "Incorrect format in the gate -> '$var5'"
				continue
			} else {
				set var [lindex [split $var1 /] 0]
				puts $var
				lappend pathPSLL $var
			}
			for {set i 0} {$i < [llength $keyinputs]} {incr i} {
				report_timing -from [lindex $keyinputs $i] -through $var -to [lindex $list 0] -unconstrained > gateCommomPath.txt
				set gateCommomPath [open gateCommomPath.txt]
				while {[gets $gateCommomPath line] != -1} {
					if {[string match *[string toupper $search]* [string toupper $line]]} {
						incr numPSLL
					}
				}
				close $gateCommomPath
				
				if {$numPSLL == [llength $keyinputs]} {
					puts "This is the commom gate between both techniques: $var"
					set commomGate $var
					set finishPSLL 1
				}
			}
			set numPSLL 0
		}
	}
}
close $gate
puts $commomGate

report_instance $commomGate > instance.txt
# Colect the pins related of the cell
set fileInstance [open "|tac instance.txt"]
while {[gets $fileInstance lineInstance] != -1} {
	if {[llength $lineInstance] != 9} {
		#puts "Incorrect format in the lineInstance -> '$lineInstance'"
		continue
	} else {
		foreach {var12 var13 var14 var15 var16 var17 var18 var19 var20} $lineInstance {
			if {$var12 == $vartmp12} {
				continue
			} else {
				set vartmp12 $var12
				puts '$commomGate/$var12'
				for {set h 0} {$h < [llength $keyinputs]} {incr h} {
					report_timing -from [lindex $keyinputs $h] -through $commomGate/$var12 -to [lindex $list 0] -unconstrained > report_pin.txt
					set filePin [open report_pin.txt]
					while {[gets $filePin linePin] != -1} {
						if {[string match *[string toupper $search]* [string toupper $linePin]]} {
							lappend psll_keys [lindex $keyinputs $h]
							incr num_psll
						}
					}
					close $filePin
				}
			}
			foreach item $pathPSLL {
				if {$item in $pathRLL} {
					lappend path $item
				}
			}
			puts $num_psll
			if {([llength $path]) == 0 && ($num_psll == 0 || $num_psll == [llength $keyinputs])} {
				puts "All the keys were classifyied correctly!"
				set psll_final $keyinputs
			} else {
				if {$num_psll > ([llength $keyinputs]/5)} {
					lappend psll_final $psll_keys
					set num_psll_final $num_psll
					set psll_keys {}
					set num_psll 0
				} else {
					set rll_keys $psll_keys
					set num_rll_final $num_psll
					set psll_keys {}
					set num_psll 0				
				}
			}
		}
	}
}
close $fileInstance

set psll_final [join $psll_final]
set psll_final [lsort -dictionary -unique $psll_final]

foreach item $keys {
    if {$item ni $psll_final} {
        lappend rll_final $item
    }
}


puts "########################################################"
puts "PSLL_KEYS:"
puts $psll_final
puts "RLL_KEYS:"
puts $rll_final
puts "COMMOM GATE:"
puts $var
size $psll_final
puts "########################################################"

echo keysPSLL: $psll_final > removal_list.log
echo keysRLL: $rll_final >> removal_list.log
echo gate: $var >> removal_list.log 
echo outputs: $list >> removal_list.log
echo keys: $keys >> removal_list.log
echo techniques: $num_tech >> removal_list.log

exit
