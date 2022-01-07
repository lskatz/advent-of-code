#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use File::Basename qw/dirname/;

my $example="3,4,3,1,2";
open(my $fh, dirname($0)."/06.txt") or die "ERROR reading real data: $!";
my $realData = <$fh>;
close $fh;

subtest "Test for exponential growth $0" => sub{
  my $fish = readData($example);
  growForSomeDays($fish, 18);
  note join(",", @$fish);
  is(scalar(@$fish), 26, "After 18 turns, 26 fish");

  $fish = readData($example);
  growForSomeDays($fish, 80);
  is(scalar(@$fish), 5934, "After 80 turns, 5934 fish");
};

subtest "Real test for exponential growth $0" => sub{
  my $fish = readData($realData);

  growForSomeDays($fish, 80);
  is(scalar(@$fish), 345793, "After 80 turns");
};


sub growForSomeDays{
  my($fish, $days) = @_;
  
  my $daysUntilPuberty = 2;
  my $daysUntilBreeding= 6;

  for(my $d=$days; $d>0; $d--){
    my $numFish = @$fish;
    for(my $i=0; $i<$numFish; $i++){
      $$fish[$i]--;

      if($$fish[$i] < 0){
        $$fish[$i] = $daysUntilBreeding;
        push(@$fish, $daysUntilPuberty+$daysUntilBreeding);
      }
    }
  }

  return $fish;
}

sub readData{
  my($data) = @_;

  my @fish = grep {/./} split(/,/, $data);
  chomp(@fish);

  return \@fish;
}

