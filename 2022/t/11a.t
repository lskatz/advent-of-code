#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use Storable qw/dclone/;
use List::Util qw/product/;

subtest "Test $0" => sub{
  my $data = ' 
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
  ';

  my $numRounds = 20;
  my $monkeys = readData($data);

  my @inspections;
  for(my $round = 1; $round <= 20; $round++){
    my $inspections;
    ($monkeys, $inspections) = finishARound($monkeys);
    my @items = map {$$_{items}} @$monkeys;

    for(my $i = 0; $i<@$inspections; $i++){
      $inspections[$i] += $$inspections[$i];
    }

    if($round == 1){
      is_deeply(\@items, [ [20,23,27,26], [2080,25,167,207,401,1046], [], [] ], "round $round");
    }
    if($round == 2){
      is_deeply(\@items, [ [695, 10, 71, 135, 350], [43, 49, 58, 55, 362], [], [] ], "round $round");
    }
    if($round == 20){
      is_deeply(\@items, [ [10, 12, 14, 26, 34], [245, 93, 53, 199, 115], [], [] ], "round $round");
    }
      
  }

  is_deeply(\@inspections, [101,95,7,105], "number of inspections");

  my @sortedInspections = sort {$b<=>$a} @inspections;
  is(product(@sortedInspections[0..1]), 10605, "product of inspections, monkey business");

  pass("foo");

};

subtest "Real $0" => sub{
  local $/=undef;
  my $data = <DATA>;
  my $monkeys = readData($data);
  my @inspections;
  for(my $round = 1; $round <= 20; $round++){
    my $inspections;
    ($monkeys, $inspections) = finishARound($monkeys);
    for(my $i = 0; $i<@$inspections; $i++){
      $inspections[$i] += $$inspections[$i];
    }
  }

  #is_deeply(\@inspections, [101,95,7,105], "number of inspections");
  my @sortedInspections = sort {$b<=>$a} @inspections;
  is(product(@sortedInspections[0..1]), 110220, "product of inspections, monkey business");

};

sub readData{
  my($data) = @_;
  my @monkey;

  # whitespace trim on left/right
  $data=~s/^\s+|\s+$//g;
  
  for my $monkeyStr (split(/\nMonkey /, $data)){
    my %m = (items=>[], operator=>'OP_NOT_FOUND', argument=>-1, modulo=>-1, trueThrow=>-1, falseThrow=>-1);
    if($monkeyStr =~ /Starting items: ([^\n]+)/){
      $m{items} = [ split(/,\s*/, $1) ];
    }
    if($monkeyStr =~ /new\s+=\s+old\s+([\+\*])\s+(.+)/){
      $m{operator} = $1;
      $m{argument} = $2;
    }
    if($monkeyStr =~ /Test: divisible by (\d+)/){
      $m{modulo} = $1;
    }
    if($monkeyStr =~ /If true.*monkey (\d+)/){
      $m{trueThrow} = $1;
    }
    if($monkeyStr =~ /If false.*monkey (\d+)/){
      $m{falseThrow} = $1;
    }

    push(@monkey, \%m);
  }
  return \@monkey;
}

sub finishARound{
  my($monkeysOrig) = @_;

  my $monkeys = dclone($monkeysOrig);
  my @handling = (0) x scalar(@$monkeys);

  for(my $i=0;$i<@$monkeys;$i++){
    my $items = worryLevels($$monkeys[$i]);

    for(my $j=0;$j<@$items;$j++){
      my $remainder = $$items[$j] % $$monkeys[$i]{modulo};
      my $otherMonkeyIdx;
      if(!$remainder){
        $otherMonkeyIdx = $$monkeys[$i]{trueThrow};
      } else {
        $otherMonkeyIdx = $$monkeys[$i]{falseThrow};
      }
      push(@{$$monkeys[$otherMonkeyIdx]{items}}, $$items[$j]);
      #note "Monkey $i had item $$monkeys[$i]{items}[$j] => $$items[$j] and gave it to monkey $otherMonkeyIdx (remainder: $remainder)";
    }
    #note "";
    
    # At this point, all items have been thrown.
    # Count them and clear them.
    $handling[$i] += @$items;
    $$monkeys[$i]{items} = [];
  }
  #note Dumper $monkeys;
  return ($monkeys, \@handling);
};

sub worryLevels{
  my($monkey) = @_;

  my @worry;
  my $items = $$monkey{items};
  for my $item(@$items){
    my $argument;
    if($$monkey{argument} =~ /\d/){
      $argument = $$monkey{argument};
    }
    elsif($$monkey{argument} eq 'old'){
      $argument = $item + 0;
    }
    else{
      BAIL_OUT("Unsure how to deal with monkey argument $$monkey{argument}");
    }

    my $worry = eval "$item $$monkey{operator} $argument";
    $worry = int($worry / 3);
    push(@worry, $worry);
    #note "$item => ($item $$monkey{operator} $argument) => $worry";
  }
  return \@worry;
}


__DATA__
Monkey 0:
  Starting items: 53, 89, 62, 57, 74, 51, 83, 97
  Operation: new = old * 3
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 5

Monkey 1:
  Starting items: 85, 94, 97, 92, 56
  Operation: new = old + 2
  Test: divisible by 19
    If true: throw to monkey 5
    If false: throw to monkey 2

Monkey 2:
  Starting items: 86, 82, 82
  Operation: new = old + 1
  Test: divisible by 11
    If true: throw to monkey 3
    If false: throw to monkey 4

Monkey 3:
  Starting items: 94, 68
  Operation: new = old + 5
  Test: divisible by 17
    If true: throw to monkey 7
    If false: throw to monkey 6

Monkey 4:
  Starting items: 83, 62, 74, 58, 96, 68, 85
  Operation: new = old + 4
  Test: divisible by 3
    If true: throw to monkey 3
    If false: throw to monkey 6

Monkey 5:
  Starting items: 50, 68, 95, 82
  Operation: new = old + 8
  Test: divisible by 7
    If true: throw to monkey 2
    If false: throw to monkey 4

Monkey 6:
  Starting items: 75
  Operation: new = old * 7
  Test: divisible by 5
    If true: throw to monkey 7
    If false: throw to monkey 0

Monkey 7:
  Starting items: 92, 52, 85, 89, 68, 82
  Operation: new = old * old
  Test: divisible by 2
    If true: throw to monkey 0
    If false: throw to monkey 1

