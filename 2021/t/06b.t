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
  $fish = growForSomeDays($fish, 18);
  is($$fish{sum}, 26, "After 18 turns, 26 fish");

  $fish = readData($example);
  $fish = growForSomeDays($fish, 80);
  is($$fish{sum}, 5934, "After 80 turns, 5934 fish");

  $fish = readData($example);
  $fish = growForSomeDays($fish, 256);
  is($$fish{sum}, 26984457539, "After 256 turns, 26984457539 fish");
};

subtest "Real test for exponential growth $0" => sub{
  my $fish = readData($realData);

  $fish = growForSomeDays($fish, 256);
  is($$fish{sum}, 1572643095893, "After 256 turns");
};


sub growForSomeDays{
  my($fish, $days) = @_;
  
  my $daysUntilPuberty = 2;
  my $daysUntilBreeding= 6;
  my $newborn = $daysUntilPuberty+$daysUntilBreeding;

  my %today = %$fish;
  for(my $d=$days; $d>0; $d--){
    my %tomorrow;
    for(my $age = $newborn; $age>=0; $age--){
      $tomorrow{$age-1} = $today{$age} || 0;
    }
    # make as many newborns as there are fish that reached day -1
    $tomorrow{$newborn} = $tomorrow{-1};
    # reset the adults to the first day of breeding
    $tomorrow{$daysUntilBreeding} += $tomorrow{-1};
    # remove the -1 counter
    delete($tomorrow{-1});

    %today = %tomorrow;
  }

  # get the sum of all fish
  for my $age(keys(%today)){
    $today{sum}+=$today{$age};
  }

  return \%today;
}

# Return hash of counts of fish ages
sub readData{
  my($data) = @_;

  my @fish = grep {/./} split(/,/, $data);
  chomp(@fish);

  my %fish;
  for my $f(@fish){
    $fish{$f}++;
  }

  return \%fish;
}

