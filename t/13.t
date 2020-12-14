#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;


subtest 'sample data' => sub{
  my $input="
    939
    7,13,x,x,59,x,31,19
  ";

  my $expEarliestBus = 59;
  my $expMinutesWaiting = 5;
  my $expProduct = $expEarliestBus * $expMinutesWaiting;

  my($obsEarliestBus, $obsMinutesWaiting) = waitForBus($input);

  is($obsEarliestBus, $expEarliestBus, "earliest bus");
  is($obsMinutesWaiting, $expMinutesWaiting, "minutes waiting");
  is($obsEarliestBus * $obsMinutesWaiting, $expProduct, "product");
};

subtest 'real data' => sub{
  local $/=undef;
  my $input = <DATA>;
  my($obsBus, $obsMinutes) = waitForBus($input);
  my $product = $obsBus * $obsMinutes;
  is($product, 370, "product");
};

sub waitForBus{
  my($input) = @_;

  my($myBus, $busIds) = grep {/./} split(/\s*\n\s*/, $input);

  #note Dumper [$myBus, $busIds];

  my @busId = grep{/\d/} split(/,/, $busIds);
  
  # Choose some large number to wait as a maximum but
  # it doesn't matter because we will exit before we
  # get there.
  my $maxMinutesToWait = $myBus ** 2;
  for(my $min=$myBus; $min<$maxMinutesToWait; $min++){
    for my $busId(@busId){
      my $mod = $min % $busId;
      #note "$mod $min % $busId";
      if($mod==0){
        return($busId, $min-$myBus);
      }
    }
  }

  BAIL_OUT("ERROR: could not find a bus");
}

__DATA__
1000507
29,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,37,x,x,x,x,x,631,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,13,19,x,x,x,23,x,x,x,x,x,x,x,383,x,x,x,x,x,x,x,x,x,41,x,x,x,x,x,x,17

