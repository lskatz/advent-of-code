#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;

subtest "Test $0" => sub{
  my $data = "
Time:      7  15   30
Distance:  9  40  200
  ";

  my $wins = marginsOfError($data);

  is($wins, 71503, "num wins with no kerning");
};

subtest "Real $0" => sub{
  local $/ = undef;
  my $data = <DATA>;
  $data =~ s/^\s+|\s+$//g; # whitespace trim on each line

  my $wins = marginsOfError($data);

  is($wins, 41513103, "num wins with no kerning");
};

sub marginsOfError{
  my($data) = @_;

  my @data = grep {/\S/} split(/\n/,$data);

  my(undef, @times) = split(/\s+/, $data[0]);
  my(undef, @dists) = split(/\s+/, $data[1]);

  my $time = join("", @times);
  my $dist = join("", @dists);

  my $wins = timePermutations($time, $dist);

  return $wins;
}

sub timePermutations{
  my($time, $distToBeat) = @_;

  my $numWins = 0;
  for(my $pressTime=0; $pressTime<$time; $pressTime++){
    my $goTime = $time - $pressTime;
    my $dist = $pressTime * $goTime;
    if($dist > $distToBeat){
      $numWins++;
    }
  }

  return $numWins;
}

__DATA__
Time:        58     81     96     76
Distance:   434   1041   2219   1218


