#!/usr/bin/env perl
use strict;
use warnings;

my $puzzleInput="172851-675869";
# Answer: 1135

###############

my($min,$max) = split(/\-/, $puzzleInput);

my $totalPossibilities = 0;
for(my $possiblePassword = $min; $possiblePassword <= $max; $possiblePassword++){
  my $couldWork = checkPassword($possiblePassword);
  $totalPossibilities += $couldWork;
}
print "$totalPossibilities\n";

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
      # New requirement:
      # the two adjacent matching digits are not part of a larger group of matching digits
      if(defined($digit[$i+1]) && $digit[$i] == $digit[$i+1]){
      } elsif (defined($digit[$i-2]) && $digit[$i-1] == $digit[$i-2]) {
      } else {
        $hasAdjacency = 1;
      }
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

