#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use List::Util qw/sum/;
use Test::More tests=>3;

subtest "Test $0" => sub{
  my $data = ' 
  noop
  addx 3
  addx -5
  ';

  my $ops = readData($data);
  my $cycles = parseOps($ops);
  my @exp = (1,1,1,4,4,-1);
  is_deeply($cycles, \@exp, "cycles");
};

subtest "Bigger test $0" => sub{
  my $data = ' 
addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop
  ';

  my $ops = readData($data);
  my $cycles = parseOps($ops);

  is($$cycles[19], 21, "20th cycle");
  is($$cycles[59], 19, "60th cycle");
  is($$cycles[99], 18, "100th cycle");
  is($$cycles[139],21, "140th cycle");
  is($$cycles[179],16, "180th cycle");
  is($$cycles[219],18, "220th cycle");

  is(signalStrength($cycles, 19), 420, "Signal strength - 20");
  is(signalStrength($cycles, 59), 1140, "Signal strength - 60");
  is(signalStrength($cycles, 99), 1800, "Signal strength - 100");
  is(signalStrength($cycles, 139),2940, "Signal strength - 140");
  is(signalStrength($cycles, 179),2880, "Signal strength - 180");
  is(signalStrength($cycles, 219),3960, "Signal strength - 220");

  is(sum(
      signalStrength($cycles, 19),
      signalStrength($cycles, 59),
      signalStrength($cycles, 99),
      signalStrength($cycles, 139),
      signalStrength($cycles, 179),
      signalStrength($cycles, 219),
    ), 13140, "sum of signal strengths at certain cycles");

};

subtest "Real $0" => sub{
  local $/=undef;
  my $data=<DATA>;
  my $ops = readData($data);
  my $cycles = parseOps($ops);

  is(sum(
      signalStrength($cycles, 19),
      signalStrength($cycles, 59),
      signalStrength($cycles, 99),
      signalStrength($cycles, 139),
      signalStrength($cycles, 179),
      signalStrength($cycles, 219),
    ), 16060, "sum of signal strengths at certain cycles");

};

# signal strength is the value at an element in the cycles,
# times the element number
sub signalStrength{
  my($cycles, $element) = @_;
  my $x = $$cycles[$element];
  my $strength = $x * ($element+1);
  return $strength;
}

sub readData{
  my($data) = @_;
  
  my @ops;

  for my $line(split(/\n/, $data)){
    next if($line =~ /^\s*$/);

    # whitespace trim
    $line =~ s/^\s+|\s+$//g;

    my($op, $num) = split(/\s+/, $line);

    push(@ops, {$op => $num});
  }
  return \@ops;
}

sub parseOps{
  my($ops) = @_;

  my $x = 1;
  my @cycle = ();

  for my $op(@$ops){
    my($instruction, $num) = each(%$op);

    if($instruction eq 'noop'){
      push(@cycle, $x);
    }
    elsif($instruction eq 'addx'){
      # two cycles of the same X and then add
      push(@cycle, ($x,$x));
      $x += $num;
    }
    else{
      die "INTERNAL ERROR: do not understand instruction $instruction";
    }

  }
  # One last cycle
  push(@cycle, $x);

  return \@cycle;
}

__DATA__
noop
addx 10
addx -4
addx -1
noop
noop
addx 5
addx -12
addx 17
noop
addx 1
addx 2
noop
addx 3
addx 2
noop
noop
addx 7
addx 3
noop
addx 2
noop
noop
addx 1
addx -38
addx 5
addx 2
addx 3
addx -2
addx 2
addx 5
addx 2
addx -4
addx 26
addx -19
addx 2
addx 5
addx -2
addx 7
addx -2
addx 5
addx 2
addx 4
addx -17
addx -23
addx 1
addx 5
addx 3
noop
addx 2
addx 24
addx 4
addx -23
noop
addx 5
addx -1
addx 6
noop
addx -2
noop
noop
noop
addx 7
addx 1
addx 4
noop
noop
noop
noop
addx -37
addx 5
addx 2
addx 1
noop
addx 4
addx -2
addx -4
addx 9
addx 7
noop
noop
addx 2
addx 3
addx -2
noop
addx -12
addx 17
noop
addx 3
addx 2
addx -3
addx -30
addx 3
noop
addx 2
addx 3
addx -2
addx 2
addx 5
addx 2
addx 11
addx -6
noop
addx 2
addx -19
addx 20
addx -7
addx 14
addx 8
addx -7
addx 2
addx -26
addx -7
noop
noop
addx 5
addx -2
addx 5
addx 15
addx -13
addx 5
noop
noop
addx 1
addx 4
addx 3
addx -2
addx 4
addx 1
noop
addx 2
noop
addx 3
addx 2
noop
noop
noop
noop
noop

