#!/usr/bin/perl -w
use strict;
use warnings;

use Time::HiRes qw(time);
use POSIX qw(strftime);

use Excel::Writer::XLSX;      # Enable Excel editing for this script


print "\n**************************************************************************\n";
print "                  Script for Compression Speed Test\n";
print "                                                   Author: Ovidiu PLUGARIU";
print "\n**************************************************************************\n";


#Create a new Excel file and a worksheet
my $workbook  = Excel::Writer::XLSX->new( 'compress_test.xlsx' );
my $worksheet = $workbook->add_worksheet();

$worksheet->write( "A1", "Filename" );
$worksheet->write( "B1", "File size [B]" );
$worksheet->write( "C1", "Soft Compression Ratio" );
$worksheet->write( "D1", "Soft Compression Speed [MBps]" );
$worksheet->write( "E1", "FPGA Compression Ratio" );
$worksheet->write( "F1", "FPGA Compression Speed [MBps]" );


my $first_name;
#$first_name=$ARGV[0];


#my $file = "/home/oplugariu/xillybus_work/xillybus/project/input.txt";  # relative path within chroot
#my $fsize = (stat($file))[7]; # in bytes
#print "File size: $fsize\n";

my $EN_PRINT = 0;

my $file;
my @files;
my $index=2;

#@files = <*corpus/*>;   # this is only for a small test
@files = <*calgary/*>;  # this is the official test

#################### Compress corpus with GZIP Software ####################
foreach $file (@files) {
if ($EN_PRINT == 1) {
  printf "\n FPGA Test %d \n", $index-1;
}
  # Calculate the compression ratio of a file by calculatin the size of the input file and the oputput file in bytes
if ($EN_PRINT == 1) {
  print $file . "\n";
}
  my $fsize_full = (stat($file))[7]; # in bytes
if ($EN_PRINT == 1) {
  print "Full size: $fsize_full\n";
}

  my $start = time;             # calculate the compression time of a file
  system("gzip -k $file -c > corpus_comp.gz");
  my $duration = time - $start;

  my $comp_file = "corpus_comp.gz";  # create a temporary file for archive name
  #my $comp_file = "/home/oplugariu/xillybus_work/xillybus/projecta/temporary.gz";  # relative path within chroot
  my $fsize_comp = (stat($comp_file))[7]; # in bytes
if ($EN_PRINT == 1) {
  print "Compressed size: $fsize_comp\n";
}

  my $compression_ratio = $fsize_full / $fsize_comp;
if ($EN_PRINT == 1) {
  printf "\nCompression_ratio = %.3f\n", $compression_ratio;
  print "Compression_time: $duration s\n";
}
  my $compression_speed = ($fsize_comp /(1024*1024)) / $duration;
  #my $compression_speed = ($fsize_comp / $duration) ;
if ($EN_PRINT == 1) {
  print "Compression_speed: $compression_speed MBps\n";
}
  # Write in excel the result of the compression test in Excel
  $worksheet->write( "A$index", "$file" );
  $worksheet->write( "B$index", "$fsize_full" );
  $worksheet->write( "C$index", "$compression_ratio" );
  $worksheet->write( "D$index", "$compression_speed" );
  $index=$index + 1;

  system("rm corpus_comp.gz");
}



#################### Compress corpus with GZIP Hardware ####################
$index=2;
foreach $file (@files) {
if ($EN_PRINT == 1) {
  printf "\n FPGA Test %d \n", $index-1;
}
  # Calculate the compression ratio of a file by calculatin the size of the input file and the oputput file in bytes
if ($EN_PRINT == 1) {
  print $file . "\n";
}
  my $fsize_full = (stat($file))[7]; # in bytes
if ($EN_PRINT == 1) {
  print "Full size: $fsize_full\n";
}

  #my $start = time;             # calculate the compression time of a file
  #system("./../program -f $file corpus_comp_fpga.gz");
  my $return_val = `./../program -f $file corpus_comp_fpga.gz`;
  #print "Return_val=: $return_val\n";
  my @all_nums    = $return_val =~ /(\d+)/g;
  #print "All nums:  $all_nums[0] / $all_nums[1] \n";
  my $duration = $all_nums[0] + $all_nums[1] * 0.000001 ; # calculate the total time
  #print "duration= : $duration\n";

  my $comp_file = "corpus_comp_fpga.gz";  # create a temporary file for archive name
  #my $comp_file = "/home/oplugariu/xillybus_work/xillybus/projecta/temporary.gz";  # relative path within chroot
  my $fsize_comp = (stat($comp_file))[7]; # in bytes
if ($EN_PRINT == 1) {
  print "Compressed size: $fsize_comp\n";
}

  my $compression_ratio = $fsize_full / $fsize_comp;
if ($EN_PRINT == 1) {
  printf "\nCompression_ratio = %.3f\n", $compression_ratio;
  print "Compression_time: $duration s\n";
}
  my $compression_speed = ($fsize_comp /(1024*1024)) / $duration;
  #my $compression_speed = ($fsize_comp / $duration) ;
if ($EN_PRINT == 1) {
  print "Compression_speed: $compression_speed MBps\n";
}

  # Write in excel the result of the compression test in Excel
  $worksheet->write( "E$index", "$compression_ratio" );
  $worksheet->write( "F$index", "$compression_speed" );
  $index=$index + 1;

  system("rm corpus_comp_fpga.gz");
}
  my $old_index = $index - 1;
  $worksheet->write( "A$index", "AVERAGE" );
  $worksheet->write( "C$index", "=AVERAGE(". "C2:C$old_index" . ')' );
  $worksheet->write( "D$index", "=AVERAGE(". "D2:D$old_index" . ')' );
  $worksheet->write( "E$index", "=AVERAGE(". "E2:E$old_index" . ')' );
  $worksheet->write( "F$index", "=AVERAGE(". "F2:F$old_index" . ')' );
  #$worksheet->write_formula( "C", $index, '=AVERAGE(' . C2:C$index +. ')' );
  

#Close the used workbook for the MRBENCH script
$workbook->close;

print "\n\n\n                    COMPRESS TEST Script terminated successfully\n\n";

