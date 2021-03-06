#!/usr/bin/env perl
#
# NOTE: set $DEBUG to 1 for verbose output

use strict;
use warnings;
use Test::More tests=>1;
use Data::Dumper;
use List::Permutor;
use List::Util qw/max/;

my $DEBUG=0;
sub note{
  if($DEBUG){
    Test::More::note(@_);
  }
}

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
    #note "DEBUG"; next unless("@phase" eq "9 7 8 5 6");
    my $thrust = thrustAmplifiersFeedback(\@int, \@phase);
    note "Phase @phase ===> $thrust";
    $maxThrust = max($thrust, $maxThrust);
  }
  is($maxThrust, $expected, "Expected: $expected");
  #note "DEBUG"; last;
}

# Run through one set of 5 amplifiers until "E" gets an
# exit code.
sub thrustAmplifiersFeedback{
  my($intOriginal, $phaseOriginal) =@_;
  
  # Copy the phase
  my @phase = @$phaseOriginal;

  # Create amplifier "structs"
  my @amp;
  for(my $i=0;$i<5;$i++){
    # Make a copy of the intcode 
    my @int = @$intOriginal;

    # Make the "struct"
    $amp[$i] = {
      int                 => \@int,
      numints             => scalar(@int),
      pointer             => 0,
      instructionsCounter => 0,
      input               => [$phase[$i]],
    }
  }

  my $input = 0;
  my $diagnosticOutput = 0;
  my $chainOutput = -1;
  for(my $i=0;$i<@amp;$i++){
    # Get the previous amp's output as the new input.
    # If this is the first round with amp A, then the input is 0.
    if(defined($input)){
      push(@{$amp[$i]{input}}, $input);
      note "AMPLIFIER $i, p$amp[$i]{pointer}, input".join(",",@{$amp[$i]{input}});
      $diagnosticOutput = processIntCode($amp[$i]);
    }

    if($i == @amp - 1){
      if(defined($diagnosticOutput)){
        $chainOutput = $diagnosticOutput;
        $i=-1; # ie reset the loop
      }
    }
    $input = $diagnosticOutput;
  }
  return $chainOutput;
}

sub processIntCode{
  my($amp) = @_;
  
  my $diagnosticOutput = "";

  while($$amp{pointer} < $$amp{numints}){
    note join(",", "p$$amp{pointer}",@{$$amp{int}});
    if(++$$amp{instructionsCounter} > 99999){
      BAIL_OUT("ERROR: number of instructions went to ".$$amp{instructionsCounter});
    }
    my $opcode = $$amp{int}[$$amp{pointer}];
    if($opcode == 99){
      return undef;
    }

    # Indexes
    my $idx1   = $$amp{int}[$$amp{pointer}+1];
    my $idx2   = $$amp{int}[$$amp{pointer}+2];
    my $idxOut = $$amp{int}[$$amp{pointer}+3];

    # Values
    my $int1   = $$amp{int}[$idx1] || 0;
    my $int2   = $$amp{int}[$idx2] || 0;

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
      $$amp{int}[$idxOut] = $value;
      $$amp{pointer} +=4;
      note "$opcode: Setting position $idxOut to $value ($int1+$int2) and moving 4 up to $$amp{pointer}";
    } elsif($opcode == 2){
      my $value = $int1 * $int2;
      $$amp{int}[$idxOut] = $value;
      $$amp{pointer} +=4;
      note "$opcode: Setting position $idxOut to $value ($int1*$int2) and moving 4 up to $$amp{pointer}";
    }
    # Opcode 3 takes a single integer as input and saves
    # it to the position given by its only parameter. For
    # example, the instruction 3,50 would take an input
    # value and store it at address 50.
    elsif($opcode == 3){
      my $value = shift(@{$$amp{input}});
      $idxOut = $idx1;
      #note "  opcode:$opcode value:$value idxOut:$idxOut";
      $$amp{int}[$idxOut] = $value;
      $$amp{pointer} +=2;
      note "$opcode: Setting position $idxOut to $value and moving 2 up to $$amp{pointer}";
    }
    # Opcode 4 outputs the value of its only parameter. 
    # For example, the instruction 4,50 would output the
    # value at address 50.
    elsif($opcode == 4){
      my $value = $int1 || 0;
      $diagnosticOutput = $value;
      $$amp{pointer} +=2;
      note "$opcode: moving 2 up to $$amp{pointer} and returning diagnosticOutput=$diagnosticOutput";
      return $diagnosticOutput;
    } 
    # Opcode 5 is jump-if-true: if the first parameter is non-zero,
    # it sets the instruction pointer to the value from
    # the second parameter. Otherwise, it does nothing.
    elsif($opcode == 5){
      if($int1 != 0){
        my $value = $int2;
        $$amp{pointer}  = $value;
        note "$opcode: current int $int1 is true and setting pointer to $$amp{pointer}";
      } else {
        $$amp{pointer} +=3;
        note "$opcode: current int $int1 is false and moving pointer up 3 to $$amp{pointer}";
      }
    }
    # Opcode 6 is jump-if-false: if the first parameter is zero, 
    # it sets the instruction pointer to the value from the 
    # second parameter. Otherwise, it does nothing.
    elsif($opcode == 6){
      if($int1 == 0){
        my $value = $int2;
        $$amp{pointer}  = $value;
        note "$opcode: current int $int1 is false and setting pointer to $$amp{pointer}";
      } else {
        $$amp{pointer} +=3;
        note "$opcode: current int $int1 is true and moving pointer up 3 to $$amp{pointer}";
      }
    }
    # Opcode 7 is less than: if the first parameter is less 
    # than the second parameter, it stores 1 in the position
    # given by the third parameter. Otherwise, it stores 0.
    elsif($opcode == 7){
      my $value;
      if($int1 < $int2){
        $value = 1;
      } else {
        $value = 0;
      }
      $$amp{int}[$idxOut] = $value;
      $$amp{pointer} +=4;
      note "$opcode (less-than): $int1 <=> $int2 and therefore setting $idxOut = $value. Moving pointer up 4 to $$amp{pointer}";
    }
    # Opcode 8 is equals: if the first parameter is equal to
    # the second parameter, it stores 1 in the position given
    # by the third parameter. Otherwise, it stores 0.
    elsif($opcode == 8){
      my $value;
      if($int1 == $int2){
        $value = 1;
      } else {
        $value = 0;
      }
      $$amp{pointer} +=4;
      note "$opcode (equals): $int1 <=> $int2 and therefore setting $idxOut = $value. Moving pointer up 4 to $$amp{pointer}";
    }
    else{
      die "INTERNAL ERROR: unsure what to do with opcode $opcode";
    }
  }
  note "Made it to the end of the int array - returning undef";
  return undef;
  
  return $diagnosticOutput;
}

# three lines per test: intcode, phasing, answer.
__DATA__
3,8,1001,8,10,8,105,1,0,0,21,34,51,64,81,102,183,264,345,426,99999,3,9,102,2,9,9,1001,9,4,9,4,9,99,3,9,101,4,9,9,102,5,9,9,1001,9,2,9,4,9,99,3,9,101,3,9,9,1002,9,5,9,4,9,99,3,9,102,3,9,9,101,3,9,9,1002,9,4,9,4,9,99,3,9,1002,9,3,9,1001,9,5,9,1002,9,5,9,101,3,9,9,4,9,99,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,99,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,99
9,8,7,6,5
54163586
