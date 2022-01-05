#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use File::Basename qw/dirname/;
use List::Util qw/max min/;

my $example="16,1,2,0,4,2,7,1,2,14";
my $realData = "";
open(my $fh, dirname($0)."/07.txt") or die $!;
$realData = <$fh>;
chomp($realData);

subtest "Test for crabs $0" => sub{
  my $dist = readData($example);

  my $minDist = ~0;
  my $minCrab = -1;
  for my $crab(keys(%$dist)){
    if($minDist > $$dist{$crab}{_sum}){
      $minDist = $$dist{$crab}{_sum};
      $minCrab = $crab;
      note "$minDist - $minCrab";
    }
  }
  note Dumper $dist;
  note Dumper $$dist{$minCrab};
  is($minDist, 170, "Min distance");
  is($minCrab, 4, "Crab with min distance");
};

subtest "Real data for crabs $0" => sub{
  my $dist = readData($realData);

  my $minDist = ~0;
  my $minCrab = -1;
  for my $crab(keys(%$dist)){
    if($minDist > $$dist{$crab}{_sum}){
      $minDist = $$dist{$crab}{_sum};
      $minCrab = $crab;
      #note "$minDist - $minCrab";
    }
  }
  is($minDist, 98231647, "Min distance");
  is($minCrab, 645, "Crab with min distance");
};

sub readData{
  my($data) = @_;
  my @coord = split(/,/, $data);

  my %dist;
  for(my $i=0;$i<@coord;$i++){
    my $sum = 0;
    for(my $j=0;$j<@coord;$j++){

      # Now each step is an increasing distance
      my $rawdist = abs($coord[$i] - $coord[$j]);
      my $sumdist = 0;
      for(my $k=1; $k<=$rawdist; $k++){
        $sumdist += $k;
      }
      $dist{$i}{$j} = $sumdist;
      $sum+=$sumdist;
    }
    $dist{$i}{_sum} = $sum;
  }

  return \%dist;
}
