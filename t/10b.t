#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use List::Util qw/max/;
use Algorithm::Combinatorics qw/combinations/;
use POSIX qw/floor ceil/;

subtest 'sample data' => sub{
  my @adapters = qw(16 10 15 5 1 11 7 19 6 12 4);
  my $exp = 8;

  my $count = countCombinations(\@adapters);
  is($count, $exp, "first set of adapters") || 
    BAIL_OUT("did not pass first test");

  my @adapters2 = qw(28 33 18 42 31 14 46 20 48 47 24 23 49 45 19 38 39 11 1 32 25 35 8 17 7 9 4 2 34 10 3);
  my $count2 = countCombinations(\@adapters2);
  is($count2, 19208, "second set of adapters");
};

subtest 'real data' => sub{
  my @adapters = <DATA>;
  chomp(@adapters);
  my $exp = 32396521357312;

  my $count = countCombinations(\@adapters);
  is($count, $exp);
};

# NOTE: I just could not figure out a fast algorithm for this one
# using combinations and so I stole this answer
# https://www.reddit.com/r/adventofcode/comments/ka8z8x/2020_day_10_solutions/gfa6sxe/?utm_source=reddit&utm_medium=web2x&context=3

sub countCombinations{
  my($adapters) = @_;

  # will be the uppermost adapter
  my $upper = 0;
  # adapters index
  my %nodes;

  for (@$adapters){
          chomp;
          $upper = $_ if $_ > $upper;
          $nodes{$_} = 1;
  }

  # Number of 3-diffs starts with our adapter vs highest adapter
  my $t3 = 1;
  # Other counts initialize with zero
  my $t2 = 0;
  my $t1 = 0;
  my $t0;

  # Loop through adapters starting with max adapter
  while ($upper) {
          $t0 = $nodes{$upper} ? $t3+$t2+$t1 : 0;
          $t3 = $t2;
          $t2 = $t1;
          $t1 = $t0;
          $upper--;
  }

  return $t3+$t2+$t1;
}


__DATA__
2
49
78
116
143
42
142
87
132
86
67
44
136
82
125
1
108
123
46
37
137
148
106
121
10
64
165
17
102
156
22
117
31
38
24
69
131
144
162
63
171
153
90
9
107
79
7
55
138
34
52
77
152
3
158
100
45
129
130
135
23
93
96
103
124
95
8
62
39
118
164
172
75
122
20
145
14
112
61
43
141
30
85
101
151
29
113
94
68
58
76
97
28
111
128
21
11
163
161
4
168
157
27
72
