#!/usr/bin/perl

use strict;
use Cwd qw(cwd); 
use lib cwd;
use POSIX();
use warnings;
#use diagnostics;
#use Math::Matrix;
use Path::Tiny qw(path);
use Storable qw(dclone);
use Time::HiRes qw(time);
use Term::ANSIColor qw(:constants);

my $arg_ok = 1;
my $arg_cnt = 0;

my $is_nvk = 0;
my $is_orst = 0;
my $att_cnt = 1;
my $the_verb = 0;
my $query_cnt = 0;
my $file_enc = "";
my $exec_org = "";
my $file_org = "";
my $query_tech = 3;
my $glb_sat_seed = 1;
my $sat_lim = 100000;
my $run_lim = 9**9**9;
my $glb_file_key = "";
my $file_dir_enc = "";
my $single_ite_dec = 0;
my $dip_sat_solver = 8;
my $reg_sat_solver = 1;
my $simp_sat_solver = 1;
my $glb_ite_lim = 9**9**9;
my $file_path = "paths.pl";
my $glb_reg_sat_phrase = "";
my $glb_dip_sat_phrase = "";
my $glb_simp_sat_phrase = "";
my $file_key_assumption = "";
my $the_contest = "helloctf";

while (1){
  if (defined $ARGV[$arg_cnt]){
    if ($ARGV[$arg_cnt] eq "-h" or $ARGV[$arg_cnt] eq "-help"){
      $arg_ok = 0;
    }
    else {
      if (index($ARGV[$arg_cnt], "-ef=") != -1){
        $file_enc = substr($ARGV[$arg_cnt], 4, length($ARGV[$arg_cnt])-4);
      }
      elsif (index($ARGV[$arg_cnt], "-ed=") != -1){
        $file_dir_enc = substr($ARGV[$arg_cnt], 4, length($ARGV[$arg_cnt])-4);
      }
      elsif (index($ARGV[$arg_cnt], "-of=") != -1){
        $file_org = substr($ARGV[$arg_cnt], 4, length($ARGV[$arg_cnt])-4);
      }
      elsif (index($ARGV[$arg_cnt], "-ox=") != -1){
        $exec_org = substr($ARGV[$arg_cnt], 4, length($ARGV[$arg_cnt])-4);
      }
      elsif (index($ARGV[$arg_cnt], "-kf=") != -1){
        $glb_file_key = substr($ARGV[$arg_cnt], 4, length($ARGV[$arg_cnt])-4);
      }
      elsif (index($ARGV[$arg_cnt], "-a=") != -1){
        $file_key_assumption = substr($ARGV[$arg_cnt], 3, length($ARGV[$arg_cnt])-3);
      }
      elsif (index($ARGV[$arg_cnt], "-p=") != -1){
        $file_path = substr($ARGV[$arg_cnt], 3, length($ARGV[$arg_cnt])-3);
      }
      elsif (index($ARGV[$arg_cnt], "-satreg=") != -1){
        $reg_sat_solver = substr($ARGV[$arg_cnt], 8, length($ARGV[$arg_cnt])-8) + 0.0;
        if ($reg_sat_solver < 0 or $reg_sat_solver > 8){
          $arg_ok = 0;
        }
      }
      elsif (index($ARGV[$arg_cnt], "-satdip=") != -1){
        $dip_sat_solver = substr($ARGV[$arg_cnt], 8, length($ARGV[$arg_cnt])-8) + 0.0;
        if ($dip_sat_solver < 0 or $dip_sat_solver > 8){
          $arg_ok = 0;
        }
      }
      elsif (index($ARGV[$arg_cnt], "-satsimp=") != -1){
        $simp_sat_solver = substr($ARGV[$arg_cnt], 9, length($ARGV[$arg_cnt])-9) + 0.0;
        if ($simp_sat_solver < 0 or $simp_sat_solver > 1){
          $arg_ok = 0;
        }
      }
      elsif (index($ARGV[$arg_cnt], "-st=") != -1){
        $sat_lim = substr($ARGV[$arg_cnt], 4, length($ARGV[$arg_cnt])-4) + 0.0;
        if ($sat_lim < 0){
          $arg_ok = 0;
        }
      }
      elsif (index($ARGV[$arg_cnt], "-ss=") != -1){
        $glb_sat_seed = substr($ARGV[$arg_cnt], 4, length($ARGV[$arg_cnt])-4) + 0.0;
        if ($glb_sat_seed <= 0){
          $arg_ok = 0;
        }
      }
      elsif (index($ARGV[$arg_cnt], "-qt=") != -1){
        $query_tech = substr($ARGV[$arg_cnt], 4, length($ARGV[$arg_cnt])-4) + 0.0;
        if ($query_tech < 0 or $query_tech > 4){
          $arg_ok = 0;
        }
      }
      elsif (index($ARGV[$arg_cnt], "-qn=") != -1){
        $query_cnt = substr($ARGV[$arg_cnt], 4, length($ARGV[$arg_cnt])-4) + 0.0;
        if ($query_cnt < 0){
          $arg_ok = 0;
        }
      }
      elsif (index($ARGV[$arg_cnt], "-tt=") != -1){
        $run_lim = substr($ARGV[$arg_cnt], 4, length($ARGV[$arg_cnt])-4) + 0.0;
        if ($run_lim < 0){
          $arg_ok = 0;
        }
      }
      elsif (index($ARGV[$arg_cnt], "-il=") != -1){
        $glb_ite_lim = substr($ARGV[$arg_cnt], 4, length($ARGV[$arg_cnt])-4) + 0.0;
        if ($glb_ite_lim < 0){
          $arg_ok = 0;
        }
      }
      elsif (index($ARGV[$arg_cnt], "-an=") != -1){
        $att_cnt = substr($ARGV[$arg_cnt], 4, length($ARGV[$arg_cnt])-4) + 0.0;
        if ($att_cnt < 1){
          $arg_ok = 0;
        }
      }
      elsif (index($ARGV[$arg_cnt], "-con=") != -1){
        $the_contest = substr($ARGV[$arg_cnt], 5, length($ARGV[$arg_cnt])-5);
        if ($the_contest ne "helloctf" and $the_contest ne "csaw19"){
          $arg_ok = 0;
        }
      }
      elsif (index($ARGV[$arg_cnt], "-orst") != -1){
        $is_orst= 1;
      }
      elsif (index($ARGV[$arg_cnt], "-sid") != -1){
        $single_ite_dec = 1;
      }
      elsif (index($ARGV[$arg_cnt], "-nvk") != -1){
        $is_nvk = 1;
      }
      elsif (index($ARGV[$arg_cnt], "-v") != -1){
        $the_verb = 1;
      }
      else{
        $arg_ok = 0;
      }
    }
  }
  else{
    last;
  }

  $arg_cnt++;
}

if ($arg_ok == 0){
  help_part();
}
else{
  if (($file_enc ne "" or $file_dir_enc ne "") and ($file_org ne "" or $exec_org ne "")){
    if ($reg_sat_solver == 0){$glb_reg_sat_phrase = "cryptominisat";}
    elsif ($reg_sat_solver == 1){$glb_reg_sat_phrase = "lingeling";}
    elsif ($reg_sat_solver == 2){$glb_reg_sat_phrase = "plingeling";}
    elsif ($reg_sat_solver == 3){$glb_reg_sat_phrase = "ilingeling";}
    elsif ($reg_sat_solver == 4){$glb_reg_sat_phrase = "riss";}
    elsif ($reg_sat_solver == 5){$glb_reg_sat_phrase = "glucose41";}
    elsif ($reg_sat_solver == 6){$glb_reg_sat_phrase = "glucose30_simp";}
    elsif ($reg_sat_solver == 7){$glb_reg_sat_phrase = "glucose30_core";}
    elsif ($reg_sat_solver == 8){$glb_reg_sat_phrase = "cadical";}

    if ($dip_sat_solver == 0){$glb_dip_sat_phrase = "cryptominisat";}
    elsif ($dip_sat_solver == 1){$glb_dip_sat_phrase = "lingeling";}
    elsif ($dip_sat_solver == 2){$glb_dip_sat_phrase = "plingeling";}
    elsif ($dip_sat_solver == 3){$glb_dip_sat_phrase = "ilingeling";}
    elsif ($dip_sat_solver == 4){$glb_dip_sat_phrase = "riss";}
    elsif ($dip_sat_solver == 5){$glb_dip_sat_phrase = "glucose41";}
    elsif ($dip_sat_solver == 6){$glb_dip_sat_phrase = "glucose30_simp";}
    elsif ($dip_sat_solver == 7){$glb_dip_sat_phrase = "glucose30_core";}
    elsif ($dip_sat_solver == 8){$glb_dip_sat_phrase = "cadical";}
    
    if ($simp_sat_solver == 0){$glb_simp_sat_phrase = "cryptominisat";}
    elsif ($simp_sat_solver == 1){$glb_simp_sat_phrase = "cadical";}

    if ($att_cnt == 1){
      if ($single_ite_dec == 0){
        main_part($glb_reg_sat_phrase, $glb_dip_sat_phrase, $glb_simp_sat_phrase, $glb_sat_seed, $glb_file_key, $glb_ite_lim);
      }
      else{
        single_iterative_decipher($glb_reg_sat_phrase, $glb_dip_sat_phrase, $glb_simp_sat_phrase, $glb_sat_seed, $glb_file_key, $glb_ite_lim);
      }
    }
    else{
      parallel_part();
    }
  }
  else{
    help_part();
  }
}

sub help_part{
  printf "################################################################################################################################################################################################################################################################# \n";
  printf "# Usage:       perl tempus.pl -ef=<FileName> -ed=<FileDir> -of=<FileName> -ox=<ExecFile> -kf=<FileName> -a=<FileName> -p=<FileName> -satreg=<int> -satdip=<int> -satsimp=<int> -st=<int> -ss=<int> -qt=<int> -qn=<int> -orst -tt=<int> -il=<int> -sid -an=<int> # \n";
  printf "#                             -con=helloctf/csaw19 -nvk -v=0/1                                                                                                                                                                                                  # \n";
  printf "# ef:          Name of the encrypted file in bench format                                                                                                                                                                                                       # \n";
  printf "# ed:          Name of the directory including encrypted files in bench format                                                                                                                                                                                  # \n";
  printf "# of:          Name of the oracle file in bench format                                                                                                                                                                                                          # \n";
  printf "# ox:          Name of the oracle executable                                                                                                                                                                                                                    # \n";
  printf "# kf:          Name of the key file including values of key inputs where unknown values are denoted as x                                                                                                                                                        # \n";
  printf "# a:           Name of the file including assumptions on key inputs described as gates as in the bench file                                                                                                                                                     # \n";
  printf "# p:           Name of the file including paths to the tools by default it is paths.pl under the same directory of tempus                                                                                                                                       # \n";
  printf "# satreg:      SAT solver used for regular tasks by default it is 1                                                                                                                                                                                             # \n";
  printf "#                0: cryptominisat                                                                                                                                                                                                                               # \n";
  printf "#                1: lingeling                                                                                                                                                                                                                                   # \n";
  printf "#                2: plingeling - parallel                                                                                                                                                                                                                       # \n";
  printf "#                3: ilingeling - incremental                                                                                                                                                                                                                    # \n";
  printf "#                4: riss                                                                                                                                                                                                                                        # \n";
  printf "#                5: glucose41                                                                                                                                                                                                                                   # \n";
  printf "#                6: glucose30_simp - incremental                                                                                                                                                                                                                # \n";
  printf "#                7: glucose30_core - incremental                                                                                                                                                                                                                # \n";
  printf "#                8: CaDiCaL                                                                                                                                                                                                                                     # \n";
  printf "# satdip:      SAT solver used for finding DIP and proving key values (incremental tasks) by default it is 8                                                                                                                                                    # \n";
  printf "#                0: cryptominisat                                                                                                                                                                                                                               # \n";
  printf "#                1: lingeling                                                                                                                                                                                                                                   # \n";
  printf "#                2: plingeling - parallel                                                                                                                                                                                                                       # \n";
  printf "#                3: ilingeling - incremental                                                                                                                                                                                                                    # \n";
  printf "#                4: riss                                                                                                                                                                                                                                        # \n";
  printf "#                5: glucose41                                                                                                                                                                                                                                   # \n";
  printf "#                6: glucose30_simp - incremental                                                                                                                                                                                                                # \n";
  printf "#                7: glucose30_core - incremental                                                                                                                                                                                                                # \n";
  printf "#                8: CaDiCaL - incremental                                                                                                                                                                                                                       # \n";
  printf "# satsimp:     SAT solver used for simplifying the SAT problem by default it is 1                                                                                                                                                                               # \n";
  printf "#                0: cryptominisat                                                                                                                                                                                                                               # \n";
  printf "#                1: CaDiCaL                                                                                                                                                                                                                                     # \n";
  printf "# st:          Run-time limit for the SAT solver in seconds by default it is infinity                                                                                                                                                                           # \n";
  printf "# ss:          Seed for the randomness in the SAT solver by default it is 1                                                                                                                                                                                     # \n";
  printf "# qt:          Technique for obtaining queries by default it is 4                                                                                                                                                                                               # \n";
  printf "#                0: none                                                                                                                                                                                                                                        # \n";
  printf "#                1: random                                                                                                                                                                                                                                      # \n";
  printf "#                2: using ATPG tool Atalanta targeting key inputs                                                                                                                                                                                               # \n";
  printf "#                3: using ATPG tool Atalanta targeting all wires                                                                                                                                                                                                # \n";
  printf "#                4: using ATPG tool Atalanta targeting key inputs + random                                                                                                                                                                                      # \n";
  printf "# qn:          Number of queries to be considered by default it is twice of the number of keyinputs                                                                                                                                                             # \n";
  printf "# orst:        Restricts the output values to be selected while finding the DIP by default it does not                                                                                                                                                          # \n";
  printf "# tt:          Run-time limit for the attack in seconds by default it is infinity                                                                                                                                                                               # \n";
  printf "# il:          Limit on the number of iterations by defaults it is infinity                                                                                                                                                                                     # \n";
  printf "# sid:         Deciphers the encrypted logic iteratively using single attack by default it does not                                                                                                                                                             # \n";
  printf "# an:          Number of attacks running on the locked circuit by default it is 1                                                                                                                                                                               # \n";
  printf "# con:         Name of the contest which provides the executable oracle by default it is helloctf                                                                                                                                                               # \n";
  printf "# cone:        Name of the output related to all the key bits by default it is empty                                                                                                                                                                            # \n";
  printf "# nvk:         Prevents running verification/simulation to check if the found key is the scret key by default it does not                                                                                                                                       # \n";
  printf "# v:           Verbosity level by default it is 0 and does not show any information                                                                                                                                                                             # \n";
  printf "# Description: This code implements the famous SAT attack                                                                                                                                                                                                       # \n";
  printf "################################################################################################################################################################################################################################################################# \n";
}

sub skip_spaces_forward{
  my ($the_string, $the_offset) = @_;
  my $the_length = length($the_string);

  while (index($the_string, " ", $the_offset) eq $the_offset) {
    $the_offset++;
    if ($the_offset > $the_length) {
      last;
    }
  }

  return $the_offset;
}

sub skip_spaces_backward{
  my ($the_string, $the_offset) = @_;

  while (index($the_string, " ", $the_offset) eq $the_offset) {
    $the_offset--;
    if ($the_offset < 0) {
      last;
    }
  }

  return $the_offset;
}

sub add_backforward_slash{
  my ($the_string) = @_;

  if (index($the_string, "/") != -1){
    $the_string .= "/";
  }
  elsif (index($the_string, "\\") != -1){
    $the_string .= "\\"
  }

  return ($the_string);
}

sub print_array_ind{
  my ($the_label, $the_ind, $the_arr_ref) = @_;

  print "$the_label=";
  print "$the_arr_ref->[$the_ind] ";
  print "\n";
}

sub print_dip_array{
  my ($the_label, $the_cnt, $the_arr_ref) = @_;

  print "$the_label=";
  for (my $i = 0; $i < $the_cnt; $i++){
    print "$the_arr_ref->[$i]";
  }
  print "\n";
}

sub print_array{
  my ($the_label, $the_cnt, $the_arr_ref) = @_;

  print "$the_label=";
  for (my $i = 0; $i < $the_cnt; $i++){
    if (defined $the_arr_ref->[$i] ){
      print "$the_arr_ref->[$i] ";
    }
    else{
      print "\n Not defined: $i \n";
    }
  }
  print "\n";
}

sub print_matrix{
  my ($the_label, $row_num, $col_num, $the_matrix_ref) = @_;

  print "$the_label=\n";
  for (my $i = 0; $i < $row_num; $i++){
    for (my $j = 0; $j < $col_num; $j++){
      print "$the_matrix_ref->[$i][$j] ";
    }
    print "\n";
  }
}

sub print_gate_matrix_ind{
  my ($the_label, $the_ind, $the_matrix_ref) = @_;

  my $the_index = 0;

  print "$the_label=";
  $the_index = 0;
  while ($the_matrix_ref->[$the_ind][$the_index] != -1){
    print "$the_matrix_ref->[$the_ind][$the_index] ";
    $the_index++;
  }
  print "\n";
}

sub print_gate_matrix{
  my ($the_label, $row_num, $the_matrix_ref) = @_;

  my $the_index = 0;

  print "$the_label=\n";
  for (my $i = 0; $i < $row_num; $i++){
    $the_index = 0;
    while ($the_matrix_ref->[$i][$the_index] != -1){
      print "$the_matrix_ref->[$i][$the_index] ";
      $the_index++;
    }
    print "\n";
  }
}

sub extract_tool_path{
  my ($paths_file, $search_phrase) = @_;

  my $path_ok = 0;
  my $path_algo = "";

  if (-e $paths_file){
    my $the_index = 0;
    my $init_index = 0;
    my $last_index = 0;

    if (open (my $file_header, '<:encoding(UTF-8)', $paths_file)){
      while (my $the_line = <$file_header>){
        chomp $the_line;
        #print "$the_line \n";

        $the_index = index ($the_line, "=");

        if ($the_index >= 0){
          $init_index = skip_spaces_forward($the_line, 0);
          $last_index = skip_spaces_backward($the_line, $the_index-1);
          my $the_solver = substr($the_line, $init_index, $last_index-$init_index+1);
          #print "the_solver: $the_solver \n";

          $init_index = skip_spaces_forward($the_line, $the_index+1);
          $last_index = skip_spaces_backward($the_line, length($the_line));
          my $the_path = substr($the_line, $init_index, $last_index-$init_index+1);
          #print "the_path: $the_path \n";

          if ($the_path =~ /[0-9a-zA-Z_]/ ){
            if ($the_solver eq $search_phrase){
              $path_algo = $the_path;
              $path_ok = 1;
              last;
            }
          }
        }
      }

      if ($path_algo eq ""){
        print "[ERROR] The path to the $search_phrase could not be extracted from the $paths_file file! \n";
        exit (1);
      }

      close ($file_header);
    }
    else{
      print "[ERROR] Could not open the $paths_file file! \n";
      exit (1);
    }
  }
  else{
    print "[ERROR] Could not find the $paths_file file including paths to solvers! \n";
    exit (1);
  }

  return ($path_ok, $path_algo);
}

sub negate_array{
  my ($the_cnt, $the_arr_ref) = @_;

  for (my $i=0; $i<$the_cnt; $i++){
    $the_arr_ref->[$i] = 1-$the_arr_ref->[$i];
  }

  return ($the_arr_ref);
}

sub is_equal_two_numeric_arrays{
  my ($the_cnt, $one_ref, $two_ref) = @_;
 
  for (my $i=0; $i<$the_cnt; $i++){
    if ($one_ref->[$i] != $two_ref->[$i]){
      return (0)
    }
  }

  return (1);
}

sub initialize_restricted_input_array{
  my ($in_cnt) = @_;

  my @in_arr = ();

  for (my $i=0; $i<$in_cnt; $i++){
    $in_arr[$i] = 2;
  }

  return (\@in_arr);
}

sub initialize_defined_key_values_array{
  my ($key_cnt) = @_;

  my @key_arr = ();

  for (my $i=0; $i<$key_cnt; $i++){
    $key_arr[$i] = 2;
  }

  return (\@key_arr);
}

sub where_is_inside_numeric_array{
  my ($the_input, $the_cnt, $the_arr_ref) = @_;

  for (my $i=0; $i<$the_cnt; $i++){
    if ($the_input == $the_arr_ref->[$i]){
      return ($i);
    }
  }

  return (-1);
}

sub where_is_inside_label_matrix{
  my ($the_input, $lbl_cnt, $the_col, $lbl_mat_ref) = @_;

  for (my $i=0; $i<$lbl_cnt; $i++){
    if ($the_input eq $lbl_mat_ref->[$i][$the_col]){
      return ($i);
    }
  }

  return (-1);
}

sub where_is_inside_array_numeric_matrix{
  my ($arr_ref, $the_row, $the_col, $mat_ref) = @_;

  for (my $i=0; $i<$the_row; $i++){
    my $the_same = 1;
    for (my $j=0; $j<$the_col; $j++){
      if ($arr_ref->[$j] != $mat_ref->[$i][$j]){
        $the_same = 0;
        last;
      }
    }

    if ($the_same){
      return ($i);
    }
  }

  return (-1);
}

sub int2bin{
  my ($the_int, $the_len) = @_;

  my @the_rep = ();

  foreach my $i (1 .. $the_len){
    $the_rep[$i] = 0;
  }

  my $the_index = 0;
  while ($the_int > 1){
    my $the_val = $the_int % 2;
    $the_rep[$the_index] = $the_val;
    $the_int = ($the_int - $the_val) / 2;
    $the_index++;
  }

  $the_rep[$the_index] = $the_int;

  return (\@the_rep);
}

sub find_backforward_slash{
  my ($the_string) = @_;

  my $is_bfs = -1;

  if (index($the_string, "/") != -1){
    $is_bfs = 1;
  }
  elsif (index($the_string, "\\") != -1){
    $is_bfs = 0
  }

  return ($is_bfs);
}

sub extract_file_name_directory{
  my ($the_file) = @_;

  my ($file_name, $file_dir) = "";
  my $the_cwd = cwd;

  #Find the bfs in the current working directory
  my $is_bfs = find_backforward_slash($the_cwd);

  ##Extract the file name and directory
  my $the_index = length($the_file);
  while (substr($the_file, $the_index, 1) ne "." and substr($the_file, $the_index, 1) ne "\\" and substr($the_file, $the_index, 1) ne "/"){
    $the_index--;

    if ($the_index < 0){
      last;
    }
  }
  if ($the_index <= 0){
    $file_name = $the_file;
    $file_dir = $the_cwd;
    if ($is_bfs == 0){ $file_dir .= "\\";}else{$file_dir .= "/";}
  }
  elsif (substr($the_file, $the_index, 1) eq "\\" or substr($the_file, $the_index, 1) eq "/"){
    $file_name = substr($the_file, $the_index+1, length($the_file)-$the_index);
    $file_dir = substr($the_file, 0, $the_index+1);
  }
  else{
    $the_index--;
    my $init_index = $the_index;
    while (substr($the_file, $init_index, 1) ne "\\" and substr($the_file, $init_index, 1) ne "/"){
      $init_index--;

      if ($init_index < 0){
        last;
      }
    }

    $file_name = substr($the_file, $init_index+1, $the_index-$init_index);

    if ($init_index<0){
      $file_dir = $the_cwd;
      if ($is_bfs == 0){ $file_dir .= "\\";}else{$file_dir .= "/";}
    }
    else{
      $file_dir = substr($the_file, 0, $init_index+1);
    }
  }

  return ($file_name, $file_dir);
}

sub write_cnfstr_and_val{
  my ($cla_cnt, $cnf_str, $the_output, $the_output_val, $in_cnt, $in_arr, $in_val_arr) = @_;

  my $no_cnf = 0;
  my $the_cnf = "";
  for (my $i=0; $i<$in_cnt; $i++){
    if ($in_val_arr->[$i] == 2 and $the_output_val == 2){
      $cnf_str .= $in_arr->[$i] . " -" . $the_output . " 0\n";
      $cla_cnt++;
    }
    #Can be removed after constant propagation is guaranteed to be done fully
    elsif ($in_val_arr->[$i] == 0 and $the_output_val == 2){
      $cnf_str .= " -" . $the_output . " 0\n";
      $cla_cnt++;
    }
    elsif ($in_val_arr->[$i] == 2 and $the_output_val == 1){
      $cnf_str .= $in_arr->[$i] . " 0\n";
      $cla_cnt++;
    }

    if ($no_cnf == 0){
      if ($in_val_arr->[$i] == 2){
        $the_cnf .= "-" . $in_arr->[$i] . " ";
      }
      elsif ($in_val_arr->[$i] == 0){
        $no_cnf = 1;
      }
    }
  }
  if ($no_cnf == 0){
    if ($the_output_val == 2){
      $cnf_str .= $the_cnf . $the_output . " 0\n";
      $cla_cnt++;
    }
    elsif ($the_output_val == 0){
      $cnf_str .= $the_cnf . "0\n";
      $cla_cnt++;
    }
  }

  return ($cla_cnt, $cnf_str);
}

sub write_cnfstr_and{
  my ($cnf_str, $the_output, $in_cnt, $in_arr_ref) = @_;

  my $the_cnf = "";
  for (my $i=0; $i<$in_cnt; $i++){
    $cnf_str .= $in_arr_ref->[$i] . " -" . $the_output . " 0\n";
    #printf $fid_cnf "%d -%d 0 \n", $in_arr_ref->[$i], $the_output;
    $the_cnf .= "-" . $in_arr_ref->[$i] . " ";
  }
  $cnf_str .= $the_cnf . $the_output . " 0\n";
  #printf $fid_cnf "%s%d 0 \n", $the_cnf, $the_output;

  return ($cnf_str);
}

sub write_cnfstr_nand_val{
  my ($cla_cnt, $cnf_str, $the_output, $the_output_val, $in_cnt, $in_arr, $in_val_arr) = @_;

  my $no_cnf = 0;
  my $the_cnf = "";
  for (my $i=0; $i<$in_cnt; $i++){
    if ($in_val_arr->[$i] == 2 and $the_output_val == 2){
      $cnf_str .= $in_arr->[$i] . " " . $the_output . " 0\n";
      $cla_cnt++;
    }
    elsif ($in_val_arr->[$i] == 0 and $the_output_val == 2){
      $cnf_str .= $the_output . " 0\n";
      $cla_cnt++;
    }
    elsif ($in_val_arr->[$i] == 2 and $the_output_val == 0){
      $cnf_str .= $in_arr->[$i] . " 0\n";
      $cla_cnt++;
    } 

    if ($no_cnf == 0){
      if ($in_val_arr->[$i] == 2){
        $the_cnf .= "-" . $in_arr->[$i] . " ";
      }
      elsif ($in_val_arr->[$i] == 0){
        $no_cnf = 1;
      }
    }
  }
  if ($no_cnf == 0){
    if ($the_output_val == 2){
      $cnf_str .= $the_cnf . "-" . $the_output . " 0\n";
      $cla_cnt++;
    }
    elsif ($the_output_val == 1){
      $cnf_str .= $the_cnf . "0\n";
      $cla_cnt++;
    }
  }

  return ($cla_cnt, $cnf_str);
}

sub write_cnfstr_nand{
  my ($cnf_str, $the_output, $in_cnt, $in_arr_ref) = @_;

  my $the_cnf = "";
  for (my $i=0; $i<$in_cnt; $i++){
    $cnf_str .= $in_arr_ref->[$i] . " " . $the_output . " 0\n";
    #printf $fid_cnf "%d %d 0 \n", $in_arr_ref->[$i], $the_output;
    $the_cnf .= "-" . $in_arr_ref->[$i] . " ";
  }
  $cnf_str .= $the_cnf . "-" . $the_output . " 0\n";
  #printf $fid_cnf "%s-%d 0 \n", $the_cnf, $the_output;

  return ($cnf_str);
}

sub write_cnfstr_buf{
  my ($cnf_str, $the_output, $in_cnt, $in_arr_ref) = @_;

  $cnf_str .= $in_arr_ref->[0] . " -" . $the_output . " 0\n";
  $cnf_str .= "-" . $in_arr_ref->[0] . " " . $the_output . " 0\n";
  #printf $fid_cnf "%d -%d 0 \n", $in_arr_ref->[0], $the_output;
  #printf $fid_cnf "-%d %d 0 \n", $in_arr_ref->[0], $the_output;

  return ($cnf_str);
}

sub write_cnfstr_buf_val{
  my ($cla_cnt, $cnf_str, $the_output, $the_output_val, $in_cnt, $in_arr, $in_val_arr) = @_;

  if ($in_val_arr->[0] == 2 and $the_output_val == 2){
    $cnf_str .= $in_arr->[0] . " -" . $the_output . " 0\n";
    $cla_cnt++;

    $cnf_str .= "-" . $in_arr->[0] . " " . $the_output . " 0\n";
    $cla_cnt++;
  }
  elsif ($in_val_arr->[0] == 0 and $the_output_val == 2){
    $cnf_str .= " -" . $the_output . " 0\n";
    $cla_cnt++;
  }
  elsif ($in_val_arr->[0] == 2 and $the_output_val == 1){
    $cnf_str .= $in_arr->[0] . " 0\n";
    $cla_cnt++;
  }
  elsif ($in_val_arr->[0] == 1 and $the_output_val == 2){
    $cnf_str .= $the_output . " 0\n";
    $cla_cnt++;
  }
  elsif ($in_val_arr->[0] == 2 and $the_output_val == 0){
    $cnf_str .= "-" . $in_arr->[0] . " 0\n";
    $cla_cnt++;
  }
  
  return ($cla_cnt, $cnf_str);
}


sub write_cnfstr_not{
  my ($cnf_str, $the_output, $in_cnt, $in_arr_ref) = @_;

  $cnf_str .= "-" . $in_arr_ref->[0] . " -" . $the_output . " 0\n";
  $cnf_str .= $in_arr_ref->[0] . " " . $the_output . " 0\n";
  #printf $fid_cnf "-%d -%d 0 \n", $in_arr_ref->[0], $the_output;
  #printf $fid_cnf "%d %d 0 \n", $in_arr_ref->[0], $the_output;

  return ($cnf_str);
}

sub write_cnfstr_not_val{
  my ($cla_cnt, $cnf_str, $the_output, $the_output_val, $in_cnt, $in_arr, $in_val_arr) = @_;

  if ($in_val_arr->[0] == 2 and $the_output_val == 2){
    $cnf_str .= "-" . $in_arr->[0] . " -" . $the_output . " 0\n";
    $cla_cnt++;
    
    $cnf_str .= $in_arr->[0] . " " . $the_output . " 0\n";
    $cla_cnt++;
  }
  elsif ($in_val_arr->[0] == 1 and $the_output_val == 2){
    $cnf_str .= " -" . $the_output . " 0\n";
    $cla_cnt++;
  }
  elsif ($in_val_arr->[0] == 2 and $the_output_val == 1){
    $cnf_str .= "-" . $in_arr->[0] . " 0\n";
    $cla_cnt++;
  }
  elsif ($in_val_arr->[0] == 0 and $the_output_val == 2){
    $cnf_str .= $the_output . " 0\n";
    $cla_cnt++;
  }
  elsif ($in_val_arr->[0] == 2 and $the_output_val == 0){
    $cnf_str .= $in_arr->[0] . " 0\n";
    $cla_cnt++;
  }

  return ($cla_cnt, $cnf_str);
}

sub write_cnfstr_or{
  my ($cnf_str, $the_output, $in_cnt, $in_arr_ref) = @_;

  my $the_cnf = "";
  for (my $i=0; $i<$in_cnt; $i++){
    $cnf_str .= "-" . $in_arr_ref->[$i] . " " . $the_output . " 0\n";
    #printf $fid_cnf "-%d %d 0 \n", $in_arr_ref->[$i], $the_output;
    $the_cnf .= $in_arr_ref->[$i] . " ";
  }
  $cnf_str .= $the_cnf . "-" . $the_output . " 0\n";
  #printf $fid_cnf "%s-%d 0 \n", $the_cnf, $the_output;

  return ($cnf_str);
}

sub write_cnfstr_or_val{
  my ($cla_cnt, $cnf_str, $the_output, $the_output_val, $in_cnt, $in_arr, $in_val_arr) = @_;

  my $no_cnf = 0;
  my $the_cnf = "";
  for (my $i=0; $i<$in_cnt; $i++){
    if ($in_val_arr->[$i] == 2 and $the_output_val == 2){
      $cnf_str .= "-" . $in_arr->[$i] . " " . $the_output . " 0\n";
      $cla_cnt++;
    }
    elsif ($in_val_arr->[$i] == 1 and $the_output_val == 2){
      $cnf_str .= $the_output . " 0\n";
      $cla_cnt++;
    }
    elsif ($in_val_arr->[$i] == 2 and $the_output_val == 0){
      $cnf_str .= "-" . $in_arr->[$i] . " 0\n";
      $cla_cnt++;
    }

    if ($no_cnf == 0){
      if ($in_val_arr->[$i] == 2){
        $the_cnf .= $in_arr->[$i] . " ";
      }
      elsif ($in_val_arr->[$i] == 1){
        $no_cnf = 1;
      }
    }
  }

  if ($no_cnf == 0){
    if ($the_output_val == 2){
      $cnf_str .= $the_cnf . "-" . $the_output . " 0\n";
      $cla_cnt++;
    }
    elsif ($the_output_val == 1){
      $cnf_str .= $the_cnf . "0\n";
      $cla_cnt++;
    }
  }

  return ($cla_cnt, $cnf_str);
}

sub write_cnfstr_nor{
  my ($cnf_str, $the_output, $in_cnt, $in_arr_ref) = @_;

  my $the_cnf = "";
  for (my $i=0; $i<$in_cnt; $i++){
    $cnf_str .= "-" . $in_arr_ref->[$i] . " -" . $the_output . " 0\n";
    #printf $fid_cnf "-%d -%d 0 \n", $in_arr_ref->[$i], $the_output;
    $the_cnf .= $in_arr_ref->[$i] . " ";
  }
  $cnf_str .= $the_cnf . $the_output . " 0\n";
  #printf $fid_cnf "%s%d 0 \n", $the_cnf, $the_output;

  return ($cnf_str);
}

sub write_cnfstr_nor_val{
  my ($cla_cnt, $cnf_str, $the_output, $the_output_val, $in_cnt, $in_arr, $in_val_arr) = @_;

  my $no_cnf = 0;
  my $the_cnf = "";
  for (my $i=0; $i<$in_cnt; $i++){
    if ($in_val_arr->[$i] == 2 and $the_output_val == 2){
      $cnf_str .= "-" . $in_arr->[$i] . " -" . $the_output . " 0\n";
      $cla_cnt++;
    }
    elsif ($in_val_arr->[$i] == 1 and $the_output_val == 2){
      $cnf_str .= " -" . $the_output . " 0\n";
      $cla_cnt++;
    }
    if ($in_val_arr->[$i] == 2 and $the_output_val == 1){
      $cnf_str .= "-" . $in_arr->[$i] . " 0\n";
      $cla_cnt++;
    }
    
    if ($no_cnf == 0){
      if ($in_val_arr->[$i] == 2){
        $the_cnf .= $in_arr->[$i] . " ";
      }
      elsif ($in_val_arr->[$i] == 1){
        $no_cnf = 1;
      }
    }
  }

  if ($no_cnf == 0){
    if ($the_output_val == 2){
      $cnf_str .= $the_cnf . " " . $the_output . " 0\n";
      $cla_cnt++;
    }
    elsif ($the_output_val == 0){
      $cnf_str .= $the_cnf . "0\n";
      $cla_cnt++;
    }
  }

  return ($cla_cnt, $cnf_str);
}

sub write_cnfstr_xnor2{
  my ($cnf_str, $the_output, $in_cnt, $in_arr_ref) = @_;

  $cnf_str .= $in_arr_ref->[0] . " " . $in_arr_ref->[1] . " " . $the_output . " 0\n";
  $cnf_str .= $in_arr_ref->[0] . " -" . $in_arr_ref->[1] . " -" . $the_output . " 0\n";
  $cnf_str .= "-" . $in_arr_ref->[0] . " " . $in_arr_ref->[1] . " -" . $the_output . " 0\n";
  $cnf_str .= "-" . $in_arr_ref->[0] . " -" . $in_arr_ref->[1] . " " . $the_output . " 0\n";

  #printf $fid_cnf "%d %d %d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  #printf $fid_cnf "%d -%d -%d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  #printf $fid_cnf "-%d %d -%d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  #printf $fid_cnf "-%d -%d %d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;

  return ($cnf_str);
}

sub write_cnfstr_xnor2_val{
  my ($cla_cnt, $cnf_str, $the_output, $the_output_val, $in_cnt, $in_arr, $in_val_arr) = @_;

  my $no_cnf = 0;
  my $the_cnf = "";
  #$cnf_str .= $in_arr_ref->[0] . " " . $in_arr_ref->[1] . " " . $the_output . " 0\n";
  if ($in_val_arr->[0] == 2){
    $the_cnf .= $in_arr->[0] . " ";
  }
  elsif ($in_val_arr->[0] == 1){
    $no_cnf = 1;
  }
  if ($in_val_arr->[1] == 2){
    $the_cnf .= $in_arr->[1] . " ";
  }
  elsif ($in_val_arr->[1] == 1){
    $no_cnf = 1;
  }
  if ($the_output_val == 2){
    $the_cnf .= $the_output . " ";
  }
  elsif ($the_output_val == 1){
    $no_cnf = 1;
  }
  if ($no_cnf == 0 and $the_cnf ne ""){
    $cnf_str .= $the_cnf . "0\n";
    $cla_cnt++;
  }

  $no_cnf = 0;
  $the_cnf = "";
  #$cnf_str .= $in_arr_ref->[0] . " -" . $in_arr_ref->[1] . " -" . $the_output . " 0\n";
  if ($in_val_arr->[0] == 2){
    $the_cnf .= $in_arr->[0] . " ";
  }
  elsif ($in_val_arr->[0] == 1){
    $no_cnf = 1;
  }
  if ($in_val_arr->[1] == 2){
    $the_cnf .= "-" . $in_arr->[1] . " ";
  }
  elsif ($in_val_arr->[1] == 0){
    $no_cnf = 1;
  }
  if ($the_output_val == 2){
    $the_cnf .= "-" . $the_output . " ";
  }
  elsif ($the_output_val == 0){
    $no_cnf = 1;
  }
  if ($no_cnf == 0 and $the_cnf ne ""){
    $cnf_str .= $the_cnf . "0\n";
    $cla_cnt++;
  }

  $no_cnf = 0;
  $the_cnf = "";
  #$cnf_str .= "-" . $in_arr_ref->[0] . " " . $in_arr_ref->[1] . " -" . $the_output . " 0\n";
  if ($in_val_arr->[0] == 2){
    $the_cnf .= "-" . $in_arr->[0] . " ";
  }
  elsif ($in_val_arr->[0] == 0){
    $no_cnf = 1;
  }
  if ($in_val_arr->[1] == 2){
    $the_cnf .= $in_arr->[1] . " ";
  }
  elsif ($in_val_arr->[1] == 1){
    $no_cnf = 1;
  }
  if ($the_output_val == 2){
    $the_cnf .= "-" . $the_output . " ";
  }
  elsif ($the_output_val == 0){
    $no_cnf = 1;
  }
  if ($no_cnf == 0 and $the_cnf ne ""){
    $cnf_str .= $the_cnf . "0\n";
    $cla_cnt++;
  }

  $no_cnf = 0;
  $the_cnf = "";
  #$cnf_str .= "-" . $in_arr_ref->[0] . " -" . $in_arr_ref->[1] . " " . $the_output . " 0\n";
  if ($in_val_arr->[0] == 2){
    $the_cnf .= "-" . $in_arr->[0] . " ";
  }
  elsif ($in_val_arr->[0] == 0){
    $no_cnf = 1;
  }
  if ($in_val_arr->[1] == 2){
    $the_cnf .= "-" . $in_arr->[1] . " ";
  }
  elsif ($in_val_arr->[1] == 0){
    $no_cnf = 1;
  }
  if ($the_output_val == 2){
    $the_cnf .= $the_output . " ";
  }
  elsif ($the_output_val == 1){
    $no_cnf = 1;
  }
  if ($no_cnf == 0 and $the_cnf ne ""){
    $cnf_str .= $the_cnf . "0\n";
    $cla_cnt++;
  }

  return ($cla_cnt, $cnf_str);
}

sub write_cnfstr_xor2{
  my ($cnf_str, $the_output, $in_cnt, $in_arr_ref) = @_;

  $cnf_str .=  $in_arr_ref->[0] . " " . $in_arr_ref->[1] . " -" . $the_output . " 0\n";
  $cnf_str .=  $in_arr_ref->[0] . " -" . $in_arr_ref->[1] . " " . $the_output . " 0\n";
  $cnf_str .=  "-" . $in_arr_ref->[0] . " " . $in_arr_ref->[1] . " " . $the_output . " 0\n";
  $cnf_str .=  "-" . $in_arr_ref->[0] . " -" . $in_arr_ref->[1] . " -" . $the_output . " 0\n";

  #printf $fid_cnf "%d %d -%d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  #printf $fid_cnf "%d -%d %d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  #printf $fid_cnf "-%d %d %d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  #printf $fid_cnf "-%d -%d -%d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;

  return ($cnf_str);
}

sub write_cnfstr_xor2_assumption{
  my ($cnf_str, $the_output, $in_cnt, $in_arr_ref) = @_;

  $cnf_str .=  "a " . $in_arr_ref->[0] . " " . $in_arr_ref->[1] . " -" . $the_output . " 0\n";
  $cnf_str .=  "a " . $in_arr_ref->[0] . " -" . $in_arr_ref->[1] . " " . $the_output . " 0\n";
  $cnf_str .=  "a -" . $in_arr_ref->[0] . " " . $in_arr_ref->[1] . " " . $the_output . " 0\n";
  $cnf_str .=  "a -" . $in_arr_ref->[0] . " -" . $in_arr_ref->[1] . " -" . $the_output . " 0\n";

  #printf $fid_cnf "%d %d -%d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  #printf $fid_cnf "%d -%d %d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  #printf $fid_cnf "-%d %d %d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  #printf $fid_cnf "-%d -%d -%d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;

  return ($cnf_str);
}

sub write_cnfstr_xor2_val{
  my ($cla_cnt, $cnf_str, $the_output, $the_output_val, $in_cnt, $in_arr, $in_val_arr) = @_;

  my $no_cnf = 0;
  my $the_cnf = "";
  #$cnf_str .=  $in_arr_ref->[0] . " " . $in_arr_ref->[1] . " -" . $the_output . " 0\n";
  if ($in_val_arr->[0] == 2){
    $the_cnf .= $in_arr->[0] . " ";
  }
  elsif ($in_val_arr->[0] == 1){
    $no_cnf = 1;
  }
  if ($in_val_arr->[1] == 2){
    $the_cnf .= $in_arr->[1] . " ";
  }
  elsif ($in_val_arr->[1] == 1){
    $no_cnf = 1;
  } 
  if ($the_output_val == 2){
    $the_cnf .= "-" . $the_output . " ";
  }
  elsif ($the_output_val == 0){
    $no_cnf = 1;
  }
  if ($no_cnf == 0 and $the_cnf ne ""){
    $cnf_str .= $the_cnf . "0\n";
    $cla_cnt++;
  }

  $no_cnf = 0;
  $the_cnf = "";
  #$cnf_str .=  $in_arr_ref->[0] . " -" . $in_arr_ref->[1] . " " . $the_output . " 0\n";
  if ($in_val_arr->[0] == 2){
    $the_cnf .= $in_arr->[0] . " ";
  }
  elsif ($in_val_arr->[0] == 1){
    $no_cnf = 1;
  }
  if ($in_val_arr->[1] == 2){
    $the_cnf .= "-" . $in_arr->[1] . " ";
  }
  elsif ($in_val_arr->[1] == 0){
    $no_cnf = 1;
  }
  if ($the_output_val == 2){
    $the_cnf .= $the_output . " ";
  }
  elsif ($the_output_val == 1){
    $no_cnf = 1;
  }
  if ($no_cnf == 0 and $the_cnf ne ""){
    $cnf_str .= $the_cnf . "0\n";
    $cla_cnt++;
  }

  $no_cnf = 0;
  $the_cnf = "";
  #$cnf_str .=  "-" . $in_arr_ref->[0] . " " . $in_arr_ref->[1] . " " . $the_output . " 0\n";
  if ($in_val_arr->[0] == 2){
    $the_cnf .= "-" . $in_arr->[0] . " ";
  }
  elsif ($in_val_arr->[0] == 0){
    $no_cnf = 1;
  }
  if ($in_val_arr->[1] == 2){
    $the_cnf .= $in_arr->[1] . " ";
  }
  elsif ($in_val_arr->[1] == 1){
    $no_cnf = 1;
  }
  if ($the_output_val == 2){
    $the_cnf .= $the_output . " ";
  }
  elsif ($the_output_val == 1){
    $no_cnf = 1;
  }
  if ($no_cnf == 0 and $the_cnf ne ""){
    $cnf_str .= $the_cnf . "0\n";
    $cla_cnt++;
  }

  $no_cnf = 0;
  $the_cnf = "";
  #$cnf_str .=  "-" . $in_arr_ref->[0] . " -" . $in_arr_ref->[1] . " -" . $the_output . " 0\n";
  if ($in_val_arr->[0] == 2){
    $the_cnf .= "-" . $in_arr->[0] . " ";
  }
  elsif ($in_val_arr->[0] == 0){
    $no_cnf = 1;
  }
  if ($in_val_arr->[1] == 2){
    $the_cnf .= "-" . $in_arr->[1] . " ";
  }
  elsif ($in_val_arr->[1] == 0){
    $no_cnf = 1;
  }
  if ($the_output_val == 2){
    $the_cnf .= "-" . $the_output . " ";
  }
  elsif ($the_output_val == 0){
    $no_cnf = 1;
  }
  if ($no_cnf == 0 and $the_cnf ne ""){
    $cnf_str .= $the_cnf . "0\n";
    $cla_cnt++;
  }

  return ($cla_cnt, $cnf_str);
}

sub write_cnf_and{
  my ($fid_cnf, $the_output, $in_cnt, $in_arr_ref) = @_;

  my $cnf_str = "";
  for (my $i=0; $i<$in_cnt; $i++){
    printf $fid_cnf "%d -%d 0 \n", $in_arr_ref->[$i], $the_output;
    $cnf_str .= "-" . $in_arr_ref->[$i] . " ";
  }
  printf $fid_cnf "%s%d 0 \n", $cnf_str, $the_output;
}

sub write_cnf_nand{
  my ($fid_cnf, $the_output, $in_cnt, $in_arr_ref) = @_;

  my $cnf_str = "";
  for (my $i=0; $i<$in_cnt; $i++){
    printf $fid_cnf "%d %d 0 \n", $in_arr_ref->[$i], $the_output;
    $cnf_str .= "-" . $in_arr_ref->[$i] . " ";
  }
  printf $fid_cnf "%s-%d 0 \n", $cnf_str, $the_output;
}

sub write_cnf_buf{
  my ($fid_cnf, $the_output, $in_cnt, $in_arr_ref) = @_;

  printf $fid_cnf "%d -%d 0 \n", $in_arr_ref->[0], $the_output;
  printf $fid_cnf "-%d %d 0 \n", $in_arr_ref->[0], $the_output;
}

sub write_cnf_not{
  my ($fid_cnf, $the_output, $in_cnt, $in_arr_ref) = @_;

  printf $fid_cnf "-%d -%d 0 \n", $in_arr_ref->[0], $the_output;
  printf $fid_cnf "%d %d 0 \n", $in_arr_ref->[0], $the_output;
}

sub write_cnf_or{
  my ($fid_cnf, $the_output, $in_cnt, $in_arr_ref) = @_;

  my $cnf_str = "";
  for (my $i=0; $i<$in_cnt; $i++){
    printf $fid_cnf "-%d %d 0 \n", $in_arr_ref->[$i], $the_output;
    $cnf_str .= $in_arr_ref->[$i] . " ";
  }
  printf $fid_cnf "%s-%d 0 \n", $cnf_str, $the_output;
}

sub write_cnf_nor{
  my ($fid_cnf, $the_output, $in_cnt, $in_arr_ref) = @_;

  my $cnf_str = "";
  for (my $i=0; $i<$in_cnt; $i++){
    printf $fid_cnf "-%d -%d 0 \n", $in_arr_ref->[$i], $the_output;
    $cnf_str .= $in_arr_ref->[$i] . " ";
  }
  printf $fid_cnf "%s%d 0 \n", $cnf_str, $the_output;
}

sub write_cnf_xnor2{
  my ($fid_cnf, $the_output, $in_cnt, $in_arr_ref) = @_;

  printf $fid_cnf "%d %d %d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  printf $fid_cnf "%d -%d -%d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  printf $fid_cnf "-%d %d -%d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  printf $fid_cnf "-%d -%d %d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
}

sub write_cnf_xor2{
  my ($fid_cnf, $the_output, $in_cnt, $in_arr_ref) = @_;

  printf $fid_cnf "%d %d -%d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  printf $fid_cnf "%d -%d %d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  printf $fid_cnf "-%d %d %d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
  printf $fid_cnf "-%d -%d -%d 0 \n", $in_arr_ref->[0], $in_arr_ref->[1], $the_output;
}

sub add_key_assumptions{
  my ($file_keas, $cla_cnt, $enc_key_cnt, $enc_key_lbl_ref, $dkey_key_lbl_ref, $cnf_str) = @_;

  my $is_err = 0; 

  my $the_char = "";
  my $the_index = 0;
  my $init_index = 0;
  my $last_index = 0;

  my $oper_type = "";
  my $oper_in_lbl = "";
  my $oper_out_lbl = "";

  my $oper_in_cnt = 0;
  my $oper_one_output = 0;
  my $oper_two_output = 0;
  my @oper_one_in_arr = ();
  my @oper_two_in_arr = ();

  $cnf_str .= "c Adding the key input assumptions... \n";

  if (open (my $file_header, '<:encoding(UTF-8)', $file_keas)){
    while (my $the_line = <$file_header>){
      chomp $the_line;
      #print "$the_line \n";

      ($init_index) = skip_spaces_forward($the_line, 0);
      if (substr($the_line, $init_index, 1) ne "#"){ #Avoid the comment line
        #Read the OPERATIONs
        if (index($the_line, "=") != -1){
          #OPERATION OUTPUT
          ($init_index) = skip_spaces_forward($the_line, 0);
          $last_index = $init_index;
          while (1){
            $the_char = substr($the_line, $last_index, 1);
            if ($the_char ne " " and $the_char ne "="){
              $last_index++;
            }
            else{
              last;
            }
          }

          $oper_out_lbl = substr($the_line, $init_index, $last_index-$init_index);
          #print "oper_out_lbl: $oper_out_lbl \n";
          #sleep (1);

          #Determine its variable
          ($the_index) = where_is_inside_label_matrix($oper_out_lbl, $enc_key_cnt, 0, $enc_key_lbl_ref);
          if ($the_index != -1){
            $oper_one_output = $dkey_key_lbl_ref->[ $the_index ];
            $oper_two_output = $dkey_key_lbl_ref->[ $enc_key_cnt+$the_index ];
          }
          else{
            print "[ERROR] Given assumption $the_line is not related to a key input \n";
            $is_err = 1;
            last;
          }

          #OPERATION TYPE
          ($init_index) = skip_spaces_forward($the_line, $last_index);
          if (substr($the_line, $init_index, 1) eq "="){
            ($init_index) = skip_spaces_forward($the_line, $init_index+1);
            $last_index = $init_index;

            while (1){
              $the_char = substr($the_line, $last_index, 1);
              if ($the_char ne " " and $the_char ne "("){
                $last_index++;
              }
              else{
                last;
              }
            }

            $oper_type = substr($the_line, $init_index, $last_index-$init_index);
            #print "oper_type: $oper_type \n";

            #OPERATION INPUTs
            $oper_in_cnt = 0;
            ($init_index) = skip_spaces_forward($the_line, $last_index);
            if (substr($the_line, $init_index, 1) eq "("){
              while (1){
                ($init_index) = skip_spaces_forward($the_line, $init_index+1);
                $last_index = $init_index;

                while (1){
                  $the_char = substr($the_line, $last_index, 1);
                  if ($the_char ne " " and $the_char ne "," and $the_char ne ")"){
                    $last_index++;
                  }
                  else{
                    last;
                  }
                }

                $oper_in_lbl = substr($the_line, $init_index, $last_index-$init_index);
                #print "oper_in_lbl: $oper_in_lbl \n";
                #sleep (1);

                ($the_index) = where_is_inside_label_matrix($oper_in_lbl, $enc_key_cnt, 0, $enc_key_lbl_ref);
                if ($the_index != -1){
                  $oper_one_in_arr[$oper_in_cnt] = $dkey_key_lbl_ref->[ $the_index ];
                  $oper_two_in_arr[$oper_in_cnt] = $dkey_key_lbl_ref->[ $enc_key_cnt+$the_index ];
                }
                else{
                  print "[ERROR] Given assumption $the_line is not related to a key input \n";
                  $is_err = 1;
                  last;
                }
                $oper_in_cnt++;

                ($last_index) = skip_spaces_forward($the_line, $last_index);
                if (substr($the_line, $last_index, 1) eq ")"){
                  last;
                }
                else{
                  $init_index = $last_index;
                }
              }

              if ($is_err == 0){
                if ($oper_type eq "AND" or $oper_type eq "and"){
                  ($cnf_str) = write_cnfstr_and($cnf_str, $oper_one_output, $oper_in_cnt, \@oper_one_in_arr);
                  ($cnf_str) = write_cnfstr_and($cnf_str, $oper_two_output, $oper_in_cnt, \@oper_two_in_arr);
                  $cla_cnt += ($oper_in_cnt + 1)*2;
                }
                elsif($oper_type eq "OR" or $oper_type eq "or"){
                  ($cnf_str) = write_cnfstr_or($cnf_str, $oper_one_output, $oper_in_cnt, \@oper_one_in_arr);
                  ($cnf_str) = write_cnfstr_or($cnf_str, $oper_two_output, $oper_in_cnt, \@oper_two_in_arr);
                  $cla_cnt += ($oper_in_cnt + 1)*2;
                }
                elsif($oper_type eq "NAND" or $oper_type eq "nand"){
                  ($cnf_str) = write_cnfstr_nand($cnf_str, $oper_one_output, $oper_in_cnt, \@oper_one_in_arr);
                  ($cnf_str) = write_cnfstr_nand($cnf_str, $oper_two_output, $oper_in_cnt, \@oper_two_in_arr);
                  $cla_cnt += ($oper_in_cnt + 1)*2;
                }
                elsif($oper_type eq "NOR" or $oper_type eq "nor"){
                  ($cnf_str) = write_cnfstr_nor($cnf_str, $oper_one_output, $oper_in_cnt, \@oper_one_in_arr);
                  ($cnf_str) = write_cnfstr_nor($cnf_str, $oper_two_output, $oper_in_cnt, \@oper_two_in_arr);
                  $cla_cnt += ($oper_in_cnt + 1)*2;
                }
                elsif($oper_type eq "NOT" or $oper_type eq "not"){
                  ($cnf_str) = write_cnfstr_not($cnf_str, $oper_one_output, $oper_in_cnt, \@oper_one_in_arr);
                  ($cnf_str) = write_cnfstr_not($cnf_str, $oper_two_output, $oper_in_cnt, \@oper_two_in_arr);
                  $cla_cnt += ($oper_in_cnt + 1)*2;
                }
                elsif($oper_type eq "BUFF" or $oper_type eq "buff" or $oper_type eq "BUF" or $oper_type eq "buf"){
                  ($cnf_str) = write_cnfstr_buf($cnf_str, $oper_one_output, $oper_in_cnt, \@oper_one_in_arr);
                  ($cnf_str) = write_cnfstr_buf($cnf_str, $oper_two_output, $oper_in_cnt, \@oper_two_in_arr);
                  $cla_cnt += ($oper_in_cnt + 1)*2;
                }
                elsif($oper_type eq "XOR" or $oper_type eq "xor"){
                  if ($oper_in_cnt == 2){
                    ($cnf_str) = write_cnfstr_xor2($cnf_str, $oper_one_output, $oper_in_cnt, \@oper_one_in_arr);
                    ($cnf_str) = write_cnfstr_xor2($cnf_str, $oper_two_output, $oper_in_cnt, \@oper_two_in_arr);
                    $cla_cnt += 8;
                  }
                  else{
                    printf "[ERROR] An XOR gate with more than 2 inputs is not READY yet! \n";
                    $is_err = 1;
                    last;
                  }
                }
                elsif($oper_type eq "XNOR" or $oper_type eq "xnor"){
                  if ($oper_in_cnt == 2){
                    ($cnf_str) = write_cnfstr_xnor2($cnf_str, $oper_one_output, $oper_in_cnt, \@oper_one_in_arr);
                    ($cnf_str) = write_cnfstr_xnor2($cnf_str, $oper_two_output, $oper_in_cnt, \@oper_two_in_arr);
                    $cla_cnt += 8;
                  }
                  else{
                    printf "[ERROR] An XNOR gate with more than 2 inputs is not READY yet! \n";
                    $is_err = 1;
                    last;
                  }
                }
                else{
                  print "[ERROR] Unknown gate type is $oper_type! \n";
                  $is_err = 1;
                  last;
                }
              }
            }
            else{
              print "[ERROR] Inputs of an operation should be given in paranthesis - $the_line \n";
              $is_err = 1;
              last;
            }
          }
        }
      }
      if ($is_err){
        last;
      }
    }

    close ($file_header);
  }
  else{
    $is_err = 1;
    print "[ERROR] Could not open the $file_keas file! \n";
  }
  
  #print "vars_cnt: $var_cnt cla_cnt: $cla_cnt \n";

  #print "cnf_str: $cnf_str \n";
  #print "in_cnt: $in_cnt out_cnt: $out_cnt \n";
  #print_matrix("in_lbl", $in_cnt, 2, $in_lbl_ref);
  #print_matrix("key_lbl", $key_cnt, 2, $key_lbl_ref);
  #print_matrix("out_lbl_val", $out_cnt, 1, \@out_lbl);
  #print_matrix("out_lbl_ind", $out_cnt, 2, \@out_lbl);
  #print_matrix("lbl_mat", $lbl_cnt, 4, \@lbl_mat);
  #print_gate_matrix("gate_matrix", $gate_cnt, \@gate_mat);

  #close ($fid_lbl);

  return ($is_err, $cla_cnt, $cnf_str)
}

sub add_defined_key_values{
  my ($file_key, $cla_cnt, $key_cnt, $key_lbl_ref, $cnf_str, $key_arr_ref) = @_;
 
  my $the_char = "";
  my $the_index = 0;
  my $bit_cnt = 0;
  my $is_err = 0;
  
  if ($the_verb){print "[INFO] Adding the defined key values... \n";}

  if (open (my $file_header, '<:encoding(UTF-8)', $file_key)){
    $cnf_str .= "c Inclusion of defined key values \n";
    while (my $the_line = <$file_header>){
      chomp $the_line;
      #print "the_line: $the_line \n";

      while ($bit_cnt < $key_cnt){
        $the_char = substr($the_line, $the_index, 1);
        if ($the_char eq "0"){
          $key_arr_ref->[$bit_cnt] = 0;
          $cnf_str .= "-" . $key_lbl_ref->[$bit_cnt] . " 0\n";
          $cnf_str .= "-" . $key_lbl_ref->[$key_cnt+$bit_cnt] . " 0\n";
          $cla_cnt++;
          $cla_cnt++;
          $bit_cnt++;
        }
        elsif ($the_char eq "1"){
          $key_arr_ref->[$bit_cnt] = 1;
          $cnf_str .= $key_lbl_ref->[$bit_cnt] . " 0\n";
          $cnf_str .= $key_lbl_ref->[$key_cnt+$bit_cnt] . " 0\n";
          $cla_cnt++;
          $cla_cnt++;
          $bit_cnt++;
        }
        elsif ($the_char eq "x" or $the_char eq "X"){
          $bit_cnt++;
        }

        $the_index++;
        if ($the_index >= length($the_line)){
          last;
        }
      }
    }

    if ($bit_cnt != $key_cnt){
      $is_err = 1;
      print "[ERROR] Number of keys in the $file_key file does not match with the given one! \n";
    }

    close ($file_header);
  }
  else{
    $is_err = 1;
    print "[ERROR] Could not open the $file_key file! \n";
  }

  return ($is_err, $cla_cnt, $cnf_str, $key_arr_ref);
}

sub convert_bench_cnf{
  my ($the_file) = @_;

  my $is_err = 0;
  my $in_cnt = 0;
  my $err_key = 0;
  my $key_cnt = 0;
  my $out_cnt = 0;
  my @in_lbl = ();
  my $var_cnt = 0;
  my $cla_cnt = 0;
  my @po_arr = ();
  my $cnf_str = "";
  my @key_lbl = ();
  my @out_lbl = ();

  my $the_index;
  my $init_index;
  my $last_index;

  my $lbl_cnt = 0;
  my @lbl_mat = ();

  my $gate_cnt = 0;
  my @gate_mat = ();

  my $the_char;
  my $the_input;
  my $the_output;

  my $oper_type;
  my $oper_in_cnt;
  my @oper_in_arr;
  my $oper_output;
  my $oper_in_lbl;
  my $oper_out_lbl;

  #my $file_lbl = $file_dir . $file_name . ".lbl";
  #open (my $fid_lbl, '>', $file_lbl);

  if (open (my $file_header, '<:encoding(UTF-8)', $the_file)){
    while (my $the_line = <$file_header>){
      chomp $the_line;
      #print "$the_line \n";
      my $lline = length($the_line);

      ($init_index) = skip_spaces_forward($the_line, 0);
      if (substr($the_line, $init_index, 1) ne "#"){ #Avoid the comment line
        #Read the INPUTs
        if (index($the_line, "INPUT") != -1){
          $init_index = index($the_line, "(");
          ($init_index) = skip_spaces_forward($the_line, $init_index+1);
          $last_index = index($the_line, ")");
          ($last_index) = skip_spaces_backward($the_line, $last_index-1);

          $the_input = substr($the_line, $init_index, $last_index-$init_index+1);
          #print "the_input: $the_input \n";
          $var_cnt++;
          #printf $fid_lbl "%d = %s \n", $var_cnt, $the_input;
          
          if (index($the_input, "keyinput") != -1){
            if (where_is_inside_label_matrix($the_input, $key_cnt, 0, \@key_lbl) == -1){
              $lbl_mat[$lbl_cnt][0] = $the_input;
              $lbl_mat[$lbl_cnt][1] = $var_cnt;
              $lbl_mat[$lbl_cnt][2] = 0; #Denotes its level
              $lbl_mat[$lbl_cnt][3] = -1; #Denotes its gate
              $lbl_cnt++;

              $key_lbl[$key_cnt][0] = $the_input;
              $key_lbl[$key_cnt][1] = $var_cnt;
              $key_cnt++;
            }
            else{
              print "[ERROR] There exist multiple keyinputs of $the_input! \n";
              $is_err = 1;
              last;
            }
          }
          else{
            if (where_is_inside_label_matrix($the_input, $in_cnt, 0, \@in_lbl) == -1){
              $lbl_mat[$lbl_cnt][0] = $the_input;
              $lbl_mat[$lbl_cnt][1] = $var_cnt;
              $lbl_mat[$lbl_cnt][2] = 0; #Denotes its level
              $lbl_mat[$lbl_cnt][3] = -1; #Denotes its gate
              $lbl_cnt++;

              $in_lbl[$in_cnt][0] = $the_input;
              $in_lbl[$in_cnt][1] = $var_cnt;
              $in_cnt++;
            }
            else{
              print "[ERROR] There exist multiple inputs of $the_input! \n";
              $is_err = 1;
              last;
            }
          }
        }
        #Read the OUTPUTs
        elsif (index($the_line, "OUTPUT") != -1){
          $init_index = index($the_line, "(");
          ($init_index) = skip_spaces_forward($the_line, $init_index+1);
          $last_index = index($the_line, ")");
          ($last_index) = skip_spaces_backward($the_line, $last_index-1);

          $the_output = substr($the_line, $init_index, $last_index-$init_index+1);
          #print "the_output: $the_output \n";
          $var_cnt++;
          #printf $fid_lbl "%d = %s \n", $var_cnt, $the_output;

          if (where_is_inside_label_matrix($the_output, $out_cnt, 0, \@out_lbl) == -1){
            $lbl_mat[$lbl_cnt][0] = $the_output;
            $lbl_mat[$lbl_cnt][1] = $var_cnt;
            $lbl_mat[$lbl_cnt][2] = -1; #Denotes its level
            $lbl_mat[$lbl_cnt][3] = -1; #Denotes its gate
            $lbl_cnt++;

            $out_lbl[$out_cnt][0] = $the_output;
            $out_lbl[$out_cnt][1] = $var_cnt;
            $out_cnt++;
          }
          else{
            print "[ERROR] There exist multiple otputs of $the_output! \n";
            $is_err = 1;
            last;
          }
        }
        #Read the OPERATIONs
        elsif (index($the_line, "=") != -1){
          $oper_in_cnt = 0;

          #OPERATION OUTPUT
          ($init_index) = skip_spaces_forward($the_line, 0);
          $last_index = $init_index;
          while (1){
            $the_char = substr($the_line, $last_index, 1);
            if ($the_char ne " " and $the_char ne "="){
              $last_index++;
            }
            else{
              last;
            }
          }

          $oper_out_lbl = substr($the_line, $init_index, $last_index-$init_index);
          #print "oper_out_lbl: $oper_out_lbl \n";

          #Determine if it is a primary output
          ($the_index) = where_is_inside_label_matrix($oper_out_lbl, $out_cnt, 0, \@out_lbl);
          $po_arr[$gate_cnt] = $the_index;

          #Determine its variable
          ($the_index) = where_is_inside_label_matrix($oper_out_lbl, $lbl_cnt, 0, \@lbl_mat);
          if ($the_index != -1){
            $oper_output = $lbl_mat[$the_index][1];
            $lbl_mat[$the_index][3] = $gate_cnt;
          }
          else{
            $var_cnt++;
            $oper_output = $var_cnt;
            #printf $fid_lbl "%d = %s \n", $var_cnt, $oper_out_lbl;
            
            $lbl_mat[$lbl_cnt][0] = $oper_out_lbl;
            $lbl_mat[$lbl_cnt][1] = $var_cnt;
            $lbl_mat[$lbl_cnt][2] = -1; #Denotes its level
            $lbl_mat[$lbl_cnt][3] = $gate_cnt;
            $lbl_cnt++;
          }
          $gate_mat[$gate_cnt][0] = $oper_output;

          #OPERATION TYPE
          ($init_index) = skip_spaces_forward($the_line, $last_index);
          if (substr($the_line, $init_index, 1) eq "="){
            ($init_index) = skip_spaces_forward($the_line, $init_index+1);
            $last_index = $init_index;

            while (1){
              $the_char = substr($the_line, $last_index, 1);
              if ($the_char ne " " and $the_char ne "("){
                $last_index++;

                if ($last_index > $lline){
                  last;
                }
              }
              else{
                last;
              }
            }

            $oper_type = substr($the_line, $init_index, $last_index-$init_index);
            #print "oper_type: $oper_type \n";

            if ($oper_type eq "vdd"){
              $oper_in_cnt = 2;
              $oper_type = "XNOR";
              $oper_in_arr[0] = $in_lbl[0][1];
              $oper_in_arr[1] = $in_lbl[0][1];
              $gate_mat[$gate_cnt][2] = $oper_in_arr[0];
              $gate_mat[$gate_cnt][3] = $oper_in_arr[0];
              goto GATE_LIST;
            }
            elsif ($oper_type eq "gnd"){
              $oper_in_cnt = 2;
              $oper_type = "XOR";
              $oper_in_arr[0] = $in_lbl[0][1];
              $oper_in_arr[1] = $in_lbl[0][1];
              $gate_mat[$gate_cnt][2] = $oper_in_arr[0];
              $gate_mat[$gate_cnt][3] = $oper_in_arr[0];
              goto GATE_LIST;
            }
            
            #OPERATION INPUTs
            ($init_index) = skip_spaces_forward($the_line, $last_index);
            if (substr($the_line, $init_index, 1) eq "("){
              while (1){
                ($init_index) = skip_spaces_forward($the_line, $init_index+1);
                $last_index = $init_index;

                while (1){
                  $the_char = substr($the_line, $last_index, 1);
                  if ($the_char ne " " and $the_char ne "," and $the_char ne ")"){
                    $last_index++;
                  }
                  else{
                    last;
                  }
                }

                $oper_in_lbl = substr($the_line, $init_index, $last_index-$init_index);
                #print "oper_in_lbl: $oper_in_lbl \n";

                ($the_index) = where_is_inside_label_matrix($oper_in_lbl, $lbl_cnt, 0, \@lbl_mat);
                if ($the_index != -1){
                  $oper_in_arr[$oper_in_cnt] = $lbl_mat[$the_index][1];
                }
                else{
                  $var_cnt++;
                  $oper_in_arr[$oper_in_cnt] = $var_cnt;
                  #printf $fid_lbl "%d = %s \n", $var_cnt, $oper_in_lbl;

                  $lbl_mat[$lbl_cnt][0] = $oper_in_lbl;
                  $lbl_mat[$lbl_cnt][1] = $var_cnt;
                  $lbl_mat[$lbl_cnt][2] = -1; #Denotes its level
                  $lbl_cnt++;
                }
                $gate_mat[$gate_cnt][$oper_in_cnt+2] = $oper_in_arr[$oper_in_cnt];

                $oper_in_cnt++;

                ($last_index) = skip_spaces_forward($the_line, $last_index);
                if (substr($the_line, $last_index, 1) eq ")"){
                  last;
                }
                else{
                  $init_index = $last_index;
                }
              }
            }
            else{
              print "[ERROR] Inputs of an operation should be given in paranthesis - $the_line \n";
              $is_err = 1;
              last;
            }

            GATE_LIST:
            if ($oper_type eq "AND" or $oper_type eq "and"){
              ($cnf_str) = write_cnfstr_and($cnf_str, $oper_output, $oper_in_cnt, \@oper_in_arr);
              $cla_cnt += $oper_in_cnt + 1;
              
              $gate_mat[$gate_cnt][$oper_in_cnt+2] = -1;
              $gate_mat[$gate_cnt][1] = 0;
              $gate_cnt++;
            }
            elsif($oper_type eq "OR" or $oper_type eq "or"){
              ($cnf_str) = write_cnfstr_or($cnf_str, $oper_output, $oper_in_cnt, \@oper_in_arr);
              $cla_cnt += $oper_in_cnt + 1;
              
              $gate_mat[$gate_cnt][$oper_in_cnt+2] = -1;
              $gate_mat[$gate_cnt][1] = 2;
              $gate_cnt++;
            }
            elsif($oper_type eq "NOT" or $oper_type eq "not"){
              ($cnf_str) = write_cnfstr_not($cnf_str, $oper_output, $oper_in_cnt, \@oper_in_arr);
              $cla_cnt += $oper_in_cnt + 1;
              
              $gate_mat[$gate_cnt][$oper_in_cnt+2] = -1;
              $gate_mat[$gate_cnt][1] = 5;
              $gate_cnt++;
            }
            elsif($oper_type eq "BUFF" or $oper_type eq "buff" or $oper_type eq "BUF" or $oper_type eq "buf"){
              ($cnf_str) = write_cnfstr_buf($cnf_str, $oper_output, $oper_in_cnt, \@oper_in_arr);
              $cla_cnt += $oper_in_cnt + 1;
              
              $gate_mat[$gate_cnt][$oper_in_cnt+2] = -1;
              $gate_mat[$gate_cnt][1] = 1;
              $gate_cnt++;
            }
            elsif($oper_type eq "XOR" or $oper_type eq "xor"){
              if ($oper_in_cnt == 2){
                ($cnf_str) = write_cnfstr_xor2($cnf_str, $oper_output, $oper_in_cnt, \@oper_in_arr);
                $cla_cnt += 4;
              }
              else{
                printf "[ERROR] An XOR gate with more than 2 inputs is not READY yet! \n";
                $is_err = 1;
                last;
              }

              $gate_mat[$gate_cnt][$oper_in_cnt+2] = -1;
              $gate_mat[$gate_cnt][1] = 3;
              $gate_cnt++;
            }
            elsif($oper_type eq "XNOR" or $oper_type eq "xnor"){
              if ($oper_in_cnt == 2){
                ($cnf_str) = write_cnfstr_xnor2($cnf_str, $oper_output, $oper_in_cnt, \@oper_in_arr);
                $cla_cnt += 4;
              }
              else{
                printf "[ERROR] An XNOR gate with more than 2 inputs is not READY yet! \n";
                $is_err = 1;
                last;
              }
              
              $gate_mat[$gate_cnt][$oper_in_cnt+2] = -1;
              $gate_mat[$gate_cnt][1] = 7;
              $gate_cnt++;
            }
            elsif($oper_type eq "NAND" or $oper_type eq "nand"){
              ($cnf_str) = write_cnfstr_nand($cnf_str, $oper_output, $oper_in_cnt, \@oper_in_arr);
              $cla_cnt += $oper_in_cnt + 1;
              
              $gate_mat[$gate_cnt][$oper_in_cnt+2] = -1;
              $gate_mat[$gate_cnt][1] = 4;
              $gate_cnt++;
            }
            elsif($oper_type eq "NOR" or $oper_type eq "nor"){
              ($cnf_str) = write_cnfstr_nor($cnf_str, $oper_output, $oper_in_cnt, \@oper_in_arr);
              $cla_cnt += $oper_in_cnt + 1;
              
              $gate_mat[$gate_cnt][$oper_in_cnt+2] = -1;
              $gate_mat[$gate_cnt][1] = 6;
              $gate_cnt++;
            }
            else{
              print "[ERROR] Unknown gate type is $oper_type! \n";
              $is_err = 1;
              last;
            }
          }
        }
      }

      if ($is_err){
        last;
      }
    }

    close ($file_header);
  }
  else{
    $is_err = 1;
    print "[ERROR] Could not open the $the_file file! \n";
  }
  
  #print "vars_cnt: $var_cnt cla_cnt: $cla_cnt \n";

  #print "cnf_str: $cnf_str \n";
  #print "in_cnt: $in_cnt out_cnt: $out_cnt \n";
  #print_matrix("in_lbl", $in_cnt, 2, $in_lbl_ref);
  #print_matrix("key_lbl", $key_cnt, 2, $key_lbl_ref);
  #print_matrix("out_lbl_val", $out_cnt, 1, \@out_lbl);
  #print_matrix("out_lbl_ind", $out_cnt, 2, \@out_lbl);
  #print_matrix("lbl_mat", $lbl_cnt, 4, \@lbl_mat);
  #print_gate_matrix("gate_matrix", $gate_cnt, \@gate_mat);

  #close ($fid_lbl);

  return ($is_err, $var_cnt, $cla_cnt, $in_cnt, \@in_lbl, $key_cnt, \@key_lbl, $out_cnt, \@out_lbl, $lbl_cnt, \@lbl_mat, $gate_cnt, \@po_arr, \@gate_mat, $cnf_str);
}

sub file_read_glucose_core_solution_extract_data{
  my ($file_sol, $data_cnt, $data_lbl_ref) = @_;
  
  #my $init_ess = time();

  my $the_var = 0;
  my $var_sign = 0;
  my @out_val = ();
  my $the_line = "";
  my $the_char = "";
  my $sol_found = -1; 
 
  if (open (my $file_header, '<:encoding(UTF-8)', $file_sol)) {
    $the_line = <$file_header>;
    if ($the_line){
      chomp $the_line;
      #print "[INFO] The line: $the_line \n";
      #sleep 1;
      
      if (index($the_line,"UNSAT") != -1){
        $sol_found = 0;
      }
      elsif (index($the_line, "INDETERMINATE") != -1){
        $sol_found = 2;
      }
      elsif (index($the_line, "SAT") != -1){
        $sol_found = 1;
      }
    }

    if ($sol_found == 1){
      read ($file_header, $the_line, 50*$data_lbl_ref->[$data_cnt-1][1]);
      #chomp $the_line;
      #print "[INFO] The line: $the_line \n";
      #sleep (1);

      #Initialize the out_val array
      for (my $i=0; $i<$data_cnt; $i++){
        $out_val[$i] = 2;
      }

      #Extract the values of variables in the SAT problem
      while (1){
        my $init_index = 0;

        while (1){
          $the_var = 0;
          $var_sign = 0;

          $the_char = substr($the_line, $init_index, 1);
          if ($the_char eq "-"){
            $var_sign = 1;
          }
          else{
            $the_var += $the_char;
          }
          $init_index++;

          while (1){
            $the_char = substr($the_line, $init_index, 1);
            if ($the_char eq " "){
              last;
            }
            else{
              $the_var *= 10;
              $the_var += $the_char;
            }
            $init_index++;
          }

          #print "[INFO] solution variable: $the_var variable sign: $var_sign \n";
          #sleep (1);

          if ($the_var >= $data_lbl_ref->[0][1] and $the_var <= $data_lbl_ref->[$data_cnt-1][1]){
            #my ($the_index) = where_is_inside_label_matrix(abs($the_var), $data_cnt, 1, $data_lbl_ref);
            my ($the_index) = $the_var - $data_lbl_ref->[0][1];
            if ($var_sign){
              $out_val[$the_index] = 0;
            }
            else{
              $out_val[$the_index] = 1;
            }
          }
          elsif ($the_var > $data_lbl_ref->[$data_cnt-1][1]){
            $the_var = 0;
            last;
          }

          $init_index = skip_spaces_forward($the_line, $init_index+1);
          if ($init_index >= length($the_line)){
            last;
          }
        }

        if ($the_var == 0){
          last;
        }
      }
    }

    close $file_header;
  }
  else{
    print "[ERROR] Could not open the $file_sol file! \n";
  }
  
  #if($the_verb){printf "[INFO] Time of the ess function: %.2f \n", time()-$init_ess;}

  return ($sol_found, \@out_val);
}

sub file_read_glucose_solution_extract_data{
  my ($file_sol, $file_out, $data_cnt, $data_lbl_ref) = @_;
  
  #my $init_ess = time();

  my $the_var = 0;
  my $var_sign = 0;
  my @out_val = ();
  my $the_line = "";
  my $the_char = "";
  my $sol_found = -1; 
 
  if (open (my $file_header, '<:encoding(UTF-8)', $file_out)) {
    while (1){
      $the_line = <$file_header>;
      if ($the_line){
        chomp $the_line;
        #print "[INFO] The line: $the_line \n";
        #sleep 1;
        
        if (index($the_line,"s UNSATISFIABLE") != -1){
          close $file_header;
          $sol_found = 0;
          last;
        }
        elsif (index($the_line, "s INDETERMINATE") != -1){
          close $file_header;
          $sol_found = 2;
          last;
        }
        elsif (index($the_line, "s SATISFIABLE") != -1){
          close $file_header;
          $sol_found = 1;
          last;
        }
      }
      else{
        last;
      }
    }

    if ($sol_found == 1){
      if (open (my $fid_sol, '<:encoding(UTF-8)', $file_sol)) {
        read ($fid_sol, $the_line, 50*$data_lbl_ref->[$data_cnt-1][1]);
        #chomp $the_line;
        #print "[INFO] The line: $the_line \n";
        #sleep (1);

        #Initialize the out_val array
        for (my $i=0; $i<$data_cnt; $i++){
          $out_val[$i] = 2;
        }

        #Extract the values of variables in the SAT problem
        while (1){
          my $init_index = 0;

          while (1){
            $the_var = 0;
            $var_sign = 0;

            $the_char = substr($the_line, $init_index, 1);
            if ($the_char eq "-"){
              $var_sign = 1;
            }
            else{
              $the_var += $the_char;
            }
            $init_index++;

            while (1){
              $the_char = substr($the_line, $init_index, 1);
              if ($the_char eq " "){
                last;
              }
              else{
                $the_var *= 10;
                $the_var += $the_char;
              }
              $init_index++;
            }

            #print "[INFO] solution variable: $the_var variable sign: $var_sign \n";
            #sleep (1);

            if ($the_var >= $data_lbl_ref->[0][1] and $the_var <= $data_lbl_ref->[$data_cnt-1][1]){
              #my ($the_index) = where_is_inside_label_matrix(abs($the_var), $data_cnt, 1, $data_lbl_ref);
              my ($the_index) = $the_var - $data_lbl_ref->[0][1];
              if ($var_sign){
                $out_val[$the_index] = 0;
              }
              else{
                $out_val[$the_index] = 1;
              }
            }
            elsif ($the_var > $data_lbl_ref->[$data_cnt-1][1]){
              $the_var = 0;
              last;
            }

            $init_index = skip_spaces_forward($the_line, $init_index+1);
            if ($init_index >= length($the_line)){
              last;
            }
          }

          if ($the_var == 0){
            last;
          }
        }

        close $fid_sol;
      }
      else{
        $sol_found = 0;
        print "[ERROR] Could not open the glucose solution file! \n";
      }
    }

    close $file_header;
  }
  else{
    print "[ERROR] Could not open the glucose output file! \n";
  }
  
  #if($the_verb){printf "[INFO] Time of the ess function: %.2f \n", time()-$init_ess;}

  return ($sol_found, \@out_val);
}

sub file_read_glucose_solution{
  my ($file_out) = @_;
  
  my $sol_found = -1; 
 
  if (open (my $file_header, '<:encoding(UTF-8)', $file_out)) {
    while (1){
      my $the_line = <$file_header>;
      if ($the_line){
        chomp $the_line;
        #print "[INFO] The line: $the_line \n";
        #sleep 1;
        
        if (index($the_line,"s UNSATISFIABLE") != -1){
          close $file_header;
          $sol_found = 0;
          last;
        }
        elsif (index($the_line, "s INDETERMINATE") != -1){
          close $file_header;
          $sol_found = 2;
          last;
        }
        elsif (index($the_line, "s SATISFIABLE") != -1){
          close $file_header;
          $sol_found = 1;
          last;
        }
      }
      else{
        last;
      }
    }

    close $file_header;
  }
  else{
    print "[ERROR] Could not open the glucose output file! \n";
  }

  return ($sol_found);
}

sub file_read_glucose_core_solution{
  my ($file_out) = @_;
  
  my $sol_found = -1; 
 
  if (open (my $file_header, '<:encoding(UTF-8)', $file_out)) {
    my $the_line = <$file_header>;
    if ($the_line){
      chomp $the_line;
      #print "[INFO] The line: $the_line \n";
      #sleep 1;
      
      if (index($the_line,"UNSAT") != -1){
        $sol_found = 0;
      }
      elsif (index($the_line, "INDETERMINATE") != -1){
        $sol_found = 2;
      }
      elsif (index($the_line, "SAT") != -1){
        $sol_found = 1;
      }
    }

    close $file_header;
  }
  else{
    print "[ERROR] Could not open the $file_out file! \n";
  }

  return ($sol_found);
}

sub file_read_cryptominisat_solution_extract_data{ 
  my ($file_sol, $data_cnt, $data_lbl_ref) = @_;
  
  #my $init_ess = time();

  my $the_var;
  my @out_val = ();
  my $sol_found = -1;
 
  if (open (my $file_header, '<:encoding(UTF-8)', $file_sol)) {
    while (my $the_line = <$file_header>){
      chomp $the_line;
      #print "[INFO] The line: $the_line \n";
      #sleep 1;
      
      if (index($the_line,"s UNSATISFIABLE") != -1){
        close $file_header;
        $sol_found = 0;
        last;
      }
      elsif (index($the_line, "s INDETERMINATE") != -1 or index($the_line, "s UNKNOWN") != -1 or index($the_line, "c UNKNOWN") != -1){
        close $file_header;
        $sol_found = 2;
        last;
      }
      elsif (index($the_line, "s SATISFIABLE") != -1){
        my $the_var = 0;
        $sol_found = 1;

        #Initialize the out_val array
        for (my $i=0; $i<$data_cnt; $i++){
          $out_val[$i] = 2;
        }

        #Extract the values of variables in the SAT problem
        while (1){
          my $the_line = <$file_header>;
          chomp $the_line;
          #print "[INFO] The line: $the_line \n";

          my $init_index = 2;
          my $last_index = 2;
          while (1){
            $last_index = $init_index;
            while (substr($the_line, $last_index, 1) ne " "){
              $last_index++;

              if ($last_index >= length($the_line)){
                last;
              }
            }

            $the_var = substr($the_line, $init_index, $last_index-$init_index) + 0.0;
            #print "[INFO] solution variable: $the_var \n";

            if (abs($the_var) >= $data_lbl_ref->[0][1] and abs($the_var) <= $data_lbl_ref->[$data_cnt-1][1]){
              my ($the_index) = where_is_inside_label_matrix(abs($the_var), $data_cnt, 1, $data_lbl_ref);
              if ($the_index != -1){
                if ($the_var < 0){
                  $out_val[$the_index] = 0;
                }
                else{
                  $out_val[$the_index]= 1;
                }
              }
            }
            elsif (abs($the_var) > $data_lbl_ref->[$data_cnt-1][1]){
              $the_var = 0;
              last;
            }

            $last_index = skip_spaces_forward($the_line, $last_index);
            $init_index = $last_index;

            if ($the_var == 0 or $last_index >= length($the_line)){
              last;
            }
          }

          if ($the_var == 0){
            last;
          }
        }

        last;
      }
    }

    close $file_header;
  }
  else{
    print "[ERROR] Could not open the cryptominisat output! \n";
  }

  #if($the_verb){printf "[INFO] Time of the ess function: %.2f \n", time()-$init_ess;}

  return ($sol_found, \@out_val);
}

sub file_read_cryptominisat_solution{ 
  my ($file_sol) = @_;
  
  my $sol_found = -1;
  
  if (open (my $file_header, '<:encoding(UTF-8)', $file_sol)) {
    while (my $the_line = <$file_header>){
      chomp $the_line;
      #print "[INFO] The line: $the_line \n";
      #sleep 1;
      
      if (index($the_line,"s UNSATISFIABLE") != -1){
        close $file_header;
        $sol_found = 0;
        last;
      }
      elsif (index($the_line, "s INDETERMINATE") != -1 or index($the_line, "s UNKNOWN") != -1){
        close $file_header;
        $sol_found = 2;
        last;
      }
      elsif (index($the_line, "s SATISFIABLE") != -1){
        my $the_var = 0;
        $sol_found = 1;
        last;
      }
    }

    close $file_header;
  }
  else{
    print "[ERROR] Could not open the cryptominisat output! \n";
  }

  return ($sol_found);
}

sub run_sat_solver{
  my ($sat_phrase, $file_dir, $file_name, $the_phrase, $path_sat, $sat_solver_ind, $sat_seed, $data_in_cnt, $data_in_lbl_ref, $option_str) = @_;

  my $init_sat_time = time();

  my $cmd_sat = "";
  my $data_out_ref;
  my $sol_found = -1;
  
  my $cnf_file = $file_dir . $file_name . $the_phrase . ".cnf";
  my $out_file = $file_dir . $file_name . $the_phrase . ".out";
  my $sol_file = $file_dir . $file_name . $the_phrase . ".sol";
 
  ### CaDiCaL
  if ($sat_solver_ind == 8){
    $cmd_sat = $path_sat . " -t " . $sat_lim . " --seed=" . $sat_seed . $option_str . $cnf_file . " > " . $sol_file;
    #print "cmd_sat: $cmd_sat \n";
    system ($cmd_sat);
    
    #READ the SAT SOLUTION and EXTRACT the INPUT
    if ($sat_phrase eq "wdata"){
      ($sol_found, $data_out_ref) = file_read_cryptominisat_solution_extract_data($sol_file, $data_in_cnt, $data_in_lbl_ref);
      #print_dip_array ("data_out_ref", $data_in_cnt, $data_out_ref);
    }
    elsif ($sat_phrase eq "wodata"){
      ($sol_found) = file_read_cryptominisat_solution($sol_file);
    }
  }
  ### GLUCOSE30_CORE
  elsif ($sat_solver_ind == 7){
    $cmd_sat = $path_sat . " -incremental -cpu-lim=" . $sat_lim . " -rnd-seed=" . $sat_seed . $option_str . $cnf_file . " " . $sol_file . " > " . $out_file;
    #print "cmd_sat: $cmd_sat \n";
    system ($cmd_sat);

    #READ the SAT SOLUTION and EXTRACT the OUTPUT 
    if ($sat_phrase eq "wdata"){
      ($sol_found, $data_out_ref) = file_read_glucose_core_solution_extract_data($sol_file, $data_in_cnt, $data_in_lbl_ref);
    }
    elsif ($sat_phrase eq "wodata"){
      ($sol_found) = file_read_glucose_core_solution($sol_file);
    }
  }
  ### GLUCOSE30_SIMP
  elsif ($sat_solver_ind == 6){
    $cmd_sat = $path_sat . " -incremental -cpu-lim=" . $sat_lim . " -rnd-seed=" . $sat_seed . $option_str . $cnf_file . " " . $sol_file . " > " . $out_file;
    #print "cmd_sat: $cmd_sat \n";
    system ($cmd_sat);

    #READ the SAT SOLUTION and EXTRACT the OUTPUT 
    if ($sat_phrase eq "wdata"){
      ($sol_found, $data_out_ref) = file_read_glucose_solution_extract_data($sol_file, $out_file, $data_in_cnt, $data_in_lbl_ref);
    }
    elsif ($sat_phrase eq "wodata"){
      ($sol_found) = file_read_glucose_solution($out_file);
    }
  }
  ### GLUCOSE41
  elsif ($sat_solver_ind == 5){
    $cmd_sat = $path_sat . " -cpu-lim=" . $sat_lim . " -rnd-seed=" . $sat_seed . $option_str . $cnf_file . " " . $sol_file . " > " . $out_file;
    #print "cmd_sat: $cmd_sat \n";
    system ($cmd_sat);

    #READ the SAT SOLUTION and EXTRACT the OUTPUT 
    if ($sat_phrase eq "wdata"){
      ($sol_found, $data_out_ref) = file_read_glucose_solution_extract_data($sol_file, $out_file, $data_in_cnt, $data_in_lbl_ref);
    }
    elsif ($sat_phrase eq "wodata"){
      ($sol_found) = file_read_glucose_solution($out_file);
    }
  }
  ### RISS
  elsif ($sat_solver_ind == 4){
    $cmd_sat = $path_sat . " -cpu-lim=" . $sat_lim . " -rnd-seed=" . $sat_seed . $option_str . $cnf_file ." > " . $sol_file;
    #print "cmd_sat: $cmd_sat \n";
    system ($cmd_sat);
    
    #READ the SAT SOLUTION and EXTRACT the INPUT
    if ($sat_phrase eq "wdata"){
      ($sol_found, $data_out_ref) = file_read_cryptominisat_solution_extract_data($sol_file, $data_in_cnt, $data_in_lbl_ref);
    }
    elsif ($sat_phrase eq "wodata"){
      ($sol_found) = file_read_cryptominisat_solution($sol_file);
    }
    #Remove the solution file Lingeling does not want an existing solution file
    $cmd_sat = "rm " . $sol_file;
    system ($cmd_sat);
  }
  ### ILINGELING
  elsif ($sat_solver_ind == 3){
    #$cmd_sat = $path_sat . " --reduce --no-flush --no-melt " . $cnf_file ." 10 > " . $sol_file;
    $cmd_sat = $path_sat . $option_str . $cnf_file ." 10 > " . $sol_file;
    #print "cmd_sat: $cmd_sat \n";
    system ($cmd_sat);
    
    #READ the SAT SOLUTION and EXTRACT the INPUT
    if ($sat_phrase eq "wdata"){
      ($sol_found, $data_out_ref) = file_read_cryptominisat_solution_extract_data($sol_file, $data_in_cnt, $data_in_lbl_ref);
    }
    elsif ($sat_phrase eq "wodata"){
      ($sol_found) = file_read_cryptominisat_solution($sol_file);
    }
  }
  ### PLINGELING
  elsif ($sat_solver_ind == 2){
    $cmd_sat = $path_sat . $option_str . $cnf_file ." > " . $sol_file;
    #print "cmd_sat: $cmd_sat \n";
    system ($cmd_sat);
    
    #READ the SAT SOLUTION and EXTRACT the INPUT
    if ($sat_phrase eq "wdata"){
      ($sol_found, $data_out_ref) = file_read_cryptominisat_solution_extract_data($sol_file, $data_in_cnt, $data_in_lbl_ref);
    }
    elsif ($sat_phrase eq "wodata"){
      ($sol_found) = file_read_cryptominisat_solution($sol_file);
    }
  }
  ### LINGELING
  elsif ($sat_solver_ind == 1){
    $cmd_sat = $path_sat . " -T " . $sat_lim . " --seed=" . $sat_seed . $option_str . $cnf_file ." > " . $sol_file;
    #print "cmd_sat: $cmd_sat \n";
    system ($cmd_sat);
    
    #READ the SAT SOLUTION and EXTRACT the INPUT
    if ($sat_phrase eq "wdata"){
      ($sol_found, $data_out_ref) = file_read_cryptominisat_solution_extract_data($sol_file, $data_in_cnt, $data_in_lbl_ref);
    }
    elsif ($sat_phrase eq "wodata"){
      ($sol_found) = file_read_cryptominisat_solution($sol_file);
    }
    #Remove the solution file Lingeling does not want an existing solution file
    $cmd_sat = "rm " . $sol_file;
    system ($cmd_sat);
  }
  ### CRYPTOMINISAT
  elsif ($sat_solver_ind == 0){
    $cmd_sat = $path_sat . " --maxtime " . $sat_lim . " --random " . $sat_seed . $option_str . $cnf_file ." > " . $sol_file;
    #print "cmd_sat: $cmd_sat \n";
    system ($cmd_sat);
    
    #READ the SAT SOLUTION and EXTRACT the INPUT
    if ($sat_phrase eq "wdata"){
      ($sol_found, $data_out_ref) = file_read_cryptominisat_solution_extract_data($sol_file, $data_in_cnt, $data_in_lbl_ref);
    }
    elsif ($sat_phrase eq "wodata"){
      ($sol_found) = file_read_cryptominisat_solution($sol_file);
    }
  }

  #if ($the_verb){printf "[INFO] SAT solver time: %.2f \n", time()-$init_sat_time;}

  return ($sol_found, $data_out_ref);
}

sub run_executable_oracle_helloctf{
  my ($file_dir, $file_name, $in_cnt, $out_cnt, $input_arr_ref) = @_;

  my @out_val = ();
  my $dip_out_found = 0;

  my $the_char = "";
  my $the_index = 0;
  my $the_line = "";
  my $out_num = 0;
  my $lline = 0;

  #Run the oracle executable
  my $file_dipout = $file_dir . $file_name . ".dipout";
  my $the_cmd = "/" . $exec_org . " ";
  for (my $i=0; $i<$in_cnt; $i++){
    $the_cmd .= $input_arr_ref->[$i] . " ";
  }
  $the_cmd .= "> " . $file_dipout;
  #print "the_cmd: $the_cmd \n";
  system ($the_cmd);

  if (open (my $file_header, '<:encoding(UTF-8)', $file_dipout)){
    $the_line = <$file_header>;
    chomp $the_line;
    my $lline = length($the_line);
    while ($the_index < $lline){
      $the_char = substr($the_line, $the_index, 1);
      if ($the_char eq "0"){
        $out_val[$out_num] = 0;
        $out_num++;
      }
      elsif ($the_char eq "1"){
        $out_val[$out_num] = 1;
        $out_num++;
      }
      $the_index = skip_spaces_forward($the_line, $the_index+1);
    }

    if ($out_num == $out_cnt){
      $dip_out_found = 1;
    }
    else{
      print "[ERROR] The number of outputs does not match with that in the oracle! \n";
    }
    close ($file_header);
  }
  else{
    print "[ERROR] Could not open the $file_dipout file! \n";
  }

  return ($dip_out_found, \@out_val);
}

sub run_executable_oracle_csaw19{
  my ($file_dir, $file_name, $in_cnt, $out_cnt, $input_arr_ref) = @_;

  my @out_val = ();
  my $dip_out_found = 0;

  my $the_char = "";
  my $the_index = 0;
  my $the_line = "";
  my $out_num = 0;
  my $lline = 0;

  #Run the oracle executable
  my $file_dipout = $file_dir . $file_name . ".dipout";
  my $the_cmd = "./" . $exec_org . " ";
  for (my $i=0; $i<$in_cnt; $i++){
    $the_cmd .= $input_arr_ref->[$i] . " ";
  }
  $the_cmd .= "> " . $file_dipout;
  #print "the_cmd: $the_cmd \n";
  system ($the_cmd);

  if (open (my $file_header, '<:encoding(UTF-8)', $file_dipout)){
    $the_line = <$file_header>;
    #print "the_line: $the_line \n";
    if (index($the_line,"Verilog \$finish") != -1){
      $the_line = <$file_header>;
      chomp $the_line;
      my $lline = length($the_line);
      while ($the_index < $lline){
        $the_char = substr($the_line, $the_index, 1);
        if ($the_char eq "0"){
          $out_val[$out_num] = 0;
          $out_num++;
        }
        elsif ($the_char eq "1"){
          $out_val[$out_num] = 1;
          $out_num++;
        }
        $the_index = skip_spaces_forward($the_line, $the_index+1);
      }

      if ($out_num == $out_cnt){
        $dip_out_found = 1;
      }
      else{
        print "[ERROR] The number of outputs does not match with that in the oracle! \n";
      }
    }

    close ($file_header);
  }
  else{
    print "[ERROR] Could not open the $file_dipout file! \n";
  }

  return ($dip_out_found, \@out_val);
}

sub apply_dip{
  my ($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $input_arr_ref, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str) = @_;

  my $out_val_ref;
  my $dip_out_found = 0;

  if ($file_org ne ""){
    my $sol_found = 0;

    my @in_val = ();
    for (my $i=0; $i<$org_in_cnt; $i++){
      if ($input_arr_ref->[$i] == 0){
        $org_cnf_str .= "-" . $org_in_lbl_ref->[$i][1] . " 0 \n";
        $org_cla_cnt++;
      }
      else{
        $org_cnf_str .= $org_in_lbl_ref->[$i][1] . " 0 \n";
        $org_cla_cnt++;
      }
    }

    #if ($the_verb){print "[INFO] Finding the output according to the given input... \n";}
    
    my $the_phrase = "";
    my $option_str = " ";
    #my $the_phrase = "_dipout";
    my $cnf_file = $file_dir . $file_name . $the_phrase . ".cnf";
    open (my $fid_cnf, '>', $cnf_file);
    printf $fid_cnf "p cnf %d %d \n", $org_var_cnt, $org_cla_cnt;
    printf $fid_cnf "%s", $org_cnf_str;
    close ($fid_cnf);

    ($sol_found, $out_val_ref) = run_sat_solver("wdata", $file_dir, $file_name, $the_phrase, $path_sat, $sat_solver_ind, $sat_seed, $org_out_cnt, $org_out_lbl_ref, $option_str);
    
    if ($sol_found == -1){
      print "[ERROR] SAT solver crashed!!! Returning... \n";
      exit (1);
    }
    elsif ($sol_found == 1){
      $dip_out_found = 1;
    }
  }
  elsif ($exec_org ne ""){
    if ($the_contest eq "helloctf"){
      ($dip_out_found, $out_val_ref) = run_executable_oracle_helloctf($file_dir, $file_name, $org_in_cnt, $org_out_cnt, $input_arr_ref);
    }
    elsif ($the_contest eq "csaw19"){
      ($dip_out_found, $out_val_ref) = run_executable_oracle_csaw19($file_dir, $file_name, $org_in_cnt, $org_out_cnt, $input_arr_ref);
    }
  }

  return ($dip_out_found, $out_val_ref);
}

sub check_regular_rules{
  my ($org_in_cnt, $org_in_lbl_ref, $enc_in_cnt, $enc_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $enc_out_cnt, $enc_out_lbl_ref, $enc_key_cnt) = @_;

  if ($org_in_cnt != $enc_in_cnt){
    print "[ERROR] Number of inputs in the original and encrypted circuits do not match! \n";
    return (0);
  }
  elsif ($org_out_cnt != $enc_out_cnt){
    print "[ERROR] Number of outputs in the original and encrypted circuits do not match! \n";
    return (0);
  }
  elsif ($enc_key_cnt == 0){
    print "[ERROR] There exists no keys in the encrypted circuit! \n";
    return (0);
  }
  
  if ($org_in_cnt == $enc_in_cnt){
    for (my $i=0; $i<$org_in_cnt; $i++){
      if ($org_in_lbl_ref->[$i][0] ne $enc_in_lbl_ref->[$i][0]){
        print "[ERROR] Original $org_in_lbl_ref->[$i][0] and encrypted $enc_in_lbl_ref->[$i][0] inputs do not match! \n";
        return (0);
      }
    }
  }
  
  if ($org_out_cnt == $enc_out_cnt){
    for (my $i=0; $i<$org_out_cnt; $i++){
      if ($org_out_lbl_ref->[$i][0] ne $enc_out_lbl_ref->[$i][0]){
        print "[ERROR] Original $org_out_lbl_ref->[$i][0] and encrypted $enc_out_lbl_ref->[$i][0] outputs do not match! \n";
        return (0);
      }
    }
  }

  return (1);
}

sub generate_dkey_cnf{
  my ($var_cnt, $cla_cnt, $in_cnt, $in_lbl_ref, $key_cnt, $key_lbl_ref, $out_cnt, $out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $gate_cnt, $po_arr_ref, $gate_mat_ref, $cnf_str) = @_;

  #print_matrix("lbl_mat", $enc_lbl_cnt, 3, $enc_lbl_mat_ref);
  #print_gate_matrix("gate_matrix", $gate_cnt, $gate_mat_ref);

  if ($the_verb){print "[INFO] Generating the circuit with two keys... \n";}

  my $the_num = 0;
  my $num_val = 0;
  my $char_cnt = 0;
  my $the_char = "";

  my $in_index = 0;
  my $key_index = 0;
  my $miter_cnf = "";

  my @dkey_key_lbl = ();
  my @dkey_out_lbl = ();
  
  my $gate_index = 0;
  my $gate_output = 0;
  my $gate_in_cnt = 0;
  my @gate_in_arr = ();

  # FIRST KEY
  my $dkey_cnf_str = $cnf_str;
  for (my $i=0; $i<$out_cnt; $i++){
    $dkey_out_lbl[$i] = $out_lbl_ref->[$i][1];
  }
  for (my $i=0; $i<$key_cnt; $i++){
    $dkey_key_lbl[$i] = $key_lbl_ref->[$i][1];
  }

  # SECOND KEY
  # Only the inputs are the same, all the other wires are new
  $dkey_cnf_str .= "c With second keyinputs \n";

  for (my $i=0; $i<$gate_cnt; $i++){
    $gate_output = $var_cnt + $gate_mat_ref->[$i][0] - $in_cnt;

    #Determine the primary output variable name
    if ($po_arr_ref->[$i] != -1){
      $dkey_out_lbl[$out_cnt+$po_arr_ref->[$i]] = $gate_output;
    }

    # Gate inputs
    $gate_index = 0;
    $gate_in_cnt = 0;
    @gate_in_arr = ();
    while ($gate_mat_ref->[$i][$gate_index+2] != -1){
      $in_index = ($gate_mat_ref->[$i][$gate_index+2] <= $in_cnt) ? $gate_mat_ref->[$i][$gate_index+2]-1 : -1; 

      if ($in_index == -1){
        $gate_in_arr[$gate_in_cnt] = $var_cnt + $gate_mat_ref->[$i][$gate_index+2] - $in_cnt;
        
        $key_index = ($gate_mat_ref->[$i][$gate_index+2] - $in_cnt <= $key_cnt) ? $gate_mat_ref->[$i][$gate_index+2] - $in_cnt - 1 : -1;
        if ($key_index != -1){
          $dkey_key_lbl[$key_cnt+$key_index] = $gate_in_arr[$gate_in_cnt];
        }
 
        $gate_in_cnt++;
      }
      else{
        $gate_in_arr[$gate_in_cnt] = $in_lbl_ref->[$in_index][1];
        $gate_in_cnt++;
      }
      
      $gate_index++;
    }
    

    if ($gate_mat_ref->[$i][1] == 0){
      ($dkey_cnf_str) = write_cnfstr_and($dkey_cnf_str, $gate_output, $gate_in_cnt, \@gate_in_arr);
    }
    elsif ($gate_mat_ref->[$i][1] == 1){
      ($dkey_cnf_str) = write_cnfstr_buf($dkey_cnf_str, $gate_output, $gate_in_cnt, \@gate_in_arr);
    }
    elsif ($gate_mat_ref->[$i][1] == 2){
      ($dkey_cnf_str) = write_cnfstr_or($dkey_cnf_str, $gate_output, $gate_in_cnt, \@gate_in_arr);
    }
    elsif ($gate_mat_ref->[$i][1] == 3){
      ($dkey_cnf_str) = write_cnfstr_xor2($dkey_cnf_str, $gate_output, $gate_in_cnt, \@gate_in_arr);
    }
    elsif ($gate_mat_ref->[$i][1] == 4){
      ($dkey_cnf_str) = write_cnfstr_nand($dkey_cnf_str, $gate_output, $gate_in_cnt, \@gate_in_arr);
    }
    elsif ($gate_mat_ref->[$i][1] == 5){
      ($dkey_cnf_str) = write_cnfstr_not($dkey_cnf_str, $gate_output, $gate_in_cnt, \@gate_in_arr);
    }
    elsif ($gate_mat_ref->[$i][1] == 6){
      ($dkey_cnf_str) = write_cnfstr_nor($dkey_cnf_str, $gate_output, $gate_in_cnt, \@gate_in_arr);
    }
    elsif ($gate_mat_ref->[$i][1] == 7){
      ($dkey_cnf_str) = write_cnfstr_xnor2($dkey_cnf_str, $gate_output, $gate_in_cnt, \@gate_in_arr);
    }
  }

  # Update the number of variables and clauses
  $cla_cnt += $cla_cnt;
  $var_cnt += $var_cnt - $in_cnt;

  #Check if there is any dangling keyinputs and replace the ones with the one in the first circuit
  #for (my $i=0; $i<$key_cnt; $i++){
  #  if (defined ($dkey_key_lbl[$i+$key_cnt]) == 0){
  #    $var_cnt++;
  #    $dkey_key_lbl[$i+$key_cnt] = $var_cnt;
  #  }
  #}

  #print_array("out_lbl_ref", $out_cnt*2, \@dkey_out_lbl);
  #print "dkey_cnf_str: $dkey_cnf_str \n"; 
  #print "key_cnt: $key_cnt \n";
  #print_array("dkey_key_lbl", $key_cnt*2, \@dkey_key_lbl);
  
  return ($var_cnt, $cla_cnt, \@dkey_key_lbl, \@dkey_out_lbl, $dkey_cnf_str);
}

sub add_miter_key{
  my ($sat_solver, $var_cnt, $cla_cnt, $key_cnt, $key_lbl_ref, $adkv_arr_ref) = @_;

  my $cnf_str = "";

  $cnf_str .= "c Miter for each keyinput \n";
  my $is_added = 0;
  my $oper_output = 0;
  my $oper_in_cnt = 0;
  my @oper_in_arr = ();
  my $miter_out_str = "";
  #if ($sat_solver == 3){ $miter_out_str .= "a "; }
  
  for (my $i=0; $i<$key_cnt; $i++){
    if ($adkv_arr_ref->[$i] == 2){
      $var_cnt++;
      $is_added = 1;
      $oper_in_cnt = 2;
      $oper_output = $var_cnt;
      $miter_out_str .= $var_cnt . " ";
      $oper_in_arr[0] = $key_lbl_ref->[$i];
      $oper_in_arr[1] = $key_lbl_ref->[$key_cnt+$i];

      #if ($sat_solver != 3){
        ($cnf_str) = write_cnfstr_xor2($cnf_str, $oper_output, $oper_in_cnt, \@oper_in_arr);
      #}
      #else{
      #  ($cnf_str) = write_cnfstr_xor2_assumption($cnf_str, $oper_output, $oper_in_cnt, \@oper_in_arr);
      #}
      $cla_cnt += 4;
    }
  }
  if ($is_added){
    $cnf_str .= $miter_out_str . "0 \n";
    $cla_cnt++;
  }

  return ($var_cnt, $cla_cnt, $cnf_str);
}

sub add_miter_output{
  my ($sat_solver, $var_cnt, $cla_cnt, $out_cnt, $out_lbl_ref) = @_;

  my $cnf_str = "";
  if ($the_verb){print "[INFO] Adding miter output... \n";}

  $cnf_str .= "c Miter for each output \n";
  my $oper_output = 0;
  my $oper_in_cnt = 0;
  my @oper_in_arr = ();
  my $miter_out_str = "";
  #if ($sat_solver == 3){ $miter_out_str .= "a "; }
  
  for (my $i=0; $i<$out_cnt; $i++){
    $var_cnt++;
    $oper_in_cnt = 2;
    $oper_output = $var_cnt;
    $miter_out_str .= $var_cnt . " ";
    $oper_in_arr[0] = $out_lbl_ref->[$i];
    $oper_in_arr[1] = $out_lbl_ref->[$out_cnt+$i];

    #if ($sat_solver != 3){
      ($cnf_str) = write_cnfstr_xor2($cnf_str, $oper_output, $oper_in_cnt, \@oper_in_arr);
    #}
    #else{
    #  ($cnf_str) = write_cnfstr_xor2_assumption($cnf_str, $oper_output, $oper_in_cnt, \@oper_in_arr);
    #}
    $cla_cnt += 4;
  }
  $cnf_str .= $miter_out_str . "0 \n";
  $cla_cnt++;

  return ($var_cnt, $cla_cnt, $cnf_str);
}

sub add_test_constraints{
  my ($ite_num, $cla_cnt, $cnf_str, $in_cnt, $in_lbl_ref, $key_cnt, $key_lbl_ref, $test_cnt, $testin_mat_ref, $testkey_mat_ref) = @_;

  $cnf_str .= "c Adding the test constraints \n";

  for (my $i=0; $i<$in_cnt; $i++){
    if ($testin_mat_ref->[$ite_num][$i] == 0){
      $cnf_str .= "-" . $in_lbl_ref->[$i][1] . " 0 \n";
      $cla_cnt++;
    }
    elsif ($testin_mat_ref->[$ite_num][$i] == 1){
      $cnf_str .= $in_lbl_ref->[$i][1] . " 0 \n";
      $cla_cnt++;
    }
  }

  for (my $i=0; $i<$key_cnt; $i++){
    if ($testkey_mat_ref->[$ite_num][$i] == 0){
      $cnf_str .= "-" . $key_lbl_ref->[$i] . " 0 \n";
      $cla_cnt++;
    }
    elsif ($testkey_mat_ref->[$ite_num][$i] == 1){
      $cnf_str .= $key_lbl_ref->[$i] . " 0 \n";
      $cla_cnt++;
    }
  }

  return ($cla_cnt, $cnf_str);
}

sub determine_output_dependency_test{
  my ($test_cnt, $out_cnt, $testout_mat_ref) = @_;

  my @out_dep_arr = ();

  if ($test_cnt == -1){
    for (my $i=0; $i<$out_cnt; $i++){
      $out_dep_arr[$i] = 1;
    }
  }
  else{
    for (my $i=0; $i<$out_cnt; $i++){
      $out_dep_arr[$i] = 0;
      for (my $j=0; $j<$test_cnt; $j++){
        if ($testout_mat_ref->[$j][$i] != 2){
          $out_dep_arr[$i] = 1;
          last;
        }
      }
    }
  }

  return (\@out_dep_arr);
}

sub determine_dip{
  my ($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $ite_num, $in_cnt, $in_lbl_ref, $var_cnt, $cla_cnt, $key_cnt, $key_lbl_ref, $adkv_arr_ref, $out_cnt, $out_lbl_ref, $cnf_str, $orst_cla_cnt, $orst_cnf_str, $test_cnt, $testin_mat_ref, $testkey_mat_ref, $testout_mat_ref) = @_;
  
  my $the_dip_ref;
  my $dip_found = 0;
  my $sol_found = 0;
  my $miter_cnf = "";
  my $worst_cla_cnt = "";
  my $worst_cnf_str = "";
 
  #my ($out_dep_arr) = determine_output_dependency_test($test_cnt, $out_cnt, $testout_mat_ref);
  #print_array("out_dep_arr", $out_cnt, $out_dep_arr);

  #Add the MITER logic for outputs
  ($var_cnt, $cla_cnt, $miter_cnf) = add_miter_output($sat_solver_ind, $var_cnt, $cla_cnt, $out_cnt, $out_lbl_ref);
  $cnf_str .= $miter_cnf;

  #Add the MITER logic for keyinputs
  ($var_cnt, $cla_cnt, $miter_cnf) = add_miter_key($sat_solver_ind, $var_cnt, $cla_cnt, $key_cnt, $key_lbl_ref, $adkv_arr_ref);
  if ($miter_cnf ne ""){$cnf_str .= $miter_cnf;}

  #Add constraints related to the output restriction
  if ($is_orst){
    $worst_cla_cnt = $cla_cnt;
    $worst_cnf_str = $cnf_str;

    $cnf_str .= $orst_cnf_str;
    $cla_cnt += $orst_cla_cnt;
  }

  #Add constraints related to the test inputs
  #if ($is_trst){
  #  if ($ite_num < $test_cnt){
  #    ($cla_cnt, $cnf_str) = add_test_constraints($ite_num, $cla_cnt, $cnf_str, $in_cnt, $in_lbl_ref, $key_cnt, $key_lbl_ref, $test_cnt, $testin_mat_ref, $testkey_mat_ref);
  #  }
  #}

  if ($the_verb){print "[INFO] Determining the DIP... \n";}
  if ($the_verb){print "[INFO] #Variables: $var_cnt #Clauses: $cla_cnt \n";}

  my $the_phrase = "";
  my $option_str = " ";
  my $cnf_file = $file_dir . $file_name . $the_phrase . ".cnf";
  open (my $fid_cnf, '>', $cnf_file);
  if ($dip_sat_solver == 3){
    printf $fid_cnf "p inccnf %d %d \n",$var_cnt, $cla_cnt;
  }
  elsif ($dip_sat_solver == 8){
    printf $fid_cnf "p inccnf \n";
  }
  else{
    printf $fid_cnf "p cnf %d %d \n",$var_cnt, $cla_cnt;
  }
  printf $fid_cnf "%s", $cnf_str;
  close ($fid_cnf);
 
  ($sol_found, $the_dip_ref) = run_sat_solver("wdata", $file_dir, $file_name, $the_phrase, $path_sat, $sat_solver_ind, $sat_seed, $in_cnt, $in_lbl_ref, $option_str);

  if ($sol_found == -1){
    print "[ERROR] SAT solver crashed!!! Returning... \n";
    exit (1);
  }
  elsif ($sol_found == 1){
    if ($the_verb){print "[INFO] The DIP has just been found! \n";}
  }
  elsif ($sol_found == 0){
    print "[INFO] A DIP could not be found! \n";
    if ($is_orst){
      $the_phrase = "";
      $option_str = " ";
      $cnf_file = $file_dir . $file_name . $the_phrase . ".cnf";
      open (my $fid_cnf, '>', $cnf_file);
      if ($dip_sat_solver == 3){
        printf $fid_cnf "p inccnf %d %d \n",$var_cnt, $worst_cla_cnt;
      }
      elsif ($dip_sat_solver == 8){
        printf $fid_cnf "p inccnf \n";
      }
      else{
        printf $fid_cnf "p cnf %d %d \n",$var_cnt, $worst_cla_cnt;
      }
      printf $fid_cnf "%s", $worst_cnf_str;
      close ($fid_cnf);
 
      ($sol_found, $the_dip_ref) = run_sat_solver("wdata", $file_dir, $file_name, $the_phrase, $path_sat, $sat_solver_ind, $sat_seed, $in_cnt, $in_lbl_ref, $option_str);

      if ($sol_found == -1){
        print "[ERROR] SAT solver crashed!!! Returning... \n";
        exit (1);
      }
      elsif ($sol_found == 1){
        if ($the_verb){print "[INFO] The DIP has just been found! \n";}
        $orst_cla_cnt = 0;
        $orst_cnf_str = "";
      }
      elsif ($sol_found == 0){
        if ($the_verb){print "[INFO] The DIP could not be found! \n";}
      }
      elsif ($sol_found == 2){
        if ($the_verb){print "[INFO] The DIP could not be found in the given SAT time-limit! \n";}
      }
    }
  }
  elsif ($sol_found == 2){
    if ($the_verb){print "[INFO] The DIP could not be found in the given SAT time-limit! \n";}
  }

  return ($sol_found, $the_dip_ref, $orst_cla_cnt, $orst_cnf_str);
}

sub constant_propagation{
  my ($gate_lvlind_arr_ref, $the_dip_ref, $adkv_arr_ref, $dip_out_ref, $in_cnt, $in_lbl_ref, $key_cnt, $out_cnt, $out_lbl_ref, $lbl_cnt, $lbl_mat_ref, $gate_cnt, $po_arr_ref, $gate_mat_ref) = @_;
 
  #print_gate_matrix("gate_matrix", $gate_cnt, $gate_mat_ref);
  #print_array("gate_lvlind_arr_ref", $gate_cnt, $gate_lvlind_arr_ref);

  my $gli = 0;
  my $ngi = 0;
  my $no_key = 1;
  my $the_val = 0;
  my $one_cnt = 0;
  my $zero_cnt = 0;
  my $undef_in = 0;
  my $undef_cnt = 0;
  my $gate_index = 0;
  my @lbl_val_arr = ();
  
  my @gate_ass_arr = ();
  my @gate_val_mat = ();
  
  #Determine the initial value of all variables in the gate-level netlist
  for (my $i=0; $i<$lbl_cnt; $i++){
    if ($lbl_mat_ref->[$i][1] <= $in_cnt){
      $lbl_val_arr[$i] = $the_dip_ref->[$lbl_mat_ref->[$i][1]-1];
    }
    elsif ($lbl_mat_ref->[$i][1] - $in_cnt <= $key_cnt and $lbl_mat_ref->[$i][1] - $in_cnt > 0){
      $lbl_val_arr[$i] = $adkv_arr_ref->[$lbl_mat_ref->[$i][1]-$in_cnt-1];
      #print "label: $lbl_mat_ref->[$i][0] index: $lbl_mat_ref->[$i][1] value: $lbl_val_arr[$i]\n";
    }
    elsif ($lbl_mat_ref->[$i][1] - $in_cnt - $key_cnt <= $out_cnt and $lbl_mat_ref->[$i][1] - $in_cnt - $key_cnt > 0){
      $lbl_val_arr[$i] = $dip_out_ref->[$lbl_mat_ref->[$i][1]-$in_cnt-$key_cnt-1];
    }
    else{
      $lbl_val_arr[$i] = 2;
    }
  }
  #print_array("lbl_var_arr", $lbl_cnt, \@lbl_val_arr);
  
  #Initialize gate assignment array and gate value matrix
  for (my $i=0; $i<$gate_cnt; $i++){
    $gate_ass_arr[$i] = 0;

    $gate_index = 2;
    $gate_val_mat[$i][0] = 2;
    $gate_val_mat[$i][1] = $gate_mat_ref->[$i][1];
    while ($gate_mat_ref->[$i][$gate_index] != -1){
      $gate_val_mat[$i][$gate_index] = 2;
      $gate_index++;
    }
    $gate_val_mat[$i][$gate_index] = -1;
  }
 
  while (1){
    my $assignment_found = 0;

    #FORWARD PROPAGATION
    #print "[INFO] Forward Propagation \n";
    for (my $i=0; $i<$gate_cnt; $i++){
      #Gate level index
      $gli = $gate_lvlind_arr_ref->[$i];
      #print "gli: $gli \n";

      if ($gate_ass_arr[$gli] == 0){
        #Gate output value
        $gate_val_mat[$gli][0] = $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ];

        #Gate input values
        $one_cnt = 0;
        $zero_cnt = 0;
        $gate_index = 0;
        while ($gate_mat_ref->[$gli][$gate_index+2] != -1){
          $the_val = $lbl_val_arr[ $gate_mat_ref->[$gli][$gate_index+2]-1 ];
          $gate_val_mat[$gli][$gate_index+2] = $the_val;
          if ($the_val == 0){$zero_cnt++;}
          if ($the_val == 1){$one_cnt++;}
          $gate_index++;
        }

        #Update gate assignment array
        if ($one_cnt + $zero_cnt == $gate_index){
          $gate_ass_arr[$gli] = 1;
        }

        #AND GATE
        if ($gate_mat_ref->[$gli][1] == 0){
          #Forward Propagation
          if ($gate_val_mat[$gli][0] == 2){
            if ($zero_cnt){
              $assignment_found = 1;
              $gate_val_mat[$gli][0] = 0;
              $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ] = 0;  
            }
            elsif ($one_cnt == $gate_index){
              $assignment_found = 1;
              $gate_val_mat[$gli][0] = 1;
              $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ] = 1;
            }
          }
        }
        #NAND GATE
        elsif ($gate_mat_ref->[$gli][1] == 4){
          #Forward Propagation
          if ($gate_val_mat[$gli][0] == 2){
            if ($zero_cnt){
              $assignment_found = 1;
              $gate_val_mat[$gli][0] = 1;
              $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ] = 1;
            }
            elsif ($one_cnt == $gate_index){
              $assignment_found = 1;
              $gate_val_mat[$gli][0] = 0;
              $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ] = 0;
            }
          }
        }
        #OR GATE
        elsif ($gate_mat_ref->[$gli][1] == 2){
          #Forward Propagation
          if ($gate_val_mat[$gli][0] == 2){
            if ($one_cnt){
              $assignment_found = 1;
              $gate_val_mat[$gli][0] = 1;
              $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ] = 1;
            }
            elsif ($zero_cnt == $gate_index){
              $assignment_found = 1;
              $gate_val_mat[$gli][0] = 0;
              $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ] = 0;
            }
          }
        }
        #NOR GATE
        elsif ($gate_mat_ref->[$gli][1] == 6){
          #Forward Propagation
          if ($gate_val_mat[$gli][0] == 2){
            if ($one_cnt){
              $assignment_found = 1;
              $gate_val_mat[$gli][0] = 0;
              $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ] = 0;
            }  
            elsif ($zero_cnt == $gate_index){
              $assignment_found = 1;
              $gate_val_mat[$gli][0] = 1;
              $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ] = 1;
            }
          }
        }
        #BUF GATE
        elsif ($gate_mat_ref->[$gli][1] == 1){
          #Forward Propagation
          if ($gate_val_mat[$gli][0] == 2){
            if ($one_cnt){
              $assignment_found = 1;
              $gate_val_mat[$gli][0] = 1;
              $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ] = 1;
            }
            elsif ($zero_cnt){
              $assignment_found = 1;
              $gate_val_mat[$gli][0] = 0;
              $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ] = 0;
            }
          }
        }
        #NOT GATE
        elsif ($gate_mat_ref->[$gli][1] == 5){
          #Forward Propagation
          if ($gate_val_mat[$gli][0] == 2){
            if ($one_cnt){
              $assignment_found = 1;
              $gate_val_mat[$gli][0] = 0;
              $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ] = 0;
            }
            elsif ($zero_cnt){
              $assignment_found = 1;
              $gate_val_mat[$gli][0] = 1;
              $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ] = 1;
            }
          }
        }
        #XOR GATE
        elsif ($gate_mat_ref->[$gli][1] == 3){
          #Forward Propagation
          if ($gate_val_mat[$gli][0] == 2){
            if ($one_cnt + $zero_cnt == $gate_index){
              $assignment_found = 1;
              $gate_val_mat[$gli][0] = $one_cnt % 2;
              $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ] = $one_cnt % 2;
            }
          }
        }
        #XNOR GATE
        elsif ($gate_mat_ref->[$gli][1] == 7){
          #Forward Propagation
          if ($gate_val_mat[$gli][0] == 2){
            if ($one_cnt + $zero_cnt == $gate_index){
              $assignment_found = 1;
              $gate_val_mat[$gli][0] = 1-($one_cnt % 2);
              $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ] = 1-($one_cnt % 2);
            }
          }
        }
      }
    }

    #BACKWARD PROPAGATION
    #print "[INFO] Backward Propagation \n";
    for (my $i=$gate_cnt-1; $i>=0; $i--){
      #Gate level index
      $gli = $gate_lvlind_arr_ref->[$i];
      #print "gli: $gli \n";

      if ($gate_ass_arr[$gli] == 0){
        #Update gate output value
        $gate_val_mat[$gli][0] = $lbl_val_arr[ $gate_mat_ref->[$gli][0]-1 ];

        #Update gate input values
        $no_key = 1;
        $one_cnt = 0;
        $zero_cnt = 0;
        $undef_in = -1;
        $undef_cnt = 0;
        $gate_index = 0;
        while ($gate_mat_ref->[$gli][$gate_index+2] != -1){
          $the_val = $lbl_val_arr[ $gate_mat_ref->[$gli][$gate_index+2]-1 ];
          $gate_val_mat[$gli][$gate_index+2] = $the_val;
          if ($the_val == 0){$zero_cnt++;}
          if ($the_val == 1){$one_cnt++;}
          if ($the_val == 2){
            $undef_cnt++; 
            if ($gate_mat_ref->[$gli][$gate_index+2] - $in_cnt <= $key_cnt and $gate_mat_ref->[$gli][$gate_index+2] - $in_cnt > 0){
              $no_key = 0;
              $undef_in = -1;
            }
            else{
              $undef_in = $gate_index+2;
            }
          }
          $gate_index++;
        }

        #AND GATE
        if ($gate_mat_ref->[$gli][1] == 0){
          #Backward Propagation
          if ($gate_val_mat[$gli][0] == 1){
            $ngi = 2;
            while ($gate_val_mat[$gli][$ngi] != -1){
              if ($gate_val_mat[$gli][$ngi] == 2){
                if (!($gate_mat_ref->[$gli][$ngi] - $in_cnt <= $key_cnt and $gate_mat_ref->[$gli][$ngi] - $in_cnt > 0)){
                  $assignment_found = 1;
                  $gate_val_mat[$gli][$ngi] = 1;
                  $lbl_val_arr[ $gate_mat_ref->[$gli][$ngi]-1 ] = 1;
                }
              }
              $ngi++;
            }
            if ($no_key){
              $gate_ass_arr[$gli] = 1;
            }
          }
          elsif ($gate_val_mat[$gli][0] == 0){
            if ($one_cnt == $gate_index-1 and $undef_cnt == 1){
              if ($undef_in != -1){
                $assignment_found = 1;
                $gate_val_mat[$gli][$undef_in] = 0;
                $lbl_val_arr[ $gate_mat_ref->[$gli][$undef_in]-1 ] = 0;
                $gate_ass_arr[$gli] = 1;
              }
            }
          }
        }
        #NAND GATE
        elsif ($gate_mat_ref->[$gli][1] == 4){
          #Backward Propagation
          if ($gate_val_mat[$gli][0] == 0){
            $ngi = 2;
            while ($gate_val_mat[$gli][$ngi] != -1){
              if ($gate_val_mat[$gli][$ngi] == 2){
                if (!($gate_mat_ref->[$gli][$ngi] - $in_cnt <= $key_cnt and $gate_mat_ref->[$gli][$ngi] - $in_cnt > 0)){
                  $assignment_found = 1;
                  $gate_val_mat[$gli][$ngi] = 1;
                  $lbl_val_arr[ $gate_mat_ref->[$gli][$ngi]-1 ] = 1;
                }
              }
              $ngi++;
            }
            if ($no_key){
              $gate_ass_arr[$gli] = 1;
            }
          }
          elsif ($gate_val_mat[$gli][0] == 1){
            if ($one_cnt == $gate_index-1 and $undef_cnt == 1){
              if ($undef_in != -1){
                $assignment_found = 1;
                $gate_val_mat[$gli][$undef_in] = 0;
                $lbl_val_arr[ $gate_mat_ref->[$gli][$undef_in]-1 ] = 0;
                $gate_ass_arr[$gli] = 1;
              }
            }
          }
        }
        #OR GATE
        elsif ($gate_mat_ref->[$gli][1] == 2){
          #Backward Propagation
          if ($gate_val_mat[$gli][0] == 0){
            $ngi = 2;
            while ($gate_val_mat[$gli][$ngi] != -1){
              if ($gate_val_mat[$gli][$ngi] == 2){
                if (!($gate_mat_ref->[$gli][$ngi] - $in_cnt <= $key_cnt and $gate_mat_ref->[$gli][$ngi] - $in_cnt > 0)){
                  $assignment_found = 1;
                  $gate_val_mat[$gli][$ngi] = 0;
                  $lbl_val_arr[ $gate_mat_ref->[$gli][$ngi]-1 ] = 0;
                }
              }
              $ngi++;
            }
            if ($no_key){
              $gate_ass_arr[$gli] = 1;
            }
          }
          elsif ($gate_val_mat[$gli][0] == 1){
            if ($zero_cnt == $gate_index-1 and $undef_cnt == 1){
              if ($undef_in != -1){
                $assignment_found = 1;
                $gate_val_mat[$gli][$undef_in] = 1;
                $lbl_val_arr[ $gate_mat_ref->[$gli][$undef_in]-1 ] = 1;
                $gate_ass_arr[$gli] = 1;
              }
            }
          }
        }
        #NOR GATE
        elsif ($gate_mat_ref->[$gli][1] == 6){
          #Backward Propagation
          if ($gate_val_mat[$gli][0] == 1){
            $ngi = 2;
            while ($gate_val_mat[$gli][$ngi] != -1){
              if ($gate_val_mat[$gli][$ngi] == 2){
                if (!($gate_mat_ref->[$gli][$ngi] - $in_cnt <= $key_cnt and $gate_mat_ref->[$gli][$ngi] - $in_cnt > 0)){
                  $assignment_found = 1;
                  $gate_val_mat[$gli][$ngi] = 0;
                  $lbl_val_arr[ $gate_mat_ref->[$gli][$ngi]-1 ] = 0;
                }
              }
              $ngi++;
            }
            if ($no_key){
              $gate_ass_arr[$gli] = 1;
            }
          }
          elsif ($gate_val_mat[$gli][0] == 0){
            if ($zero_cnt == $gate_index-1 and $undef_cnt == 1){
              if ($undef_in != -1){
                $assignment_found = 1;
                $gate_val_mat[$gli][$undef_in] = 1;
                $lbl_val_arr[ $gate_mat_ref->[$gli][$undef_in]-1 ] = 1;
                $gate_ass_arr[$gli] = 1;
              }
            }
          }
        }
        #BUF GATE
        elsif ($gate_mat_ref->[$gli][1] == 1){
          #Backward Propagation
          if ($gate_val_mat[$gli][0] != 2){
            $ngi = 2;
            while ($gate_val_mat[$gli][$ngi] != -1){
              if ($gate_val_mat[$gli][$ngi] == 2){
                if (!($gate_mat_ref->[$gli][$ngi] - $in_cnt <= $key_cnt and $gate_mat_ref->[$gli][$ngi] - $in_cnt > 0)){
                  $assignment_found = 1;
                  $gate_val_mat[$gli][$ngi] = $gate_val_mat[$gli][0];
                  $lbl_val_arr[ $gate_mat_ref->[$gli][$ngi]-1 ] = $gate_val_mat[$gli][0];
                }
              }
              $ngi++;
            }
            if ($no_key){
              $gate_ass_arr[$gli] = 1;
            }
          }
        }
        #NOT GATE
        elsif ($gate_mat_ref->[$gli][1] == 5){
          #Backward Propagation
          if ($gate_val_mat[$gli][0] != 2){
            $ngi = 2;
            while ($gate_val_mat[$gli][$ngi] != -1){
              if ($gate_val_mat[$gli][$ngi] == 2){
                if (!($gate_mat_ref->[$gli][$ngi] - $in_cnt <= $key_cnt and $gate_mat_ref->[$gli][$ngi] - $in_cnt > 0)){
                  $assignment_found = 1;
                  $gate_val_mat[$gli][$ngi] = 1-$gate_val_mat[$gli][0];
                  $lbl_val_arr[ $gate_mat_ref->[$gli][$ngi]-1 ] = 1-$gate_val_mat[$gli][0];
                }
              }
              $ngi++;
            }
            if ($no_key){
              $gate_ass_arr[$gli] = 1;
            }
          }
        }
        #XOR GATE
        elsif ($gate_mat_ref->[$gli][1] == 3){
          #Backward Propagation
          if ($gate_val_mat[$gli][0] != 2){
            if ($no_key){
              if ($undef_cnt == 1){
                if ($gate_val_mat[$gli][0] == 1){
                  if ($zero_cnt){
                    $assignment_found = 1;
                    $gate_val_mat[$gli][$undef_in] = 1;
                    $lbl_val_arr[ $gate_mat_ref->[$gli][$undef_in]-1 ] = 1;
                    $gate_ass_arr[$gli] = 1;
                  }
                  elsif ($one_cnt){
                    $assignment_found = 1;
                    $gate_val_mat[$gli][$undef_in] = 0;
                    $lbl_val_arr[ $gate_mat_ref->[$gli][$undef_in]-1 ] = 0;
                    $gate_ass_arr[$gli] = 1;
                  }
                }
                elsif ($gate_val_mat[$gli][0] == 0){
                  if ($zero_cnt){
                    $assignment_found = 1;
                    $gate_val_mat[$gli][$undef_in] = 0;
                    $lbl_val_arr[ $gate_mat_ref->[$gli][$undef_in]-1 ] = 0;
                    $gate_ass_arr[$gli] = 1;
                  }
                  elsif ($one_cnt){
                    $assignment_found = 1;
                    $gate_val_mat[$gli][$undef_in] = 1;
                    $lbl_val_arr[ $gate_mat_ref->[$gli][$undef_in]-1 ] = 1;
                    $gate_ass_arr[$gli] = 1;
                  }
                }
              }
            }
          }
        }
        #XNOR GATE
        elsif ($gate_mat_ref->[$gli][1] == 7){
          #Backward Propagation
          if ($gate_val_mat[$gli][0] != 2){
            if ($no_key){
              if ($undef_cnt == 1){
                if ($gate_val_mat[$gli][0] == 1){
                  if ($zero_cnt){
                    $assignment_found = 1;
                    $gate_val_mat[$gli][$undef_in] = 0;
                    $lbl_val_arr[ $gate_mat_ref->[$gli][$undef_in]-1 ] = 0;
                    $gate_ass_arr[$gli] = 1;
                  }
                  elsif ($one_cnt){
                    $assignment_found = 1;
                    $gate_val_mat[$gli][$undef_in] = 1;
                    $lbl_val_arr[ $gate_mat_ref->[$gli][$undef_in]-1 ] = 1;
                    $gate_ass_arr[$gli] = 1;
                  }
                }
                elsif ($gate_val_mat[$gli][0] == 0){
                  if ($zero_cnt){
                    $assignment_found = 1;
                    $gate_val_mat[$gli][$undef_in] = 1;
                    $lbl_val_arr[ $gate_mat_ref->[$gli][$undef_in]-1 ] = 1;
                    $gate_ass_arr[$gli] = 1;
                  }
                  elsif ($one_cnt){
                    $assignment_found = 1;
                    $gate_val_mat[$gli][$undef_in] = 0;
                    $lbl_val_arr[ $gate_mat_ref->[$gli][$undef_in]-1 ] = 0;
                    $gate_ass_arr[$gli] = 1;
                  }
                }
              }
            }
          }
        }
      }
    }

    #print "Backward \n";
    #print_gate_matrix_ind("special one", 99, $gate_mat_ref);
    #print_gate_matrix_ind("special one value", 99, \@gate_val_mat);

    if ($assignment_found == 0){
      last;
    }
  }
  
  #print "gate_cnt: $gate_cnt \n";
  #print_gate_matrix("gate_mat", $gate_cnt, $gate_mat_ref);
  #print_gate_matrix("gate_val_mat", $gate_cnt, \@gate_val_mat);
 
  return (\@gate_ass_arr, \@gate_val_mat);
}

sub generate_gate_cnf{
  my ($gli, $enc_gate_val_ref, $lbl_cnt, $lbl_mat_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $cnf_str, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $cnf_gate_cnt, $cnf_gate_arr_ref) = @_;

  my $the_index = 0;
  my $key_index = 0;
  my $lbl_index = 0;

  my $gate_index = 0; 
  my $gate_output_val = 0;
  my @gate_in_val_arr = ();

  my $one_gate_output = 0;
  my $two_gate_output = 0;
  my $one_gate_in_cnt = 0;
  my $two_gate_in_cnt = 0;
  my @one_gate_in_arr = ();
  my @two_gate_in_arr = ();

  $gate_output_val = $enc_gate_val_ref->[$gli][0];
  $lbl_index = where_is_inside_label_matrix($enc_gate_mat_ref->[$gli][0], $lbl_cnt, 0, $lbl_mat_ref);
  if ($lbl_index == -1){
    $dkey_var_cnt++;
    $one_gate_output = $dkey_var_cnt;
    $lbl_mat_ref->[$lbl_cnt][0] = $enc_gate_mat_ref->[$gli][0];
    $lbl_mat_ref->[$lbl_cnt][1] = $dkey_var_cnt;

    $dkey_var_cnt++;
    $two_gate_output = $dkey_var_cnt;
    $lbl_mat_ref->[$lbl_cnt][2] = $dkey_var_cnt;
    $lbl_cnt++;
  }
  else{
    $one_gate_output = $lbl_mat_ref->[$lbl_index][1];
    $two_gate_output = $lbl_mat_ref->[$lbl_index][2];
  }

  $gate_index = 0;
  while ($enc_gate_mat_ref->[$gli][$gate_index+2] != -1){
    $gate_in_val_arr[$gate_index] = $enc_gate_val_ref->[$gli][$gate_index+2];
    if ($gate_in_val_arr[$gate_index] == 2){
      $key_index = ($enc_gate_mat_ref->[$gli][$gate_index+2] - $enc_in_cnt <= $enc_key_cnt and $enc_gate_mat_ref->[$gli][$gate_index+2] - $enc_in_cnt > 0) ? $enc_gate_mat_ref->[$gli][$gate_index+2] - $enc_in_cnt - 1 : -1;
      
      if ($key_index != -1){
        $one_gate_in_arr[$gate_index] = $dkey_key_lbl_ref->[$key_index];
        $two_gate_in_arr[$gate_index] = $dkey_key_lbl_ref->[$key_index+$enc_key_cnt];
      }
      else{
        $lbl_index = where_is_inside_label_matrix($enc_gate_mat_ref->[$gli][$gate_index+2], $lbl_cnt, 0, $lbl_mat_ref);
        if ($lbl_index == -1){
          $dkey_var_cnt++;
          $one_gate_in_arr[$gate_index] = $dkey_var_cnt;
          $lbl_mat_ref->[$lbl_cnt][0] = $enc_gate_mat_ref->[$gli][$gate_index+2];
          $lbl_mat_ref->[$lbl_cnt][1] = $dkey_var_cnt;

          $dkey_var_cnt++;
          $two_gate_in_arr[$gate_index] = $dkey_var_cnt;
          $lbl_mat_ref->[$lbl_cnt][2] = $dkey_var_cnt;
          $lbl_cnt++;
        }
        else{
          $one_gate_in_arr[$gate_index] = $lbl_mat_ref->[$lbl_index][1];
          $two_gate_in_arr[$gate_index] = $lbl_mat_ref->[$lbl_index][2];
        }

        #Add the gate generating this input to be included into the SAT problem
        my $cnf_gate_lbl = $enc_lbl_mat_ref->[ $enc_gate_mat_ref->[$gli][$gate_index+2]-1 ][3];
        $cnf_gate_arr_ref->[$cnf_gate_cnt] = $cnf_gate_lbl;
        $cnf_gate_cnt++;  
      }
    }
    $gate_index++;
  }

  if ($enc_gate_mat_ref->[$gli][1] == 0){
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_and_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_and_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
  }
  elsif ($enc_gate_mat_ref->[$gli][1] == 1){
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_buf_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_buf_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
  }
  elsif ($enc_gate_mat_ref->[$gli][1] == 2){
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_or_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_or_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
  }
  elsif ($enc_gate_mat_ref->[$gli][1] == 3){
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_xor2_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_xor2_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
  }
  elsif ($enc_gate_mat_ref->[$gli][1] == 4){
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_nand_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_nand_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
  }
  elsif ($enc_gate_mat_ref->[$gli][1] == 5){
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_not_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_not_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
  }
  elsif ($enc_gate_mat_ref->[$gli][1] == 6){
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_nor_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_nor_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
  }
  elsif ($enc_gate_mat_ref->[$gli][1] == 7){
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_xnor2_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
    ($dkey_cla_cnt, $cnf_str) = write_cnfstr_xnor2_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
  }

  return ($lbl_cnt, $lbl_mat_ref, $dkey_var_cnt, $dkey_cla_cnt, $cnf_str, $cnf_gate_cnt, $cnf_gate_arr_ref);
}

sub add_dip_output{
  my ($gate_lvlind_arr_ref, $the_dip_ref, $adkv_arr_ref, $dip_out_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref) = @_;

  #my $ado_init_time = time();
  #print "BEFORE $dkey_var_cnt $dkey_cla_cnt \n";

  my $cnf_str = "";
  my $the_index = 0;
  my $key_index = 0;
  my $lbl_index = 0;

  my $lbl_cnt = 0;
  my @lbl_mat = ();

  my $gate_index = 0; 
  my $gate_output_val = 0;
  my @gate_in_val_arr = ();

  my $one_gate_output = 0;
  my $two_gate_output = 0;
  my $one_gate_in_cnt = 0;
  my $two_gate_in_cnt = 0;
  my @one_gate_in_arr = ();
  my @two_gate_in_arr = ();

  #if ($the_verb){print "[INFO] Adding the information related to the input and its output... \n";}

  my ($enc_gate_ass_ref, $enc_gate_val_ref) = constant_propagation($gate_lvlind_arr_ref, $the_dip_ref, $adkv_arr_ref, $dip_out_ref, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref);

  #print_gate_matrix("enc_gate_mat", $enc_gate_cnt, $enc_gate_mat_ref);
  #print_gate_matrix("enc_gate_val", $enc_gate_cnt, $enc_gate_val_ref);
  #print_array("enc_gate_ass", $enc_gate_cnt, $enc_gate_ass_ref);

  $cnf_str = "c Inclusion of the information related to DIP and its output \n";
  for (my $i=0; $i<$enc_gate_cnt; $i++){
    if ($enc_gate_ass_ref->[$i] == 0){
      $gate_output_val = $enc_gate_val_ref->[$i][0];
      if ($gate_output_val == 2){
        $lbl_index = where_is_inside_label_matrix($enc_gate_mat_ref->[$i][0], $lbl_cnt, 0, \@lbl_mat);
        if ($lbl_index == -1){
          $dkey_var_cnt++;
          $one_gate_output = $dkey_var_cnt;
          $lbl_mat[$lbl_cnt][0] = $enc_gate_mat_ref->[$i][0];
          $lbl_mat[$lbl_cnt][1] = $dkey_var_cnt;

          $dkey_var_cnt++;
          $two_gate_output = $dkey_var_cnt;
          $lbl_mat[$lbl_cnt][2] = $dkey_var_cnt;
          $lbl_cnt++;
        }
        else{
          $one_gate_output = $lbl_mat[$lbl_index][1];
          $two_gate_output = $lbl_mat[$lbl_index][2];
        }
      }

      $gate_index = 0;
      while ($enc_gate_mat_ref->[$i][$gate_index+2] != -1){
        $gate_in_val_arr[$gate_index] = $enc_gate_val_ref->[$i][$gate_index+2];
        if ($gate_in_val_arr[$gate_index] == 2){
          $key_index = ($enc_gate_mat_ref->[$i][$gate_index+2] - $enc_in_cnt <= $enc_key_cnt and $enc_gate_mat_ref->[$i][$gate_index+2] - $enc_in_cnt > 0) ? $enc_gate_mat_ref->[$i][$gate_index+2] - $enc_in_cnt - 1 : -1;
          
          if ($key_index != -1){
            $one_gate_in_arr[$gate_index] = $dkey_key_lbl_ref->[$key_index];
            $two_gate_in_arr[$gate_index] = $dkey_key_lbl_ref->[$key_index+$enc_key_cnt];
          }
          else{
            $lbl_index = where_is_inside_label_matrix($enc_gate_mat_ref->[$i][$gate_index+2], $lbl_cnt, 0, \@lbl_mat);
            if ($lbl_index == -1){
              $dkey_var_cnt++;
              $one_gate_in_arr[$gate_index] = $dkey_var_cnt;
              $lbl_mat[$lbl_cnt][0] = $enc_gate_mat_ref->[$i][$gate_index+2];
              $lbl_mat[$lbl_cnt][1] = $dkey_var_cnt;

              $dkey_var_cnt++;
              $two_gate_in_arr[$gate_index] = $dkey_var_cnt;
              $lbl_mat[$lbl_cnt][2] = $dkey_var_cnt;
              $lbl_cnt++;
            }
            else{
              $one_gate_in_arr[$gate_index] = $lbl_mat[$lbl_index][1];
              $two_gate_in_arr[$gate_index] = $lbl_mat[$lbl_index][2];
            }
          }
        }
        $gate_index++;
      }

      if ($enc_gate_mat_ref->[$i][1] == 0){
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_and_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_and_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
      }
      elsif ($enc_gate_mat_ref->[$i][1] == 1){
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_buf_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_buf_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
      }
      elsif ($enc_gate_mat_ref->[$i][1] == 2){
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_or_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_or_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
      }
      elsif ($enc_gate_mat_ref->[$i][1] == 3){
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_xor2_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_xor2_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
      }
      elsif ($enc_gate_mat_ref->[$i][1] == 4){
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_nand_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_nand_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
      }
      elsif ($enc_gate_mat_ref->[$i][1] == 5){
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_not_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_not_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
      }
      elsif ($enc_gate_mat_ref->[$i][1] == 6){
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_nor_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_nor_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
      }
      elsif ($enc_gate_mat_ref->[$i][1] == 7){
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_xnor2_val($dkey_cla_cnt, $cnf_str, $one_gate_output, $gate_output_val, $gate_index, \@one_gate_in_arr, \@gate_in_val_arr);
        ($dkey_cla_cnt, $cnf_str) = write_cnfstr_xnor2_val($dkey_cla_cnt, $cnf_str, $two_gate_output, $gate_output_val, $gate_index, \@two_gate_in_arr, \@gate_in_val_arr);
      }
    }
  }

  #my $gli = 0;
  #my $lbl_mat_ref;
  #my $key_gate = 1;
  #my $all_unknown = 1;
  #my $cnf_gate_cnt = 0;
  #my $cnf_gate_arr_ref;
  #
  #$cnf_str = "c Inclusion of the information related to DIP and its output \n";
  #for (my $i=$enc_gate_cnt-1; $i>=0; $i--){
  #  $gli = $gate_lvlind_arr_ref->[$i];
  #  if (where_is_inside_numeric_array($gli, $cnf_gate_cnt, $cnf_gate_arr_ref) != -1){
  #    ($lbl_cnt, $lbl_mat_ref, $dkey_var_cnt, $dkey_cla_cnt, $cnf_str, $cnf_gate_cnt, $cnf_gate_arr_ref) = generate_gate_cnf($gli, $enc_gate_val_ref, $lbl_cnt, $lbl_mat_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $cnf_str, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $cnf_gate_cnt, $cnf_gate_arr_ref);
  #  }
  #  elsif ( ($enc_gate_ass_ref->[$gli] == 0 and $enc_gate_val_ref->[$gli][0] != 2)){
  #    $gate_index = 0;
  #    $all_unknown = 1;
  #    while ($enc_gate_mat_ref->[$gli][$gate_index+2] != -1){
  #      $key_index = ($enc_gate_mat_ref->[$gli][$gate_index+2] - $enc_in_cnt <= $enc_key_cnt and $enc_gate_mat_ref->[$gli][$gate_index+2] - $enc_in_cnt > 0) ? $enc_gate_mat_ref->[$gli][$gate_index+2] - $enc_in_cnt - 1 : -1;
  #      if ($key_index != -1){
  #        $key_gate = 1;
  #      }
  #      if ($enc_gate_val_ref->[$gli][$gate_index+2] != 2){
  #        $all_unknown = 0;
  #      }
  #      $gate_index++;
  #    }
  #    if ($all_unknown){
  #      ($lbl_cnt, $lbl_mat_ref, $dkey_var_cnt, $dkey_cla_cnt, $cnf_str, $cnf_gate_cnt, $cnf_gate_arr_ref) = generate_gate_cnf($gli, $enc_gate_val_ref, $lbl_cnt, $lbl_mat_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $cnf_str, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $cnf_gate_cnt, $cnf_gate_arr_ref);
  #    }
  #  }
  #}

  $dkey_cnf_str .= $cnf_str;
  #print "dkey_cnf_str: $dkey_cnf_str \n";
  #if ($the_verb){printf "[INFO] Run time of the ado function: %.2f \n", time()-$ado_init_time;}

  #print "AFTER $dkey_var_cnt $dkey_cla_cnt \n";

  return ($dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str);
}

sub extract_sat_problem{
  my ($cnf_file) = @_;
  
  my $is_err = 0;
  my $var_cnt = 0; 
  my $cla_cnt = 0; 
  my $cnf_str = "";
  my $the_char = "";
  my $the_index = 0;

  if (open (my $file_header, '<:encoding(UTF-8)', $cnf_file)){
    my $the_line = <$file_header>;
    chomp $the_line;
    #print "the_line: $the_line \n";

    ($is_err, $var_cnt, $cla_cnt) = extract_cnf_header($the_line);

    if ($is_err == 0){
      if ($cla_cnt){
        while (my $the_line = <$file_header>){
          $cnf_str .= $the_line;
          #print "$the_line \n";
        }
      }
    }
    else{
      print "[ERROR] No information on number of variables and clauses could be found! \n";
    }

    close ($file_header);

    #Remove the updated SAT problem
    my $the_cmd = "rm -f " . $cnf_file;
    system($the_cmd);
  }
  else{
    $is_err = 1;
    print "[ERROR] Could not open the $cnf_file file! \n";
  }

  return ($is_err, $var_cnt, $cla_cnt, $cnf_str);
}

sub update_sat_problem{
  my ($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $enc_key_cnt, $enc_key_lbl_ref, $dkey_key_lbl_ref, $adkv_arr_ref) = @_;

  if ($the_verb){print "[INFO] Updating the SAT problem... \n";}
  if ($the_verb){print "[INFO] Before UPDATE - #variables: $dkey_var_cnt #clauses: $dkey_cla_cnt \n";}

  my $the_phrase = "";
  my $option_str = "";
  #my $the_phrase = "_key";
  my $cnf_file = $file_dir . $file_name . $the_phrase . ".cnf";
  my $ext_file = $file_dir . $file_name . $the_phrase . ".ext";
  my $dimacs_file = $file_dir . $file_name . $the_phrase . "_dimacs.cnf";
 
  my $sat_solver_index = 0;
  #CRYPTOMINISAT
  if ($sat_solver_ind == 0){
    $sat_solver_index = 1;
    $option_str = " --preproc 1 " . $dimacs_file . " ";
  }
  #CaDiCaL
  elsif ($sat_solver_ind == 1){
    $sat_solver_index = 8;
    $option_str = " -o " . $dimacs_file . " -n -O16 ";
  }

  open (my $fid_cnf, '>', $cnf_file);
  printf $fid_cnf "p cnf %d %d \n", $dkey_var_cnt, $dkey_cla_cnt;
  printf $fid_cnf "%s", $dkey_cnf_str;
  close ($fid_cnf);
   
  my ($sol_found, $key_val_ref) = run_sat_solver("wodata", $file_dir, $file_name, $the_phrase, $path_sat, $sat_solver_index, $sat_seed, $enc_key_cnt, $enc_key_lbl_ref, $option_str);

  if ($sol_found == -1){
    print "[WARNING] SAT solver crashed!!! Returning... \n";
  }
  elsif ($sol_found == 1){
    my ($is_err, $var_cnt, $cla_cnt, $cnf_str) = extract_sat_problem($dimacs_file);
    if ($is_err == 0){
      for (my $i=0; $i<$enc_key_cnt; $i++){
        if ($adkv_arr_ref->[$i] == 0){
          $cla_cnt += 2;
          $cnf_str .= "-" . $dkey_key_lbl_ref->[$i] . " 0 \n";
          $cnf_str .= "-" . $dkey_key_lbl_ref->[$enc_key_cnt+$i] . " 0 \n";
        }
        elsif ($adkv_arr_ref->[$i] == 1){
          $cla_cnt += 2;
          $cnf_str .= $dkey_key_lbl_ref->[$i] . " 0 \n";
          $cnf_str .= $dkey_key_lbl_ref->[$enc_key_cnt+$i] . " 0 \n";
        }
      }

      $dkey_var_cnt = $var_cnt;
      $dkey_cla_cnt = $cla_cnt;
      $dkey_cnf_str = $cnf_str;

      if ($the_verb){print "[INFO] After UPDATE - #variables: $dkey_var_cnt #clauses: $dkey_cla_cnt \n";}
    }
  }
  else {
    print "[INFO] Could not update the SAT problem! \n";
  }

  return ($dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str);
}

sub extract_key{
  my ($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $enc_key_cnt, $enc_key_lbl_ref) = @_;

  my $key_found = 0;

  if ($the_verb){print "[INFO] Extracting the key... \n";}

  my $the_phrase = "";
  my $option_str = " ";
  #my $the_phrase = "_key";
  my $cnf_file = $file_dir . $file_name . $the_phrase . ".cnf";
  open (my $fid_cnf, '>', $cnf_file);
  printf $fid_cnf "p cnf %d %d \n", $dkey_var_cnt, $dkey_cla_cnt;
  printf $fid_cnf "%s", $dkey_cnf_str;
  close ($fid_cnf);
 
  my ($sol_found, $key_val_ref) = run_sat_solver("wdata", $file_dir, $file_name, $the_phrase, $path_sat, $sat_solver_ind, $sat_seed, $enc_key_cnt, $enc_key_lbl_ref, $option_str);
  #print_dip_array("key_val_ref", $enc_key_cnt, $key_val_ref);

  if ($sol_found == -1){
    print "[ERROR] SAT solver crashed!!! Returning... \n";
    exit (1);
  }
  elsif ($sol_found == 1){
    $key_found = 1;
    print_dip_array("[INFO] key", $enc_key_cnt, $key_val_ref);
  }
  elsif ($sol_found == 0){
    print "[ERROR] The key could not be found! \n";
  }
  elsif ($sol_found == 2){
    print "[WARNING] The key could not be found in the given SAT time-limit! \n";
  }

  return ($key_found, $key_val_ref);
}

sub simulate_key{
  my ($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $enc_var_cnt, $enc_cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_key_lbl_ref, $enc_out_cnt, $enc_out_lbl_ref, $enc_cnf_str, $key_val_ref) = @_;

  my $out_val_ref = 0;
  my $test_cnt = 10000;
  my $dip_out_found = 0;
  my $inkey_cla_cnt = 0;
  my $inkey_cnf_str = "";
  my @inkey_val_arr = ();

  my $var_cnt = $enc_var_cnt;
  my $cla_cnt = $enc_cla_cnt;
  my $cnf_str = $enc_cnf_str;

  my @out_lbl = ();
  my $out_cnt = $enc_out_cnt;
  for (my $i=0; $i<$out_cnt; $i++){
    $out_lbl[$i] = $enc_out_lbl_ref->[$i][1];
  }

  $cnf_str .= "c Adding the key value of key inputs ... \n";
  for (my $i=0; $i<$enc_key_cnt; $i++){
    if ($key_val_ref->[$i] == 0){
      $cnf_str .= "-" . $enc_key_lbl_ref->[$i][1] . " 0 \n";
    }
    else{
      $cnf_str .= $enc_key_lbl_ref->[$i][1] . " 0 \n";
    }
    $cla_cnt++;
  }

  if ($the_verb){print "[INFO] Simulating the locked circuit under the found key with the oracle... \n";}

  for (my $test_index=0; $test_index<$test_cnt; $test_index++){
    @inkey_val_arr = ();
    $inkey_cnf_str = $cnf_str;
    $inkey_cla_cnt = $cla_cnt;
    
    for (my $i=0; $i<$enc_in_cnt; $i++){
      my $in_val = int(rand(2));
      if ($in_val == 0){
        $inkey_cnf_str .= "-" . $enc_in_lbl_ref->[$i][1] . " 0 \n";
      }
      else{
        $inkey_cnf_str .= $enc_in_lbl_ref->[$i][1] . " 0 \n";
      }
      $inkey_val_arr[$i] = $in_val;
      $inkey_cla_cnt++;
    }
    #print_array("inkey_val_arr", $enc_in_cnt, \@inkey_val_arr);

    my $the_phrase = "";
    my $option_str = " ";
    my $cnf_file = $file_dir . $file_name . $the_phrase . ".cnf";
    open (my $fid_cnf, '>', $cnf_file);
    printf $fid_cnf "p cnf %d %d \n",$var_cnt, $inkey_cla_cnt;
    printf $fid_cnf "%s", $inkey_cnf_str;
    close ($fid_cnf);

    my ($sol_found, $enc_out_val_ref) = run_sat_solver("wdata", $file_dir, $file_name, $the_phrase, $path_sat, $sat_solver_ind, $sat_seed, $enc_out_cnt, $enc_out_lbl_ref, $option_str);
    #print_array("enc_out_val_ref", $enc_out_cnt, $enc_out_val_ref);

    if ($sol_found == -1){
      print "[ERROR] SAT solver crashed!!! Returning... \n";
      exit (1);
    }
    
    if ($the_contest eq "helloctf"){
      ($dip_out_found, $out_val_ref) = run_executable_oracle_helloctf($file_dir, $file_name, $enc_in_cnt, $enc_out_cnt, \@inkey_val_arr);
    }
    elsif ($the_contest eq "csaw19"){
      ($dip_out_found, $out_val_ref) = run_executable_oracle_csaw19($file_dir, $file_name, $enc_in_cnt, $enc_out_cnt, \@inkey_val_arr);
    }
    #print_array("out_val_ref", $enc_out_cnt, $out_val_ref);
   
    for (my $i=0; $i<$enc_out_cnt; $i++){
      if ($out_val_ref->[$i] != $enc_out_val_ref->[$i]){
        print "[ERROR] Outputs of the locked design under the found key and oracle do NOT match! \n";
        exit (1);
      }
    }
  } 

  if ($the_verb){print "[INFO] There has been no mistach on the outputs during simulation! \n";} 
}

sub verify_key{
  my ($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_gate_cnt, $org_gate_mat_ref, $enc_var_cnt, $enc_cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_key_lbl_ref, $enc_out_cnt, $enc_out_lbl_ref, $enc_cnf_str, $key_val_ref, $test_cnt, $testout_mat_ref) = @_;

  my $in_index = 0;
  my $lbl_index = 0;
  my $out_index = 0;
  my $miter_cnf = "";

  my $lbl_cnt = 0;
  my @lbl_mat = ();

  my $var_cnt = $enc_var_cnt;
  my $cla_cnt = $enc_cla_cnt;
  my $cnf_str = $enc_cnf_str;

  my $gate_index = 0;
  my $gate_output = 0;
  my $gate_in_cnt = 0;
  my @gate_in_arr = ();

  my @out_lbl = ();
  my $out_cnt = $enc_out_cnt;
  for (my $i=0; $i<$out_cnt; $i++){
    $out_lbl[$i] = $enc_out_lbl_ref->[$i][1];
  }

  $cnf_str .= "c Adding the key value of key inputs ... \n";
  for (my $i=0; $i<$enc_key_cnt; $i++){
    if ($key_val_ref->[$i] == 0){
      $cnf_str .= "-" . $enc_key_lbl_ref->[$i][1] . " 0 \n";
      $cla_cnt++;
    }
    else{
      $cnf_str .= $enc_key_lbl_ref->[$i][1] . " 0 \n";
      $cla_cnt++;
    }
  }

  $cnf_str .= "c Adding gates of the original circuit ... \n";
  for (my $i=0; $i<$org_gate_cnt; $i++){
    $lbl_index = where_is_inside_label_matrix($org_gate_mat_ref->[$i][0], $lbl_cnt, 0, \@lbl_mat);
    if ($lbl_index == -1){
      $var_cnt++;
      $lbl_mat[$lbl_cnt][0] = $org_gate_mat_ref->[$i][0];
      $lbl_mat[$lbl_cnt][1] = $var_cnt;
      $lbl_index = $lbl_cnt;
      $lbl_cnt++;
    }
    $gate_output = $lbl_mat[$lbl_index][1];
    $out_index = where_is_inside_label_matrix($org_gate_mat_ref->[$i][0], $org_out_cnt, 1, $org_out_lbl_ref);
    if ($out_index != -1){
      $out_lbl[$out_cnt+$out_index] = $lbl_mat[$lbl_index][1];
    }
    
    $gate_index = 0;
    while ($org_gate_mat_ref->[$i][$gate_index+2] != -1){
      $lbl_index = where_is_inside_label_matrix($org_gate_mat_ref->[$i][$gate_index+2], $lbl_cnt, 0, \@lbl_mat);
      if ($lbl_index == -1){
        $in_index = where_is_inside_label_matrix($org_gate_mat_ref->[$i][$gate_index+2], $org_in_cnt, 1, $org_in_lbl_ref);
        if ($in_index != -1){
          $lbl_mat[$lbl_cnt][0] = $org_gate_mat_ref->[$i][$gate_index+2];
          $lbl_mat[$lbl_cnt][1] = $org_in_lbl_ref->[$in_index][1];
          $lbl_index = $lbl_cnt;
          $lbl_cnt++;
        }
        else{
          $var_cnt++;
          $lbl_mat[$lbl_cnt][0] = $org_gate_mat_ref->[$i][$gate_index+2];
          $lbl_mat[$lbl_cnt][1] = $var_cnt;
          $lbl_index = $lbl_cnt;
          $lbl_cnt++;
        }
      }
      $gate_in_arr[$gate_index] = $lbl_mat[$lbl_index][1];
      $gate_index++;
    }

    if ($org_gate_mat_ref->[$i][1] == 0){
      ($cnf_str) = write_cnfstr_and($cnf_str, $gate_output, $gate_index, \@gate_in_arr);
      $cla_cnt += $gate_index + 1;
    }
    elsif ($org_gate_mat_ref->[$i][1] == 1){
      ($cnf_str) = write_cnfstr_buf($cnf_str, $gate_output, $gate_index, \@gate_in_arr);
      $cla_cnt += $gate_index + 1;
    }
    elsif ($org_gate_mat_ref->[$i][1] == 2){
      ($cnf_str) = write_cnfstr_or($cnf_str, $gate_output, $gate_index, \@gate_in_arr);
      $cla_cnt += $gate_index + 1;
    }
    elsif ($org_gate_mat_ref->[$i][1] == 3){
      ($cnf_str) = write_cnfstr_xor2($cnf_str, $gate_output, $gate_index, \@gate_in_arr);
      $cla_cnt += 4;
    }
    elsif ($org_gate_mat_ref->[$i][1] == 4){
      ($cnf_str) = write_cnfstr_nand($cnf_str, $gate_output, $gate_index, \@gate_in_arr);
      $cla_cnt += $gate_index + 1;
    }
    elsif ($org_gate_mat_ref->[$i][1] == 5){
      ($cnf_str) = write_cnfstr_not($cnf_str, $gate_output, $gate_index, \@gate_in_arr);
      $cla_cnt += $gate_index + 1;
    }
    elsif ($org_gate_mat_ref->[$i][1] == 6){
      ($cnf_str) = write_cnfstr_nor($cnf_str, $gate_output, $gate_index, \@gate_in_arr);
      $cla_cnt += $gate_index + 1;
    }
    elsif ($org_gate_mat_ref->[$i][1] == 7){
      ($cnf_str) = write_cnfstr_xnor2($cnf_str, $gate_output, $gate_index, \@gate_in_arr);
      $cla_cnt += 4;
    }
  }

  #my ($out_dep_arr) = determine_output_dependency_test($test_cnt, $out_cnt, $testout_mat_ref);
  ($var_cnt, $cla_cnt, $miter_cnf) = add_miter_output($reg_sat_solver, $var_cnt, $cla_cnt, $out_cnt, \@out_lbl);
  $cnf_str .= $miter_cnf;

  if ($the_verb){print "[INFO] Verifying the key with the original circuit... \n";}
 
  my $the_phrase = "";
  my $option_str = " ";
  #my $the_phrase = "_ver";
  my $cnf_file = $file_dir . $file_name . $the_phrase . ".cnf";
  open (my $fid_cnf, '>', $cnf_file);
  printf $fid_cnf "p cnf %d %d \n",$var_cnt, $cla_cnt;
  printf $fid_cnf "%s", $cnf_str;
  close ($fid_cnf);

  my ($sol_found, $in_val_ref) = run_sat_solver("wodata", $file_dir, $file_name, $the_phrase, $path_sat, $sat_solver_ind, $sat_seed, $org_in_cnt, $org_in_lbl_ref, $option_str);

  if ($sol_found == -1){
    print "[ERROR] SAT solver crashed!!! Returning... \n";
    exit (1);
  }
  elsif ($sol_found == 1){
    if ($the_verb){print "[ERROR] Found key values could not be proven to be right! \n";}
  }
  elsif ($sol_found == 0){
    if ($the_verb){print "[INFO] Found key values has just proven to be right! \n";}
  }
  elsif ($sol_found == 2){
    if ($the_verb){print "[WARNING] Found key values could not be verified in the given SAT time-limit! \n";}
  }
}

sub add_reverse_constraint{
  my ($the_cnt, $the_lbl_ref, $the_val_ref) = @_;

  my $the_con = "";
  
  for (my $i=0; $i<$the_cnt; $i++){
    if ($the_val_ref->[$i] == 0){
      $the_con .= $the_lbl_ref->[$i][1] . " ";
    }
    else{
      $the_con .= "-" . $the_lbl_ref->[$i][1] . " ";
    }
  }
  $the_con .= "0 \n";

  return ($the_con);
}

sub find_queries_random{
  my ($query_num, $file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $gate_lvlind_arr_ref, $adkv_arr_ref, $var_cnt, $cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $cnf_str, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str) = @_;
  
  my $test_cnt = 0;
  my @test_arr = ();

  if ($the_verb){print "[INFO] Finding random queries... \n";}
  
  my $exhaust_way = (2**$enc_in_cnt <= $query_num) ? 1 : 0;

  if ($exhaust_way == 1){
    for (my $i=0; $i<2**$enc_in_cnt; $i++){
      my ($test_arr_ref) = int2bin($i, $enc_in_cnt);

      #if ($the_verb){print_dip_array("[INFO] RANDIN", $org_in_cnt, $test_arr_ref)};
      my ($test_out_found, $test_out_ref) = apply_dip($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $test_arr_ref, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str);
      if ($test_out_found){
        #if ($the_verb){print_dip_array("[INFO] RANDOUT", $org_out_cnt, $test_out_ref)};
        ($dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str) = add_dip_output($gate_lvlind_arr_ref, $test_arr_ref, $adkv_arr_ref, $test_out_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref);
      }
    }
  }
  else{
    while ($test_cnt < $query_num){
      for (my $i=0; $i<$enc_in_cnt; $i++){
        $test_arr[$i] = int(rand(2));
      }

      #if ($the_verb){print_dip_array("[INFO] RANDIN", $org_in_cnt, \@test_arr)};
      my ($test_out_found, $test_out_ref) = apply_dip($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, \@test_arr, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str);
      if ($test_out_found){
        #if ($the_verb){print_dip_array("[INFO] RANDOUT", $org_out_cnt, $test_out_ref)};
        ($dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str) = add_dip_output($gate_lvlind_arr_ref, \@test_arr, $adkv_arr_ref, $test_out_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref);
        $test_cnt++;
      }
    }
  }

  if ($the_verb){print "[INFO] $test_cnt random queries are added! \n";};
  
  return ($dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str);
}

sub find_key_restrictions{
  my ($key_cnt, $key_lbl_ref, $test_cnt, $test_mat_ref, $cla_cnt, $cnf_str) = @_;

  $cnf_str .= "c Adding restrictions on key inputs \n";

  for (my $i=0; $i<$key_cnt; $i++){
    my $is_conflict = 0;
    for (my $j=0; $j<$test_cnt; $j++){
      if ($test_mat_ref->[$j][$i] != 2){
        $is_conflict = 1;
        last;
      }
    }

    if ($is_conflict == 0){
      if ($the_verb){print "[INFO] Value of $i. key input is not relevant! \n";}
      #By default the dont care input is assigned to 0
      #$cnf_str .= "-" . $key_lbl_ref->[$i] . " 0 \n";
      #$cla_cnt++;
      #$cnf_str .= "-" . $key_lbl_ref->[$key_cnt+$i] . " 0 \n";
      #$cla_cnt++;
    }
  }

  return ($cla_cnt, $cnf_str);
}

sub find_queries_atalanta{
  my ($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $gate_lvlind_arr_ref, $adkv_arr_ref, $var_cnt, $cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $cnf_str, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str) = @_;
  
  my $test_cnt = 0;
  my @test_arr = ();
  my @testin_mat = ();
  my @testkey_mat = ();
  my @testout_mat = ();

  my $x_cnt = 0;
  my @x_arr = ();
  
  my $bit_cnt = 0;
  my $the_char = "";
  my $the_line = "";
  my $the_index = 0;

  if ($the_verb){print "[INFO] Running the ATPG tool Atalanta to find the queries... \n";}
  #ADD the filename as a comment to the bench file for the Atalanta tool to work
  my $sed_cmd = "sed -i '1 i #circuit: " . $file_name . "' " . $file_enc;
  system ($sed_cmd);

  my ($path_ok, $path_atpg) = extract_tool_path($file_path, "atalanta");
  #print "path_atpg: $path_atpg \n";
  
  #Generating the necessary files and running Atalanta
  my $fault_test = $file_dir . $file_name . ".test";
  my $fault_summary = $file_dir . $file_name . "_atpg.summary";

  my $atpg_cmd = "";
  if ($query_tech == 2 or $query_tech == 4){
    my $fault_list = $file_dir . $file_name . ".fl";

    open (my $fid_fl, '>', $fault_list);
    for (my $i=0; $i<$enc_key_cnt; $i++){
      printf $fid_fl "keyinput%d /0 \n", $i;
    }
    close $fid_fl;

    #From the help guide of Atalanta
    $atpg_cmd = $path_atpg . " -A -f " . $fault_list . " -t " . $fault_test . " " . $file_enc . " > " . $fault_summary;
  }
  elsif ($query_tech == 3){
    #From the help guide of Atalanta
    $atpg_cmd = $path_atpg . " -r 16 -R -s 0 -b 10 -B 20 -c 2 -t "  . $fault_test . " " . $file_enc . " > " . $fault_summary;
  }
  #print "atpg_cmd: $atpg_cmd \n" ;
  system ($atpg_cmd);

  #Read the test patterns
  if ($query_tech == 2 or $query_tech == 4){
    if (open (my $file_header, '<:encoding(UTF-8)', $fault_test)){
      my $the_end = 0;
      my $key_cnt = 0;
      while ($the_end == 0){
        $the_line = <$file_header>;
        if ($the_line){
          chomp $the_line;
          if ($the_line eq "* Test patterns and fault free responses:"){
            $the_line = <$file_header>;

            while (1){
              $the_line = <$file_header>;
              #print "the_line: $the_line \n";

              if ($the_line){
                KEYCHECK: 
                my $key_index = index($the_line, "keyinput");
                if ($key_index != -1){
                  $key_index += 8;
                  my $key_num = 0;
                  while (1){
                    $the_char =substr($the_line, $key_index, 1);

                    if ($the_char =~ /[0-9]/){
                      $key_num = $key_num*10 + $the_char;
                      $key_index++;
                    }
                    else{
                      last;
                    }
                  }
                  my $key_str = "keyinput" . $key_num;
                  #print "key_num: $key_num \n";

                  #Read the next line
                  $the_line = <$file_header>;

                  if ($the_line){
                    #print "the_line: $the_line \n";
                    $the_index = index($the_line, ":");
                    if ($the_index == -1){
                      #$adkv_arr_ref->[$key_num] = 0;
                      #if ($the_verb){print "[INFO] The stuck-at-fault of $key_str is redundant and its value is assigned to logic 0! \n";}
                      if ($the_verb){print "[INFO] The stuck-at-fault of $key_str is redundant! \n";}
                      $key_cnt++;
                      goto KEYCHECK;
                    }
                    else{
                      $the_index++;
                      $bit_cnt = 0;
                      while ($bit_cnt < $enc_in_cnt){
                        $the_index++;
                        $the_char = substr($the_line, $the_index, 1);

                        if ($the_char eq "x"){
                          #A dont care bit is assumed to be 0
                          $test_arr[$bit_cnt] = 0;
                          $testin_mat[$test_cnt][$bit_cnt] = 2;
                        }
                        else{
                          $test_arr[$bit_cnt] = $the_char + 0;
                          $testin_mat[$test_cnt][$bit_cnt] = $test_arr[$bit_cnt];
                        }
                        $bit_cnt++;
                      }
                      #print_array("test_arr", $bit_cnt, \@test_arr);
                      
                      $bit_cnt = 0;
                      while ($bit_cnt < $enc_key_cnt){
                        $the_index++;
                        $the_char = substr($the_line, $the_index, 1);

                        if ($the_char eq "x"){
                          $testkey_mat[$test_cnt][$bit_cnt] = 2;
                        }
                        else{
                          if ($key_num == $bit_cnt){
                            $testkey_mat[$test_cnt][$bit_cnt] = 2;
                          }
                          else{
                            $testkey_mat[$test_cnt][$bit_cnt] = $the_char + 0;
                          }
                        }
                        $bit_cnt++;
                      }
                      #print_array("test_arr", $bit_cnt, \@test_arr);

                      $the_index++; #For the space between inputs and outputs
                      $bit_cnt = 0;
                      while ($bit_cnt < $enc_out_cnt){
                        $the_index++;
                        $the_char = substr($the_line, $the_index, 1);

                        if ($the_char eq "x"){
                          $testout_mat[$test_cnt][$bit_cnt] = 2;
                        }
                        else{
                          $testout_mat[$test_cnt][$bit_cnt] = $the_char + 0;
                        }
                        $bit_cnt++;
                      }
                      #print_array("test_arr", $bit_cnt, \@test_arr);
                      
                      $test_cnt++;

                      if ($the_verb){print_dip_array("[INFO] TESTIN", $org_in_cnt, \@test_arr)};
                      my ($test_out_found, $test_out_ref) = apply_dip($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, \@test_arr, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str);
                      if ($test_out_found){
                        if ($the_verb){print_dip_array("[INFO] TESTOUT", $org_out_cnt, $test_out_ref)};
                        ($dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str) = add_dip_output($gate_lvlind_arr_ref, \@test_arr, $adkv_arr_ref, $test_out_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref);
                      }

                      if ($test_cnt == $query_cnt){
                        $the_end = 1;
                        last;
                      }
                    }
                  }
                  else{
                    $adkv_arr_ref->[$key_cnt] = 0;
                    if ($the_verb){print "[INFO] The stuck-at-fault of $key_str is redundant and its value is assigned to logic 0! \n";}
                    $the_end = 1;
                    last;
                  }
                }
              }
              else{
                $the_end = 1;
                last;
              }

              $key_cnt++;
            }
          }
        }
        else{
          last;
        }
      }

      if ($the_verb){print "[INFO] $test_cnt test queries are added! \n";};

      close ($file_header);
    }
    else{
      print "[ERROR] Could not open the $fault_test file! \n";
    }
  }
  #Only differs on the style the test inputs are written
  elsif ($query_tech == 3){
    if (open (my $file_header, '<:encoding(UTF-8)', $fault_test)){
      my $the_end = 0;
      my $key_cnt = 0;
      while ($the_end == 0){
        $the_line = <$file_header>;
        if ($the_line){
          chomp $the_line;
          if ($the_line eq "* Test patterns and fault free responses:"){
            $the_line = <$file_header>;

            while (1){
              $the_line = <$file_header>;
              #print "the_line: $the_line \n";

              if ($the_line){
                $the_index = index($the_line, ":");
                if ($the_index != -1){
                  $the_index++;
                  $bit_cnt = 0;
                  while ($bit_cnt < $enc_in_cnt){
                    $the_index++;
                    $the_char = substr($the_line, $the_index, 1);

                    if ($the_char eq "x"){
                      #A dont care input bit is assumed to be 0
                      $test_arr[$bit_cnt] = 0;
                      $testin_mat[$test_cnt][$bit_cnt] = 2;
                    }
                    else{
                      $test_arr[$bit_cnt] = $the_char + 0;
                      $testin_mat[$test_cnt][$bit_cnt] = $test_arr[$bit_cnt];
                    }
                    $bit_cnt++;
                  }
                  #print_array("test_arr", $bit_cnt, \@test_arr);
                  #sleep (1);
                  
                  $bit_cnt = 0;
                  while ($bit_cnt < $enc_key_cnt){
                    $the_index++;
                    $the_char = substr($the_line, $the_index, 1);

                    if ($the_char eq "x"){
                      $testkey_mat[$test_cnt][$bit_cnt] = 2;
                    }
                    else{
                      $testkey_mat[$test_cnt][$bit_cnt] = $the_char + 0;
                    }
                    $bit_cnt++;
                  }

                  $the_index++; #For the space between inputs and outputs
                  $bit_cnt = 0;
                  while ($bit_cnt < $enc_out_cnt){
                    $the_index++;
                    $the_char = substr($the_line, $the_index, 1);

                    if ($the_char eq "x"){
                      $testout_mat[$test_cnt][$bit_cnt] = 2;
                    }
                    else{
                      $testout_mat[$test_cnt][$bit_cnt] = $the_char + 0;
                    }
                    $bit_cnt++;
                  }
                  
                  $test_cnt++;

                  #if ($the_verb){print_dip_array("[INFO] TESTIN", $org_in_cnt, \@test_arr)};
                  my ($test_out_found, $test_out_ref) = apply_dip($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, \@test_arr, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str);
                  if ($test_out_found){
                    #if ($the_verb){print_dip_array("[INFO] TESTOUT", $org_out_cnt, $test_out_ref)};
                    ($dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str) = add_dip_output($gate_lvlind_arr_ref, \@test_arr, $adkv_arr_ref, $test_out_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref);
                  }

                  if ($test_cnt == $query_cnt){
                    $the_end = 1;
                    last;
                  }
                }
              }
              else{
                $the_end = 1;
                last;
              }

              $key_cnt++;
            }
          }
        }
        else{
          last;
        }
      }

      if ($the_verb){print "[INFO] $test_cnt test queries are added! \n";};

      close ($file_header);
    }
    else{
      print "[ERROR] Could not open the $fault_test file! \n";
    }
  }

  #Remove the comment put at the top of the bench file for the Atalanta tool to work
  $sed_cmd = "sed -i '1 d' " . $file_enc;
  system ($sed_cmd);

  #print_matrix("testkey_mat", $test_cnt, $enc_key_cnt, \@testkey_mat);
  #($dkey_cla_cnt, $dkey_cnf_str) = find_key_restrictions($enc_key_cnt, $dkey_key_lbl_ref, $test_cnt, \@testkey_mat, $dkey_cla_cnt, $dkey_cnf_str);

  return ($test_cnt, \@testin_mat, \@testkey_mat, \@testout_mat, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $adkv_arr_ref);
}

sub find_queries{
  my ($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $gate_lvlind_arr_ref, $adkv_arr_ref, $var_cnt, $cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $cnf_str, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str, $res_in_arr) = @_;
 
  my $test_cnt = -1;
  my @test_arr = ();
  my $rev_cons = "";
  my $testin_mat_ref;
  my $testkey_mat_ref;
  my $testout_mat_ref;

  #Generate Queries Using Random Inputs
  if ($query_tech == 1){
    ($dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str) = find_queries_random($query_cnt, $file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $gate_lvlind_arr_ref, $adkv_arr_ref, $var_cnt, $cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $cnf_str, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str);
  }
  #Generate Queries Using Atalanta
  elsif ($query_tech == 2 or $query_tech == 3){
    ($test_cnt, $testin_mat_ref, $testkey_mat_ref, $testout_mat_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $adkv_arr_ref) = find_queries_atalanta($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $gate_lvlind_arr_ref, $adkv_arr_ref, $var_cnt, $cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $cnf_str, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str);
  }
  #Generate Queries Using Atalanta + Random Inputs
  elsif ($query_tech == 4){
    ($test_cnt, $testin_mat_ref, $testkey_mat_ref, $testout_mat_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $adkv_arr_ref) = find_queries_atalanta($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $gate_lvlind_arr_ref, $adkv_arr_ref, $var_cnt, $cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $cnf_str, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str);
    my $rand_query_cnt = $query_cnt - $test_cnt;
    if ($rand_query_cnt){
      ($dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str) = find_queries_random($rand_query_cnt, $file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $gate_lvlind_arr_ref, $adkv_arr_ref, $var_cnt, $cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $cnf_str, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str);
    }
  }

  return ($test_cnt, $testin_mat_ref, $testkey_mat_ref, $testout_mat_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $adkv_arr_ref, $res_in_arr);
}

sub prove_newkey_values{
  my ($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $key_cnt, $key_val_ref, $var_cnt, $cla_cnt, $key_lbl_ref, $cnf_str, $proven_key_val_ref) = @_;

  print "[INFO] Proving the values of the found key... \n";
  
  my $proven_key_cnt = 0;
  my $proven_key_str = "[INFO] Proven key: ";

  for (my $i=0; $i<$key_cnt; $i++){
    if ($proven_key_val_ref->[$i] == 2){
      #if ($the_verb){print "[INFO] Proving the value of the $i. key... \n";}
  
      my $key_cnf_str = $cnf_str;
      my $key_cla_cnt = $cla_cnt;
      if ($key_val_ref->[$i] == 1){
        $key_cla_cnt += 2;
        $key_cnf_str .= "-" . $key_lbl_ref->[$i] . " 0\n";
        $key_cnf_str .= "-" . $key_lbl_ref->[$i+$key_cnt] . " 0\n";
      }
      elsif ($key_val_ref->[$i] == 0) {
        $key_cla_cnt += 2;
        $key_cnf_str .= $key_lbl_ref->[$i] . " 0\n";
        $key_cnf_str .= $key_lbl_ref->[$i+$key_cnt] . " 0\n";
      }
  
      my $the_phrase = "";
      my $option_str = " ";
      #my $the_phrase = "_key";
      my $cnf_file = $file_dir . $file_name . $the_phrase . ".cnf";
      open (my $fid_cnf, '>', $cnf_file);
      if ($sat_solver_ind == 3){
        printf $fid_cnf "p inccnf %d %d \n", $var_cnt, $key_cla_cnt;
      }
      elsif ($sat_solver_ind == 8){
        printf $fid_cnf "p inccnf \n";
      }
      else{
        printf $fid_cnf "p cnf %d %d \n", $var_cnt, $key_cla_cnt;
      }
      printf $fid_cnf "%s", $key_cnf_str;
      close ($fid_cnf);
 
      my ($sol_found, $out_val_ref) = run_sat_solver("wodata", $file_dir, $file_name, $the_phrase, $path_sat, $sat_solver_ind, $sat_seed, $key_cnt, $key_lbl_ref, $option_str);
      
      if ($sol_found == -1){
        print "[ERROR] SAT solver crashed!!! Returning... \n";
        exit (1);
      }
      elsif ($sol_found == 0){
        print "[INFO] Value of the $i. key has been confirmed! \n";
        $proven_key_val_ref->[$i] = $key_val_ref->[$i];
        $proven_key_str .= $key_val_ref->[$i];
        $proven_key_cnt++;
      }
      else{
        $proven_key_str .= "x";
      }
    }
    else{
      $proven_key_str .= $proven_key_val_ref->[$i];
      $proven_key_cnt++;
    }
  }

  if ($the_verb){print "[INFO] #proven keys: $proven_key_cnt \n";}
  if ($the_verb){print "$proven_key_str \n";}

  return ($proven_key_val_ref);
}

sub prove_key_values{
  my ($file_dir, $file_name, $path_sat, $sat_solver_ind, $sat_seed, $key_cnt, $key_val_ref, $var_cnt, $cla_cnt, $key_lbl_ref, $cnf_str) = @_;

  print "[INFO] Proving the values of the found key... \n";

  my $proven_key_cnt = 0;
  my @proven_key_val = ();
  my $proven_key_str = "[INFO] Proven key: ";

  for (my $i=0; $i<$key_cnt; $i++){
    #if ($the_verb){print "[INFO] Proving the value of the $i. key... \n";}
    $proven_key_val[$i] = 2;
    
    my $key_cnf_str = $cnf_str;
    my $key_cla_cnt = $cla_cnt;
    if ($key_val_ref->[$i] == 1){
      $key_cla_cnt += 2;
      $key_cnf_str .= "-" . $key_lbl_ref->[$i] . " 0\n";
      $key_cnf_str .= "-" . $key_lbl_ref->[$i+$key_cnt] . " 0\n";
    }
    else{
      $key_cla_cnt += 2;
      $key_cnf_str .= $key_lbl_ref->[$i] . " 0\n";
      $key_cnf_str .= $key_lbl_ref->[$i+$key_cnt] . " 0\n";
    }
  
    my $the_phrase = "";
    my $option_str = " ";
    #my $the_phrase = "_key";
    my $cnf_file = $file_dir . $file_name . $the_phrase . ".cnf";
    open (my $fid_cnf, '>', $cnf_file);
    if ($sat_solver_ind  == 3){
      printf $fid_cnf "p inccnf %d %d \n", $var_cnt, $key_cla_cnt;
    }
    elsif ($sat_solver_ind == 8){
      printf $fid_cnf "p inccnf \n";
    }
    else{
      printf $fid_cnf "p cnf %d %d \n", $var_cnt, $key_cla_cnt;
    }
    printf $fid_cnf "%s", $key_cnf_str;
    close ($fid_cnf);
 
    my ($sol_found, $out_val_ref) = run_sat_solver("wodata", $file_dir, $file_name, $the_phrase, $path_sat, $sat_solver_ind, $sat_seed, $key_cnt, $key_lbl_ref, $option_str);
    
    if ($sol_found == -1){
      print "[ERROR] SAT solver crashed!!! Returning... \n";
      exit (1);
    }
    elsif ($sol_found == 0){
      print "[INFO] Value of the $i. key has been confirmed! \n";
      $proven_key_val[$i] = $key_val_ref->[$i];
      $proven_key_str .= $key_val_ref->[$i];
      $proven_key_cnt++;
    }
    else{
      $proven_key_str .= "x";
    }
  }

  if ($the_verb){print "[INFO] #proven keys: $proven_key_cnt \n";}
  if ($the_verb){print "$proven_key_str \n";}

  return (\@proven_key_val);
}

sub store_key{
  my ($file_dir, $file_name, $key_cnt, $key_val_ref) = @_;

  my $file_key = $file_dir . $file_name . ".key";
  open (my $fid_key, '>', $file_key);
  for (my $i=0; $i<$key_cnt; $i++){
    if ($key_val_ref->[$i] == 2){
      printf $fid_key "x";
    }
    else{
      printf $fid_key "%d", $key_val_ref->[$i];
    }
  }
  printf $fid_key "\n";
  close ($fid_key);
}

sub store_dipout{
  my ($file_dir, $file_name, $in_cnt, $out_cnt, $dip_cnt, $dip_ref_arr_ref, $dipout_ref_arr_ref) = @_;

  my $the_ref;

  my $file_dip = $file_dir . $file_name . ".dip";
  open (my $fid_dip, '>', $file_dip);
  for (my $i=0; $i<$dip_cnt; $i++){
    $the_ref = $dip_ref_arr_ref->[$i];
    for (my $j=0; $j<$in_cnt; $j++){
      printf $fid_dip "%d", $the_ref->[$j];
    }

    printf $fid_dip " ";

    $the_ref = $dipout_ref_arr_ref->[$i];
    for (my $k=0; $k<$out_cnt; $k++){
      printf $fid_dip "%d", $the_ref->[$k];
    }

    printf $fid_dip "\n";
  }

  close ($fid_dip);
}

sub order_by_level{
  my ($lbl_mat_ref, $gate_cnt, $gate_mat_ref) = @_;

  #print_gate_matrix("gate_matrix", $gate_cnt, $gate_mat_ref);

  my $max_level = 0;
  my $the_index = 2;
  my $node_level = -1;
  my $gate_level = -1;

  my @gate_index_arr = ();
  my @gate_level_arr = (); 

  for (my $i=0; $i<$gate_cnt; $i++){
    $gate_level_arr[$i] = -1;
  }

  #Compute the level of gates
  my $level_updated = 1;
  while ($level_updated){
    $level_updated = 0;

    for (my $i=0; $i<$gate_cnt; $i++){
      if ($gate_level_arr[$i] == -1){
        $gate_level = -1;

        $the_index = 2;
        while ($gate_mat_ref->[$i][$the_index] != -1){
          $node_level = $lbl_mat_ref->[ $gate_mat_ref->[$i][$the_index]-1 ][2];
          if ($node_level == -1){
            $gate_level = -1;
            last;
          }
          else{
            if ($node_level > $gate_level){
              $gate_level = $node_level;
            }
          }

          $the_index++;
        }

        if ($gate_level != -1){
          $lbl_mat_ref->[ $gate_mat_ref->[$i][0]-1 ][2] = $gate_level+1;
          $gate_level_arr[$i] = $gate_level+1;
          $level_updated = 1;

          if ($gate_level+1 > $max_level){
            $max_level = $gate_level+1;
          }
        }
      }
    }
  }

  #print "max_level: $max_level \n";

  #Determine the gate index according to gate level
  for (my $i=1; $i<=$max_level; $i++){
    for (my $j=0; $j<$gate_cnt; $j++){
      if ($gate_level_arr[$j] == $i){
        push (@gate_index_arr, $j);
      }
    }
  }
  
  #print_array("gate_level_arr", $gate_cnt, \@gate_level_arr);
  #print_array("gate_index_arr", $gate_cnt, \@gate_index_arr);
  
  return (\@gate_index_arr);
}

sub update_key_values{
  my ($key_cnt, $key_arr_ref, $auto_key_ref) = @_;

  for (my $i=0; $i<$key_cnt; $i++){
    if (!(defined $auto_key_ref->[$i])){
      $auto_key_ref->[$i] = $key_arr_ref->[$i];
    }
    else{
      if ($key_arr_ref->[$i] != 2){
        if ($auto_key_ref->[$i] == 2){
          $auto_key_ref->[$i] = $key_arr_ref->[$i];
        }
        else{
          if ($auto_key_ref->[$i] != $key_arr_ref->[$i]){
            print "[ERROR] A conflict on the key value $i has just been found! \n";
          }
        }
      }
    }
  }

  return ($auto_key_ref);
}

sub generate_orst_constraint{
  my ($cla_cnt, $cnf_str, $out_cnt, $out_lbl_ref, $out_ref) = @_;

  my $one_cnf_str = "";
  my $two_cnf_str = "";

  for (my $i=0; $i<$out_cnt; $i++){
    if ($out_ref->[$i] == 0){
      $one_cnf_str .= $out_lbl_ref->[$i] . " ";
      $two_cnf_str .= $out_lbl_ref->[$i+$out_cnt] . " ";
    }
    elsif ($out_ref->[$i] == 1){
      $one_cnf_str .= "-" . $out_lbl_ref->[$i] . " ";
      $two_cnf_str .= "-" . $out_lbl_ref->[$i+$out_cnt] . " ";
    }
  }

  $cla_cnt += 2;
  $cnf_str .= $one_cnf_str . "0 \n";
  $cnf_str .= $two_cnf_str . "0 \n";

  #print "cnf_str: $cnf_str \n";

  return ($cla_cnt, $cnf_str);
}


sub extract_proven_keys{
  my ($ext_file, $in_cnt, $key_cnt, $adkv_arr_ref, $dkey_cla_cnt, $dkey_cnf_str, $dkey_key_lbl_ref) = @_;

  my $is_err = 0;
  my $key_pos = 0;
  my $key_val = -1;
  my $the_var = "";
  my $the_sign = 0;
  my $the_index = 0;

  if (open (my $file_header, '<:encoding(UTF-8)', $ext_file)){
    my $line_cnt = 0;

    $dkey_cnf_str .= "c Inclusion of the proven key values... \n";

    while (my $the_line = <$file_header>){
      chomp $the_line;
      $line_cnt++;

      if ($line_cnt > $in_cnt){
        print "$the_line \n";
        $the_index = 0;

        while (substr($the_line, $the_index, 1) ne " "){
          $the_index++;
        }

        $the_var = substr($the_line, 0, $the_index) + 0.0;
        print "the_var: $the_var \n";

        if (abs($the_var) > $in_cnt and abs($the_var) <= $in_cnt + $key_cnt){
          $key_val = ($the_var > 0) ? 1 : 0;
          $key_pos = abs($the_var) - $in_cnt - 1;
          if ($the_verb){print "[INFO] Value of the $key_pos. key is confirmed! \n ";}

          if ($key_val == 0){
            $dkey_cla_cnt += 2;
            $dkey_cnf_str .= "-" . $dkey_key_lbl_ref->[$key_pos] . " 0 \n";
            $dkey_cnf_str .= "-" . $dkey_key_lbl_ref->[$key_cnt+$key_pos] . " 0 \n";
          }
          else{
            $dkey_cla_cnt += 2;
            $dkey_cnf_str .= $dkey_key_lbl_ref->[$key_pos] . " 0 \n";
            $dkey_cnf_str .= $dkey_key_lbl_ref->[$key_cnt+$key_pos] . " 0 \n";
          }
        }
        else{
          last;
        }
      }
    }

    #my $the_cmd = "rm -f " . $ext_file;
    #system ($the_cmd);

    close ($file_header);
  }
  else{
    print "[ERROR] Could not open the $ext_file file! \n";
    $is_err = 1;
  }

  return ($is_err, $adkv_arr_ref, $dkey_cla_cnt, $dkey_cnf_str);
}

sub extract_cnf_header{
  my ($the_line) = @_;

  my $is_err = 0;
  my $var_cnt = 0;
  my $cla_cnt = 0;
  my $the_char = "";

  my $lline = length($the_line);
  my $the_index = index($the_line, "p cnf");

  if ($the_index != -1){
    ($the_index) = skip_spaces_forward($the_line, $the_index+5);
    while (1){
      $the_char = substr($the_line, $the_index, 1);
      if ($the_char =~ /[0-9]/){
        $var_cnt = $var_cnt*10 + $the_char;
      }
      else{
        last;
      }
      $the_index++;
    }
    #print "var_cnt: $var_cnt \n";

    ($the_index) = skip_spaces_forward($the_line, $the_index);
    while (1){
      $the_char = substr($the_line, $the_index, 1);
      if ($the_char =~ /[0-9]/){
        $cla_cnt = $cla_cnt*10 + $the_char;
      }
      else{
        last;
      }
      $the_index++;
      if ($the_index > $lline){
        last;
      }
    }
    #print "cla_cnt: $cla_cnt \n";
  }
  else{
    $is_err = 1;
  }

  return ($is_err, $var_cnt, $cla_cnt);
}

sub add_key_relations{
  my ($dimacs_file, $var_cnt, $in_cnt, $key_cnt, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $dkey_key_lbl_ref) = @_;

  my $is_err = 0;
  my $the_var = 0;
  my $var_index = -1;
  my $var_index_cnt = 0;
  my @var_index_mat = ();

  my $init_index = 0;
  my $last_index = 0;

  if (open (my $file_header, '<:encoding(UTF-8)', $dimacs_file)){
    my $the_line = <$file_header>;
    chomp $the_line;

    my ($dimacs_is_err, $dimacs_var_cnt, $dimacs_cla_cnt) = extract_cnf_header($the_line);
    print "dimacs_var_cnt: $dimacs_var_cnt dimacs_cla_cnt: $dimacs_cla_cnt \n";
    if ($dimacs_is_err){
      print "[ERROR] No information on number of variables and clauses could be found! \n";
      $is_err = 1;
    }
    elsif ($dimacs_var_cnt != $var_cnt){
      print "dimacs_var_cnt: $dimacs_var_cnt dkey_var_cnt: $var_cnt \n";
      print "[ERROR] Number of variables in the original and simplified SAT problem does not match! Returning... \n";
      $is_err = 1;
    }
    elsif ($dimacs_cla_cnt == 0){
      print "[INFO] No clauses could be found in the simplified SAT problem! \n";
    }
    else{
      $dkey_cnf_str .= "c Inclusion of the information related to DIP and its output \n";
      while (my $the_line = <$file_header>){
        print "the_line: $the_line \n";

        $init_index = 0;
        $last_index = 0;
        my $one_cnf_str = "";
        my $two_cnf_str = "";
        my $lline = length($the_line);

        while (1){
          ($init_index) = skip_spaces_forward($the_line, $init_index);
          $last_index = $init_index;
          while (substr($the_line, $last_index, 1) ne " "){
            $last_index++;
            if ($last_index > $lline){
              last;
            }
          }

          $the_var = substr($the_line, $init_index, $last_index-$init_index) + 0.0;
          print "the_var: $the_var \n";

          if ($the_var == 0){
            $dkey_cla_cnt += 2;
            $dkey_cnf_str .= $one_cnf_str . "0 \n";
            $dkey_cnf_str .= $two_cnf_str . "0 \n";
            last;
          }
          else{
            my $var_sign = ($the_var > 0) ? 0 : 1;
            if (abs($the_var) > $in_cnt and abs($the_var) <= $in_cnt+$key_cnt){
              my $key_pos = abs($the_var)-$in_cnt-1;
              if ($var_sign == 1){
                $one_cnf_str .= "-" . $dkey_key_lbl_ref->[$key_pos] . " ";
                $two_cnf_str .= "-" . $dkey_key_lbl_ref->[$key_cnt+$key_pos] . " ";
              }
              else{
                $one_cnf_str .= $dkey_key_lbl_ref->[$key_pos] . " ";
                $two_cnf_str .= $dkey_key_lbl_ref->[$key_cnt+$key_pos] . " ";
              }
            }
            else{
              $var_index = where_is_inside_label_matrix(abs($the_var), $var_index_cnt, 0, \@var_index_mat);
              if ($var_index == -1){
                $var_index_mat[$var_index_cnt][0] = abs($the_var);
                
                $dkey_var_cnt++;
                $var_index_mat[$var_index_cnt][1] = $dkey_var_cnt;
                if ($var_sign == 1){
                  $one_cnf_str .= "-" . $dkey_var_cnt . " ";
                }
                else{
                  $one_cnf_str .= $dkey_var_cnt . " ";
                }

                $dkey_var_cnt++;
                $var_index_mat[$var_index_cnt][2] = $dkey_var_cnt; 
                if ($var_sign == 1){
                  $two_cnf_str .= "-" . $dkey_var_cnt . " ";
                }
                else{
                  $two_cnf_str .= $dkey_var_cnt . " ";
                }

                $var_index_cnt++;
              }
              else{
                if ($var_sign == 1){
                  $one_cnf_str .= "-" . $var_index_mat[$var_index][1] . " ";
                  $two_cnf_str .= "-" . $var_index_mat[$var_index][2] . " ";
                }
                else{
                  $one_cnf_str .= $var_index_mat[$var_index][1] . " ";
                  $two_cnf_str .= $var_index_mat[$var_index][2] . " ";
                }
              }
            }
          }

          $init_index = $last_index;
        }
      }
    }

    #my $the_cmd = "rm -f " . $dimacs_file;
    #system ($the_cmd);

    close ($file_header);
  }
  else{
    print "[ERROR] Could not open the $dimacs_file file! \n";
    $is_err = 1;
  }

  return ($is_err, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str);
}

sub add_dip_output_alt{
  my ($file_dir, $file_name, $path_sat, $sat_solver, $sat_seed, $the_dip_ref, $adkv_arr_ref, $dip_out_ref, $var_cnt, $cla_cnt, $cnf_str, $in_cnt, $in_lbl_ref, $key_cnt, $key_lbl_ref, $out_cnt, $out_lbl_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $dkey_key_lbl_ref) = @_;

  my $is_err = 0;

  print "BEFORE $dkey_var_cnt $dkey_cla_cnt \n";

  #Add the values of inputs to the SAT problem
  for (my $i=0; $i<$in_cnt; $i++){
    if ($the_dip_ref->[$i] == 0){
      $cnf_str .= "-" . $in_lbl_ref->[$i][1] . " 0 \n";
      $cla_cnt++;
    }
    elsif ($the_dip_ref->[$i] == 1){
      $cnf_str .= $in_lbl_ref->[$i][1] . " 0 \n";
      $cla_cnt++;
    }
  }

  #Add the values of keyinputs to the SAT problem
  for (my $i=0; $i<$key_cnt; $i++){
    if ($adkv_arr_ref->[$i] == 0){
      $cnf_str .= "-" . $key_lbl_ref->[$i][1] . " 0 \n";
      $cla_cnt++;
    }
    elsif ($adkv_arr_ref->[$i] == 1){
      $cnf_str .= $key_lbl_ref->[$i][1] . " 0 \n";
      $cla_cnt++;
    }
  }
  
  #Add the values of outputs to the SAT problem
  for (my $i=0; $i<$out_cnt; $i++){
    if ($dip_out_ref->[$i] == 0){
      $cnf_str .= "-" . $out_lbl_ref->[$i][1] . " 0 \n";
      $cla_cnt++;
    }
    elsif ($dip_out_ref->[$i] == 1){
      $cnf_str .= $out_lbl_ref->[$i][1] . " 0 \n";
      $cla_cnt++;
    }
  }

  my $the_phrase = "";
  my $option_str = "";
  #my $the_phrase = "_key";
  my $cnf_file = $file_dir . $file_name . $the_phrase . ".cnf";
  my $ext_file = $file_dir . $file_name . $the_phrase . ".ext";
  my $dimacs_file = $file_dir . $file_name . $the_phrase . "_dimacs.cnf";
 
  my $sat_solver_index = 0;
  #CRYPTOMINISAT
  if ($sat_solver == 0){
    $sat_solver_index = 1;
    $option_str = " --preproc 1 " . $dimacs_file . " ";
  }
  #CaDiCaL
  elsif ($sat_solver == 1){
    $sat_solver_index = 8;
    $option_str = " -o " . $dimacs_file . " -e " . $ext_file . " -n -O16 ";
  }

  open (my $fid_cnf, '>', $cnf_file);
  printf $fid_cnf "p cnf %d %d \n", $var_cnt, $cla_cnt;
  printf $fid_cnf "%s", $cnf_str;
  close ($fid_cnf);
   
  my ($sol_found, $key_val_ref) = run_sat_solver("wodata", $file_dir, $file_name, $the_phrase, $path_sat, $sat_solver_index, $sat_seed, $key_cnt, $key_lbl_ref, $option_str);

  if ($sol_found == -1){
    print "[WARNING] SAT solver crashed!!! Returning... \n";
  }
  elsif ($sol_found == 1){
    ($is_err, $adkv_arr_ref, $dkey_cla_cnt, $dkey_cnf_str) = extract_proven_keys($ext_file, $in_cnt, $key_cnt, $adkv_arr_ref, $dkey_cla_cnt, $dkey_cnf_str, $dkey_key_lbl_ref);
    if ($is_err == 0){
      ($is_err, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str) = add_key_relations($dimacs_file, $var_cnt, $in_cnt, $key_cnt, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $dkey_key_lbl_ref);
      print "dkey_cnf_str: $dkey_cnf_str \n";
    }
  }
  else {
    print "[INFO] Could not update the SAT problem! \n";
  }

  print "AFTER $dkey_var_cnt $dkey_cla_cnt \n";
  
  exit (1);

  return ($dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $adkv_arr_ref);
}

sub main_part{
  my ($reg_sat_phrase, $dip_sat_phrase, $simp_sat_phrase, $sat_seed, $file_key, $ite_lim) = @_;

  my $initial_time = time();
  
  my $ite_num = 0;
  my $dip_cnt = 0;
  my $the_dip_ref;
  my $dip_found = 0;
  my $sol_found = 0;
  my @mask_cone = ();
  my $res_in_arr = 0;
  my $adkv_is_err = 0;
  my $keas_is_err = 0;
  my $orst_cla_cnt = 0;
  my $orst_cnf_str = "";

  my $dip_out_ref;
  my $dip_ref_arr_ref;
  my $dip_out_found = 0; 
  my $dipout_ref_arr_ref;

  my $test_cnt = -1;
  my $testin_mat_ref;
  my $testkey_mat_ref;
  my $testout_mat_ref;

  #Oracle data from bench file
  my $org_po_arr_ref;
  my $org_in_lbl_ref;
  my $org_key_lbl_ref;
  my $org_out_lbl_ref;
  my $org_lbl_mat_ref;
  my $org_gate_mat_ref;
  my $org_in_cnt = 0;
  my $org_is_err = 0;
  my $org_var_cnt = 0;
  my $org_cla_cnt = 0;
  my $org_key_cnt = 0;
  my $org_out_cnt = 0;
  my $org_lbl_cnt = 0;
  my $org_gate_cnt = 0;
  my $org_cnf_str = "";
  my $check_org_enc = 1;
  
  my ($file_name, $file_dir) = extract_file_name_directory($file_enc);

  if ($file_org ne ""){
    ($org_is_err, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_key_cnt, $org_key_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_lbl_cnt, $org_lbl_mat_ref, $org_gate_cnt, $org_po_arr_ref, $org_gate_mat_ref, $org_cnf_str) = convert_bench_cnf($file_org);
  }  
  if ($org_is_err == 0){
    my ($enc_is_err, $enc_var_cnt, $enc_cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_key_lbl_ref, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $enc_cnf_str) = convert_bench_cnf($file_enc);
    if ($enc_is_err == 0){
      if ($file_org ne ""){
        $check_org_enc = check_regular_rules($org_in_cnt, $org_in_lbl_ref, $enc_in_cnt, $enc_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $enc_out_cnt, $enc_out_lbl_ref, $enc_key_cnt);
      }
      else{
        $org_in_cnt = $enc_in_cnt;
        $org_out_cnt = $enc_out_cnt;
      }
      if ($check_org_enc){
        my ($path_reg_sat_ok, $path_reg_sat) = extract_tool_path($file_path, $reg_sat_phrase);
        my ($path_dip_sat_ok, $path_dip_sat) = extract_tool_path($file_path, $dip_sat_phrase);
        my ($path_simp_sat_ok, $path_simp_sat) = extract_tool_path($file_path, $simp_sat_phrase);
        if ($path_reg_sat_ok and $path_dip_sat_ok and $path_simp_sat_ok){
          $file_name .= "_" . $reg_sat_phrase . "_" . $sat_seed;
          if ($query_cnt == 0){
            if ($query_tech == 1 or $query_tech == 2){
              $query_cnt = $enc_key_cnt;
            }
            elsif ($query_tech == 4){
              $query_cnt = 2*$enc_key_cnt;
            }
            elsif ($query_tech == 3){
              $query_cnt = 9**9**9;
            }
          }
          my ($adkv_arr_ref) = initialize_defined_key_values_array($enc_key_cnt);
          my ($gate_lvlind_arr_ref) = order_by_level($enc_lbl_mat_ref, $enc_gate_cnt, $enc_gate_mat_ref);
          my ($dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str) = generate_dkey_cnf($enc_var_cnt, $enc_cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_key_lbl_ref, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $enc_cnf_str);
          if ($file_key ne ""){
            ($adkv_is_err, $dkey_cla_cnt, $dkey_cnf_str, $adkv_arr_ref) = add_defined_key_values($file_key, $dkey_cla_cnt, $enc_key_cnt, $dkey_key_lbl_ref, $dkey_cnf_str, $adkv_arr_ref);
          }
          if ($adkv_is_err == 0){
            if ($file_key_assumption ne ""){
              ($keas_is_err, $dkey_cla_cnt, $dkey_cnf_str) = add_key_assumptions($file_key_assumption, $dkey_cla_cnt, $enc_key_cnt, $enc_key_lbl_ref, $dkey_key_lbl_ref, $dkey_cnf_str);
            }
            if ($keas_is_err == 0){
              if ($query_tech){
                ($test_cnt, $testin_mat_ref, $testkey_mat_ref, $testout_mat_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $adkv_arr_ref) = find_queries($file_dir, $file_name, $path_reg_sat, $reg_sat_solver, $sat_seed, $gate_lvlind_arr_ref, $adkv_arr_ref, $enc_var_cnt, $enc_cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $enc_cnf_str, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str);
              }
              while (1){
                if ($the_verb){print "[INFO] ### Iteration $ite_num ### \n";}
                ($dip_found, $the_dip_ref, $orst_cla_cnt, $orst_cnf_str) = determine_dip($file_dir, $file_name, $path_dip_sat, $dip_sat_solver, $sat_seed, $ite_num, $enc_in_cnt, $enc_in_lbl_ref, $dkey_var_cnt, $dkey_cla_cnt, $enc_key_cnt, $dkey_key_lbl_ref, $adkv_arr_ref, $enc_out_cnt, $dkey_out_lbl_ref, $dkey_cnf_str, $orst_cla_cnt, $orst_cnf_str, $test_cnt, $testin_mat_ref, $testkey_mat_ref, $testout_mat_ref);
                #exit (1);
                if ($dip_found == 1){
                  if ($the_verb){print_dip_array("[INFO] DIP", $org_in_cnt, $the_dip_ref)};
                  ($dip_out_found, $dip_out_ref) = apply_dip($file_dir, $file_name, $path_reg_sat, $reg_sat_solver, $sat_seed, $the_dip_ref, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str);
                  if ($the_verb){print_dip_array("[INFO] DIPOUT", $org_out_cnt, $dip_out_ref)};
                  ($dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str) = add_dip_output($gate_lvlind_arr_ref, $the_dip_ref, $adkv_arr_ref, $dip_out_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref);
                  $dip_ref_arr_ref->[$dip_cnt] = $the_dip_ref;
                  $dipout_ref_arr_ref->[$dip_cnt] = $dip_out_ref;
                  $dip_cnt++;
                  if ($is_orst){
                    ($orst_cla_cnt, $orst_cnf_str) = generate_orst_constraint($orst_cla_cnt, $orst_cnf_str, $enc_out_cnt, $dkey_out_lbl_ref, $dip_out_ref);
                  }
                }
                else{
                  my ($key_found, $key_val_ref) = extract_key($file_dir, $file_name, $path_reg_sat, $reg_sat_solver, $sat_seed, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $enc_key_cnt, $enc_key_lbl_ref);
                  if ($key_found){
                    if ($dip_found == 0){
                      if ($file_org ne ""){
                        if ($is_nvk == 0){
                          verify_key($file_dir, $file_name, $path_reg_sat, $reg_sat_solver, $sat_seed, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_gate_cnt, $org_gate_mat_ref, $enc_var_cnt, $enc_cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_key_lbl_ref, $enc_out_cnt, $enc_out_lbl_ref, $enc_cnf_str, $key_val_ref, -1, $testout_mat_ref);
                        }
                        store_key($file_dir, $file_name, $enc_key_cnt, $key_val_ref);
                      }
                      elsif ($exec_org ne ""){
                        if ($is_nvk == 0){
                          simulate_key($file_dir, $file_name, $path_reg_sat, $reg_sat_solver, $sat_seed, $enc_var_cnt, $enc_cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_key_lbl_ref, $enc_out_cnt, $enc_out_lbl_ref, $enc_cnf_str, $key_val_ref);
                        }
                      }
                      $sol_found = 1;
                    }
                    elsif ($dip_found == 2){
                      my ($proven_key_val_ref) = prove_key_values($file_dir, $file_name, $path_dip_sat, $dip_sat_solver, $sat_seed, $enc_key_cnt, $key_val_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_cnf_str);
                      store_dipout($file_dir, $file_name, $org_in_cnt, $org_out_cnt, $dip_cnt, $dip_ref_arr_ref, $dipout_ref_arr_ref);
                      store_key($file_dir, $file_name, $enc_key_cnt, $proven_key_val_ref);
                    }
                  }
                  last;
                }
                $ite_num++;
                if ((time() - $initial_time > $run_lim) or $ite_num > $ite_lim){
                  if ($the_verb){print "[INFO] Quitting due to the exceeded run time/iteration number limit... \n";}
                  my ($key_found, $key_val_ref) = extract_key($file_dir, $file_name, $path_reg_sat, $reg_sat_solver, $sat_seed, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $enc_key_cnt, $enc_key_lbl_ref);
                  my ($proven_key_val_ref) = prove_key_values($file_dir, $file_name, $path_dip_sat, $dip_sat_solver, $sat_seed, $enc_key_cnt, $key_val_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_cnf_str);
                  store_dipout($file_dir, $file_name, $org_in_cnt, $org_out_cnt, $dip_cnt, $dip_ref_arr_ref, $dipout_ref_arr_ref);
                  store_key($file_dir, $file_name, $enc_key_cnt, $proven_key_val_ref);
                  last;
                }
              }
            }
          }
        }
      }
    }
  }
  printf "[INFO] Total number of iterations: %d \n", $ite_num;
  printf "[INFO] Total CPU time: %.2f \n", time()-$initial_time;

  return ($sol_found, $dip_cnt, $dip_ref_arr_ref, $dipout_ref_arr_ref);
}

sub single_iterative_decipher{
  my ($reg_sat_phrase, $dip_sat_phrase, $simp_sat_phrase, $sat_seed, $file_key, $ite_lim) = @_;

  my $initial_time = time();
 
  my $ite_cnt = 0;
  my $ite_num = 0;
  my $dip_cnt = 0;
  my $sol_found = 0;
  my $res_in_arr = 0;
  my $adkv_is_err = 0;
  my $orst_cla_cnt = 0;
  my $orst_cnf_str = "";

  my $dip_ref_arr_ref;
  my $dipout_ref_arr_ref;
  
  my $test_cnt = -1;
  my $testin_mat_ref;
  my $testkey_mat_ref;
  my $testout_mat_ref;

  #Oracle data from bench file
  my $org_po_arr_ref;
  my $org_in_lbl_ref;
  my $org_key_lbl_ref;
  my $org_out_lbl_ref;
  my $org_lbl_mat_ref;
  my $org_gate_mat_ref;
  my $org_in_cnt = 0;
  my $org_is_err = 0;
  my $org_var_cnt = 0;
  my $org_cla_cnt = 0;
  my $org_key_cnt = 0;
  my $org_out_cnt = 0;
  my $org_lbl_cnt = 0;
  my $org_gate_cnt = 0;
  my $org_cnf_str = "";
  my $check_org_enc = 1;
  
  my ($file_name, $file_dir) = extract_file_name_directory($file_enc);

  if ($file_org ne ""){
    ($org_is_err, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_key_cnt, $org_key_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_lbl_cnt, $org_lbl_mat_ref, $org_gate_cnt, $org_po_arr_ref, $org_gate_mat_ref, $org_cnf_str) = convert_bench_cnf($file_org);
  }
  if ($org_is_err == 0){
    my ($enc_is_err, $enc_var_cnt, $enc_cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_key_lbl_ref, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $enc_cnf_str) = convert_bench_cnf($file_enc);
    if ($enc_is_err == 0){
      if ($file_org ne ""){
        $check_org_enc = check_regular_rules($org_in_cnt, $org_in_lbl_ref, $enc_in_cnt, $enc_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $enc_out_cnt, $enc_out_lbl_ref, $enc_key_cnt);
      }
      else{
        $org_in_cnt = $enc_in_cnt;
        $org_out_cnt = $enc_out_cnt;
      }
      if ($check_org_enc){
        my ($path_reg_sat_ok, $path_reg_sat) = extract_tool_path($file_path, $reg_sat_phrase);
        my ($path_dip_sat_ok, $path_dip_sat) = extract_tool_path($file_path, $dip_sat_phrase);
        my ($path_simp_sat_ok, $path_simp_sat) = extract_tool_path($file_path, $simp_sat_phrase);
        if ($path_reg_sat_ok and $path_dip_sat_ok and $path_simp_sat_ok){
          $file_name .= "_" . $reg_sat_phrase . "_" . $sat_seed;
          if ($query_cnt == 0){
            if ($query_tech == 1 or $query_tech == 2){
              $query_cnt = $enc_key_cnt;
            }
            elsif ($query_tech == 4){
              $query_cnt = 2*$enc_key_cnt;
            }
            elsif ($query_tech == 3){
              $query_cnt = 9**9**9;
            }
          }
          my ($adkv_arr_ref) = initialize_defined_key_values_array($enc_key_cnt);
          my ($gate_lvlind_arr_ref) = order_by_level($enc_lbl_mat_ref, $enc_gate_cnt, $enc_gate_mat_ref);
          my ($dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str) = generate_dkey_cnf($enc_var_cnt, $enc_cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_key_lbl_ref, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $enc_cnf_str);
          if ($file_key ne ""){
            ($adkv_is_err, $dkey_cla_cnt, $dkey_cnf_str, $adkv_arr_ref) = add_defined_key_values($file_key, $dkey_cla_cnt, $enc_key_cnt, $dkey_key_lbl_ref, $dkey_cnf_str, $adkv_arr_ref);
          }
          if ($adkv_is_err == 0){
            if ($query_tech){
              ($test_cnt, $testin_mat_ref, $testkey_mat_ref, $testout_mat_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $adkv_arr_ref) = find_queries($file_dir, $file_name, $path_reg_sat, $reg_sat_solver, $sat_seed, $gate_lvlind_arr_ref, $adkv_arr_ref, $enc_var_cnt, $enc_cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref, $enc_cnf_str, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str);
              my ($key_found, $key_val_ref) = extract_key($file_dir, $file_name, $path_reg_sat, $reg_sat_solver, $sat_seed, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $enc_key_cnt, $enc_key_lbl_ref);
              ($adkv_arr_ref) = prove_newkey_values($file_dir, $file_name, $path_dip_sat, $dip_sat_solver, $sat_seed, $enc_key_cnt, $key_val_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_cnf_str, $adkv_arr_ref);
              ($dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str) = update_sat_problem($file_dir, $file_name, $path_simp_sat, $simp_sat_solver, $sat_seed, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $enc_key_cnt, $enc_key_lbl_ref, $dkey_key_lbl_ref, $adkv_arr_ref);
            }
            while (1){
              while (1){
                if ($the_verb){print "[INFO] ### Iteration $ite_cnt ### \n";}
                my ($dip_found, $the_dip_ref, $orst_cla_cnt, $orst_cnf_str) = determine_dip($file_dir, $file_name, $path_dip_sat, $dip_sat_solver, $sat_seed, $ite_num, $enc_in_cnt, $enc_in_lbl_ref, $dkey_var_cnt, $dkey_cla_cnt, $enc_key_cnt, $dkey_key_lbl_ref, $adkv_arr_ref, $enc_out_cnt, $dkey_out_lbl_ref, $dkey_cnf_str, $orst_cla_cnt, $orst_cnf_str, $test_cnt, $testin_mat_ref, $testkey_mat_ref, $testout_mat_ref);
                if ($dip_found == 1){
                  #if ($the_verb){print_dip_array("[INFO] DIP", $org_in_cnt, $the_dip_ref)};
                  my ($dip_out_found, $dip_out_ref) = apply_dip($file_dir, $file_name, $path_reg_sat, $reg_sat_solver, $sat_seed, $the_dip_ref, $org_var_cnt, $org_cla_cnt, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_cnf_str);
                  #if ($the_verb){print_dip_array("[INFO] DIPOUT", $org_out_cnt, $dip_out_ref)};
                  ($dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str) = add_dip_output($gate_lvlind_arr_ref, $the_dip_ref, $adkv_arr_ref, $dip_out_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_out_lbl_ref, $dkey_cnf_str, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_out_cnt, $enc_out_lbl_ref, $enc_lbl_cnt, $enc_lbl_mat_ref, $enc_gate_cnt, $enc_po_arr_ref, $enc_gate_mat_ref);
                  $dip_ref_arr_ref->[$dip_cnt] = $the_dip_ref;
                  $dipout_ref_arr_ref->[$dip_cnt] = $dip_out_ref;
                  $dip_cnt++;
                  if ($is_orst){
                    ($orst_cla_cnt, $orst_cnf_str) = generate_orst_constraint($orst_cla_cnt, $orst_cnf_str, $enc_out_cnt, $dkey_out_lbl_ref, $dip_out_ref);
                  }
                }
                else{
                  my ($key_found, $key_val_ref) = extract_key($file_dir, $file_name, $path_reg_sat, $reg_sat_solver, $sat_seed, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $enc_key_cnt, $enc_key_lbl_ref);
                  #($adkv_arr_ref) = prove_newkey_values($file_dir, $file_name, $path_dip_sat, $dip_sat_solver, $sat_seed, $enc_key_cnt, $key_val_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_cnf_str, $adkv_arr_ref);
                  if ($key_found){
                    if ($file_org ne ""){
                      verify_key($file_dir, $file_name, $path_reg_sat, $reg_sat_solver, $sat_seed, $org_in_cnt, $org_in_lbl_ref, $org_out_cnt, $org_out_lbl_ref, $org_gate_cnt, $org_gate_mat_ref, $enc_var_cnt, $enc_cla_cnt, $enc_in_cnt, $enc_in_lbl_ref, $enc_key_cnt, $enc_key_lbl_ref, $enc_out_cnt, $enc_out_lbl_ref, $enc_cnf_str, $key_val_ref, -1, $testout_mat_ref);
                      store_key($file_dir, $file_name, $enc_key_cnt, $key_val_ref);
                    }
                    $sol_found = 1;
                    last;
                  }
                  else{
                    $sol_found = -1;
                    exit (1);
                  }
                }
                $ite_num++;
                $ite_cnt++;
                if (time() - $initial_time > $run_lim){
                  if ($the_verb){print "[INFO] Quitting due to the exceeded run time... \n";}
                  last;
                }
                elsif ($ite_num == $ite_lim){
                  if ($the_verb){print "[INFO] Iteration number limit has been reached. Proving key values and updating SAT problem... \n";}
                  my ($key_found, $key_val_ref) = extract_key($file_dir, $file_name, $path_reg_sat, $reg_sat_solver, $sat_seed, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $enc_key_cnt, $enc_key_lbl_ref);
                  ($adkv_arr_ref) = prove_newkey_values($file_dir, $file_name, $path_dip_sat, $dip_sat_solver, $sat_seed, $enc_key_cnt, $key_val_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_cnf_str, $adkv_arr_ref);
                  ($dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str) = update_sat_problem($file_dir, $file_name, $path_simp_sat, $simp_sat_solver, $sat_seed, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $enc_key_cnt, $enc_key_lbl_ref, $dkey_key_lbl_ref, $adkv_arr_ref);
                  $ite_num = 0;
                  last;
                }
              }
              if ($sol_found == 1){
                last;
              }
              elsif ($sol_found == -1){
                print "[INFO] Not all the proven keys are right! \n";
                last;
              }
              if ((time() - $initial_time > $run_lim)){
                my ($key_found, $key_val_ref) = extract_key($file_dir, $file_name, $path_reg_sat, $reg_sat_solver, $sat_seed, $dkey_var_cnt, $dkey_cla_cnt, $dkey_cnf_str, $enc_key_cnt, $enc_key_lbl_ref);
                ($adkv_arr_ref) = prove_newkey_values($file_dir, $file_name, $path_dip_sat, $dip_sat_solver, $sat_seed, $enc_key_cnt, $key_val_ref, $dkey_var_cnt, $dkey_cla_cnt, $dkey_key_lbl_ref, $dkey_cnf_str, $adkv_arr_ref);
                store_dipout($file_dir, $file_name, $org_in_cnt, $org_out_cnt, $dip_cnt, $dip_ref_arr_ref, $dipout_ref_arr_ref);
                store_key($file_dir, $file_name, $enc_key_cnt, $adkv_arr_ref);
                last;
              }
            }
          }
        }
      }
    }
  }
  printf "[INFO] Total number of iterations: %d \n", $ite_cnt;
  printf "[INFO] Total CPU time: %.2f \n", time()-$initial_time;

  return ($sol_found, $dip_cnt, $dip_ref_arr_ref, $dipout_ref_arr_ref);
}

sub parallel_part{
  my @sat_seed_arr = ();
  for (my $i=0; $i<$att_cnt; $i++){
    $sat_seed_arr[$i] = int(rand(2**16-1))+1;
  }

  fork_main($glb_reg_sat_phrase, $glb_dip_sat_phrase, \@sat_seed_arr, 10, \&main_part);
}

sub fork_main (\@$&) {
  my ($sat_solver, $data, $max, $code) = @_;

  my $c = 0;
  foreach my $data (@$data) {
    wait unless ++ $c <= $max;
    die "Fork failed: $!\n" unless defined (my $pid = fork);
    exit $code -> ($sat_solver, $data) unless $pid;
  }

  1 until -1 == wait;
}

