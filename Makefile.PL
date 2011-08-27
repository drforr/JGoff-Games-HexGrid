use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'JGoff::Games::HexGrid',
    AUTHOR              => q{Jeff Goff <jgoff@cpan.org>},
    VERSION_FROM        => 'lib/JGoff/Games/HexGrid.pm',
    ABSTRACT_FROM       => 'lib/JGoff/Games/HexGrid.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Try::Tiny' => 0,
        'Readonly' => 0,
        'SDL' => 0,
        'Moose' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'JGoff-Games-HexGrid-*' },
);
