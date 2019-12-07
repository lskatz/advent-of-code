#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests=>1;

my $intcode = <DATA>;
chomp($intcode);
my @originalInt = split(/,/,$intcode);
my @int         = @originalInt;


my $expected = 8298;
my $observed = -1;

for(my $noun = 0; $noun < 99; $noun++){
  for(my $verb = 0; $verb < 99; $verb++){

    @int = @originalInt;

    $int[1] = $noun;
    $int[2] = $verb;

    # Day 2, part 2 instructions:
    # need to determine what pair of inputs produces the output 19690720

    for(my $i=0; $i < @int; $i+=4){
      # optcode: 1, 2, or 99
      my $opcode = $int[$i];

      # Indexes
      my $idx1   = $int[$i+1];
      my $idx2   = $int[$i+2];
      my $idxOut = $int[$i+3];

      my $int1   = $int[$idx1];
      my $int2   = $int[$idx2];

      if($opcode == 1){
        my $value = $int1 + $int2;
        $int[$idxOut] = $value;

      } elsif($opcode == 2){
        my $value = $int1 * $int2;
        $int[$idxOut] = $value;

      } elsif($opcode == 99){
        #print "Saw a 99 at position $i! Breaking the loop.\n";
        last;
      } else{
        die "INTERNAL ERROR: unsure what to do with opcode $opcode";
      }
    }

    if($int[0] == 19690720){
      my $product = 100 * $noun + $verb;
      #print "100 x $noun + $verb => $product\n";
      $observed = $product;
    }
  }
}

is($observed, $expected, "Should be 100 x 82 + 98 => 8298");

# answer: 100 x 82 + 98 => 8298

__DATA__
1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,10,1,19,1,5,19,23,1,23,5,27,1,27,13,31,1,31,5,35,1,9,35,39,2,13,39,43,1,43,10,47,1,47,13,51,2,10,51,55,1,55,5,59,1,59,5,63,1,63,13,67,1,13,67,71,1,71,10,75,1,6,75,79,1,6,79,83,2,10,83,87,1,87,5,91,1,5,91,95,2,95,10,99,1,9,99,103,1,103,13,107,2,10,107,111,2,13,111,115,1,6,115,119,1,119,10,123,2,9,123,127,2,127,9,131,1,131,10,135,1,135,2,139,1,10,139,0,99,2,0,14,0
