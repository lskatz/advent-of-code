#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests=>2;
use constant PI => 3.14159265358979;

sub deg2rad {
    my $degrees = shift;
    return ($degrees / 180) * PI;
}

sub rad2deg {
    my $radians = shift;
    return ($radians / PI) * 180;
}

subtest 'sample data' => sub{
  my $input="
    F10
    N3
    F7
    R90
    F11
  ";
  
  my $exp = 25;
  my $distance = moveShip($input);
  is($distance, $exp, "manhattan distance");
};

subtest 'real data' => sub{
  local $/= undef;
  my $input = <DATA>;
  my $exp = 1589;
  my $distance = moveShip($input);
  is($distance, $exp, "manhattan distance");
};

sub moveShip{
  my($input) = @_;

  # initial coordinates
  my $x = 0;
  my $y = 0;

  # initial direction: east
  my $degrees = 0;
  my $dx = cos(deg2rad($degrees));
  my $dy = sin(deg2rad($degrees));

  my @instruction = grep{/./} split(/\s*\n\s*/,$input);
  for (@instruction){
    my $cmd = substr($_,0,1);
    my $int = substr($_,1);
    
    # Move north by a given value
    if($cmd eq 'N'){
      $y += $int;
    }
    elsif($cmd eq 'S'){
      $y -= $int;
    }
    elsif($cmd eq 'E'){
      $x += $int;
    }
    elsif($cmd eq 'W'){
      $x -= $int;
    }
    # L means to turn counterclockwise by given number
    # of degrees
    elsif($cmd eq 'L'){
      $degrees += $int;
      $dx = cos(deg2rad($degrees));
      $dy = sin(deg2rad($degrees));
    }
    elsif($cmd eq 'R'){
      $degrees -= $int;
      $dx = cos(deg2rad($degrees));
      $dy = sin(deg2rad($degrees));
    }
    # F means to move forward
    elsif($cmd eq 'F'){
      $x += $dx * $int;
      $y += $dy * $int;
    }
    else{
      BAIL_OUT("I do not understand $cmd");
    }

    # avoid rounding errors from sin/cos
    for($x,$y,$dx,$dy,$degrees){
      $_ = int($_);
    }
    
    #note "facing $dx/$dy and am at $x,$y";
  }

  my $manhattan = abs($x) + abs($y);
  return $manhattan;
}

__DATA__
R180
S4
L90
S2
R90
W3
F30
R90
W3
L90
F68
L90
E5
F88
S1
L90
F46
W5
F51
S2
L90
F53
S5
F19
W2
L90
F91
E2
S3
F83
N5
F79
W1
S3
F11
E4
F53
W4
S5
R90
E1
F76
R90
F47
E5
R90
W3
R90
S5
L180
W5
N4
F10
S2
R90
S4
W4
F29
S5
F34
E2
S4
R90
F73
N2
F43
W1
N4
R90
S3
F26
S5
W1
N5
R90
W3
F29
R90
W4
F81
R90
E5
S4
W1
F73
N2
E1
F66
L90
E4
S4
E3
N2
F34
L90
W1
F13
S4
E2
F21
N5
E5
N2
F65
L90
N3
R270
F49
E5
L90
E5
R90
F20
S4
F99
W3
N2
E5
L90
F94
R90
S2
R90
S3
F47
S3
R90
F71
W1
R90
N4
E5
S1
F72
L90
F18
E5
F94
L270
F80
W5
R180
N1
F40
R180
N1
E3
N5
F29
R90
E1
R90
E3
L180
E3
R90
S2
L90
E3
L180
F80
E2
S5
E1
N2
L180
F25
N2
L90
F66
R90
F48
N3
L180
N3
R90
E5
R90
F52
R180
S5
L270
S4
L90
F53
S4
W3
W4
F36
W2
N2
N4
L90
W1
R90
E4
F30
N5
W1
S2
W5
F98
W1
N1
F92
L180
N2
R90
S4
L90
F66
N3
L90
F33
W2
S2
E4
F8
W2
L180
F15
S1
E1
F14
S1
W2
L270
F86
E1
R180
W5
R90
N3
L90
N5
E1
F78
N1
L90
F1
F73
R90
F68
W4
F79
F34
N5
R180
E5
L180
S3
W5
F27
R180
F70
R90
S4
F62
L180
N3
R90
S5
F4
R90
S5
W2
N5
R90
F81
L90
N1
F32
E2
N1
W2
L180
E5
R180
S3
E3
R90
S3
F1
N5
E3
F60
W2
F58
L180
S2
E3
L90
F36
L90
E4
E1
F29
W2
R90
R180
N3
L90
R180
S5
W1
F13
R90
W5
S2
R180
F16
W4
L90
W2
S5
F25
R90
F40
L90
L90
F76
S2
R180
N2
R180
W4
S5
F61
N4
E1
F57
E5
F72
W4
F61
R90
S4
F52
W2
N1
F30
L90
F59
N1
L90
W2
N2
F51
E5
F16
S1
W3
L90
F92
E3
N2
F22
L180
N3
F10
E4
N2
F43
R90
F99
S3
R180
E1
S1
W2
L180
F56
N3
F6
N4
F21
L90
N4
L180
N4
F15
E5
S3
W1
F57
E3
S4
W3
L90
S3
L90
F41
E1
S5
L90
F63
N4
F89
F57
S1
L90
S4
L180
F96
L180
N5
E4
L90
E1
S1
F77
S3
L90
E4
L90
E5
L90
N3
L180
S1
N2
L90
N3
R90
F45
R180
F57
N3
R90
E4
L180
F37
L90
W2
R90
S1
R90
N3
F77
W5
F80
S1
S5
R90
N5
E5
S3
L270
F15
L180
W5
F48
E1
L180
S4
E1
S4
W5
F76
S1
E1
S1
F55
L90
F70
R180
R90
E4
R90
S3
E2
S3
F84
S4
W3
F100
R90
S1
L90
F37
W4
F3
R180
N3
R90
L90
W2
F28
R270
N5
R180
S2
E4
F54
L90
W5
R90
F79
N3
R90
F34
W1
N3
F76
W3
F2
W1
L90
R90
F72
N1
E3
F79
W1
L90
F8
E4
F87
E2
F4
S3
L90
F100
F94
E4
R270
S1
E2
F70
E4
L90
S2
W5
L90
S5
W2
S2
W5
F19
E2
E1
F62
L90
F55
E3
R180
F74
S3
W2
F66
L180
F32
W5
F66
W1
F48
S3
R90
N5
W2
N2
F18
E3
F41
L90
N4
F56
L90
R90
F42
R90
S3
L90
E2
S2
F7
W3
N5
L180
L90
L90
N5
L90
W4
F82
W2
F68
S1
E3
S2
F87
L90
F93
L90
F16
L90
S4
L90
N3
E2
R90
S2
R180
F94
W1
S3
F68
S2
F70
S3
W4
F29
E5
R180
S2
F63
L180
F65
R90
W1
F64
E1
L180
L90
S5
F65
L90
N3
N4
L270
S1
E2
S3
W3
N1
E5
F16
E2
L90
N1
L90
E1
S4
W2
R180
F27
N1
R180
E2
L90
F20
N1
W3
N1
R90
W5
R90
E3
S2
F48
N1
R180
N3
W1
S4
F92
S3
R90
S5
E1
W5
R90
S2
W1
L90
R180
E3
N3
E1
R180
E4
L90
E5
L90
W3
L270
E1
S5
W5
L180
W3
S2
F16
W5
S4
R90
N3
L90
N4
F43
N2
F83
S2
W5
F58
W4
N5
R180
E3
F81
L90
F61
L90
W4
F41
E3
N2
F74
R90
F6
R90
W1
F18
R90
R90
N2
F87
S4
F16
S3
E3
F67
R90
E2
L90
S4
R90
F5
W1
R90
W4
F54
S1
W1
F100
S5
E2
L90
W3
F61
L180
W2
S3
F68
F35
N3
R180
E4
R270
S5
E4
L180
S3
R90
N5
E4
F60
W4
S1
L90
L180
N5
L180
W3
S1
E3
S1
N2
E4
R180
N4
F7
N3
W4
F89
N4
E3
L90
F97

