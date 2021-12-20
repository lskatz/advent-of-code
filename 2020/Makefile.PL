#!/usr/bin/env perl

use strict;
use warnings;
use ExtUtils::MakeMaker;
 
WriteMakefile(
    NAME         => 'lskatz::adventofcode',
    AUTHOR       => q{Lee Katz <gzu2@cdc.gov>},
    VERSION      => '0.1',
    ABSTRACT     => 'Lee Katz answers to adventofcode.com',
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002
        ? ( 'LICENSE' => 'perl' )
        : () ),
    PL_FILES  => {},
    PREREQ_PM => {
      'Math::Round'    => 0,
      'List::Permutor' => 0,
    },
    TEST_REQUIRES => {
          'Test::More'    => 1.001014,
    },
);
