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
  my $coordinates = readData($example);

  my $floor = plotFloor($coordinates);
  note formatFloor($floor);
  
  my $hot = 0;
  while(my($row, $cols) = each(%$floor)){
    while(my($col, $count) = each(%$cols)){
      if($count > 1){
        $hot++;
      }
    }
  }

  is($hot, 12, "number of hot squares");
};

subtest "Real for most dangerous $0" => sub{
  my $coordinates = readData($realData);

  my $floor = plotFloor($coordinates);
  #note formatFloor($floor);
  
  my $hot = 0;
  while(my($row, $cols) = each(%$floor)){
    while(my($col, $count) = each(%$cols)){
      if($count > 1){
        $hot++;
      }
    }
  }

  is($hot, 20196, "number of hot squares");
};

sub readData{
  my($data) = @_;
  my @coordinates;

  # Label the coordinates of the raw string in order
  my @coordinatesLabel = qw(x1 y1 x2 y2);
  for my $line(split(/\n/, $data)){
    $line =~ s/^\s+|\s+$//g; # trim
    next if($line =~ /^$/);  # skip empty lines

    # get coordinates with a split on the string
    my %c = ();
    $line =~ s/\s+//g; # remove all whitespace
    my @unlabeledCoordinates = split(/,|->/, $line);
    @c{@coordinatesLabel} = @unlabeledCoordinates;
    $c{raw} = $line; #capture raw str for sanity

    # A couple more metrics
    $c{xDist} = $c{x2} - $c{x1};
    $c{yDist} = $c{y2} - $c{y1};

    # Use the comparison operator to figure out the step
    $c{xStep} = $c{xDist} <=> 0;
    $c{yStep} = $c{yDist} <=> 0;

    push(@coordinates, \%c);
  }
  return \@coordinates;
}

sub plotFloor{
  my($coordinates) = @_;

  # plot all the lines
  my %floor;
  for my $c(@$coordinates){
    my $i=$$c{y1};
    my $j=$$c{x1};
    my $numSquares = 0;
    while($j != $$c{x2} || $i != $$c{y2}){
      $floor{$i}{$j}++;
      $i += $$c{yStep};
      $j += $$c{xStep};
      $numSquares++;
    }
    #note "$$c{raw}: $$c{x2},$$c{y2}";
    $floor{$$c{y2}}{$$c{x2}}++;
    $numSquares++;
    #note "$$c{raw}: $numSquares";
  }
  return \%floor;
}


sub readDataOld{
  my($data) = @_;
  
  my @floor;
  my @text = grep{s/^\s+|\s+$//g; /./} split(/\n/, $data);

  # Figure out the width and height as we go
  my $width = 0;
  my $height= 0;
  for (@text){
    if(/(\d+),(\d+)\D+(\d+),(\d+)/){
      my($y,$x,$Y,$X) = ($1,$2,$3,$4);

      my ($loY,$hiY) = (min($y,$Y), max($y,$Y));
      my ($loX,$hiX) = (min($x,$X), max($x,$X));

      $width = max($width, $x, $X);
      $height= max($height,$y, $Y);

      # Only consider horizontal or vertical lines
      if($x==$X && $y!=$Y){
        for my $j($loY..$hiY){
          $floor[$j][$x]++;
        }
      }
      elsif($y==$Y && $x!=$X){
        for my $i($loX..$hiX){
          $floor[$y][$i]++;
        }
      }
      # Part B: also consider diagonal lines
      # negative slope
      elsif( $x > $X && $y < $Y){
        note "$y,$x->$Y,$X";
        for(my $i=$x; $i>=$X; $i--){
          my $j=$y;
          $floor[$j][$i]++;
          $j++;
        }
      }
      # other negative slope
      elsif( $x < $X && $y > $Y){
        note "$y,$x->$Y,$X";
        for(my $i=$x; $i<=$X; $i++){
          my $j=$y;
          $floor[$j][$i]++;
          $j--;
        }
      }
      # Positive slope
      elsif( $x < $X && $y < $Y){
        note "$y,$x->$Y,$X";
        for(my $i=$x; $i<=$X; $i++){
          my $j=$y;
          $floor[$j][$i]++;
          $j++;
        }
      }
      # Other positive slope
      elsif( $x > $X && $y > $Y){
        note "$y,$x->$Y,$X";
        for(my $i=$x; $i>=$X; $i--){
          my $j=$y;
          $floor[$j][$i]++;
          $j--;
        }
      }
      else { 
        note "$y,$x->$Y,$X";
        die "INTERNAL ERROR";
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

  # find dimensions
  my $width=0;
  my $height=0;
  while(my($row,$cols) = each(%$floor)){
    while(my($col, $count) = each(%$cols)){
      $width = max($col, $width);
      $height= max($row, $height);
    }
  }
  $width++;
  $height++;

  my $str = "    ";
  # Number the row coordinates
  for(0..$width-1){
    $str .= sprintf("%02.0f ", $_);
  }
  $str .= "\n\n";

  for(my $i=0;$i<$height;$i++){
    $str .= sprintf("%02.0f  ", $i);
    for(my $j=0;$j<$width;$j++){
      my $heat = $$floor{$i}{$j} || 0;
      $str .= sprintf("%02.0f ", $heat);
    }
    $str.="\n";
  }

  return $str;
}

