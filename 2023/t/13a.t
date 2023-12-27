#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use List::Util qw/min sum/;

subtest "Test $0" => sub{
  my $data = "
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
  ";
  my $plotObjects = findReflections($data);

  my @exp = (5,400);
  my @obs;
  for my $obj(@$plotObjects){
    push(@obs, $$obj{score});
  }
  is_deeply(\@obs, \@exp, "individuals");
  is(sum(@obs), 405, "sum");
};

subtest "Real $0" => sub{
  local $/ = undef;
  my $data = <DATA>;
  $data =~ s/^\s+|\s+$//g; # whitespace trim on each line
  my $plotObjects = findReflections($data);
  my @obs;
  for my $obj(@$plotObjects){
    push(@obs, $$obj{score});
  }
  # 28396 is too low
  # 30096 is too low
  is(sum(@obs), 40006, "sum");
};

sub findReflections{
  my($data) = @_;

  # Make 2d arrays for each plot
  my @plot;
  for my $plotStr (split(/\n\n/, $data)){
    $plotStr =~ s/^\s+|\s+$//g;
    my @plotRow = split(/\n/, $plotStr);
    $_ = [split(//, $_)] for(@plotRow);
    my $plotObj = {
      plot=>\@plotRow,
      plotStr => "\n$plotStr",
      dimension=>"", # H or V
      reflectionAfter => 0, # col or row that the reflection is after.
      score => 0,
    };

    findVerticalReflection($plotObj);
    if($$plotObj{dimension}){
      $$plotObj{score} = $$plotObj{reflectionAfter} * 1;
    }
    else{
      my $transposed = transposeMatrix($$plotObj{plot});
      $$plotObj{plot} = $transposed;
      findVerticalReflection($plotObj);
      $$plotObj{dimension} = "H";

      # Turn it back
      $transposed = transposeMatrix($$plotObj{plot});
      $$plotObj{plot} = $transposed;
      #findHorizontalReflection($plotObj);
      $$plotObj{score} = $$plotObj{reflectionAfter} * 100;
    }
    #delete($$plotObj{plot});
    #delete($$plotObj{plotStr});
    #note Dumper $plotObj;

    #note $$plotObj{plotStr}."\n".$$plotObj{dimension}.$$plotObj{reflectionAfter}."\n";
    #die if($$plotObj{reflectionAfter} == 0);
    if($$plotObj{reflectionAfter} >= -1){
      push(@plot, $plotObj);
    }
  }
  
  return \@plot;
}

sub transposeMatrix{
  my($m) = @_;
  my @tr;
  for my $row(0..@$m - 1){
    for my $col(0..@{$$m[$row]}-1){
      $tr[$col][$row] = $$m[$row][$col];
    }
  }
  return \@tr;
}

# Note the column that a reflection is under
sub findVerticalReflection{
  my($plotObj) = @_;
  
  #note $$plotObj{plotStr};
  my $plot = $$plotObj{plot};
  die "ERROR: plot is not an array" if(ref($plot) ne 'ARRAY');

  my $numCols = scalar(@{ $$plot[0] });
  my $numRows = scalar(@$plot);
  my $reflectionIdx;

  # Start the columns at 1 to give us something to reflect to
  for(my $j=1; $j<$numCols-0; $j++){
    my $numReflectingRows = 0;
    for(my $i=0; $i<$numRows; $i++){
      my @row = @{ $$plot[$i] };
      my $row = join("", @row);
      my $leftStr = substr($row, 0, $j);
      my $rightStr = substr($row, $j);

      my $numToCompare = min(length($leftStr), length($rightStr));
      if(length($leftStr) > length($rightStr)){
        $leftStr = substr($leftStr, -1*$numToCompare);
      }
      elsif(length($leftStr) < length($rightStr)){
        $rightStr = substr($rightStr, 0, $numToCompare);
      }
      if($leftStr eq reverse($rightStr)){
        $numReflectingRows++;
      }
      #note "Col $j Row $i: $leftStr | $rightStr (count: $numReflectingRows)";
    }

    #note "$numReflectingRows <> $numRows";
    if($numReflectingRows >= $numRows-0){
      $$plotObj{dimension} = "V";
      $$plotObj{reflectionAfter} = $j;
      return 1;
    }
  }

  return 0;
}


__DATA__
.#..#......
..#.#......
..#...#....
#.##...####
.#..#..####
#.#.##.####
###..#.#..#

.#.##.#.###
..####..##.
#########..
.##..##..##
.##..##..##
#########..
..####..##.
.#.##.#.###
#.#..#.##.#
..#####.###
...##.....#
..#..#..#..
...##...#..

..##.#.
#...###
#...###
..##.##
..#..#.
....##.
#.#.#..
.#...##
##.#...
###.###
###.###
##.#...
.#...##

#.#.###
..##.##
...####
##....#
##....#
...####
..##.##
#.#.###
#.#####
....##.
.#...#.
#.#####
#....##
#..##.#
#..##.#
#..#.##
#.#####

###...#...#.#..
.#.##.#.....#..
..###..#..#....
..###..#..#....
.#.##.#........
###...#...#.#..
###..#..##.#.##

##.#.....
##.#...#.
..#.#..##
..##....#
#..#....#
#.#..##..
#.#..##..
#..#....#
..##....#
..#.#..##
##.#...#.
##.#.....
#.#..#.#.

#..#..#..#.##
..........###
..........###
#..#..#..#.##
###....####.#
....##......#
##..##..##..#
###....####..
....##.....##
.#......#.#.#
.##....##..##
..#.##.#....#
####..######.
.##..#.##.###
..##..##...#.

..#.###..#.
####.#.....
..#.##.##..
...##...#.#
###.#......
#######.###
..#.#...###
###.###.##.
###..#...##
##....##.#.
####...#.##
..###......
.###..#.#..
##.##..#.#.
##.##..#.#.

#.##.###......#
.#..#.#..##..##
..##..#.#..#...
#....##.#.#.#..
#....##.######.
######....###.#
#.##.#...##.##.
..##..#####.###
..##..######..#
..##..######..#
..##..#####.###
#.##.#...##.##.
######....###.#
#....##.######.
#....##...#.#..

......#....#...
.####...##...#.
######..##..###
######..##..###
......##..##...
.####.######.##
.#..#.######.#.

#############..##
.########...###.#
.########...#.#.#
#.##..##.###..##.
..#.##.#....#.#..
..#....#...####..
#.#....#.##.#.#..
.#......#......##
.#......#......##
#.#....#.##.#.##.
..#....#...####..

...#.###.#.
....##.#.##
..##..#.###
..##..#.###
....##.#.##
...#.###.#.
#.#.#.#.#..
...##.#..##
.#.####...#
.#.#.##...#
...##.#..##
#.#.#.#.#..
...#.###.#.
....##.#.##
..##..#.###

.#.##.#.#.#..#.
.........######
###..####.#..#.
##.##.##.......
..#..#..##....#
.#.##.#...####.
##.....#..####.
..####..#..##..
##....##...##..

....####.####..
.#..####.####..
#.#.##..#####..
##..#.#.#######
.#.#.##.##.##..
..##..#.##..#..
####....#...#..
..#.#....##.#..
#..#..#..##.#..
.#.......#.####
..........##...
#.....####.#.##
##....##....###
.....#.##.#####
.#..#.##....#..
#.....###...#..
#....##........

#..##..#....###
#..#.#......###
.....#..####...
.##.##.##...###
.....##.###..##
.##..##....#.#.
.##...#.#.#.#..

.###.....##
..#......#.
..####.####
#.##...#.#.
#..#...####
##.#.#..###
##.#.#..###
#..#...####
#.##...#.#.
..####.####
..#......#.
.###.....##
.#.##.#..#.
..#...###..
..#...###..
.#.#..#..#.
.###.....##

###..##
...####
.#..#.#
#.##...
#...#..
#...#..
#.##...

..#......#.....
#.#......#.#..#
.#..####..#....
.#.#....#.#.##.
..########..##.
..#.####.#.....
..###..###..##.
#..######..####
.#####.####.##.
#..#....#..#..#
##........##..#
.....##.....##.
.##.#..#.##....

...#.##
...#...
#..####
#..####
...#...
...#.##
#.###.#
.##.#.#
.#.###.
.##.##.
.##..#.
.#.###.
.##.#.#

..#...##.
..###..##
...##.#..
###.#.##.
..##..##.
###..###.
..#.#.#..
####..#..
...#####.
##.####..
###.#..##
..#######
..#######
###.#...#
##.####..
...#####.
####..#..

.##...##.
#..##..#.
###..####
#..##.##.
.##..##..
#..###.##
.##.##.##
....##.##
.##.##..#
.##.##...
.##.##...
.##.##..#
....##.##

#...#.##.##..#.##
##..#.###...#####
##..#.###...###.#
#...#.##.##..#.##
...#.....###..##.
..####.#.#.####.#
..####.#.#.####.#
...#.....###..##.
#...#.##.##..#.##

.##..####.#####
.##..####.####.
.##.#.##..#.###
#..#.######.#.#
.#....##..##...
##..#.####..##.
.....#......##.
##..##..#.#.###
...##..#.#.#.#.
...#..##.###...
...#..##.###...

#..##.#.#.#
######..##.
#..#...#..#
#..#...#..#
######..##.
#..##.#.#.#
#..#..##..#
#...##.#.##
######.##.#
....#..####
####..##.#.

##.##..##.#.##.#.
....##.###..##..#
.##.#.##..######.
.##.#.##..######.
....##.###..##..#
##.##..##.#.##.#.
#####..#...####..
..##....###.##.##
.####...##.#..#.#
.####....#......#
##..#...#........
.##.#..#..##...#.
#####..#.##....##
#.#.#.#..#.####.#
##.######........

....#.#..
....#.##.
##.##.#..
##...#.#.
#.##..###
#.##..###
##...#.#.

##....###.####..#
##....###.####..#
.#.##.#.....#####
.######..#.#..#.#
.######.##.######
..#..#....####.##
.######.#.#.###.#
###########.#.##.
........##....#..
##.##.###..#.####
#......##....###.
#.....#####...#.#
###..###.##...##.

#..#...##
........#
....##...
....###..
........#
#..#...##
####.##..

.##..#.
##....#
##....#
.##..#.
...#.#.
#####.#
#####..
...#.#.
.##..#.

.##....#.#.##
#..#.....#...
.##.....###..
#..#...##....
#..#...#...##
..#.#.#......
.....#.#..###

#.....###....#.##
#.##.#.....#...#.
....#####.#...###
#...#..#...#.....
....#...#...####.
....#.#.#...####.
#...#..#...#.....
....#####.#...###
#.##.#.....#...#.
#.....###....#.##
.##.##....#..##..
...#.#.#..#.#...#
####...##.##...#.
.###.....###....#
.###.....###....#

..##..#...##...
##..##..#....#.
......#.#.##.#.
..##..#.#.##.#.
#.##.###.####.#
.####.....##...
.###..#........
.#..#.####..###
##..###...##...
#.##.####.##.##
######....##...
######.##.##.##
.####.#.#.##.#.
######..##..##.
.#..#..########
#.##.##...##...
#....##.##..##.

#..#..##.##.....#
....###.#...##.#.
##..#.#...###.##.
##...#..#.#..##.#
..#.#.....#.#####
..#.#.....#.#####
###..#..#.#..##.#
##..#.#...###.##.
....###.#...##.#.
#..#..##.##.....#
#..#..##.##.....#
....###.#...##.#.
##..#.#...###.##.
###..#..#.#..##.#
..#.#.....#.#####

##.########.####.
......#...#.####.
#.##..###.#######
##...#.###.##..##
##...#.###.##..##
#.##..###.#######
......#...#.####.
##.########.####.
..#####..#.######
#..###.#.#.#....#
..#.#....##.####.
......#.###..#...
..#...##...#....#
#...#....##..##..
.###.#.##.##.##.#
..#...##.##......
.##..#.##....##..

.###...#...#.#.
.###...#...#.#.
#...#.###..###.
##.##.#..#.####
.........#..###
..##.###..###.#
.......####....
####.#.#.#..###
####.###.#..###
.......####....
..##.###..###.#

.#..#..
.#..#..
#.#.#..
.##.#.#
#..#.##
..###..
.#.....
######.
#####.#
#####.#
######.
.#..#..
..###..
#..#.##
.##.#.#

#....#.#...##
######....#..
..........###
########.#...
#...###...###
##..###....##
..##...##....
#....##...#..
......#.#.#..

##########.#.#.##
..........#.#.##.
#..#..#..#..##..#
..........#.###.#
..........######.
.##.##.##.####.#.
#..####..#####..#
#..####..##...##.
..#.##.#...###..#
#..####..#......#
####..#######..##
#..####..##.##.#.
####..#####..####
....##.........#.
.............##..

.#..#.####..#.#..
####.#...#.......
#.##.#.#.##..#...
.........#..#.###
......#..#.#.##..
######.#.##...#..
.####..##.#...###

...##.##.
.....#.##
##...#..#
...##.##.
..#######
..#######
...##.##.
##...#..#
.....#.##
...##.##.
..####..#
....#####
.#.##....

..##....###
######.#..#
..##..#.#..
#######.###
...#.####..
##..#.###.#
##..#...#.#
###.##..##.
###.#.#.#.#
...#...#..#
###.#.#####
###..##....
...#.#....#
...#.#....#
###..##....
###.#.###.#
...#...#..#

##..####.#.
##..###.###
......##.#.
######...##
##..##..#.#
##..###...#
##..###.###
#.##.#.####
......####.

..#.##.##.#
#.##..####.
#....#.##.#
.##....##..
#..##......
##.#.......
#####......
#.#.#.#..#.
##..#.####.
#.#...#..#.
#.##..###..
###........
###.#......
..###..##..
..###..##..

####.###.##.#
......#......
....##.##.#..
....#..#.#..#
#####..#.###.
.....##...##.
#####.#.#.#..
....#......#.
.....#..#...#
####.#####.#.
#####.#..#...
.##...######.
.....#.######
####.#.##...#
.....##..####
....###.###.#
####.####...#

..###....###...
.##...###......
#.#..#..###....
##.##.#...#..##
#.####.#.##.###
#.####.#.##.###
##.##.#...#..##
#.#..#..###....
.##...###......
..###....###...
#.#..#......###
....#..##.#.###
...#.##..#.###.
.#.####.#.##.##
.#...##.###.###
###..#...#...##
###.#.#........

...##..#.##
..#..###..#
##.##.##..#
..#.#.#....
##....#.##.
..#####....
##..#.##..#
###...#....
...#.#.#..#
...########
###..##....
..##.......
###..#.....
###.##.....
###.#.#....

.#.#..#
#..#..#
.#.####
#...##.
..#....
##.#..#
.#.....
#...##.
#...##.
.#.....
#..#..#

###...##.##..#.#.
..#.####...#....#
....#..######....
....#.....#..#.#.
....#.....#..#.#.
....#..######....
..#.####...#....#
###..###.##..#.#.
###..#......#..#.
##..###.##..#####
...#...###....#..

.#.....####..##.#
#.####.##.##.....
##..###.###.##..#
...###.##.##.#...
##.#.#.##.#..#...
#..#.##.#.....#..
.#..#...##....##.
.#..#...##....##.
#..#.##.......#..
#..#.##.......#..
.#..#...##....##.
.#..#...##....##.
#..#.##.#.....#..

##..##..##..#
..##.#..#.##.
##...#.##...#
###..####..##
..##..##..##.
..#...##...#.
.....####....
....#....#...
..###.##.###.
###........##
..###.##.###.
##..######..#
..#..#..#..#.
##..##..##..#
..##.#..#.##.

#....########
.#....#..##..
#.##...##..##
..#.#.#.####.
##...#..####.
###.#...####.
.#.##...#..#.
.#....#..##..
..#...#.####.
..#...#.####.
.#....#..##..
.#.##...#..#.
##..#...####.

#.#......###.##.#
#.#...#..###.##.#
#..###..#.#..##..
###.#..##..##..##
.#..#..##........
#.###.....###..##
##..#.#.##.######
##.#.....#.#.##.#
##...#.##..#....#
...#.##..........
.##.#.#..#.......

..#####.#
....##.##
..#.#####
#..###.#.
###..##.#
.#...#.#.
.#...#.#.
###..#..#
#..###.#.
..#.#####
....##.##
..#####.#
.###..##.
...#.####
..###...#
..###...#
...#.####

..#...#...##.#.
##.....####.###
##.....###..###
..#...#...##.#.
##........#....
..#.##.###.#...
####.###.#####.
####.....###..#
....#.....#####
##....#.#..#..#
....##..#..#.#.
...##.###.....#
###.#.##.....##
##..###.#..####
##..####....##.
##.###....#.#.#
###..#.#.##.#.#

...#.##..
..#.####.
####.##.#
###.#..#.
##.#.##.#
..#..##..
###......
....#..#.
.....##..
####....#
...#.##.#
..#..##..
##.######

#.##.....
..#.#..#.
..#.#..#.
#.##.....
.##.....#
##.##..##
..###.###
.##..##..
.##..##..
..###.###
##.##..##
.##.....#
#.###....

#....#.##.####...
##.#...#..#..#.#.
####..####.######
..#...#...#...##.
###....#.#.#####.
###.#..##.....#.#
##.####.##.##..##
....##...##..#..#
##.....#.#.#...##
###.#.##.#.##..##
..##..##....#.###
##.##..#...###...
...###.#...####.#
...#....##.....##
##########...#..#
##....#.#.#......
##....#.#.#......

###.##.####
.##.##.##.#
#####.####.
#.#.##.#.#.
.#..##..#.#
..##..##...
#...##...##
#.#.##.#.##
##.####.##.
####..#####
..##..##..#
.##....##.#
.##....##.#
..##..##..#
####..#####
##.####.##.
#.#.##.#.##

.###............#
..#..##......##..
###....#....##...
###..####..####..
.....##.#..#.##..
..###.###..###.##
.##....#.##.#....
..#...#......#...
#..#.###.##.###.#
#.##...#.##.#...#
..#.##.#.##.#.##.
####...#....#...#
####...#....#...#
..#.##.#.##.#.##.
#.##...#.##.#...#

#..##.#
.##..##
.##..##
#..##.#
.#...##
..#####
....#..
.#...#.
.#.###.
.#.###.
.#...#.
....#..
..####.

##.......
##..#..##
#####....
.#.#..#..
.....#.#.
.##.##.##
.##.##.##
.....#.#.
.#.#..#..
#####.#..
##..#..##
##.......
##.......
##..#..##
#####.#..

..###....#.#.###.
#........###.####
..#...##.###.#..#
.#.##.##....#....
#.##.###..#.#####
##..###.#.....##.
##..###.#.....##.

..##.#.##.#.##..#
.#.##.####..#.#.#
...###....###...#
#....#....#....#.
####.#....#.#####
.##..........##..
.##..........##..
####.#....#.#####
#....#....#....#.

..##...##
.....#.##
.###.#...
..###.#..
..#.##.##
...#.####
...##..##
##.##...#
#####.#..
###.####.
.......#.
##.#.####
##.#.####
.......#.
###.####.

#..#..###
#####..##
..#.#....
###..#..#
##.###...
...###.#.
##.###.#.
...#.....
...###..#
....#..#.
##.#####.
###.#.###
###.#.###
##.#####.
....#..#.
...###..#
...#.....

...#...
...#.#.
##.....
....##.
...#.#.
..#.#..
#.#.#.#
#.#.#.#
..#.#..
...#.#.
....##.
##.....
...#.#.
...#...
##..#..
#.#.#..
#.##...

#..#...##.#....
#...#....###..#
.#.##.......##.
##..##..#..#..#
####..##..#....
###..#.........
#..##.#.##..##.
##..#.#.#..#..#
.###########..#
..........#.##.
###....#.#.....
##...##.####..#
##...##.####..#
###....#.#.....
..........#.##.
.###########..#
##....#.#..#..#

####.##.###..
###########..
....##...##..
########.####
####.####.#.#
....##.#.####
####..#.##.#.
######.#...##
#..#..#..#...
........#....
....##...##.#

.###..##.
###.#.#..
.######..
###.##.#.
###..#.#.
....#..#.
....#..#.
###..#.#.
###.##.#.
.######..
###.#.#..
.###..##.
..#.##..#
..#.#...#
..#.#...#
..#..#..#
.###..##.

###.#..
.#.####
#.##.##
...####
.#.#..#
##.#.##
#####..
#####..
##.#.##

..##.###..##.##.#
#.#....##.#...#..
#.#....##.#......
..##.###..##.##.#
..##.###..##.##.#
#.#....##.#......
#.#....##.#...#..
..##.###..##.##.#
##.##.##....##.#.
.#.#.###.###..#..
...##.#.#.#######
##..#.#..###.####
#.....##.###.#..#
.####.##..#.##...
###.#.#...##.#.#.

#....###.###..#
#######.#...#..
######.##..###.
#....#..#...#.#
##..##..####.#.
#########......
.#..#.####....#
######.##....#.
######.##....#.
.#..#.####....#
#########.....#
##..##..####.#.
#....#..#...#.#
######.##..###.
#######.#...#..

##.##..##.####.
.#........#..#.
.#..#..#..#..#.
###.#..#.######
##........####.
##.#....#.####.
..###..###....#
.#...##.#.#..#.
###.####.######

#...#..#.
#.#.#..#.
#.#..##..
###.#..#.
#.###..##
#.#..##..
##..#..#.
####....#
.#.#....#

##.....##....
.#...##..##..
#..##.#..#.##
##.###.##.###
.#.####..####
....########.
.##..######..
#.#..#....#..
.##...####...
#.###.#..#.##
..###.#..#.##
.##..######..
##.###....###

#.#.###..
#.#.#.#.#
#.#.#.#.#
#.#..##..
#..##...#
....##...
#.#..###.
##...#.##
##...#.##
#.#..###.
....##...
#..##...#
#.#..##..

.....##..###..#
##..#..##.##...
.##...##..#..##
.#..###.##.##.#
.#..###.##.##.#
.##...##..#..##
#...#..##.##...
.....##..###..#
#.###.......#.#
##..##...#.####
##..##...#.####
#.###.......#.#
.....##..###..#

#........
..#.####.
..#..##..
##.......
####....#
##.......
...######
..##.##.#
#####..##

##......#####
#.######.##..
#..####..##..
..##..##...##
##......###..
.#.#..#.#....
##..##..###..
.#.#..#.#.###
##########.##
..#....#..#..
.##.##.##....
#..####..#...
#.#.##.#.#...
#.#.##.###...
....##....###
###....###...
##.#..#.###..

....###...####...
.##.#.#..##..##..
......##...##...#
#..##.####.##.###
.#...#..#.#..#.#.
.##.#.###......##
#..##..###....###
.##.#..###.##.###
.##...#..#.##.#..
........#.####.#.
####.###.#.##.#.#
####..#.########.
######...######..
.....###...##...#
#..#.##.########.

###..####..
......##...
......##...
###..####..
...#..##..#
#..#.####.#
##.#.####.#
.##.#.##.#.
..#........
#..##....##
..#.#....#.
..#........
#..#....#.#
.#....##...
#.#...##...

###......###.
####....#####
..#..##..#.#.
....####....#
#.##....##.##
.##.#..#.##..
...##..##....
#.##.##.##.#.
#.##.##.##.#.
...##..##....
.##.#..#.##..

.##.....#..#.
....####....#
.#.####.#..#.
##.#...#....#
##.....#....#
##.##..#....#
..#..#...##..
..#..#...##..
##.##..#....#
##.....#....#
##.#...#....#
.#.####.#..#.
....####....#
.##.....#..#.
.#..###..#...

...#...######
.###....#####
..##....#....
#.#.#.##.#..#
##.##..#.####
##.....#.####
..#.##...#..#
.#.......#..#
##..##.#.####
##...#.#.####
.#.......#..#

.#.###..#.##.
.#.###..#.##.
..#...#...###
##.....#.##..
#.#.#....#..#
###....#.....
.#.###.#...#.
########..#.#
##.#####..#.#

#.#....#....#..
######.#....#.#
.#####.######.#
##....#.#..#.#.
.##...####.###.
....#..######..
#######.#..#.##
.......#.##.#..
.###....#..#...
#..##.#..##..#.
.#.##.###..###.
...##..######..
...##..######..

.#.####.#.....#.#
...#..#...#...##.
###....###.#.#.##
#.#.##.#.#.#.#...
##.####.#####..##
##.#..#.####...##
#######.##.#..##.
##..##..####.#..#
#..####..#....##.
#.######.#.##..#.
##########.####.#
#.#.##.#.##.##..#
..#....#..####.#.
#........#..####.
..######....#.###
..######....#.###
#........#..####.

#.#..#..##..#
#.#..#..##..#
.###...#..#..
.#.##..####..
.###.#......#
...#..######.
...###.#..#.#
###.....##...
###.##......#
#...##.##.#.#
..##..#.##.#.

.#....#.#.#..#.
##.####.##.#..#
.#..#.#.##..##.
.#..#.#.##..##.
##.####.##.#..#
.#..#.#.#.#..#.
...#..#.###..#.
..##....#.#.#.#
##.#.#..##..##.
..###.#..##..##
#.#..##.##.#...
..#..###...###.
#..#...####.###
...#.#.#.###.#.
...#..#...##..#
...#..#...##..#
...#.#.#.###.#.

..#.#.###...#.##.
#####...###...#..
#...#..#.#..##.#.
#...#..#.#..##.#.
#####...###...#..
..#.#.###...#.##.
.#.##......#.#...
.........#..##...
####.#...#....#.#
.#..##.###....##.
.#..##.###....##.
####.#...#....#.#
.........#..##...
.#.##......#.#..#
..#.#.###...#.##.

#..#.#.#..##..##.
.#..#.##..##..##.
#....#.#....##...
..##..#####.##.##
#....#.###..##..#
..##..#.#..####..
######.#.#.#..#.#
#.##.#..#...##...
#.##.#....##..##.
..##..###.######.
##..####..#....#.
##..##...#..##..#
##..###..##.##.##
##..######.####.#
..##......#....#.

##..###.#
..##.##..
###.#...#
####.####
###..###.
...##....
...##....
###..###.
####.####
###.#..##
..##.##..
##..###.#
######...
....#..##
######.##

..###.####.......
##..####.###.##..
#.....#..##.####.
#.##.##..#.##..##
.#####.#.#.#.##.#
##....##...######
####....##.######
#.#####.##.#.##.#
...#.###..#..##..
....##.......##..
....##.......##..
...#.###..#..##..
#.#####.##.#.##.#
####....##.######
##....##...######
.#####.#.#.#.##.#
#.##.##..#.##..##

.#.##.#.##.
.#.##.#.##.
#.#..#.####
.######.#.#
##....###.#
.#.##.#.##.
#.#..#.#.##
#.####.##.#
..#.....###

..#####....
..###..####
..#..#.#...
#..#..##..#
..##..#....
#..#..##..#
.####......
..######..#
...#.#.####
#.##.#.#..#
..#..#.#..#
..#..#..##.
..#..#..##.

#....##....##
###......####
#..#....#..##
#.#.#..#.#.##
#.###..###.##
###.#..#.####
.#........#..
##.######.###
#..##..##..##
.####..####..
#.#..##..#.##
#.#.#..#.#.##
#.##....##.##
##.######.###
..#.####.#...
###..##.#####
##...##...###

.#.####...###
##.###.#.##..
#...##..#.###
#...##..#.###
##..##.#.##..
.#.####...###
#.#...#.##...
...#.......##
####.##.#.#..

..#.#..
##..#..
##..#..
...####
####.##
....#..
#####..
#..##..
.....##
..##...
....#..
##..###
...##..

.##..#...#.#.
.##..#...#.#.
.....#..####.
.##.#.#..###.
.##...#..#..#
#####.##.#.#.
#.##.#..#.#.#

#....##...#.##.
#....#...###..#
.####.##.##....
..##...########
##..##..##.#..#
#.##.#.....#..#
..##..#.....#..

