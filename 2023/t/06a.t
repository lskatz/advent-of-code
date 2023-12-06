#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use List::Util qw/product/;

subtest "Test $0" => sub{
  my $data = "
Time:      7  15   30
Distance:  9  40  200
  ";

  my $marginsOfError = marginsOfError($data);
  my @exp = (4, 8, 9);
  is_deeply($marginsOfError, \@exp);

  is(product(@$marginsOfError), product(@exp), "product");
};

subtest "Real $0" => sub{
  local $/ = undef;
  my $data = <DATA>;
  $data =~ s/^\s+|\s+$//g; # whitespace trim on each line

  my $marginsOfError = marginsOfError($data);

  is(product(@$marginsOfError), 1159152, "product");
};

sub marginsOfError{
  my($data) = @_;

  my @data = grep {/\S/} split(/\n/,$data);

  my(undef, @times) = split(/\s+/, $data[0]);
  my(undef, @dists) = split(/\s+/, $data[1]);

  my @wins;
  for(my $i=0; $i<@times; $i++){
    my $wins = timePermutations($times[$i], $dists[$i]);
    #note "$times[$i]/$dists[$i]: $wins";
    push(@wins, $wins);
  }

  return \@wins;
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


