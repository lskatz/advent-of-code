#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use Array::Compare;

subtest "Test $0" => sub{
  my $data = "
[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
  ";

  my @cmp = compareSignals($data);

  pass("test");
};

subtest "Real $0" => sub{
  #...;
  #my $data = readData();
  pass("real");
};

sub compareSignals{
  my($data) = @_;
  my $compObj = Array::Compare->new;

  $data =~ s/^\s+|\s+$//g;

  my $pairCount=0;
  while($data =~ /(\S+)\n(\S+)\n+/gm){
    my($left, $right) = ($1, $2);

    my $L = eval "$left";
    my $R = eval "$right";

    note ++$pairCount ."pair count";
    my $cmp = compare($L, $R, 0, $compObj);
    note "CMP: $cmp"; 
    note "";
  }
}

sub compare{
  my($L, $R, $level, $compObj) = @_;
  $level //= 0;

  for(my $i=0; $i<@$L;$i++){
    my $cmp;

    # If left is an array but right isn't, then convert right to an array
    if(ref($$L[$i]) eq 'ARRAY' && !ref($$R[$i])){
      note "  left is an array; converting right to an array";
      $$R[$i] = [$$R[$i]];
      $cmp = compare($$L[$i], $$R[$i], $level+1);
    }
    # If right is an array but left isn't, then convert left to an array
    elsif(ref($$R[$i]) eq 'ARRAY' && !ref($$L[$i])){
      note "  right is an array; converting left to an array";
      $$L[$i] = [$$L[$i]];
      $cmp = compare($$L[$i], $$R[$i], $level+1);
    }
    # If both are arrays, then recurse
    elsif(ref($$L[$i]) eq 'ARRAY' && ref($$R[$i]) eq 'ARRAY'){
      note "  comparing two arrays ".join(" ",@{$$L[$i]},"..",@{$$R[$i]});
      $cmp = compare($$L[$i], $$R[$i], $level+1);
    }
    elsif(!ref($$L[$i]) && !ref($$R[$i])){
      $cmp = $$L[$i] <=> $$R[$i];
    }
    else{
      die "ERROR I do not understand: ".Dumper($$L[$i], $$R[$i]);
    }
    note "  ref? ".ref($$L[$i])." ".ref($$R[$i]);
    note "($level) $cmp = $$L[$i] <=> $$R[$i]";
    return $cmp if($cmp);
  }
  note "  ($level) Ran out of items";
  return -1;
}

sub array_compare {
    my($a1, $a2) = @_;

    return 0 if (scalar @$a1) != (scalar @$a2);
    my @ar1 = sort { $a <=> $b } @$a1;
    my @ar2 = sort { $a <=> $b } @$a2;
    for my $i (0..$#ar1 ) {
        return 0 if $ar1[$i] != $ar2[$i];
    }
    return 1;
}

