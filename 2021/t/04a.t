#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Statistics::Descriptive;
use Test::More tests=>2;
use File::Basename qw/dirname/;

my $example="7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
";

subtest "Test $0" => sub{
  my($drawing, $boards) = readData($example);
  for(my $i=0; $i<12; $i++){
    my $drew = playTurn($drawing, $boards);
    my $winnerIdx = findWinningBoard($boards);
    if($winnerIdx > -1){
      note "WINNER with drawing $i with integer $drew";
      my $score = score($drew, $$boards[$winnerIdx]);
      #note formatBoard($$boards[$winnerIdx]);

      is($winnerIdx, 2, "Board index");
      is($i, 11, "The turn the board won");
      is($drew, 24, "The number drawn");
      is($score, 4512, "actual score");
    }
  }
};

subtest "Real $0" => sub{
  my $dataStr;
  {
    local $/ = undef;
    my $infile = dirname($0)."/04.txt";
    open(my $fh, $infile) or die "ERROR: could not read from $infile: $!";
    $dataStr = <$fh>;
    close $fh;
  }
  my($drawing, $boards) = readData($dataStr);
  for(my $i=0; $i<@$drawing; $i++){
    my $drew = playTurn($drawing, $boards);
    my $winnerIdx = findWinningBoard($boards);
    if($winnerIdx > -1){
      note "WINNER with drawing $i with integer $drew";
      my $score = score($drew, $$boards[$winnerIdx]);
      #note formatBoard($$boards[$winnerIdx]);

      is($score, 10680, "actual score");
      last;
    }
  }

};

sub score{
  my($int, $board) = @_;
  my $sum = 0;
  for(my $i=0;$i<@$board;$i++){
    for(my $j=0; $j<scalar(@{ $$board[$i] }); $j++){
      if(!$$board[$i][$j]{marked}){
        $sum += $$board[$i][$j]{int};
      }
    }
  }
  my $score = $int * $sum;
  return $score;
}

# Returns a board index for the first winner
# -1 for no winner found
sub findWinningBoard{
  my($boards) = @_;
  
  for(my $boardIdx=0; $boardIdx<@$boards; $boardIdx++){
    my $cols = $$boards[$boardIdx];
    # See if this board is a winner by column or row
    # by row
    for(my $i=0; $i<@$cols; $i++){
      my $numMarked = 0;
      for(my $j=0; $j<scalar(@{ $$cols[$i] }); $j++){
        my $marked = $$cols[$i][$j]{marked};
        if(!defined($marked)){
          die "ERROR: marked not a value in row $i col $j ";
        }
        $numMarked += $marked;
      }
      if($numMarked == scalar(@$cols)){
        return $boardIdx;
      }
    }

    # TODO by column
  }

  return -1;
}

sub playTurn{
  my($drawing, $boards) = @_;

  my $int = shift(@$drawing);

  for(my $i=0; $i<@$boards; $i++){
    markBoard($int, $$boards[$i]);
  }

  return $int;
}

sub markBoard{
  my($int, $board) = @_;
  for(my $i=0; $i<@$board; $i++){
    my $numCols = scalar(@{ $$board[$i] });
    for(my $j=0; $j<$numCols; $j++){
      my $boardInteger = $$board[$i][$j]{int};
      if(!defined($boardInteger)){
        die "Could not find int in row $i col $j";
      }
      if($boardInteger == $int){
        $$board[$i][$j]{marked} = 1;
      }
    }
  }
  return 1;
}

# Make a grid of 2 digit numbers from a board array
sub formatBoard{
  my($board) = @_;
  my $str = "";
  for(my $i=0; $i<@$board; $i++){
    #my @col = map{$$_{int}} @{ $$board[$i] };
    for my $c(@{ $$board[$i] }){
      my $chars = sprintf("%02.0f", $$c{int});
      if($$c{marked}){
        $chars = "xx";
      }
      $str .= $chars . " ";
    }
    $str.="\n";
  }
  
  return $str;
}

sub readData{
  my($str) = @_;

  my($drawing, $boards) = split(/\n/, $str, 2);

  my @drawing = split(/,/, $drawing);
  
  my @boardStr = grep {s/^\s+|\s+$//g; /./}
                   split(/^\s*$/m, $boards);
  
  # Make a 2d array of hashes. Each hash is the int and
  # whether the spot is marked
  my @board = ();
  for(my $i=0;$i<@boardStr;$i++){
    for my $row(split(/\n/, $boardStr[$i])){
      my @col = map{
                  {int=>$_, marked=>0}
                }
                grep {/./}
                split(/\s+/, $row);
      push(@{ $board[$i] }, \@col);
    }
  }
  
  return(\@drawing, \@board);
}

