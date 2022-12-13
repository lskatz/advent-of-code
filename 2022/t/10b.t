#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use List::Util qw/sum/;
use Test::More tests=>2;

use constant LIT => '#';
use constant DARK=> '.';

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
  my $ascii = parseOps($ops);

  my $obs = formatCrt($ascii);
  note formatCrt($obs);
  pass("crt format");

};

subtest "Real $0" => sub{
  local $/=undef;
  my $data=<DATA>;
  my $ops = readData($data);
  my $ascii = parseOps($ops);

  note formatCrt($ascii);
  pass("crt format");
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
  my $ascii = "";
  my $cycleNum = 0;

  for my $op(@$ops){
    my($instruction, $num) = each(%$op);

    # Each instruction has different properties:
    # noop adds zero but takes only one cycle
    # addx adds $num but takes two cycles
    my $cyclePenalty;
    if($instruction eq 'noop'){
      $num = 0;
      $cyclePenalty = 1;
    }
    elsif($instruction eq 'addx'){
      $cyclePenalty = 2;
    }
    else{
      die "I do not understand instruction $instruction";
    }

    for(1..$cyclePenalty){
      $cycleNum++;
      my $crtPos = $cycleNum % 40;

      # What character is being added?
      my $char = DARK;
      if($x-0 <= $crtPos && $crtPos <= $x+2){
        $char = LIT;
      }
      $ascii .= $char;

      #note "cycle $cycleNum; x=$x; char $char";
    }

    # at the end of the cycle(s), add onto X
    $x += $num;
  }

  return $ascii;
}

sub formatCrt{
  my($ascii) = @_;
  $ascii =~ s/\n//g;

  my $str = $ascii;
  $str =~ s/(.{40})/$1\n/g;
  return $str;
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

