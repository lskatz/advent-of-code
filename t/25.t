#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use warnings FATAL => "printf";


subtest 'sample data' => sub{
  my $cardPub = 5764801;
  my $doorPub = 17807724;

  my $cardExp = 8;
  my $cardObs = predictLoopNumber($cardPub);
  is($cardObs, $cardExp, "Loop number for card public key");

  my $doorExp = 11;
  my $doorObs = predictLoopNumber($doorPub);
  is($doorObs, $doorExp, "Loop number for door public key");

  #handshake($cardExp, $doorExp);
};

sub handshake{
  my($cardLoops, $doorLoop) = @_;
  
  my $cardPubKey = transform($cardLoops-1);
  note $cardPubKey;
}

sub predictLoopNumber{
  my($key) = @_;

  for my $subjectNumber(1..10){
    my $loopSize = transform($subjectNumber, $key);
    if($loopSize > -1){
      return $loopSize;
    }
  }

  BAIL_OUT("For key $key I could not determine subject number");
}

sub transform{
  my($subjectNumber, $key) = @_;

  my $loopSize = 0;
  my $value = 1;
  while(1){
    $value = $value * $subjectNumber;
    $value = $value % 20201227;
    $loopSize++;

    if($value == $key){
      return $loopSize;
    }

    if($loopSize > 9999){
      last;
      BAIL_OUT("Loop size got too large for subject number $subjectNumber");
    }
  }

  return -1;

  BAIL_OUT("Could not determine loop size for subject number $subjectNumber");
}


      
