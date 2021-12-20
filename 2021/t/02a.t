#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;

subtest "Test $0" => sub{
  my @data = qw(forward 5
down 5
forward 8
up 3
down 8
forward 2
);
  my $pos = move(\@data);
  note(Dumper $pos);
};

sub move{
  my($data) = @_;

  my($horizontal, $depth);
  for(my $i=0;$i<@$data; $i+=2){
    my($direction, $increment) = @$data[$i..$i+1];

    if($direction eq 'forward'){
      $horizontal += $increment;
    }
    if($direction eq 'down'){
      $depth += $increment;
    }
    if($direction eq 'up'){
      $depth -= $increment;
    }
  }

  if(!wantarray){
    return $depth * $horizontal;
  }
  return {depth=>$depth, horizontal=>$horizontal};
}

