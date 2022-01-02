#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use File::Basename qw/dirname/;
use List::Util qw/max min/;

my $example="
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
";

my $realData = "";
{
  local $/ = undef;
  my $infile = dirname($0)."/05.txt";
  open(my $fh, $infile) or die "ERROR: could not read from $infile: $!";
  $realData = <$fh>;
  close $fh;
}

subtest "Test for most dangerous $0" => sub{
  my $floor = readData($example);
  note formatFloor($floor);

  my $hot=0;
  for(my $row=0;$row<@$floor;$row++){
    my @col = @{ $$floor[$row] };
    note "$row: ".join(" . ",@col);
    for my $c(@col){
      #$c // note "col undefined on row $row";
      if($c > 1){
        $hot++;
      }
    }
  }
  is($hot, 5, "number of hot squares");
};

subtest "Real for most dangerous $0" => sub{
  my $floor = readData($realData);
  note formatFloor($floor);

  my $hot=0;
  for(my $row=0;$row<@$floor;$row++){
    my @col = @{ $$floor[$row] };
    #note "$row: ".join(" . ",@col);
    for my $c(@col){
      #$c // note "col undefined on row $row";
      if($c > 1){
        $hot++;
      }
    }
  }
  is($hot, 6267, "number of hot squares");
};

sub readData{
  my($data) = @_;
  
  my @floor;
  my @text = grep{s/^\s+|\s+$//g; /./} split(/\n/, $data);

  # Figure out the width and height as we go
  my $width = 0;
  my $height= 0;
  for (@text){
    if(/(\d+),(\d+)\D+(\d+),(\d+)/){
      my($y,$x,$Y,$X) = ($1,$2,$3,$4);

      ($y,$Y) = (min($y,$Y), max($y,$Y));
      ($x,$X) = (min($x,$X), max($x,$X));

      $width = max($width, $x, $X);
      $height= max($height,$y, $Y);

      # Only consider horizontal or vertical lines
      if($x==$X){
        for my $j($y..$Y){
          $floor[$j][$x]++;
        }
      }
      if($y==$Y){
        for my $i($x..$X){
          $floor[$y][$i]++;
        }
      }
    }
    else {
      die "ERROR: could not read line: $_";
    }
  }
   
  # Initialize all other elements to 0 using the width
  # and height that were determined as it was read in.
  for(my $col=0;$col<=$height;$col++){
    for(my $row=0;$row<=$width;$row++){
      $floor[$col][$row] ||= 0;
    }
  }

  return \@floor;
}

sub formatFloor{
  my($floor) = @_;

  # how wide is this thing
  my $width=0;
  for(my $i=0;$i<@$floor;$i++){
    my $col = $$floor[$i] || next;
    next if(!@$col);
    if($width < @$col){
      $width = @$col;
    }
  }

  my $str;
  for(my $i=0;$i<@$floor;$i++){
    for(my $j=0;$j<$width;$j++){
      my $heat = $$floor[$i][$j] || 0;
      $str .= sprintf("%02.0f ", $heat);
    }
    $str.="\n";
  }

  return $str;
}

