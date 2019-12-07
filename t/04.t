#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests=>1;

my $puzzleInput="172851-675869";
# Answer: 1660

###############

my($min,$max) = split(/\-/, $puzzleInput);

my $totalPossibilities = 0;
for(my $possiblePassword = $min; $possiblePassword <= $max; $possiblePassword++){
  my $couldWork = checkPassword($possiblePassword);
  $totalPossibilities += $couldWork;
}
is($totalPossibilities, 1660, "Total possibilities: 1660");

# Returns 0 or 1
sub checkPassword{
  my($password) = @_;
  my $couldWork = 1;

  my $length = length($password);
  if($length != 6){
    $couldWork = 0;
  }

  my $hasAdjacency = 0;
  my @digit = split(//, $password);
  for(my $i=1; $i<$length; $i++){
    if($digit[$i] == $digit[$i-1]){
      $hasAdjacency = 1;
    }
    if($digit[$i] < $digit[$i-1]){
      $couldWork = 0;
    }
  }

  if(!$hasAdjacency){
    $couldWork = 0;
  }
  return $couldWork;
}

