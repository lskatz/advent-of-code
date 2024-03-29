#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use List::Util qw/sum max/;

# You get a base score for whichever you pick
my %baseScore = (X=>1, Y=>2, Z=>3);
# Second value is how it needs to end: X means lose, Y means draw, and Z means win
my %outcome = (
  A => {X=>2, Y=>2, Z=>5},
  B => {X=>0,Y=>3, Z=>6},
  C => {X=>1, Y=>4,Z=>4},
);

subtest "Test $0" => sub{
  my @data = (["A", "Y"], ["B","X"], ["C","Z"]);
  my $obs = score(\@data);
  
  is($$obs[0], 4);
  is($$obs[1], 1);
  is($$obs[2], 7);

  is(sum(@$obs), 12, "sum");
};

subtest "Real $0" => sub{
  my $data = readData();
  my $obs  = score($data);
  is(sum(@$obs), 11696);
};

sub readData{
  my @data;
  while(<DATA>){
    next if(/^\s*$/);
    chomp;
    my($you, $me) = split(/\s+/);
    push(@data, [$you, $me]);
  }
  return \@data;
}

sub score{
  my($data) = @_;

  my @score = ();
  for my $d(@$data){
    my $score = 0;
    $score += $baseScore{$$d[1]};
    $score += $outcome{$$d[0]}{$$d[1]};
    push(@score, $score);
  }

  return \@score;
}
    

__DATA__
B X
B Z
B Z
A Y
B X
A Y
C Y
A Y
C X
B X
A Y
B Z
A Y
A X
B X
A Y
A Y
B Y
A Y
A Y
A Y
B Y
C Y
A Y
A Y
C X
B Z
B Z
C Z
B Z
A Y
A Y
B Z
A Y
B X
A Y
A Y
A Y
C Z
A Y
C Y
B X
A Y
A Y
A Y
B X
A X
B Y
B Z
A Y
A Y
A Y
B Z
A Y
A Y
B Y
B X
C Y
B Z
C Z
A Y
C X
B Z
A Z
C X
A Y
A Y
A Z
B Z
A Y
A Y
B Y
B Z
A Y
A Y
C X
B X
A Y
B Z
A Y
B Y
B Y
A Y
B Y
B Z
B X
B Y
B X
B Z
B Z
A Y
A Y
A Z
A X
A Y
B Z
A Y
B X
A X
A Y
B X
A X
A Z
B Z
A Y
A Y
A Y
B Z
A Y
B X
A Y
A Y
B Z
B Y
A X
C Y
C Y
A Y
B X
B X
B Z
B Z
B Y
B Y
B Z
B Z
B X
B Z
B Z
B Z
A Y
A Y
B Z
B Z
B X
A Y
C Z
B Z
B X
B Z
A X
A Y
B X
B X
A Y
B X
B Z
B Z
A Z
B Y
A Y
B X
A Y
C Y
B Y
A Y
A Y
B Y
B X
A Y
B X
B Z
A Y
B Z
B X
B X
A Y
A Y
B Z
A Z
B Z
C Z
B Z
C X
A Y
A Y
A Y
A Y
A Y
A Z
B Z
B Y
C Y
A X
C Y
A Y
A X
B Z
A Y
C Z
A Y
A Y
A Z
C Y
C Y
A Y
A Y
A Y
B Z
B Z
B X
B X
B Y
A Y
A X
B Z
B X
B Z
A Y
B Z
A X
B Z
A Y
A Y
B Z
A X
B Y
A Y
A Y
A Y
B X
A Y
C Z
B Y
B X
A Y
B Z
A Y
A Y
A Y
B Z
A Z
C Y
A Y
A Y
B Z
A Y
A Y
A Y
B Z
A Z
A Y
A Y
A Y
A Y
A Y
A Y
B X
A Y
B X
A Y
C Z
B Z
A Y
A Y
B Z
A Y
A Y
B Z
A Y
A Y
A Y
B Z
A Z
A Y
A Y
C Y
A Y
A Y
A Y
B Z
A Y
A Z
B Z
C Y
B Y
B Z
B Z
C X
A Y
A X
B Y
A Y
B Z
A X
B Y
C Y
B Z
A Y
A Y
B X
A Y
B Z
B Z
B X
B Z
A Y
A Y
A Y
A Y
A Y
A Y
B Y
A Y
A Y
A Y
A Y
A Y
B Z
A Y
A Y
A Y
A Y
A Y
B Y
B Y
A Y
A Z
A Y
A Y
A Y
B X
B Z
A X
A Z
A Y
B X
A Z
A Y
B X
A X
B X
A Y
A Y
B X
B X
A Y
B X
A Y
A Y
B Y
B Z
A Y
A Y
B Z
C X
B X
B Z
B Z
A Y
A X
A Y
A Y
C Y
A Y
B Z
C Y
C Y
A Y
A Y
B X
A Y
A Y
A Y
A Y
A X
A Y
B Y
B Z
A Y
B Z
B X
C Y
B Z
B X
B Z
A Y
A Y
A Z
A Y
C Y
B Z
A Y
A Y
B Y
B Z
B Z
A X
A Y
B Z
A Y
B X
A Y
A Y
B Z
B X
B Z
A Y
A Y
B Y
B Z
B X
A Y
B X
A Y
A Y
A Y
A Y
A Y
B Z
A Y
B Y
A Z
B X
B Z
B X
A Y
B X
A Y
B Y
B Y
A Y
C Z
C Y
A Y
B Z
B X
A Y
A Y
A Y
A Y
B Y
B Z
B Z
A Y
A Y
A Y
A Y
B X
A Y
B Y
B Z
A Y
B Z
B Z
B Z
A Y
B Z
B Z
B X
B Z
A Y
B Z
A Y
B X
B Z
A Y
A Y
A Y
C Y
B Z
C Z
A Y
B Z
C Y
A Y
A Y
A Y
B Z
A Y
A Y
B X
B X
A X
A Y
A Y
B X
B X
A X
A Y
A Y
A X
B X
B Y
A Y
A Y
B X
B Z
B X
A Y
B X
B Y
A Y
B Y
B X
A Z
A Y
A Y
B X
A X
A Z
B X
A Y
A X
B X
A Y
A Y
A Y
A Y
A Y
B Y
A Y
B X
B Y
B Z
B Y
A Y
A Y
A Y
A Y
B Y
A Y
A X
B Y
A Y
B Z
A Y
A Z
A Y
A Y
A Y
C Z
A Y
A Y
B X
B X
C Z
A Y
B Z
A X
B X
A Y
B Z
A Y
B Z
A Y
A Y
B Z
A X
A X
B X
B Y
B Z
B Z
C Z
A Y
A X
A Y
C X
A Y
B X
B X
B Z
A Y
A Z
A Y
C Z
B Z
B Y
B Z
C Y
C X
A Y
B X
B Z
A Y
B X
B Y
A Y
A Y
A Y
A Y
B Z
C Y
B Y
C X
A Y
A Y
B Z
C Y
B Z
A Y
A X
A Y
A Y
A Y
A Y
B X
C Y
A Y
A Y
B X
A Y
B X
B Y
C Z
A Y
A Y
A Y
A Y
B Z
B X
C Y
B X
A Y
A Z
C Y
A X
A Y
B Z
B Z
A Y
A Y
C Y
A Y
B X
C Z
B Z
A X
A Y
A Y
B Z
B Z
A Y
B X
B X
B X
A Y
B X
B Z
A Y
A Y
A Y
A Y
C Y
A Y
C Z
A X
B Z
B X
A Y
B X
A Y
B Y
A Y
A Z
A Y
A Y
B Z
B Y
B X
B Z
A Y
A Y
A Y
A Y
A Y
A Y
A Y
A Y
C Z
B Z
B X
A Y
A Z
B Y
A Y
A Y
B Y
A Y
B Y
B X
A Y
A Z
A Y
A Y
A Y
A Y
A Z
A Y
B Z
A Y
A Y
B Z
B Z
A Y
C Z
B X
A Y
C Y
B X
A Y
B X
B Z
B Z
A Y
A Y
A Y
A X
B X
B X
A Y
B Y
B Y
A Y
A X
A Y
B Z
C Y
A Y
C Z
B Z
C Y
B X
A Z
A Y
A Y
A Y
A Y
C X
B X
B X
A Z
B Y
A Y
A Y
B X
A Y
A Y
A X
B X
C Z
B X
C Y
A X
B X
C Y
C X
A Y
A Y
B Y
C Y
A Y
B X
B Z
A X
A Y
B X
B Z
B Z
B X
B Z
B Y
A Y
A Y
A Y
A Y
A Y
A Z
B Y
A X
B X
C Y
A Y
B Y
A Y
B X
A Y
A Y
A Y
A Y
A Y
A Y
B Z
B Z
A Y
A Y
A Y
C Z
A Y
A Y
A Z
B Z
C Y
B Z
A Y
B Z
A X
A Y
B X
B Z
A Y
A Y
A Y
A Y
B X
B Y
C Z
A Y
A Y
A Y
C Z
A X
B Z
B X
C Y
B X
B X
A Y
C Y
B X
A Z
A Y
B X
A Y
A Y
B Z
A Y
A Y
A Y
B Y
A Y
A Y
A Y
A Y
B X
C Y
A Y
A Y
A Y
A Y
A Y
B Z
B X
B Z
A Y
B X
A Y
B X
C Y
A Y
A Y
A Y
C Y
A Z
A Y
A Y
B Y
B Z
B Z
A Y
B X
A Y
B X
C Y
A Y
B X
B X
B X
A Y
B Y
A Y
A Y
B X
B X
A Y
A Y
C Y
A Y
B Z
A Y
A Y
B Z
A Y
C Y
B X
A Y
A Y
A Y
B X
B X
B X
A Y
B Z
B Z
B X
B Z
A Y
B X
B Z
A Y
A Y
C Z
B X
B X
C Z
C Y
A Y
C Z
A Y
A X
B Z
A Y
A Y
A Y
B Z
B Z
B Z
A Y
A Y
B Z
C Y
A Y
A X
B Z
A Y
A Y
B Z
B Z
C Y
C Z
A Y
A X
B Z
C Z
B Y
B X
B X
B X
B Y
B X
A Y
B X
B Z
B Z
A Y
B Z
A Y
A Y
A Y
B X
A Y
A Y
B X
A Y
A Y
A Y
A Y
A Z
B X
A Y
B Z
A Y
A Y
B Z
A Y
A Y
A Y
A X
A Z
A Y
B Y
C Y
A Y
A Y
A Y
C Y
A Y
B X
A Y
B Z
B X
B Z
A Y
B Z
A Z
B X
A Y
A Z
B X
B X
B Z
A Y
A Y
B Z
A Z
A Y
C Y
A Y
A Y
B Z
B Z
B X
C Y
B X
A Y
B X
B Y
B Y
C Z
A Y
A Y
B Z
B X
A Y
A X
A Y
A Z
A Y
B Y
A X
A Y
B Y
A Y
B X
A Y
A Y
A Y
A Y
B Z
A Y
A Y
A Y
B X
A Y
B Y
A Y
A Y
B X
B Y
B X
B Z
A X
A Y
B X
B Z
A Y
B Y
B Y
A X
C Y
B Z
B X
A Y
B Z
A X
B Y
B X
A Y
C Y
B Z
B X
A Y
B Z
C Z
A Y
A Y
A Y
A Y
B X
B X
A X
A Y
A Y
A Y
A X
C Y
C X
B Z
A Y
A Y
B X
A Y
A Y
C Y
B X
A X
B X
C X
A Z
A Y
C Z
A Y
A Y
B Z
B Z
C Y
A Y
A Y
B X
B X
A Y
C X
A X
A Y
A Y
A Y
B Y
A Y
A Y
B X
A Y
B Z
C X
A Y
B X
A Y
A X
A Y
A X
B X
A Y
A Y
A Y
B Y
B Z
B Z
B X
B Z
A Y
B Z
A Y
B Z
C Z
A Z
A Z
B X
A X
B Z
B Z
A X
B X
C X
C X
A X
A Y
A X
B Z
C Y
B X
B Z
B X
A Y
A Y
A Y
B X
B Z
B Z
B Z
A Y
A Y
B Y
B Z
A Y
A Y
C Y
A Y
A X
A Y
A Y
A Y
B Z
B Z
A Y
B X
A Y
A Y
A Y
A Y
A X
A Y
B Z
A Y
A Y
B Z
A Y
A Y
A Y
B X
A Y
C Y
B X
A Y
A X
A Y
B Z
B Z
B Z
B Z
B Z
A Z
B Z
A Z
C Y
B X
B Y
A X
B X
B X
A Y
A Y
A Y
A Y
B Y
A Y
A Y
A X
A Y
B Y
B X
C Y
B X
C X
A Y
B Z
A Y
A Y
B Z
A Y
A Y
B X
A Y
C Y
A Y
A Y
A Y
C Z
A X
B Y
A Y
C Y
A Y
B Z
A Y
B Z
B X
A Y
A Y
C Y
A Y
B Y
B Z
A Y
B X
A Y
A Y
C Y
C X
A Y
B Z
A Y
B X
B Z
B X
B X
A Y
A Z
B X
A Z
A Y
C Y
B Y
B X
A Y
A Y
A Y
B X
B Z
B Y
B X
A Y
A Y
A Y
A Y
A X
A Y
B X
A Y
B Z
B Z
B X
A Y
A Y
C X
B Z
B Z
B Y
A Z
B Y
B Y
C Z
A X
B X
B X
A Y
A Y
B X
A Y
B Z
B X
B X
C X
B Z
A Y
A Y
B X
B Z
A Y
B Y
A Y
B X
B X
B X
B Y
A Y
B Z
A Y
B Y
B Z
B X
B X
A Y
A Y
A Y
C Y
B X
B Z
A Z
A Y
A Z
A Y
A Y
B Z
A Y
B Z
C Z
B X
A Y
B Z
A Y
A X
B Y
A X
C Y
B Z
B Z
A Y
A X
B Z
C Z
B Z
A Y
A Y
A Y
A Y
A Y
B Z
A Y
A Y
B Z
A Y
A Y
A Y
A Y
B X
B Z
A Y
A Y
C Y
B Z
A Y
C Y
C Z
B Z
A Y
A Y
C Z
B Z
B Y
B X
A Y
A Y
B Z
A Y
C X
B Z
B X
B Z
B X
B Z
B Z
B Z
A Y
A Y
A Y
C Y
A Y
A Y
B Z
B X
B X
A Y
A Y
A X
A Y
A Y
A X
B X
B Y
B Z
A Y
A X
C Z
A Y
C Y
B X
A X
B Z
A Y
B Z
B Z
B X
A Y
A Y
C Z
A Y
A X
A Y
A Y
C Z
A Y
B X
A Z
B Z
B X
A Y
A X
A Y
A Z
B X
B Z
A Y
B Y
A Y
A Y
A Y
A Y
A Y
A Y
B X
C Y
A X
B Z
B X
B X
A Y
A Y
B X
A Y
C Y
A Y
A Y
B X
A Y
C X
A Y
B Z
B X
A Y
A X
C X
A Y
A Y
B Y
A Y
B Z
C Z
B X
B Y
C X
A Y
B X
A Y
B X
B Z
B Y
A Y
A Y
A Y
A Y
A Y
A Y
A Y
B X
A Y
A Y
B Z
B Z
A Y
C Y
B X
A Y
A Y
A Y
B X
A Y
B Z
A Y
B X
B Y
B X
B Y
B X
B Z
A X
B Z
C Z
B Y
A Y
A X
A Z
B Z
B Z
B Z
A Y
A Y
A Y
A Y
A Y
B Z
A Y
A Y
B Y
A Y
A Y
C Z
B Y
C Y
A Y
B Z
A Y
B Z
A Y
B X
A Z
B Z
A Y
A Y
A Y
A Y
A Y
A Y
A Y
A Y
A Y
B Z
B X
A Y
B Z
A Y
A Z
A Y
B Y
A Y
B X
B X
B Z
A Y
A Y
A Y
B Z
B Y
A Y
B X
C Z
A X
B Z
B X
A Y
A Y
A Z
B X
A X
A Y
C Y
C Y
A Y
A Y
A Y
A Y
B Z
B X
B X
A Y
B X
A Y
B X
A Y
A X
B X
B Z
A Y
B X
B X
B Z
B Y
A Y
B Z
A Y
A Y
A Y
A Y
B Y
B Y
B X
B Y
B X
B X
A Y
C X
A X
B X
A Y
B Z
A Y
A Y
B Z
B X
A Y
B Z
B X
B Z
A Y
A Y
A Y
A Y
B Y
B Z
A X
B Z
B X
A Y
A Y
C Z
A Y
B X
B Z
A Y
A Y
C X
A Y
C Y
A Z
A Y
B Y
B X
A Y
B Z
A Y
A Y
A Y
A Y
A X
B Z
B X
B Z
A Y
A Y
B X
A Y
C Z
B X
B X
A Y
A Y
B X
B Y
A Y
A Y
A Y
B Z
A X
A Y
A Y
A Y
A Y
B X
B Z
C Y
B Z
B X
A Y
B Z
A Y
B Z
A Y
C X
A Y
A Y
C Y
A Y
A Y
A Y
A Y
A Y
B X
B Y
A X
A Y
B Z
C Y
A Y
A Y
B X
A X
A X
B X
A Y
A Y
A Y
A X
C Y
B X
A Y
A Y
A Y
A Y
A Y
A Y
B Z
A Y
B Z
C Y
A Y
A Y
A Y
A Y
B Z
B Z
A X
A Y
A X
A X
A Y
A Y
B Z
B X
A Y
A Y
B X
B Y
C Z
A X
A X
A Y
B X
A Y
B X
B Z
A Y
B X
A Y
A Y
B Z
B X
B X
B X
A Y
A Y
B Z
B Z
A Y
B Y
A Y
A Y
A Y
A Y
B X
A X
B Y
B X
A Y
C X
B Z
B X
A Y
B X
B X
B X
B Y
B Y
A Y
A Z
B Z
C Y
A Y
A Y
A Z
A X
A Y
C Y
A Y
B Z
A Y
C Y
C Y
B Z
A Y
B Z
B Z
A Y
B Z
A Y
C Y
B Z
B X
B X
A Y
A Y
C Y
A Y
A Y
A Y
A X
A Y
A Y
A Y
C Z
B X
B Y
B X
A Y
A Y
C Y
A Y
A Y
A Y
B Z
B Y
A X
B Z
A Y
A Y
C Y
A Y
A Y
C Y
B X
B X
A Y
C Z
A Y
A Y
A Y
C Y
B Y
B Z
B Y
C X
A Y
B Y
C Y
B Z
A Y
B X
B X
A Y
A Y
A Y
B Y
B Y
A Y
A Y
B X
A Y
B Y
A Y
A Y
B Z
B Z
A Z
B X
B Z
B X
A Y
A Y
B Z
B Z
C Y
A Y
B Z
B Y
A Y
B X
B Z
B Z
A X
B X
A Y
A Z
B Z
A Y
B X
A Y
A Y
A Y
B X
B X
B Z
A Y
A Y
A X
C X
A Y
A X
B Z
B Z
A Y
C Y
B Z
B Z
B Y
B Z
A X
A Y
A Y
B Z
B X
A Y
C Z
A X
A Y
B Z
B X
C Y
A Y
A Y
B Y
B X
A Z
B X
A Y
A Y
B Z
C Z
B Z
B Z
A Y
A Y
A Y
B X
A Y
A X
C X
A Y
A Y
B Z
A Y
B Y
B X
A Z
A Y
A Y
A Y
C Y
B X
B Y
A Y
B Y
C Z
B X
B Z
B Z
B X
A Y
B Z
B X
A Y
A X
B Y
A Y
A Z
B X
B Z
A Y
C Z
B X
B Z
A Y
A X
A Y
B Z
B Z
A X
C Y
B X
C Z
B Y
A X
B X
C Y
A Y
B Y
B Z
A Y
A Y
A Y
A Y
B Y
B Z
B X
B X
A Y
A Z
B X
A Y
A Y
A Y
A X
B Z
C Z
C Y
B X
A Y
A Y
A Y
C X
B Z
B Z
A Y
A X
B X
A Y
B X
A X
B X
B Z
B X
B X
A Y
A Y
B X
A Y
A Y
A Y
B Z
B Y
B Z
A Y
A Y
A Y
B Z
A Y
A Y
A Y
C Y
B Y
B Z
A Y
B X
B Z
B Y
B X
A Y
A Y
A Y
A Y
C Z
A Y
A X
A Y
A Y
A Y
A Y
B Z
B Z
B Z
C Y
A Y
A Y
A Y
A Z
A Y
C Y
A Y
A Y
B Z
A Y
A Y
A Y
B X
A Y
B Y
A Y
A Y
B Z
B X
A Y
A Y
B Y
B X
A Y
B X
A Y
A Y
A Y
A Z
A Y
B X
B Y
B X
C Y
B Z
A X
A Y
A Y
A Y
B Z
B X
B X
B Z
B Y
A Y
A Z
A Y
C Z
B X
A Y
B Z
B Z
B Y
B X
A Y
C X
A Y
A Y
A Y
A Y
B Z
B Z
A Y
A Y
A Y
B Z
A Y
A Y
A Y
A Y
A Y
A Y
A Y
B X
A Y
C Y
B Z
B Z
A Y
A Y
A Y
B Y
A X
B Z
A X
B Z
B Y
A Y
B Z
B X
B X
A Y
A Y
A Y
B Z
A Y
A Y
B X
B X
A Y
B X
A Y
B X
A Y
B Z
A Y
B X
A Z
B Z
A Y
C Y
A Y
A Y
C Y
A Y
A Y
A X
A Y
C Y
A Y
A Y
B X
A Y
A Y
B X
C Y
A Y
B X
C Z
B Z
B Y
A Y
B Z
B Y
A X
A X
A Y
A Y
A Y
B X
B Z
C Y
B X
B Z
A Y
A Y
A Y
A Y
B X
B Y
C Y
A Y
A Y
A Y
B Z
B Y
A Y
B X
B Z
A Y
A Y
A Y
A Y
B Y
A X
A X
B Z
B Y
C Y
B Z
B Z
A Y
A Y
B Z
A Y
B Z
C X
A Y
A Y
B Y
A Y
B Z
A Y
B Z
B Z
A Y
A Y
C Z
C Y
A Y
A Y
C Y
A Y
C Y
A Y
B Z
A Y
B X
A X
B Z
A Y
A Y
A Y
B Z
A Z
C Y
A Y
A Y
A Y
B X
B X
A Y
A Y
A X
A Y
B Y
B X
B X
A Y
A Y
C Y
A Z
A Y
B X
B X
B Z
A Y
A Y
B Y
C Y
B X
A Y
A Y
A Y
A Y
A X
B X
A Y
A Y
B Z
A X
C Y
B X
A Y
B Z
A Y
A Y
C Y
A Y
A X
A Y
A Y
B Z
A Y
C Z
A Y
B X
B X
B Y
B Z
A Y
A Y
A Y
B Z
A Y
B Z
A Y
A X
A Z
A Y
C Z
B X
A Y
B Z
B Y
A Y
B X
B Z
B Z
B Z
A Y
A X
B Y
B X
A Y
A Y
A Y
B X
A Y
A Y
B Z
A Y
C Y
B X
A Y
A Y
C Z
B Z
A Y
B Z
B Z
B Z
A Y
B Z
B Y
A Y
A Y
C Y
A Y
B Y
A Y
B X
A Y
C Z
A Y
B X
A X
A Y
A Y
B Z
A Y
B X
B Z
B X
A Y
A Y
A Y
A Y
B Z
A Y
B Z
A Y
A Y
C Y
A Y
C Y
B X
B X
A Y
A X
B Z
B X
A Y
A Y
A Y
A Y
B Y
C Y
A X
B X
A Y
C Y
B Y
A Y
B Y
B Z
A Y
B Z
B X
A Y
B X
A Y
C Y
A Y
B X
B Z
A Y
A Y
A Y
A X
A Y
A Z
C Z
A Y
B Z
A Y
B X
B X
A Y
C Y
C Y
A Y
A Y
B Y
A Y
C Z
B Z
C Y
B X
A Y
B Z
A Y
B X
C Y
B X
A Y
A Y
B X
B Z
A Y
B Z
C Y
B X
A Y
B Z
A Y
B Z
B Z
B Z
A Y
A Y
A Y

