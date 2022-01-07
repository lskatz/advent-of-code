#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests=>2;
use File::Basename qw/dirname/;
use List::Util qw/max min/;

my $example1="acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf";
my $example2="be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
";

my $realData = "";
{
  local $/=undef;
  open(my $fh, dirname($0)."/08.txt") or die $!;
  $realData = <$fh>;
  chomp($realData);
}

subtest "Test for mixed numbers $0" => sub{
  my $entries = readData($example1);
  my $num     = translate($entries);
  is($num, 0, "number of 1,4,7,8");

  my $entries2 = readData($example2);
  my $num2     = translate($entries2);
  is($num2, 26, "number of 1,4,7,8");
};
subtest "Real for mixed numbers $0" => sub{
  my $entries = readData($realData);
  my $num     = translate($entries);
  is($num, 514, "number of 1,4,7,8");
};

sub translate{
  my($entries) = @_;

  # Map the number of segments to the digit
  my %segmentCount = (
    "0" => 6,
    "1" => 2,
    "2" => 5,
    "3" => 5,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 3,
    "8" => 7,
    "9" => 6,
  );
  my %countToSegment = (
    2 => 1,
    4 => 4,
    3 => 7,
    7 => 8,
  );

  my $numEasyDigits = 0;
  for my $e(@$entries){
    my @translation;
    for my $encoded(@{ $$e{output} }){
      my $numSegments = length($encoded);
      
      if(defined $countToSegment{$numSegments}){
        push(@translation, $countToSegment{$numSegments});
        $numEasyDigits++;
      } else {
        push(@translation, undef);
      }
    }
  }
  return $numEasyDigits;
}

sub readData{
  my($data) = @_;
  chomp($data);

  my @entry;
  for my $signalPattern(split(/\n/, $data)){
    next if($signalPattern =~ /^\s*$/);
    my($input, $output) = split(/\s*\|\s*/, $signalPattern);
    my @input = split(/\s+/, $input);
    my @output= split(/\s+/, $output);
    push(@entry, {
        input => \@input,
        output=> \@output,
    });
  }
    
  return \@entry;
}

