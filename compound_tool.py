import sys
import argparse
import os
import re
import time

start_time = time.time()

parser=argparse.ArgumentParser(
    description='''Python script to analysis the design regarding with the number of techniques applied''',
    epilog="""This tool performs a structural analysis to discover logic locking techniques applied, differentiate them and split the design in portional for each method.""")
parser.add_argument('<nameModule>', type=str, default=42, help='Top level design name')
args=parser.parse_args()

arg1 = sys.argv[1]

file_copy = open("../script/compound_tool.tcl", "r+")
original_file = file_copy.read().splitlines(True)
file_copy.truncate(0)
file_copy.close()
file_copy = open("../script/compound_tool.tcl", "w")
file_copy.write("set DESIGN " + arg1)
file_copy.write("\n")
file_copy.write("\n")
file_copy.writelines(original_file[2:])    
file_copy.close()

print("Loading the design...")

os.system("genus -files ../script/compound_tool.tcl " + ">" + "compound_tool.log")

print("Running the compound structural logic locking tool!")

# Get the output list and outputs affected by the keys
var = []
keysPSLL = []
outputs = []
classification = time.time() - start_time

with open("removal_list.log", "a") as myfile:
    myfile.write("Time of classification: " + str(classification) + " seconds \n")


file1 = open('removal_list.log', 'r')
for line in reversed(list(file1)):
    if (line.startswith('gate:')):
        gate = re.findall(r' .+?\b', line)
        var = [element.replace(' ','') for element in gate]
    elif (line.startswith('keysPSLL:')):
        keys = re.findall(r' .+?\b', line) 
        keysPSLL = [element.replace(' ','') for element in keys]
    elif (line.startswith('outputs:')):
        list = re.findall(r' .+?\b', line) 
        outputs = [element.replace(' ','') for element in list]
    elif (line.startswith('techniques:')):
        list = re.findall(r' .+?\b', line) 
        techniques = [element.replace(' ','') for element in list]
    elif (line.startswith('keys:')):
        keysall = re.findall(r' .+?\b', line)
        keys_all = [element.replace(' ','') for element in keysall]  
             
        
print(var)
print(outputs)
print(keysPSLL)

incr = 0
incr1 = 0
incr2 = 0
      
print("Generating the original or stripped netlist using 0 as restore output....")
append_copy = open("../script/edit_netlist_original_0.tcl", "r+")
original_text = append_copy.read().splitlines(True)
append_copy.truncate(0)
append_copy.close()
append_copy = open("../script/edit_netlist_original_0.tcl", "w")
append_copy.write("set DESIGN " + arg1)
append_copy.write("\n")
append_copy.write("\n")
append_copy.write("set var {")
for element in var:
  if (incr == len(var)-1):
    append_copy.write(element)
    incr = incr + 1
  elif (incr < len(var)):
    append_copy.write(element)
    append_copy.write(" ")
    incr = incr + 1
append_copy.write("}")
append_copy.write("\n")
append_copy.write("\n")
append_copy.write("set list {")
for element in outputs:
  if (incr1 < len(outputs)):
    append_copy.write(element)
    incr1 = incr1 + 1
    if (incr1 == len(outputs)-1):
      append_copy.write("}")
      incr1 = incr1 + 1
    else:
      append_copy.write(" ")
append_copy.write("\n")
append_copy.write("\n")
append_copy.write("set keys_PSLL {")
for element in keysPSLL:
  if (incr2 == len(keysPSLL)-1):
    append_copy.write(element)
    incr2 = incr2 + 1
  elif (incr < len(keysPSLL)):
    append_copy.write(element)
    append_copy.write(" ")
    incr2 = incr2 + 1
append_copy.write("}")
append_copy.write("\n")
append_copy.write("\n")
append_copy.writelines(original_text[8:])    
append_copy.close()  
os.system("genus -files ../script/edit_netlist_original_0.tcl" + ">>" + "compound_tool.log")

incr = 0
incr1 = 0
incr2 = 0
      
print("Generating the original or stripped netlist using 1 as restore output....")
append_copy = open("../script/edit_netlist_original_1.tcl", "r+")
original_text = append_copy.read().splitlines(True)
append_copy.truncate(0)
append_copy.close()
append_copy = open("../script/edit_netlist_original_1.tcl", "w")
append_copy.write("set DESIGN " + arg1)
append_copy.write("\n")
append_copy.write("\n")
append_copy.write("set var {")
for element in var:
  if (incr == len(var)-1):
    append_copy.write(element)
    incr = incr + 1
  elif (incr < len(var)):
    append_copy.write(element)
    append_copy.write(" ")
    incr = incr + 1
append_copy.write("}")
append_copy.write("\n")
append_copy.write("\n")
append_copy.write("set list {")
for element in outputs:
  if (incr1 < len(outputs)):
    append_copy.write(element)
    incr1 = incr1 + 1
    if (incr1 == len(outputs)-1):
      append_copy.write("}")
      incr1 = incr1 + 1
    else:
      append_copy.write(" ")
append_copy.write("\n")
append_copy.write("\n")
append_copy.write("set keys_PSLL {")
for element in keysPSLL:
  if (incr2 == len(keysPSLL)-1):
    append_copy.write(element)
    incr2 = incr2 + 1
  elif (incr < len(keysPSLL)):
    append_copy.write(element)
    append_copy.write(" ")
    incr2 = incr2 + 1
append_copy.write("}")
append_copy.write("\n")
append_copy.write("\n")
append_copy.writelines(original_text[8:])    
append_copy.close()  
os.system("genus -files ../script/edit_netlist_original_1.tcl" + ">>" + "compound_tool.log")
  
print("Generating the restore netlist....")

incr = 0
incr1 = 0
incr2 = 0

append_copy = open("../script/edit_netlist_restore.tcl", "r+")
original_text = append_copy.read().splitlines(True)
append_copy.truncate(0)
append_copy.close()
append_copy = open("../script/edit_netlist_restore.tcl", "w")
append_copy.write("set DESIGN " + arg1)
append_copy.write("\n")
append_copy.write("\n")
append_copy.write("set var {")
for element in var:
  if (incr == len(var)-1):
    append_copy.write(element)
    incr = incr + 1
  elif (incr < len(var)):
    append_copy.write(element)
    append_copy.write(" ")
    incr = incr + 1
append_copy.write("}")
append_copy.write("\n")
append_copy.write("\n")
append_copy.write("set list {")
for element in outputs:
  if (incr1 < len(outputs)):
    append_copy.write(element)
    incr1 = incr1 + 1
    if (incr1 == len(outputs)-1):
      append_copy.write("}")
      incr1 = incr1 + 1
    else:
      append_copy.write(" ")
append_copy.write("\n")
append_copy.write("\n")
append_copy.write("set keys_PSLL {")
for element in keysPSLL:
  if (incr2 == len(keysPSLL)-1):
    append_copy.write(element)
    incr2 = incr2 + 1
  elif (incr < len(keysPSLL)):
    append_copy.write(element)
    append_copy.write(" ")
    incr2 = incr2 + 1
append_copy.write("}")
append_copy.write("\n")
append_copy.write("\n")
append_copy.writelines(original_text[8:])    
append_copy.close()  
os.system("genus -files ../script/edit_netlist_restore.tcl" + ">>" + "compound_tool.log")

  
print ("The tool generated the restore and original/stripped netlist...")
print ("Files are in the netlist folder...")  


print ("Running the LEC in two versions...")


for item in range(0,2):
  append_copy = open("../script/lec_" + str(item) + ".do", "r+")
  original_text = append_copy.read().splitlines(True)
  append_copy.truncate(0)
  append_copy.close()
  append_copy = open("../script/lec_" + str(item) + ".do", "w")
  append_copy.write("set parallel option -threads 4\n")
  append_copy.write("read library -both -liberty /folder/file.lib\n")
  append_copy.write("read lef file /folder/file.lef\n")
  append_copy.write("read design -golden /home/almeida/compound/tifs_final/verilog/rll/" + "_".join(arg1.split("_", 2)[:2]) + ".v\n")
  append_copy.write("read design -revised ../netlist/" + arg1 + "_original_" + str(item) + ".v\n")
  append_copy.write("set system mode lec -nomap\n")
  append_copy.write("analyze retiming\n")
  append_copy.write("map key points\n")
  append_copy.write("analyze setup\n")
  append_copy.write("analyze datapath -merge\n")
  append_copy.write("add compare point -all\n")
  append_copy.write("compare\n")
  append_copy.write("report verification > ../report/check_equivalence_" + str(item) + ".rpt\n")
  append_copy.write("report statistics >> ../report/check_equivalence_" + str(item) + ".rpt\n")
  append_copy.write("exit -f")
  append_copy.close()
  command = "lec_64 -nogui -xl -dofile ../script/lec_" + str(item) + ".do"
  os.system(command)
  print ("Done LEC")
  
  
print("Extract keys from ORIGINAL + RLL and RESTORE designs...")

nonEq = 0

file_rpt0 = open('../report/check_equivalence_0.rpt', 'r')
for line in file_rpt0:
    if (line.startswith('      Non-equivalent')):
      nonEq = nonEq + 1



file_rpt1 = open('../report/check_equivalence_1.rpt', 'r')
for line in file_rpt1:
    if (line.startswith('      Non-equivalent')):
      nonEq = nonEq + 1
      
      

print("Translate the verilog into bench files...")

os.system("perl ../script/ver2bench.pl -v=../netlist/" + arg1 + "_original_0.v " + "-l=../script/mcnc_tsmc65.genlib")

os.system("perl ../script/ver2bench.pl -v=../netlist/" + arg1 + "_original_1.v " + "-l=../script/mcnc_tsmc65.genlib") 

os.system("perl ../script/ver2bench.pl -v=../netlist/" + arg1 + "_restore.v " + "-l=../script/mcnc_tsmc65.genlib")

result = 0
key = []

print("Extract keys from RESTORE designs...")
if (nonEq <= 1):
  os.system("perl ../script/extract_key.pl -f=../netlist/" + arg1 + "_restore.bench -v=0" + " -p=../script/paths.pl > " + arg1 + "_restore_0.key")
  os.system("perl ../script/extract_key.pl -f=../netlist/" + arg1 + "_restore.bench -v=1" + " -p=../script/paths.pl > " + arg1 + "_restore_1.key")

  if (os.stat(arg1 + "_restore_0.key").st_size != 0):
    print("The output from restore logic is 0")
    result = 1
    file = open(arg1 + "_restore_0.key", "r+")
    for line in file:
        if(line.startswith('#key=')):
            key_PSLL = re.findall(r'.+?\b', line)[3]
  elif(os.stat(arg1 + "_restore_1.key").st_size != 0):
    print("The output from restore logic is 1")
    result = 2
    file = open(arg1 + "_restore_1.key", "r+")
    for line in file:
        if(line.startswith('#key=')):
            key_PSLL = re.findall(r'.+?\b', line)[3]
  elif(os.stat(arg1 + "_restore_1.key").st_size == 0 and os.stat(arg1 + "_restore_1.key").st_size == 0):
    result = 3
    print("Key PSLL was not found!!!")
    key_PSLL = 'x'*(len(keysPSLL))
else:
    result = 4
    print("Key PSLL was not found!!!")
    key_PSLL = 'x'*(len(keysPSLL))

print(result)

if (result == 1):
    os.system("perl ../script/tempus.pl -ef=../netlist/" + arg1 + "_original_0.bench " + "-of=/home/almeida/compound/tifs_final/bench/original/" + arg1.split('_')[0] + ".bench -qt=0 -v -p=../script/paths.pl > " + arg1 + "_original_0.key")
    file = open(arg1 + "_original_0.key", "r+")
    for line in file:
        if(line.startswith("[INFO] key=")):
            key_RLL = re.findall(r'.+?\b', line)[5]      
elif (result == 2):
    os.system("perl ../script/tempus.pl -ef=../netlist/" + arg1 + "_original_1.bench " + "-of=/home/almeida/compound/tifs_final/bench/original/" + arg1.split('_')[0] + ".bench -qt=0 -v -p=../script/paths.pl > " + arg1 + "_original_1.key")
    file = open(arg1 + "_original_1.key", "r+")
    for line in file:
        if(line.startswith("[INFO] key=")):
            key_RLL = re.findall(r'.+?\b', line)[5]
else:
    os.system("perl ../script/qatt.pl -ef=../netlist/" + arg1 + "_original_0.bench " + "-of=/home/almeida/compound/tifs_final/bench/original/" + arg1.split('_')[0] + ".bench -qt=0 -v -iter -p=../script/paths.pl > " + arg1 + "_original_0.key")
    os.system("perl ../script/qatt.pl -ef=../netlist/" + arg1 + "_original_1.bench " + "-of=/home/almeida/compound/tifs_final/bench/original/" + arg1.split('_')[0] + ".bench -qt=0 -v -iter -p=../script/paths.pl > " + arg1 + "_original_1.key")
    if (os.stat(arg1 + "_original_0.key").st_size > 200):
        file = open(arg1 + "_original_0.key", "r+")
        for line in file:
            if(line.startswith('[INFO] Proven key: ')):
                key_RLL = re.findall(r'.+?\b', line)[7]
    elif (os.stat(arg1 + "_original_1.key").st_size > 200):
        file = open(arg1 + "_original_1.key", "r+")
        for line in file:
            if(line.startswith('[INFO] Proven key: ')):
                key_RLL = re.findall(r'.+?\b', line)[7]
    else:
        key_RLL = 'x'*(len(keys_all) - len(keysPSLL))         


key = key_RLL + key_PSLL


# Classify the technique based on the restore verilog file
if(nonEq == 1 and result < 3):
    print("The PSLL technique is Single-Flip Logic Locking")
    print("The final key is: " + key)
    print(key)
    print ("Running the LEC between original versus compound design with the keys discovered...")
    append_copy = open("../script/lec.do", "r+")
    original_text = append_copy.read().splitlines(True)
    append_copy.truncate(0)
    append_copy.close()
    append_copy = open("../script/lec.do", "w")
    append_copy.write("set parallel option -threads 4\n")
    append_copy.write("read library -both -liberty /folder/file.lib\n")
    append_copy.write("read lef file /folder/file.lef\n")
    append_copy.write("read design -golden /home/almeida/compound/tifs_final/verilog/original/" + arg1.split('_')[0] + ".v\n")
    append_copy.write("read design -revised ../netlist/" + arg1 + ".v\n")
    for x in range(len(keys_all)):
      append_copy.write("add pin constraint " + key[x] + " " + keys_all[x] + " -revised\n")
  
    append_copy.write("set system mode lec -nomap\n")
    append_copy.write("analyze retiming\n")
    append_copy.write("map key points\n")
    append_copy.write("analyze setup\n")
    append_copy.write("analyze datapath -merge\n")
    append_copy.write("add compare point -all\n")
    append_copy.write("compare\n")
    append_copy.write("report verification > ../report/check_equivalence_SAT.rpt\n")
    append_copy.write("report statistics >> ../report/check_equivalence_SAT.rpt\n")
    append_copy.write("exit -f")
    append_copy.close()
    command = "lec_64 -nogui -xl -dofile ../script/lec.do"
    os.system(command)
    print ("Done LEC Restore")
    file_rpt3 = open('../report/check_equivalence_SAT.rpt', 'r')
    for line in file_rpt1:
      if (line.startswith('      Non-equivalent')):
        print("This single point is not SAT family")
      elif(line.startswith('      Equivalent')):
        print("This single flip technique is SAT family")
elif(result == 3):
    print("The PSLL technique is Single-Flip Logic Locking DTL")
    print("The final key is: " + key)
elif(result == 4):
    print("The PSLL technique is Double-Flipe Logic Locking")
    print("The final key is: " + key)


file = open("../report/" + arg1 + ".key", "w+")
file.write(key)
file.close()

inputs_restore = []

file1 = open('removal_list.log', 'r')
for line in file1:
    if (line.startswith('inputs:')):
        inputrestore = re.findall(r' .+?\b', line)
        inputs_restore = [element.replace(' ','') for element in inputrestore] 

elem = []
finish = 0
z = ""
z_tmp = ""

print(inputs_restore)


print ("Running all the attack")
for x in inputs_restore:
    elem.append(x)
    incr = 0
    with open("../netlist/" + arg1 + "_restore.v", 'r+') as file1:
        for line1 in file1:
          if(incr < 2):
            if(len(re.findall(x+"\)",line1)) != 0):
                if(len(re.findall(r"keyinput[0-9]+", line1)) != 0):
                    z = re.findall(r"keyinput[0-9]+", line1)[0]
                    elem.append(z)
                    incr = incr + 1
                else:
                    t = re.findall(r"\([a-z]_[0-9]+\)", line1)[0]
                    with open("../netlist/" + arg1 + "_restore.v", 'r+') as file_tmp:
                        for line_tmp in file_tmp:
                            if(len(re.findall(t+"\)", line_tmp)) != 0 and len(re.findall(r"keyinput[0-9]+", line_tmp)) != 0 and incr < 2):
                              z = re.findall(r"keyinput[0-9]+", line_tmp)[0]
                              if(z_tmp != z):
                                z_tmp = z
                                elem.append(z)
                                incr = incr + 1
                                finish = 1
                        file_tmp.close()
        file.close()


print("Elements:")
print(elem)
print("#####################")
execution = time.time() - start_time

with open("removal_list.log", "a") as myfile:
    myfile.write("Time of execution: " + str(execution) + " seconds \n")


if(elem[1].startswith('key') and  elem[2].startswith('key')):
    print("Circuit is from ANTISAT family with a complementary logic in the restore!!!!!")
else:
    print("Circuit is not ANTISAT family!!!!")


     
file = open("../netlist/" + arg1 + ".bench", 'r')
for line in file:
    if (line.startswith('# key=')):
        key_proven = line.strip('# key=')
        i = 0
        dc = 0
        dw = 0
        count = 0
        dk = len(key) - count
        for key_index in key:
          if (key_index == 'x'):
              count = coun + 1
              i = i + 1
          else:
            if (key_index == key_proven[i]):
              dc = dc + 1
              i = i + 1
            else:
              dw = dw + 1
              i = i + 1
        
        with open("removal_list.log", "a") as myfile:
          myfile.write("The number of deciphered keys: " + str(dk) + "\n")  
          myfile.write("The number of correct deciphered keys: " + str(dc) + "\n")
          myfile.write("The number of wrong deciphered keys: " + str(dw) + "\n" )
          myfile.write("#key_discovered=" + key_proven + "\n")
 
