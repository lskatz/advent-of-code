#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Data::Dumper;
use List::Permutor;

# First line of data is the intcode
while(my $intcode = <DATA>){
  my $phasing = <DATA>;
  my $expected= <DATA>;
  last if(!$expected);
  chomp($intcode, $phasing, $expected);
  my @int = split(/,/,$intcode);
  my @phaseOriginal = split(/,/, $phasing);

  my $permutor = List::Permutor->new(@phaseOriginal);
  my $maxThrust = 0;
  while(my @phase = $permutor->next() ){
    my $thrust = thrustAmplifiersFeedback(\@int, \@phase);

    if($thrust > $maxThrust){
      $maxThrust = $thrust;
    }

  }
  is($maxThrust, $expected, "Expected: $expected");
}

sub thrustAmplifiersFeedback{
  my($intOriginal, $phaseOriginal) =@_;
  
  # Copy the phase
  my @phase = @$phaseOriginal;

  # Create amplifier "structs"
  my %amp;
  for my $amp("A".."E"){
    # Make a copy of the intcode and then store the reference
    $amp{$amp}{int} = [@$intOriginal];
  }

  my $input = 0;
  my $chainOutput = -1;
  for(my $i=0;$i<@phase;$i++){
    for my $amp(keys(%amp)){
      my @ampInput = ($phase[$i], $input);
      my $diagnosticOutput = processIntCode($amp{$amp}{int}, \@ampInput);
      $input = $diagnosticOutput;
    }
    last if($input == $chainOutput);
    $chainOutput = $input;
  }
  note "Phase @phase ===> $chainOutput";
  sleep 1;
  return $chainOutput;
}

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
3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5
9,8,7,6,5
139629729

