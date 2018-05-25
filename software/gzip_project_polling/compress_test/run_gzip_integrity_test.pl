#!/usr/bin/perl -w
use strict;
use warnings;

use File::Slurp qw/read_file/;
use List::Compare;

use Time::HiRes qw(time);
use POSIX qw(strftime);

use Excel::Writer::XLSX;      # Enable Excel editing for this script


print "\n**************************************************************************\n";
print "                           GZIP Integrity Test\n";
print "                                                   Author: Ovidiu PLUGARIU";
print "\n**************************************************************************\n";


my $first_name;
#$first_name=$ARGV[0];

my $EN_PRINT = 1;

my $file;
my @files;
my $index=2;
my $difference_counter = 0;
my $test_counter = 0;
my $success_counter = 0;
my $error_counter = 0;


@files = <*calgary/*>;  # here are some books in .txt format
#@files = <*KAT_books/*>;  # here are some books in .txt format


print "\n\n\n************* Test Compression in STORED mode  ************\n";
foreach $file (@files) {
if ($EN_PRINT == 1) {
  print $file . "\n";
}
  my $fsize_full = (stat($file))[7]; # in bytes
if ($EN_PRINT == 1) {
  print "Full size: $fsize_full\n bytes";
}
  $test_counter = $test_counter + 1;
  $difference_counter = 0;   #clear the difference counter from the previous file
  
  system("./../program -n $file temporary.gz"); #compress each file with the GZIP core in STORED mode
  system("gzip -d temporary.gz "); #decompress the archive with GZIP utilitary

  #compare 2 files to check if they are identical
  chomp( my @a_file = read_file $file );
  chomp( my @b_file = read_file 'temporary' );

  my $lc = List::Compare->new( \@a_file, \@b_file );

  my @LorRonly = $lc->get_symmetric_difference; #Get those items which appear at least once in either the first or the second list, but not both.
  #my @Ronly = $lc->get_Ronly;
  #my @Lonly = $lc->get_Lonly;

  foreach (@LorRonly) {
     print "'$_'\n";  # Prints each element.
     $difference_counter = $difference_counter + 1; # increment the counter if there are differences  
  }
  print "difference_counter = $difference_counter";  # Prints each element.

  if ($difference_counter == 0) {
     $success_counter = $success_counter + 1;
     print "\nSUCCES: $file was successfully compressed and decompressed in STORED mode\n";  # Prints each element.
  } else {
     $error_counter = $error_counter + 1;
     print "\nERROR: $file was compressed and decompressed with $difference_counter errors in STORED mode \n";  # Prints each element.
  }
  #foreach (@Ronly) {print "'$_'\n";} # Prints each element.
  #foreach (@Lonly) {print "'$_'\n";} # Prints each element.

  system("rm temporary"); # delete the temporary file
}


print "\n\n\n************* Test Compression in FIXED HUFFMAN mode  ************\n";
foreach $file (@files) {
if ($EN_PRINT == 1) {
  print $file . "\n";
}
  my $fsize_full = (stat($file))[7]; # in bytes
if ($EN_PRINT == 1) {
  print "Full size: $fsize_full\n bytes";
}
  $test_counter = $test_counter + 1;
  $difference_counter = 0;   #clear the difference counter from the previous file

  system("./../program -f $file temporary.gz"); #compress each file with the GZIP core in FIXED_HUFFMAN
  system("gzip -d temporary.gz "); #decompress the archive with GZIP utilitary

  #compare 2 files to check if they are identical
  chomp( my @a_file = read_file $file );
  chomp( my @b_file = read_file 'temporary' );

  my $lc = List::Compare->new( \@a_file, \@b_file );

  my @LorRonly = $lc->get_symmetric_difference; #Get those items which appear at least once in either the first or the second list, but not both.
  #my @Ronly = $lc->get_Ronly;
  #my @Lonly = $lc->get_Lonly;

  foreach (@LorRonly) {
     print "'$_'\n";  # Prints each element.
     $difference_counter = $difference_counter + 1; # increment the counter if there are differences
  }
  print "difference_counter = $difference_counter";  # Prints each element.

  if ($difference_counter == 0) {
     $success_counter = $success_counter + 1;
     print "\nSUCCES: $file was successfully compressed and decompressed\n in FIXED HUFFMAN";  # Prints each element.
  } else {
     $error_counter = $error_counter + 1;
     print "\nERROR: $file was compressed and decompressed with $difference_counter errors in FIXED HUFFMAN\n";  # Prints each element.
  }
  system("rm temporary"); # delete the temporary file
}

# Check the verification metrics
my $no_of_files = $test_counter / 2;
if ($test_counter == $success_counter){
   print "\n\n\n          GZIP Integrity TEST Script terminated successfully\n\n";
   print "           $no_of_files files were tested with $error_counter erros\n\n";
} else {
   print "\n\n\n          GZIP Integrity TEST Script terminated with $error_counter errors\n\n";
   print "           $no_of_files files were tested with $error_counter erros\n\n";
}


