#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

my $initialState = <DATA>;
$initialState=~s/.+:\s*//;
$initialState=~s/^\s+|\s+$//g;

my @initialState = split(//, $initialState);

my %pattern;
while(<DATA>){
  chomp;
  next if(/^\s*$/);
  my($pattern,$result) = split(/ => /);
  $pattern{$pattern} = $result;
}

print $initialState."\n";
my $currentState = $initialState;
for my $generation(0..19){
  $currentState = applyPattern($currentState);
  print $currentState."\n";
}

sub applyPattern{
  my($origState) = @_;
  my $state = substr($origState,0,2);
  for(my $i=0;$i<length($origState) - 5;$i++){
    my $substr = substr($origState,$i,5);
    #my $replace = substr($substr,0,2).$pattern{$substr}.substr($substr,3);
    $state.=$pattern{$substr} || ".";
  }
  $state.= substr($origState,-3,3);
  return $state;
}

__DATA__
initial state: ##.####..####...#.####..##.#..##..#####.##.#..#...#.###.###....####.###...##..#...##.#.#...##.##..

##.## => #
....# => .
.#.#. => #
..### => .
##... => #
##### => .
###.# => #
.##.. => .
..##. => .
...## => #
####. => .
###.. => .
.#### => #
#...# => #
..... => .
..#.. => .
#..## => .
#.#.# => #
.#.## => #
.###. => .
##..# => .
.#... => #
.#..# => #
...#. => .
#.#.. => .
#.... => .
##.#. => .
#.### => .
.##.# => .
#..#. => #
..#.# => .
#.##. => #

