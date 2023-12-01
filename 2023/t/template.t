#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;

subtest "Test $0" => sub{
  my $data = "

  ";

  pass("test");
};

subtest "Real $0" => sub{
  my $data = readData();
  pass("real");
};

sub readData{
  note "TODO";
}

