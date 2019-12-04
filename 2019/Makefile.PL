use strict;
use warnings;
 
use 5.010;
 
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mashtree',
  #VERSION_FROM => 'lib/Mashtree.pm',
  #ABSTRACT_FROM => 'lib/Mashtree.pm',
  #ABSTRACT_FROM => 'README.md',
  AUTHOR => q{Lee S. Katz <gzu2@cdc.gov>},
  EXE_FILES    => [
  ],
  PREREQ_PM    => {
    # Core modules
    'Data::Dumper'   => 0,
  },
  BUILD_REQUIRES => {
    'Test::More'     => 0.47,
  },
  MIN_PERL_VERSION => '5.16.1',
  LICENSE          => "gpl_3",
  dist=>{
    COMPRESS => "gzip -9f",
    SUFFIX   => "gz",
  },
  META_MERGE => {
    'meta-spec' => { version => 2 },
    resources => {
      repository => {
        type => 'git',
        url => 'git://github.com/lskatz/advent-of-code',
        web => 'https://github.com/lskatz/advent-of-code',
      },
    },
  },
);

