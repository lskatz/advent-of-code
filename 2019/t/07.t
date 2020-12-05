#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests=>4;
use Data::Dumper;
use List::Permutor;

# First line of data is the intcode
while(my $intcode = <DATA>){
  my $phasing = <DATA>;
  my $expected= <DATA>;
  last if(!$expected);
  chomp($intcode, $phasing, $expected);
  my @int = split(/,/,$intcode);
  my @phase = split(/,/, $phasing);

  my $thrust = thrustAmplifiers(\@int, \@phase);
  is($thrust, $expected, "Phasing: @phase  Expected: $expected");
}

sub thrustAmplifiers{
  my($intOriginal, $phaseOriginal) =@_;
  my @int   = @$intOriginal;
  my @phase = @$phaseOriginal;

  my $input = 0;
  for(my $i=0;$i<@phase;$i++){
    my @ampInput = ($phase[$i], $input);
    my $diagnosticOutput = processIntCode(\@int, \@ampInput);
    $input = $diagnosticOutput;
  }
  return $input;
}

my $puzzleInput = "3,8,1001,8,10,8,105,1,0,0,21,34,51,64,81,102,183,264,345,426,99999,3,9,102,2,9,9,1001,9,4,9,4,9,99,3,9,101,4,9,9,102,5,9,9,1001,9,2,9,4,9,99,3,9,101,3,9,9,1002,9,5,9,4,9,99,3,9,102,3,9,9,101,3,9,9,1002,9,4,9,4,9,99,3,9,1002,9,3,9,1001,9,5,9,1002,9,5,9,101,3,9,9,4,9,99,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,99,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,99";
my $permutor = List::Permutor->new(0..4);
my $maxThrust = 0;
my @int = split(/,/, $puzzleInput);
while(my @phase = $permutor->next() ){
  my $input = 0;
  for(my $i=0;$i<@phase;$i++){
    my @ampInput = ($phase[$i], $input);
    my $diagnosticOutput = processIntCode(\@int, \@ampInput);
    #note "$input => $diagnosticOutput";
    $input = $diagnosticOutput;
  }
  if($maxThrust < $input){
    $maxThrust = $input;
  }
}
is($maxThrust, 46248, "Expected max thrust: 46248");

sub processIntCode{
  my($intOriginal, $ampInputOriginal) = @_;
  
  # avoid modifying by reference
  my @int      = @$intOriginal;
  my @ampInput = @$ampInputOriginal;

  my $diagnosticOutput = "";

  my $i=0;
  my $numInstructions = 0;
  while($i < @int){
    #note join(",", "pointer: $i ",@int);
    if(++$numInstructions > 99999){
      BAIL_OUT("ERROR: number of instructions went to $numInstructions with input ".join(",",@$ampInputOriginal));
    }
    my $opcode = $int[$i];
    if($opcode == 99){
      last;
    }

    # Indexes
    my $idx1   = $int[$i+1];
    my $idx2   = $int[$i+2];
    my $idxOut = $int[$i+3];

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
    }
    # Opcode 3 takes a single integer as input and saves
    # it to the position given by its only parameter. For
    # example, the instruction 3,50 would take an input
    # value and store it at address 50.
    elsif($opcode == 3){
      my $value = shift(@ampInput);
      $idxOut = $idx1;
      #note "  opcode:$opcode value:$value idxOut:$idxOut";
      $int[$idxOut] = $value;
      $i+=2;
    }
    # Opcode 4 outputs the value of its only parameter. 
    # For example, the instruction 4,50 would output the
    # value at address 50.
    elsif($opcode == 4){
      my $value = $int1 || 0;
      if(!defined($value)){
        #BAIL_OUT(join(", ", $input, "pointer: $i numinstructions $numInstructions", "..", @int,"\n", @$intOriginal));
      }
      $diagnosticOutput = $value;
      #note "Diagnostic output: $value";
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
    else{
      die "INTERNAL ERROR: unsure what to do with opcode $opcode";
    }
  }
  
  return $diagnosticOutput;
}

# three lines per test: intcode, phasing, answer.
__DATA__
3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0
4,3,2,1,0
43210
3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0
0,1,2,3,4
54321
3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0
1,0,4,3,2
65210

