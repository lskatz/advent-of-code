#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use File::Basename qw/dirname/;
use List::Util qw/sum/;

my $example="2199943210
3987894921
9856789892
8767896789
9899965678";

my $realData = "";
{
  $/=undef;
  open(my $fh, dirname($0)."/09.txt") or die $!;
  $realData = <$fh>;
  chomp($realData);
}

subtest "Test for low points $0" => sub{
  my $grid = readData($example);
  my $lowPoints = findLowPoints($grid);

  my $sumRisk = sum map{$$_{risk}} @$lowPoints;
  is($sumRisk, 15, "sum of risk");
};

subtest "Real for low points $0" => sub{
  my $grid = readData($realData);
  my $lowPoints = findLowPoints($grid);

  my $sumRisk = sum map{$$_{risk}} @$lowPoints;
  is($sumRisk, 607, "sum of risk");
};

sub findLowPoints{
  my($grid) = @_;

  my @lowPoint = ();

  my $numRows = @$grid;
  for(my $row=0; $row<$numRows; $row++){
    my $numCols = @{ $$grid[$row] };
    for(my $col=0; $col<$numCols; $col++){
      # Pretend the default for surrounding points are
      # really high up.
      my($left, $right, $up, $down) = (9) x 4;

      if($row > 0){
        $down = $$grid[$row-1][$col];
      }
      if($col > 0){
        $left = $$grid[$row][$col-1];
      }
      if($row<$numRows-1){
        $up   = $$grid[$row+1][$col];
      }
      if($col<$numCols-1){
        $right = $$grid[$row][$col+1];
      }

      my $v = $$grid[$row][$col];
      if($v < $up && $v < $down && $v < $left && $v < $right){
        note "$v < $up && $v < $down && $v < $left && $v < $right";
        push(@lowPoint, {risk=>$v+1, v=>$v, row=>$row, col=>$col});
      }
    }
  }
  return \@lowPoint;
}

sub readData{
  my($data) = @_;

  my @grid = ();
  for my $line(split(/\n/, $data)){
    chomp($line);
    push(@grid,
      [split(//, $line)]
    );
  }

  return \@grid;
}

