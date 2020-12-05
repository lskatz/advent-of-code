#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

# Loop through __DATA__
while(my $intcode = <DATA>){
  my $input = <DATA>;
  my $expected = <DATA>;
  last if(!$expected);
  chomp($intcode, $input, $expected);
  my @int = split(/,/,$intcode);

  # Run the intcode through the machine
  my $diagnosticOutput = processIntCode(\@int, $input);

  # Check against expected result
  is($diagnosticOutput, $expected, "Expected $expected for input $input");
}

sub processIntCode{
  my($intOriginal, $input) = @_;
  my @int = @$intOriginal; # avoid modifying by reference

  my $diagnosticOutput = "";

  my $i=0;
  my $numInstructions = 0;
  my $relativeBase = 0; # altered by opcode 9

  # The machine goes until the pointer reaches the end
  while($i < @int){
    # A catch in case we're about to go into an infinite loop
    if(++$numInstructions > 99999){
      BAIL_OUT("ERROR: number of instructions went to $numInstructions with input $input");
    }
    # The opcode at pointer $i
    my $opcode = $int[$i];

    # Exit with opcode 99
    if($opcode == 99){
      last;
    }

    # Indexes
    my $idx1   = $int[$i+1+$relativeBase];
    my $idx2   = $int[$i+2+$relativeBase];
    my $idxOut = $int[$i+3+$relativeBase];

    # Values
    my $int1   = $int[$idx1] || 0;
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
        # Not implemented yet
        ...;
      }
      # The final two digits are the opcode
      $opcode = substr($opcode, -2, 2);
    }

    # Opcode 1: addition
    if($opcode == 1){
      my $value = $int1 + $int2;
      $int[$idxOut] = $value;
      $i+=4;
    } 
    # Opcode 2: multiplication
    elsif($opcode == 2){
      my $value = $int1 * $int2;
      $int[$idxOut] = $value;
      $i+=4;
    }
    # Opcode 3 takes a single integer as input and saves
    # it to the position given by its only parameter. For
    # example, the instruction 3,50 would take an input
    # value and store it at address 50.
    elsif($opcode == 3){
      my $value = $input;
      $idxOut = $idx1;
      $int[$idxOut] = $value;
      $i+=2;
    }
    # Opcode 4 outputs the value of its only parameter. 
    # For example, the instruction 4,50 would output the
    # value at address 50.
    elsif($opcode == 4){
      my $value = $int1 || 0;
      $diagnosticOutput = $value;
      note "Diagnostic output: $value";
      $i+=2;
    } 
    # Opcode 5 is jump-if-true: if the first parameter is non-zero,
    # it sets the instruction pointer to the value from
    # the second parameter. Otherwise, it does nothing.
    elsif($opcode == 5){
      if($int1 != 0){
        my $value = $int2;
        $i = $value;
      } else {
        $i+=3;
      }
    }
    # Opcode 6 is jump-if-false: if the first parameter is zero, 
    # it sets the instruction pointer to the value from the 
    # second parameter. Otherwise, it does nothing.
    elsif($opcode == 6){
      if($int1 == 0){
        my $value = $int2;
        $i = $value;
      } else {
        $i+=3;
      }
    }
    # Opcode 7 is less than: if the first parameter is less 
    # than the second parameter, it stores 1 in the position
    # given by the third parameter. Otherwise, it stores 0.
    elsif($opcode == 7){
      if($int1 < $int2){
        $int[$idxOut] = 1;
      } else {
        $int[$idxOut] = 0;
      }
      $i+=4;
    }
    # Opcode 8 is equals: if the first parameter is equal to
    # the second parameter, it stores 1 in the position given
    # by the third parameter. Otherwise, it stores 0.
    elsif($opcode == 8){
      if($int1 == $int2){
        $int[$idxOut] = 1;
      } else {
        $int[$idxOut] = 0;
      }
      $i+=4;
    }
    # Opcode 9 adjusts the relative base by the value of its
    # only parameter. The relative base increases (or
    # decreases, if the value is negative) by the value of
    # the parameter.
    elsif($opcode == 9){
      $relativeBase += $int1;
      $i+=2;
    }
    # Hopefully we don't end up with an unknown opcode but
    # catch it just in case
    else{
      die "INTERNAL ERROR: unsure what to do with opcode $opcode";
    }
  }
  
  return $diagnosticOutput;
}

__DATA__
109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99
4
109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99
1102,34915192,34915192,7,4,7,99,0
0
1219070632396864
104,1125899906842624,99
0
1125899906842624
