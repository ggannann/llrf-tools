#!/usr/bin/perl
# Script by Fredrik Kristensen
# Version date: 2015-09-16
use warnings;
use strict;
use POSIX;
use List::Util qw(max min);

###################################################
# INPUT
###################################################
my $comp_val;
my $metric;
if (@ARGV < 2 || @ARGV > 3){
    my $help =    sprintf("Usage: log-file, compare value, optional [Error metric (0|1)]\n");
    $help = $help.sprintf("Output 0 if error metric is belov compare value else 1\n");
    $help = $help.sprintf("Error metric  0: Average error (Default)\n");
    $help = $help.sprintf("              1: Max error\n");
    die $help;
}elsif(@ARGV == 2){
    $comp_val = pop @ARGV;
    $metric   = 0;
}elsif(@ARGV == 3){
    $metric   = pop @ARGV;
    $comp_val = pop @ARGV;
}
#print "comp=$comp_val metric=$metric\n";

###################################################
# Constants
###################################################

###################################################
# Sub functions
###################################################

###################################################
# MAIN
###################################################
# Scan log file
my $avg_i;
my $avg_q;
my $max_i;
my $max_q;
my $test_end=0;
while (<>){
  if (/(TEST END)/) {
      $test_end = 1;
  } elsif ($test_end && /I:RMS-AVERAGE\s*(\d.\d*)/){
      $avg_i = $1;
  } elsif ($test_end && /Q:RMS-AVERAGE\s*(\d.\d*)/){
      $avg_q = $1;
  } elsif ($test_end && /I:RMS-MAX\s*(\d.\d*)/){
      $max_i = $1;
  } elsif ($test_end && /Q:RMS-MAX\s*(\d.\d*)/){
      $max_q = $1;
  }
}

###################################################
# OUTPUT
###################################################
#print error
my $val;
my $exit_code=1;
if ($metric==0) {
    $val = ($avg_i+$avg_q)/2;
}else{
    $val = max($max_i,$max_q);
}
#round output
$val=sprintf("%0.6f\n",$val);
print($val);

#Exit
if ( $val <= $comp_val ) {$exit_code=0;}
exit $exit_code;

