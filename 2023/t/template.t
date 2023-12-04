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

note "Remove this line after testing"; exit;

subtest "Real $0" => sub{
  local $/ = undef;
  my $data = <DATA>;
  $data =~ s/^\s+|\s+$//g; # whitespace trim on each line
  pass("real");
};

__DATA__
Replace this line with the input data

