use v5.20;
use warnings;
use Time::HiRes qw/usleep/;
use List::Util qw/max min/;

my @pts = ();
my $s = 0;

sub print_grid {
  my %positions = ();
  my @xs = ();
  my @ys = ();
  for (@pts) {
    $positions{$_->[0] . " " . $_->[1]} = 1;
    push @xs, $_->[0];
    push @ys, $_->[1];
  }
   my $x_start = min @xs;
   my $x_end = max @xs;
   my $y_start = min @ys;
   my $y_end = max @ys;
   if ($x_end - $x_start > 100) {
    return;
   }
  usleep(0.1 * 1000000);
  say $s;
  for my $y ($y_start..$y_end) {
    for my $x ($x_start..$x_end) {
      print $positions{$x . " " . $y} ? '#' : '.';
    }
    say "";

  }
}

sub update {
  for (@pts) {
    $_->[0] += $_->[2];
    $_->[1] += $_->[3];
  }
}

while (my $line = <>) {
  my @parts = split /[ ,<>]+/, $line;
  if (@parts > 3) {
    push @pts, [$parts[1], $parts[2], $parts[4], $parts[5]];
  }
}

while (1) {
  print_grid();
  update();
  $s++;
}
