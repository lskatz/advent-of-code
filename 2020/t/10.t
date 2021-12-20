#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;

subtest 'sample data' => sub{
  plan tests=>4;

  my @adapters = qw(16 10 15 5 1 11 7 19 6 12 4);
  
  # seven counts of a 1 differene and five counts of a 3 difference
  my $expDifferences = {1=>7, 3=>5}; 

  my $differencesCount = connectAdapters(\@adapters);
  is_deeply($differencesCount, $expDifferences, "differences count");
  is($$differencesCount{1} * $$differencesCount{3}, 35, "Product of 1s and 3s");

  my @adapters2= qw(28 33 18 42 31 14 46 20 48 47 24 23 49 45 19 38 39 11 1 32 25 35 8 17 7 9 4 2 34 10 3);
  my $expDifferences2= {1=>22, 3=>10};
  my $differencesCount2= connectAdapters(\@adapters2);
  is_deeply($differencesCount2,$expDifferences2, "second differences count");
  is($$differencesCount2{1} * $$differencesCount2{3}, 220, "Product of 1s and 3s");
};

subtest 'real data' => sub{
  my @adapters = <DATA>;
  chomp(@adapters);
  my $d = connectAdapters(\@adapters);
  is($$d{1} * $$d{3}, 2450, "Product of 1s and 3s");
};

sub connectAdapters{
  my($adapters) = @_;

  my %diffs;

  # sort the adapters
  my @a = sort{$a<=>$b} @$adapters;

  my $currJolt = 0;
  for(my $i=0;$i<@a;$i++){
    my $diff = $a[$i] - $currJolt;
    #note "$diff = $a[$i] -$currJolt";
    $diffs{$diff}++;
    $currJolt = $a[$i];
  }

  # add on my last adapter which has a jolt+3 always
  $diffs{3}++;

  return \%diffs;
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
