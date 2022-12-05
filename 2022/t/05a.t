#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use List::Util qw/sum max uniq/;
use Storable qw/dclone/;

subtest "Test $0" => sub{
  my $data = "
    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
  ";
   my $stacks = init($data);
   my $newStacks = moveData($stacks, $data);

   my @exp = qw(C M Z);
   my @obs = map { $$_[0] } @$newStacks;
   is_deeply(\@obs, \@exp, "top of stack");
};

subtest "Real $0" => sub{
  my @data = <DATA>;
  my $data = join("", @data);
  
  my $stacks = init($data);
  my $newStacks = moveData($stacks, $data);
  my @obs = map { $$_[0] } @$newStacks;
  my $topOfStack = join("", @obs);
  is($topOfStack, "QPJPLMNNR");
};

sub init{
  my($data) = @_;

  my @stack;
  for my $line(split(/\n/, $data)){
    next if($line =~ /^\s*$/);
    last if($line !~ /\[/);
    chomp($line);

    # Make this easier for me to parse
    # by changing [] to _
    $line =~ s/[\[\]]/_/g;
    my $i=0;
    while($line =~ /(_(\w)_)|(   ) /g){
      if($2){
        push(@{ $stack[$i] }, $2);
      }
      $i++;
    }
  }
  return \@stack;
}

sub moveData{
  my($stacks, $data) = @_;

  # It pains me to alter arrays by reference in a sub
  my $stack = dclone($stacks);
  my @stack = @$stack;
  
  for my $line(split(/\n/, $data)){
    next if($line !~ /move/);

    my @command;
    while($line =~ /(\d+)/g){
      push(@command, $1);
    }
    die "Command has less than 3 ints" if(@command < 3);

    # Coordinates changed from 1-based to 0-based
    $command[1]--;
    $command[2]--;

    my @toMove = splice(@{ $stack[$command[1]] }, 0, $command[0]);
    unshift(@{ $stack[$command[2]] }, reverse(@toMove));
  }

  return \@stack;
}

__DATA__
[M] [H]         [N]                
[S] [W]         [F]     [W] [V]    
[J] [J]         [B]     [S] [B] [F]
[L] [F] [G]     [C]     [L] [N] [N]
[V] [Z] [D]     [P] [W] [G] [F] [Z]
[F] [D] [C] [S] [W] [M] [N] [H] [H]
[N] [N] [R] [B] [Z] [R] [T] [T] [M]
[R] [P] [W] [N] [M] [P] [R] [Q] [L]
 1   2   3   4   5   6   7   8   9 

 move 1 from 7 to 6
 move 1 from 9 to 4
 move 4 from 9 to 6
 move 1 from 2 to 3
 move 7 from 8 to 6
 move 1 from 6 to 3
 move 6 from 2 to 9
 move 1 from 2 to 9
 move 3 from 5 to 6
 move 4 from 5 to 4
 move 1 from 1 to 6
 move 8 from 9 to 4
 move 1 from 5 to 1
 move 7 from 3 to 9
 move 11 from 4 to 1
 move 1 from 9 to 3
 move 1 from 3 to 6
 move 9 from 1 to 2
 move 1 from 4 to 8
 move 1 from 8 to 2
 move 5 from 9 to 4
 move 8 from 2 to 1
 move 10 from 6 to 3
 move 5 from 4 to 3
 move 9 from 3 to 2
 move 1 from 9 to 5
 move 1 from 6 to 1
 move 4 from 1 to 8
 move 5 from 7 to 6
 move 1 from 5 to 9
 move 2 from 4 to 3
 move 13 from 6 to 1
 move 1 from 6 to 3
 move 3 from 1 to 7
 move 9 from 2 to 7
 move 2 from 4 to 6
 move 25 from 1 to 9
 move 2 from 2 to 7
 move 2 from 3 to 5
 move 1 from 6 to 5
 move 2 from 5 to 2
 move 2 from 8 to 9
 move 2 from 2 to 5
 move 23 from 9 to 5
 move 1 from 8 to 5
 move 1 from 8 to 9
 move 6 from 3 to 7
 move 3 from 5 to 7
 move 1 from 3 to 1
 move 1 from 1 to 5
 move 11 from 7 to 6
 move 9 from 6 to 2
 move 1 from 7 to 1
 move 1 from 1 to 7
 move 2 from 6 to 8
 move 8 from 2 to 3
 move 4 from 7 to 1
 move 7 from 7 to 6
 move 6 from 9 to 6
 move 1 from 1 to 5
 move 5 from 6 to 8
 move 2 from 7 to 6
 move 2 from 3 to 2
 move 24 from 5 to 8
 move 1 from 3 to 5
 move 4 from 3 to 2
 move 1 from 5 to 6
 move 31 from 8 to 6
 move 1 from 5 to 6
 move 1 from 3 to 6
 move 2 from 1 to 9
 move 2 from 9 to 6
 move 1 from 1 to 9
 move 46 from 6 to 5
 move 1 from 9 to 4
 move 35 from 5 to 1
 move 28 from 1 to 5
 move 24 from 5 to 3
 move 1 from 3 to 4
 move 1 from 6 to 3
 move 19 from 3 to 4
 move 2 from 3 to 8
 move 3 from 1 to 8
 move 4 from 2 to 1
 move 4 from 8 to 6
 move 6 from 1 to 5
 move 1 from 8 to 5
 move 3 from 4 to 1
 move 5 from 1 to 7
 move 23 from 5 to 2
 move 21 from 2 to 8
 move 6 from 8 to 2
 move 2 from 2 to 5
 move 2 from 5 to 6
 move 5 from 4 to 5
 move 6 from 6 to 7
 move 4 from 5 to 2
 move 1 from 7 to 9
 move 3 from 3 to 2
 move 1 from 5 to 2
 move 2 from 8 to 5
 move 11 from 2 to 5
 move 3 from 2 to 7
 move 13 from 7 to 4
 move 11 from 8 to 1
 move 1 from 9 to 5
 move 23 from 4 to 2
 move 1 from 4 to 9
 move 10 from 1 to 2
 move 1 from 9 to 5
 move 1 from 1 to 3
 move 2 from 8 to 6
 move 4 from 5 to 9
 move 19 from 2 to 5
 move 3 from 9 to 2
 move 28 from 5 to 7
 move 1 from 3 to 5
 move 1 from 9 to 5
 move 15 from 7 to 5
 move 2 from 6 to 4
 move 2 from 4 to 3
 move 19 from 5 to 9
 move 5 from 7 to 5
 move 8 from 7 to 8
 move 1 from 8 to 1
 move 14 from 9 to 6
 move 2 from 8 to 5
 move 1 from 3 to 8
 move 3 from 5 to 9
 move 1 from 1 to 9
 move 3 from 9 to 6
 move 8 from 6 to 5
 move 1 from 8 to 1
 move 1 from 8 to 3
 move 13 from 2 to 4
 move 4 from 9 to 8
 move 4 from 4 to 1
 move 1 from 6 to 1
 move 2 from 3 to 4
 move 2 from 1 to 7
 move 10 from 5 to 1
 move 2 from 5 to 2
 move 7 from 4 to 7
 move 6 from 6 to 7
 move 1 from 9 to 7
 move 3 from 7 to 1
 move 7 from 2 to 7
 move 1 from 6 to 3
 move 1 from 6 to 9
 move 8 from 7 to 8
 move 2 from 7 to 6
 move 8 from 7 to 9
 move 17 from 1 to 7
 move 13 from 8 to 5
 move 2 from 7 to 1
 move 2 from 6 to 3
 move 9 from 7 to 6
 move 5 from 7 to 6
 move 1 from 4 to 5
 move 3 from 5 to 9
 move 4 from 9 to 2
 move 2 from 8 to 6
 move 1 from 7 to 9
 move 4 from 9 to 1
 move 12 from 6 to 2
 move 10 from 2 to 6
 move 4 from 9 to 4
 move 6 from 1 to 6
 move 2 from 7 to 8
 move 2 from 8 to 4
 move 1 from 8 to 1
 move 8 from 4 to 7
 move 5 from 5 to 2
 move 3 from 4 to 1
 move 3 from 2 to 8
 move 2 from 8 to 4
 move 1 from 4 to 5
 move 3 from 2 to 1
 move 2 from 9 to 8
 move 11 from 6 to 5
 move 4 from 7 to 2
 move 1 from 3 to 7
 move 1 from 8 to 5
 move 8 from 6 to 4
 move 2 from 3 to 7
 move 1 from 6 to 2
 move 15 from 5 to 3
 move 15 from 3 to 5
 move 5 from 1 to 6
 move 12 from 2 to 8
 move 4 from 7 to 3
 move 4 from 6 to 3
 move 7 from 4 to 3
 move 8 from 3 to 8
 move 1 from 6 to 8
 move 10 from 5 to 3
 move 8 from 5 to 4
 move 15 from 3 to 9
 move 1 from 1 to 3
 move 9 from 4 to 9
 move 1 from 7 to 3
 move 2 from 7 to 6
 move 1 from 9 to 7
 move 19 from 8 to 2
 move 1 from 1 to 9
 move 4 from 3 to 9
 move 1 from 5 to 6
 move 4 from 8 to 1
 move 1 from 4 to 1
 move 3 from 1 to 3
 move 1 from 1 to 9
 move 4 from 9 to 7
 move 2 from 6 to 1
 move 2 from 1 to 2
 move 1 from 6 to 3
 move 1 from 1 to 4
 move 3 from 7 to 5
 move 21 from 2 to 8
 move 1 from 7 to 8
 move 2 from 5 to 3
 move 1 from 4 to 3
 move 3 from 3 to 1
 move 1 from 7 to 5
 move 1 from 1 to 2
 move 1 from 1 to 2
 move 2 from 3 to 2
 move 1 from 3 to 8
 move 2 from 5 to 6
 move 1 from 3 to 9
 move 4 from 2 to 8
 move 12 from 9 to 6
 move 1 from 1 to 4
 move 14 from 6 to 1
 move 3 from 9 to 1
 move 1 from 4 to 7
 move 4 from 8 to 6
 move 3 from 6 to 4
 move 3 from 4 to 7
 move 15 from 1 to 5
 move 1 from 6 to 5
 move 12 from 5 to 4
 move 10 from 9 to 8
 move 3 from 7 to 8
 move 1 from 9 to 1
 move 2 from 1 to 7
 move 17 from 8 to 5
 move 10 from 4 to 2
 move 16 from 5 to 8
 move 30 from 8 to 7
 move 4 from 5 to 2
 move 4 from 7 to 1
 move 1 from 5 to 8
 move 4 from 8 to 4
 move 5 from 4 to 8
 move 8 from 7 to 8
 move 19 from 7 to 5
 move 4 from 1 to 4
 move 7 from 5 to 3
 move 10 from 2 to 3
 move 5 from 5 to 1
 move 1 from 5 to 3
 move 4 from 2 to 8
 move 4 from 4 to 6
 move 1 from 5 to 7
 move 3 from 7 to 1
 move 1 from 4 to 2
 move 7 from 3 to 7
 move 2 from 5 to 1
 move 1 from 2 to 8
 move 3 from 5 to 2
 move 3 from 2 to 7
 move 11 from 1 to 9
 move 9 from 9 to 6
 move 1 from 3 to 8
 move 2 from 9 to 6
 move 3 from 3 to 7
 move 3 from 7 to 1
 move 5 from 6 to 7
 move 14 from 7 to 6
 move 1 from 7 to 2
 move 5 from 3 to 5
 move 1 from 3 to 4
 move 2 from 1 to 4
 move 1 from 6 to 9
 move 1 from 3 to 8
 move 1 from 9 to 2
 move 1 from 1 to 4
 move 4 from 4 to 9
 move 1 from 2 to 3
 move 5 from 5 to 9
 move 1 from 9 to 5
 move 1 from 5 to 3
 move 11 from 6 to 3
 move 2 from 9 to 1
 move 1 from 1 to 7
 move 5 from 6 to 4
 move 4 from 3 to 9
 move 1 from 3 to 7
 move 1 from 4 to 2
 move 1 from 4 to 5
 move 2 from 2 to 1
 move 1 from 4 to 5
 move 2 from 1 to 6
 move 1 from 3 to 6
 move 8 from 9 to 6
 move 19 from 8 to 7
 move 2 from 7 to 4
 move 1 from 1 to 3
 move 6 from 6 to 5
 move 1 from 8 to 6
 move 8 from 5 to 9
 move 1 from 9 to 8
 move 1 from 4 to 6
 move 1 from 9 to 1
 move 4 from 7 to 5
 move 2 from 4 to 7
 move 1 from 4 to 5
 move 8 from 9 to 5
 move 3 from 8 to 2
 move 8 from 6 to 8
 move 5 from 3 to 1
 move 6 from 8 to 3
 move 9 from 5 to 7
 move 3 from 2 to 4
 move 1 from 6 to 1
 move 2 from 3 to 9
 move 2 from 8 to 1
 move 1 from 4 to 7
 move 1 from 5 to 6
 move 1 from 9 to 3
 move 8 from 3 to 8
 move 2 from 4 to 9
 move 2 from 5 to 7
 move 5 from 8 to 3
 move 2 from 6 to 9
 move 1 from 9 to 5
 move 3 from 9 to 3
 move 3 from 6 to 5
 move 1 from 9 to 6
 move 1 from 8 to 3
 move 4 from 5 to 4
 move 24 from 7 to 5
 move 8 from 3 to 1
 move 24 from 5 to 2
 move 3 from 4 to 6
 move 5 from 6 to 3
 move 1 from 3 to 1
 move 1 from 5 to 2
 move 4 from 2 to 1
 move 5 from 3 to 9
 move 1 from 4 to 3
 move 5 from 2 to 3
 move 3 from 1 to 2
 move 1 from 7 to 1
 move 4 from 7 to 8
 move 1 from 1 to 2
 move 5 from 2 to 8
 move 2 from 9 to 8
 move 19 from 1 to 7
 move 9 from 8 to 9
 move 2 from 3 to 5
 move 8 from 9 to 6
 move 5 from 6 to 2
 move 1 from 3 to 8
 move 2 from 9 to 5
 move 3 from 5 to 9
 move 5 from 9 to 4
 move 2 from 6 to 4
 move 2 from 8 to 3
 move 1 from 5 to 6
 move 3 from 8 to 4
 move 1 from 6 to 9
 move 8 from 4 to 3
 move 19 from 7 to 5
 move 5 from 3 to 6
 move 1 from 4 to 5
 move 1 from 4 to 7
 move 1 from 9 to 1
 move 4 from 6 to 8
 move 1 from 7 to 5
 move 2 from 6 to 4
 move 4 from 8 to 5
 move 6 from 3 to 1
 move 6 from 5 to 8
 move 5 from 5 to 1
 move 2 from 4 to 7
 move 2 from 3 to 2
 move 7 from 5 to 2
 move 1 from 7 to 9
 move 3 from 2 to 6
 move 7 from 2 to 1
 move 4 from 1 to 7
 move 7 from 1 to 7
 move 11 from 2 to 4
 move 3 from 6 to 7
 move 2 from 8 to 5
 move 8 from 7 to 3
 move 6 from 3 to 5
 move 4 from 2 to 3
 move 3 from 7 to 6
 move 3 from 2 to 5
 move 7 from 5 to 1
 move 10 from 1 to 6
 move 1 from 2 to 8
 move 3 from 6 to 7
 move 4 from 4 to 1
 move 2 from 3 to 6
 move 3 from 3 to 9
 move 1 from 3 to 6
 move 4 from 1 to 4
 move 3 from 9 to 6
 move 2 from 4 to 1
 move 9 from 4 to 7
 move 11 from 7 to 4
 move 6 from 1 to 6
 move 6 from 4 to 7
 move 5 from 4 to 7
 move 4 from 8 to 1
 move 1 from 8 to 6
 move 1 from 9 to 7
 move 4 from 6 to 4
 move 5 from 5 to 4
 move 5 from 5 to 9
 move 5 from 1 to 6
 move 1 from 5 to 6
 move 4 from 9 to 7
 move 1 from 9 to 8
 move 7 from 7 to 1
 move 1 from 7 to 8
 move 4 from 1 to 5
 move 5 from 4 to 1
 move 1 from 4 to 8
 move 6 from 1 to 2
 move 11 from 6 to 8
 move 2 from 8 to 9
 move 1 from 5 to 9
 move 6 from 2 to 8
 move 1 from 1 to 2
 move 2 from 7 to 8
 move 1 from 9 to 2
 move 2 from 2 to 8
 move 1 from 7 to 8
 move 10 from 8 to 3
 move 3 from 5 to 9
 move 4 from 8 to 5
 move 4 from 8 to 2
 move 7 from 7 to 8
 move 2 from 5 to 9
 move 1 from 5 to 1
 move 2 from 7 to 8
 move 5 from 3 to 5
 move 1 from 1 to 3
 move 1 from 1 to 6
 move 1 from 2 to 4
 move 7 from 6 to 4
 move 2 from 2 to 3
 move 3 from 8 to 4
 move 2 from 3 to 1
 move 3 from 5 to 6
 move 3 from 6 to 8
 move 1 from 1 to 9
 move 3 from 3 to 1
 move 8 from 8 to 1
 move 1 from 2 to 9
 move 1 from 6 to 2
 move 3 from 5 to 1
 move 1 from 8 to 3
 move 3 from 4 to 1
 move 4 from 8 to 9
 move 1 from 7 to 1
 move 7 from 1 to 6
 move 8 from 9 to 6
 move 1 from 8 to 9
 move 4 from 9 to 8
 move 15 from 6 to 5
 move 3 from 1 to 6
 move 2 from 1 to 2
 move 1 from 2 to 7
 move 1 from 9 to 6
 move 3 from 8 to 1
 move 1 from 4 to 9
 move 11 from 5 to 9
 move 1 from 7 to 1
 move 1 from 2 to 3
 move 2 from 3 to 4
 move 6 from 1 to 7
 move 7 from 4 to 5
 move 2 from 6 to 7
 move 1 from 4 to 5
 move 2 from 4 to 1
 move 13 from 9 to 1
 move 2 from 3 to 2
 move 1 from 3 to 7
 move 2 from 4 to 1
 move 4 from 6 to 9
 move 1 from 8 to 4
 move 4 from 6 to 8
 move 1 from 4 to 9
 move 9 from 1 to 6
 move 8 from 6 to 9
 move 4 from 5 to 3
 move 1 from 8 to 4
