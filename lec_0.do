set parallel option -threads 4
read library -both -liberty /folder/file.lib
read lef file /folder/file.lef
read design -golden /home/almeida/compound/tifs_final/verilog/rll/c2670_xor.v
read design -revised ../netlist/c2670_xor_ant_original_0.v
set system mode lec -nomap
analyze retiming
map key points
analyze setup
analyze datapath -merge
add compare point -all
compare
report verification > ../report/check_equivalence_0.rpt
report statistics >> ../report/check_equivalence_0.rpt
exit -f