#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use List::Util qw/max/;

subtest "Test $0" => sub{
  my $data = "
R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
  ";

  my $plot = digLines($data);
  #my $numFilled = fillPlot($plot);
  my $numFilled = area($plot);

  is($numFilled, 62, "num filled");
};

subtest "Real $0" => sub{
  local $/ = undef;
  my $data = <DATA>;
  $data =~ s/^\s+|\s+$//g; # whitespace trim on each line

  my $plot = digLines($data);
  #my $numFilled = fillPlot($plot);
  my $numFilled = area($plot);
  # 41889 is too low
  # 72570 is too high
  is($numFilled, 61865, "num filled");
};

sub area{
  my($plot) = @_;

  
  my $coords = findStart($plot);
  my ($y, $x) = @$coords;

  my %visited;

  walk($y, $x, $plot, \%visited);

  # Calculate how many squares are occupied.
  my $area = 0;
  my $numRows=@$plot;
  for(my $i=0;$i<$numRows;$i++){
    my $numCols = scalar(@{ $$plot[$i] });
    for(my $j=0;$j<$numCols;$j++){
      if($$plot[$i][$j] > 0){
        $area++;
      }
    }
  }

  return $area;

}

sub walk{
  my($y, $x, $plot, $visited) = @_;
  # Do nothing if this plot is not defined.
  # This can happen if we go off the edge of the plot.
  return if(!defined($$plot[$y][$x]));
  # It can appear defined in perl arrays though if it's -1
  # because perl lets you wrap around to the end of an array,
  # and so check for negative coordinates.
  return if($y < 0 || $x < 0);

  # Mark where I have visited.
  # If I have visited, then return and do nothing.
  return if($$visited{$y}{$x}++);

  # If this is a boundary, return and do nothing.
  return if($$plot[$y][$x] == 1);

  # If this is an empty spot, then mark the plot and continue.
  if($$plot[$y][$x] == 0){
    $$plot[$y][$x] = 2;
  }

  # Recursive for all four directions
  no warnings 'recursion'; # we know it's going to be deep recursion and so avoid that warning message
  walk($y, $x+1, $plot, $visited);
  walk($y, $x-1, $plot, $visited);
  walk($y-1, $x, $plot, $visited);
  walk($y+1, $x, $plot, $visited);
}


sub findStart{
  my($plot) = @_;

  # Find the first spot that might be inside the polygon
  my $numRows = scalar(@$plot);
  for(my $i=0;$i<$numRows;$i++){
    my $numCols = scalar(@{ $$plot[$i] });
    $$plot[$i] //= [];
    for(my $j=0; $j<$numCols; $j++){
      $$plot[$i][$j] //= 0;
      if($$plot[$i][$j] == 1){
        return [$i+1,$j+1];
      }
    }
  }
}


sub fillPlot{
  my($plot) = @_;

  # Fill up all squares in the plot
  my $numRows = scalar(@$plot);
  for(my $i=0;$i<$numRows;$i++){
    # Give the row a default array if not defined
    $$plot[$i] //= [];
    my $numCols = scalar(@{ $$plot[$i] });
    for(my $j=0;$j<$numCols;$j++){
      # Give the plot a default value in this cell
      $$plot[$i][$j] //= 0;
      if($$plot[$i][$j] == 0 && is_surrounded($i,$j,$plot)){
        $$plot[$i][$j] = 2;
      }
    }
  }

  # Calculate how many are filled
  my $numFilled = 0;
  for(my $i=0;$i<$numRows;$i++){
    my $numCols = scalar(@{ $$plot[$i] });
    # Sum up all the 1s in this row.
    # If I need to make it go faster, I can use sum(), probably
    for(my $j=0;$j<$numCols;$j++){
      $$plot[$i][$j] //= 0;
      if($$plot[$i][$j] == 1 || $$plot[$i][$j] == 2){
        $numFilled++;
      }
    }
  }

  #printPlot($plot);

  return $numFilled;
}

# Check all sides to see if a spot on the grid
# is surrounded by trench.
sub is_surrounded{
  my($i,$j,$plot) = @_;

  if($$plot[$i][$j] =~ /^[12]$/){
    return 1;
  }

  # Need 4 to be surrounded
  my %directionsSurrounded=();
  
  # left
  for(my $x=$j; $x>=0; $x--){
    $$plot[$i][$x] //= 0;
    if($$plot[$i][$x] =~ /^[12]$/){
      $directionsSurrounded{L}++;
      last;
    }
  }
    
  # Right
  my $numCols = scalar(@{ $$plot[$i] });
  for(my $x=$j; $x<$numCols; $x++){
    $$plot[$i][$x] //= 0;
    if($$plot[$i][$x] =~ /^[12]$/){
      $directionsSurrounded{R}++;
      last;
    }
  }
    
  # Up
  for(my $y=$i; $y>=0; $y--){
    $$plot[$y][$j] //= 0;
    if($$plot[$y][$j] =~ /^[12]$/){
      $directionsSurrounded{U}++;
      last;
    }
  }
    
  # Down
  my $numRows = scalar(@$plot);
  for(my $y=$i; $y<$numRows; $y++){
    $$plot[$y][$j] //= 0;
    if($$plot[$y][$j] =~ /^[12]$/){
      $directionsSurrounded{D}++;
      last;
    }
  }

  my $numDirectionsSurrounded = scalar(keys(%directionsSurrounded));
    
  if($numDirectionsSurrounded == 4){
    return 1;
  }
  elsif($numDirectionsSurrounded < 4){
    return 0;
  }

  die "INTERNAL ERROR: more than four sides surround $i,$j";
}

sub digLines{
  my($data) = @_;

  # my coordinates are x,y
  my $x=0;
  my $y=0;
  # 2d plot of dug or not.
  # The first square starts off dug for free.
  my @plot = (
    [1,0],
  );

  for my $line(split(/\n/, $data)){
    next if($line =~ /^\s*$/);
    chomp($line);

    my($direction, $length, $color) = split(/\s+/, $line);
    #note "BEFORE MOVING: $x,$y";
    #note "  DIRECTION $direction $length $color  <== $line";

    if($direction eq 'R'){
      for(my $j=0; $j<$length; $j++){
        $x++;
        $plot[$y][$x] = 1;
      }
    }
    elsif($direction eq 'L'){
      for(my $j=0; $j<$length; $j++){
        $x--;
        
        # Avoid underflow
        if($x < 0){
          my $numRows = scalar(@plot);
          for(my $i=0; $i<$numRows; $i++){
            unshift(@{ $plot[$i] }, 0);
          }
          $x = 0;
        }

        $plot[$y][$x] = 1;
      }
    }
    elsif($direction eq 'U'){
      for(my $j=0; $j<$length; $j++){
        $y--;

        # Avoid underflow
        if($y < 0){
          unshift(@plot, []);
          $y = 0;
        }

        $plot[$y][$x] = 1;
      }
    }
    elsif($direction eq 'D'){
      for(my $j=0; $j<$length; $j++){
        $y++;
        $plot[$y][$x] = 1;
      }
    }
    #note "  AFTER MOVING: $x,$y";
    #printPlot(\@plot);
    #note " ";
  }

  defineWholePlot(\@plot);

  return \@plot;

}

sub defineWholePlot{
  my($plot) = @_;
  my $numRows = scalar(@$plot);

  # Find the max width of the plot
  my $width = 0;
  for(my $i=0;$i<$numRows;$i++){
    # Fill in any undefined rows
    $$plot[$i] //= [];
    # Max width
    $width = max($width, scalar(@{ $$plot[$i] }));
  }

  # Go fill in cells
  for(my $i=0;$i<$numRows;$i++){
    for(my $j=0; $j<$width; $j++){
      $$plot[$i][$j] //= 0;
    }
  }
}

sub printPlot{
  my($plot) = @_;
  for(my $i=0; $i<@$plot; $i++){
    $$plot[$i] //= [];
    for(my $j=0; $j<@{ $$plot[$i] }; $j++){
      $$plot[$i][$j] //= 0;
    }
    note join("", @{ $$plot[$i] });
  }
}
sub colored_text {
    my ($text, $hex_color) = @_;

    # Convert hexadecimal color code to RGB
    my ($r, $g, $b) = unpack('C*', pack('H*', $hex_color));

    # ANSI escape code for setting text color
    my $color_code = "\e[38;2;$r;$g;$b"."m";

    # ANSI escape code for resetting text color
    my $reset_code = "\e[0m";

    # Print colored text
    return $color_code . $text . $reset_code . "\n";
}


__DATA__
R 11 (#00b1d2)
U 10 (#0afb33)
R 2 (#10afc2)
U 12 (#2f8191)
R 9 (#2fa802)
D 2 (#413001)
R 10 (#6b5602)
D 4 (#14b421)
R 2 (#0c2dd2)
D 11 (#19f1c1)
R 12 (#5d5b92)
D 6 (#42ac81)
R 4 (#1063e2)
D 3 (#013f81)
R 4 (#130b92)
U 7 (#4c8883)
R 4 (#311e72)
U 2 (#0a50a3)
R 4 (#429752)
U 8 (#0a50a1)
R 15 (#1a8b12)
U 3 (#1b2553)
R 3 (#0492e2)
U 7 (#027343)
R 2 (#380692)
U 10 (#0766f3)
R 5 (#389950)
D 15 (#4b3be3)
L 4 (#1b76f0)
D 4 (#4b3be1)
R 4 (#217590)
D 5 (#3c1df3)
L 13 (#555470)
D 10 (#359d83)
R 13 (#1756e2)
D 3 (#289d81)
R 5 (#31d542)
U 10 (#289d83)
R 6 (#33adc2)
U 13 (#0afb31)
R 10 (#38f252)
U 3 (#120823)
R 6 (#0ae480)
U 4 (#57db83)
L 5 (#44a490)
U 12 (#4a8743)
L 6 (#253f30)
U 8 (#315f43)
L 14 (#2d28e0)
U 6 (#660453)
L 7 (#42aed0)
U 3 (#08fb33)
L 11 (#6c90f0)
U 5 (#315e73)
L 7 (#687aa0)
U 7 (#08ad13)
L 2 (#42dbf0)
U 13 (#131393)
L 6 (#27b842)
U 9 (#2f2403)
L 12 (#411a02)
U 2 (#3a9103)
L 10 (#63f842)
U 2 (#2fa803)
L 3 (#63f840)
U 9 (#13c553)
L 8 (#428452)
U 14 (#358723)
L 9 (#1f3410)
U 9 (#131301)
L 4 (#1f01b0)
U 8 (#131303)
L 10 (#386340)
U 4 (#0bdf53)
R 4 (#619e20)
U 13 (#08a623)
R 10 (#667950)
U 7 (#0a7083)
R 7 (#2f94a2)
U 3 (#1cf9c3)
R 8 (#5f7db2)
U 7 (#2ff4b3)
R 3 (#344612)
D 3 (#4cee71)
R 8 (#658252)
D 10 (#194b03)
R 8 (#314cc2)
D 4 (#23fc93)
R 8 (#14ec62)
U 7 (#09aa03)
R 13 (#2ea512)
D 7 (#1c8623)
R 11 (#6395b0)
U 4 (#46c0f3)
R 8 (#6395b2)
U 4 (#21df03)
R 9 (#1743b2)
U 9 (#2d2321)
R 3 (#592f12)
U 9 (#5824b1)
L 4 (#00f542)
U 7 (#098841)
L 5 (#16ba92)
U 2 (#4106a3)
L 6 (#0003e2)
U 12 (#1dfa43)
L 9 (#2a4592)
U 6 (#3a6f83)
L 6 (#33f9a2)
U 15 (#0f0af3)
L 7 (#0b3a32)
D 11 (#4d29d1)
L 3 (#1c0b92)
D 4 (#1704d1)
L 6 (#35c8d2)
D 5 (#13bd91)
L 3 (#51d460)
D 9 (#548bb1)
L 9 (#0088a2)
D 3 (#341f93)
L 3 (#56f692)
D 10 (#4e6673)
L 7 (#56f690)
U 16 (#4fb3e3)
L 3 (#07d7e0)
U 13 (#1e2c93)
R 9 (#031e20)
U 5 (#359693)
R 12 (#0b29f0)
U 5 (#603801)
R 5 (#3eccf0)
U 14 (#603803)
R 8 (#2d47b0)
U 4 (#359691)
R 7 (#057760)
D 4 (#1e2c91)
R 10 (#062330)
D 3 (#01f703)
R 6 (#055820)
D 9 (#33dc63)
R 12 (#403c10)
D 5 (#33dc61)
R 8 (#3fcfc0)
D 6 (#1f15b3)
R 6 (#518200)
D 5 (#369ce3)
R 6 (#471190)
D 4 (#1bef93)
R 11 (#435df0)
D 5 (#0fe403)
R 6 (#515fc0)
D 3 (#034263)
R 3 (#348b52)
D 12 (#0bbb83)
L 9 (#301e52)
D 4 (#0df7d3)
R 10 (#5b5ba0)
D 5 (#445193)
R 3 (#094e00)
D 7 (#2c2973)
R 11 (#205600)
D 3 (#4c8cb1)
R 6 (#60e720)
D 3 (#26d831)
L 4 (#6b6182)
D 2 (#415ba1)
L 16 (#01cad2)
D 3 (#273241)
R 9 (#620570)
D 6 (#305fd1)
L 17 (#0b26e0)
D 2 (#237e61)
L 6 (#21b5f0)
D 11 (#0800e1)
R 5 (#1cdcc0)
D 7 (#2e24a1)
R 9 (#19fd20)
D 6 (#33ce11)
R 9 (#24ed10)
D 6 (#33ce13)
R 5 (#3bf770)
U 4 (#284df1)
R 5 (#113a90)
U 6 (#2a4381)
R 5 (#1ef520)
U 9 (#410c73)
R 13 (#701f70)
U 3 (#410043)
R 6 (#004c52)
U 10 (#332643)
R 7 (#143062)
U 6 (#62ee33)
L 4 (#49c9e2)
U 11 (#62ee31)
L 9 (#283ae2)
U 12 (#29bc31)
R 5 (#66ffe2)
D 9 (#29bc33)
R 11 (#27c3f2)
D 5 (#4ccc03)
R 5 (#4fce10)
D 9 (#2b36c3)
R 3 (#240170)
D 10 (#2f1a03)
L 8 (#39b340)
D 3 (#167e93)
R 6 (#24e020)
D 11 (#3eace3)
R 2 (#42e260)
D 9 (#070cc3)
R 5 (#715010)
D 6 (#069781)
R 8 (#0f67d0)
D 10 (#1bf5d1)
R 10 (#1bd720)
D 4 (#27aad1)
L 8 (#6e28d0)
D 3 (#1e5481)
L 7 (#6b0920)
D 8 (#1b8fa1)
L 8 (#01ae30)
D 8 (#2d2c51)
R 8 (#15c4d0)
U 5 (#417e11)
R 11 (#0112d0)
D 3 (#613051)
R 2 (#47f230)
D 10 (#0adb51)
R 3 (#3fdce0)
U 3 (#4b86e1)
R 9 (#38c990)
U 10 (#282fa1)
R 5 (#30e120)
U 9 (#374533)
R 5 (#3e3f00)
U 4 (#3c7153)
R 11 (#3aeb10)
U 5 (#17a6f1)
R 5 (#2f5e80)
U 5 (#5ede21)
L 10 (#224800)
U 3 (#285d21)
L 8 (#45d4a0)
U 5 (#03b5d1)
L 3 (#423150)
U 5 (#0782e1)
R 8 (#36ced0)
U 6 (#323851)
R 7 (#7203f2)
U 3 (#22df91)
R 4 (#035562)
U 8 (#2c71a3)
R 14 (#548c02)
U 5 (#2c71a1)
R 7 (#2d6322)
U 6 (#122801)
R 6 (#07b192)
U 12 (#1a3521)
R 5 (#1e80a0)
U 6 (#2712f1)
R 11 (#435600)
U 8 (#4d6401)
R 9 (#29e960)
D 8 (#113b21)
R 10 (#252702)
D 3 (#323ba1)
R 11 (#440560)
D 5 (#6c78b1)
R 9 (#440562)
D 3 (#0bc0d1)
R 3 (#252700)
D 11 (#132991)
R 5 (#1ec0e0)
D 4 (#1a3c61)
R 8 (#2355e0)
D 7 (#1a3c63)
R 6 (#312340)
D 5 (#3da4d1)
R 7 (#1c14f0)
D 11 (#1645a1)
R 7 (#4a8ee2)
D 9 (#4722d1)
R 10 (#4a8ee0)
U 7 (#1a0621)
R 10 (#1419d0)
U 6 (#322873)
L 8 (#138690)
U 12 (#393373)
L 7 (#09dfa0)
U 3 (#4630c3)
R 15 (#67cdd0)
U 4 (#4630c1)
R 10 (#12c3e0)
D 8 (#393371)
R 2 (#054cd0)
D 5 (#285993)
R 7 (#148090)
D 6 (#2f4bb1)
L 7 (#685b80)
D 13 (#2f4bb3)
R 7 (#0559d0)
D 5 (#4ea313)
L 17 (#20a790)
D 4 (#4336e3)
R 12 (#3aea70)
D 10 (#31ba33)
R 5 (#3a4a20)
D 11 (#2a9491)
R 11 (#010c52)
D 6 (#06b7e1)
L 5 (#1ff852)
D 4 (#5f1871)
L 10 (#1ff850)
D 7 (#1243a1)
R 10 (#010c50)
D 7 (#10c261)
L 5 (#4598b0)
D 2 (#14f741)
L 8 (#330100)
U 7 (#442a51)
L 2 (#3ab5d2)
U 13 (#4e8ff3)
L 8 (#1a52f2)
D 9 (#4e8ff1)
L 9 (#2390f2)
D 4 (#1189b1)
L 3 (#4928c0)
U 4 (#321d21)
L 10 (#52daa0)
U 4 (#5287b1)
L 14 (#52daa2)
U 8 (#06d521)
L 6 (#05f8e2)
U 5 (#0d7ae1)
R 5 (#4115b0)
U 6 (#17e7f1)
R 17 (#1d8500)
U 4 (#437581)
R 3 (#143a30)
U 6 (#171271)
L 9 (#31de22)
U 9 (#043981)
L 9 (#3cfae2)
U 9 (#043983)
L 3 (#03fbe2)
D 18 (#010431)
L 4 (#362c72)
U 7 (#38a1f3)
L 13 (#10f702)
D 6 (#470dd1)
L 5 (#425952)
D 3 (#405c51)
L 3 (#1f80c2)
D 7 (#2e36e3)
L 12 (#33e352)
D 5 (#2157f3)
L 3 (#33e350)
D 3 (#37db53)
R 4 (#403e32)
D 8 (#38a1f1)
L 11 (#098212)
D 6 (#27d8f1)
R 11 (#493b60)
D 8 (#4789d1)
R 9 (#47d6e2)
U 4 (#2a17d1)
L 6 (#47d6e0)
U 8 (#2e3d01)
R 6 (#175a80)
U 10 (#173c83)
R 12 (#341db0)
D 4 (#5d0793)
L 3 (#05ae40)
D 5 (#2b9a93)
L 4 (#5e54d0)
D 14 (#0071d1)
L 2 (#518400)
D 4 (#48d711)
R 6 (#3af910)
D 16 (#191181)
L 7 (#1c1ac0)
D 7 (#13ee81)
L 12 (#373742)
D 6 (#67ff51)
R 12 (#299280)
D 9 (#05baf1)
L 8 (#348550)
U 6 (#2a3533)
L 9 (#2d1370)
U 4 (#2a3531)
L 3 (#4f0230)
U 9 (#0074e1)
L 5 (#1bea20)
U 11 (#055591)
R 5 (#5935f2)
U 3 (#5f0aa1)
L 9 (#5935f0)
D 15 (#0e5c01)
L 7 (#1bea22)
D 12 (#154231)
L 10 (#4a33a2)
D 6 (#1b47b1)
L 11 (#70f912)
D 4 (#1b47b3)
R 4 (#1f00c2)
D 10 (#691cd1)
R 5 (#373740)
D 4 (#4419c1)
R 6 (#22e012)
D 5 (#396321)
R 11 (#1e4732)
U 5 (#000191)
R 12 (#2d80d2)
D 2 (#552391)
R 7 (#46a252)
D 6 (#28b3b1)
R 5 (#4fd020)
U 3 (#163863)
R 13 (#54a0e0)
U 6 (#163861)
R 7 (#10d960)
U 15 (#1f7e71)
L 7 (#61a832)
U 3 (#393681)
R 8 (#02d882)
U 11 (#2c6641)
R 9 (#5e0952)
D 11 (#302733)
R 9 (#0d7152)
U 5 (#1b43e1)
R 3 (#0caec2)
U 13 (#3d4651)
R 2 (#6af2c2)
U 3 (#02a7b1)
R 10 (#038872)
D 11 (#5b31e3)
R 4 (#0e63b2)
D 10 (#3287a3)
R 4 (#71abb2)
D 4 (#0325e3)
R 6 (#072ca2)
D 5 (#5e55e3)
L 4 (#120150)
D 4 (#625f63)
R 3 (#120152)
D 13 (#330273)
R 9 (#3ee252)
D 4 (#443303)
L 12 (#424100)
D 5 (#3891b3)
L 13 (#1ff340)
U 6 (#423ee3)
R 6 (#558660)
U 17 (#353de3)
L 6 (#6935d2)
U 3 (#0e6043)
L 11 (#2f8592)
D 7 (#19b4d3)
L 3 (#4ae5c2)
D 7 (#45db13)
L 7 (#05fa32)
D 4 (#333263)
R 11 (#424962)
D 11 (#6a73d3)
L 9 (#094982)
D 2 (#03da33)
L 11 (#29e442)
D 3 (#5a4ed3)
L 7 (#32d322)
D 4 (#094381)
L 13 (#0ad8f2)
D 7 (#36fd01)
L 5 (#6812e2)
D 11 (#2a0581)
L 7 (#6812e0)
D 13 (#11b9d1)
L 2 (#0ad8f0)
D 4 (#0240d1)
L 6 (#0254f2)
D 6 (#4a5c31)
L 7 (#511332)
D 3 (#57ef83)
L 4 (#30ef42)
D 10 (#67e103)
L 7 (#420dd2)
D 4 (#2c1f43)
L 13 (#496712)
D 5 (#3de561)
L 9 (#61dee0)
D 7 (#262651)
L 13 (#61dee2)
D 5 (#3124f1)
L 6 (#2e9eb2)
U 8 (#31a0d3)
L 2 (#16dcb2)
U 7 (#2b4163)
L 3 (#16dcb0)
U 5 (#384e73)
R 5 (#1dafb2)
U 13 (#3a4033)
R 5 (#062822)
U 4 (#08a533)
R 3 (#0d00e0)
U 4 (#3ea553)
R 8 (#0d00e2)
U 11 (#4515e3)
R 8 (#062820)
U 9 (#724413)
R 6 (#21c4f2)
U 5 (#107373)
L 11 (#627d82)
U 5 (#496323)
L 9 (#0ba742)
U 10 (#0f4383)
L 5 (#2df852)
U 3 (#4c0663)
L 10 (#2dad12)
U 7 (#31d3d3)
L 10 (#171f92)
U 6 (#2ac473)
L 7 (#30fdb2)
U 7 (#362d81)
L 9 (#23bde2)
U 12 (#0f8651)
L 3 (#1fc622)
U 5 (#415f21)
L 9 (#1fc620)
D 4 (#23bd41)
L 6 (#23bde0)
D 7 (#0d11f1)
L 10 (#1cc5e2)
D 4 (#371151)
R 9 (#393700)
D 2 (#0159d1)
R 2 (#2d7e42)
D 9 (#1f71b1)
L 6 (#4fd9c0)
D 7 (#3d8411)
L 5 (#4fd9c2)
D 3 (#4a2d71)
L 11 (#2d7e40)
U 11 (#2676a1)
R 12 (#4dd340)
U 3 (#41c901)
L 12 (#4dd342)
U 11 (#2ca4f1)
L 5 (#393702)
D 13 (#4a6791)
L 5 (#354e62)
D 9 (#4316a3)
L 7 (#598752)
D 9 (#0d84c3)
L 3 (#0ba362)
D 7 (#2cd153)
L 11 (#011cb2)
D 9 (#528631)
L 12 (#3601e2)
D 7 (#0d2991)
L 10 (#3100a2)
D 8 (#384861)
L 4 (#255642)
D 3 (#1d2b31)
L 11 (#3e6092)
U 4 (#1d3701)
R 4 (#0097d2)
U 14 (#2119c1)
L 4 (#08d842)
U 10 (#45a973)
L 7 (#57dd02)
D 4 (#2b7753)
L 5 (#57dd00)
D 4 (#5749f3)
L 2 (#2bed82)
D 14 (#2b0963)
L 6 (#35ecd2)
D 6 (#0f0de3)
L 3 (#25f2e2)
U 13 (#133bc3)
L 10 (#2c7a02)
U 3 (#11a973)
L 9 (#2078f0)
U 12 (#4065c3)
L 11 (#2078f2)
U 9 (#4c4583)
L 4 (#198d02)
U 5 (#6b4fa1)
L 7 (#38d972)
U 9 (#4640d1)
L 4 (#182aa2)
D 11 (#0f0de1)
L 2 (#097592)
D 8 (#2fcc43)
L 5 (#3d86b2)
U 12 (#3e7893)
L 3 (#136362)
U 7 (#6c9833)
L 7 (#345b42)
U 3 (#425e31)
L 9 (#0a2722)
D 8 (#162461)
L 13 (#4bb4d2)
U 8 (#528e31)
L 4 (#01e2a2)
U 9 (#1117a3)

