#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

# Try 1: 1111111111 too high
# Try 2: 10 not right
# Try 3: 1 is not right
#

while(my $input = <DATA>){
  my $intcode = <DATA>;
  last if(!$intcode);
  chomp($input, $intcode);
  my @int = split(/,/,$intcode);
  my $diagnosticOutput = processIntCode(\@int, $input);
  print "$diagnosticOutput\n";
  BAIL_OUT("DEBUG");
}

sub processIntCode{
  my($intOriginal, $input) = @_;
  my @int = @$intOriginal; # avoid modifying by reference

  my $diagnosticOutput = "";

  my $i=0;
  while($i < @int){
    my $opcode = $int[$i];
    if($opcode == 99){
      last;
    }

    # Indexes
    my $idx1   = $int[$i+1];
    my $idx2   = $int[$i+2];
    my $idxOut = $int[$i+3];

    # Values
    my $int1   = $int[$idx1];
    my $int2   = $int[$idx2] || 0;

    # Watch out for immediate mode
    if($opcode > 99){
      # Force a five digit code
      $opcode = sprintf("%05d", $opcode);

      if(substr($opcode, -3, 1) == 1){
        $int1 = $idx1;
      }
      if(substr($opcode, -4, 1) == 1){
        $int2 = $idx2;
      }
      if(substr($opcode, -5, 1) == 1){
        ...;
      }
      $opcode = substr($opcode, -2, 2);
    }

    if($opcode == 1){
      my $value = $int1 + $int2;
      $int[$idxOut] = $value;
      $i+=4;
    } elsif($opcode == 2){
      my $value = $int1 * $int2;
      $int[$idxOut] = $value;
      $i+=4;
    } elsif($opcode == 3){
      my $value = $input;
      $int[$idxOut] = $value;
      $i+=2;
    } elsif($opcode == 4){
      my $value = $input;
      $diagnosticOutput = $value;
      diag $value;
      $i+=2;
    } else{
      die "INTERNAL ERROR: unsure what to do with opcode $opcode";
    }
  }
  
  return $diagnosticOutput;
}

__DATA__
1
3,225,1,225,6,6,1100,1,238,225,104,0,1002,92,42,224,1001,224,-3444,224,4,224,102,8,223,223,101,4,224,224,1,224,223,223,1102,24,81,225,1101,89,36,224,101,-125,224,224,4,224,102,8,223,223,101,5,224,224,1,224,223,223,2,118,191,224,101,-880,224,224,4,224,1002,223,8,223,1001,224,7,224,1,224,223,223,1102,68,94,225,1101,85,91,225,1102,91,82,225,1102,85,77,224,101,-6545,224,224,4,224,1002,223,8,223,101,7,224,224,1,223,224,223,1101,84,20,225,102,41,36,224,101,-3321,224,224,4,224,1002,223,8,223,101,7,224,224,1,223,224,223,1,188,88,224,101,-183,224,224,4,224,1002,223,8,223,1001,224,7,224,1,224,223,223,1001,84,43,224,1001,224,-137,224,4,224,102,8,223,223,101,4,224,224,1,224,223,223,1102,71,92,225,1101,44,50,225,1102,29,47,225,101,7,195,224,101,-36,224,224,4,224,102,8,223,223,101,6,224,224,1,223,224,223,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,107,677,677,224,1002,223,2,223,1006,224,329,1001,223,1,223,1108,226,677,224,102,2,223,223,1006,224,344,101,1,223,223,1107,226,226,224,1002,223,2,223,1006,224,359,101,1,223,223,8,677,226,224,1002,223,2,223,1006,224,374,1001,223,1,223,1107,677,226,224,102,2,223,223,1005,224,389,1001,223,1,223,1008,677,677,224,1002,223,2,223,1006,224,404,1001,223,1,223,108,677,677,224,102,2,223,223,1005,224,419,1001,223,1,223,1107,226,677,224,102,2,223,223,1006,224,434,101,1,223,223,1008,226,226,224,1002,223,2,223,1006,224,449,1001,223,1,223,107,226,226,224,102,2,223,223,1006,224,464,1001,223,1,223,1007,677,226,224,1002,223,2,223,1006,224,479,1001,223,1,223,1108,226,226,224,102,2,223,223,1006,224,494,1001,223,1,223,8,226,226,224,1002,223,2,223,1005,224,509,1001,223,1,223,7,226,677,224,102,2,223,223,1005,224,524,101,1,223,223,1008,677,226,224,102,2,223,223,1005,224,539,101,1,223,223,107,226,677,224,1002,223,2,223,1006,224,554,1001,223,1,223,1108,677,226,224,102,2,223,223,1005,224,569,101,1,223,223,108,226,226,224,1002,223,2,223,1005,224,584,1001,223,1,223,7,677,226,224,1002,223,2,223,1005,224,599,1001,223,1,223,108,226,677,224,1002,223,2,223,1006,224,614,101,1,223,223,1007,677,677,224,1002,223,2,223,1006,224,629,101,1,223,223,7,677,677,224,102,2,223,223,1005,224,644,101,1,223,223,1007,226,226,224,1002,223,2,223,1006,224,659,1001,223,1,223,8,226,677,224,102,2,223,223,1005,224,674,1001,223,1,223,4,223,99,226
99
1002,4,3,4,33
