#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'JGoff::Games::HexGrid' ) || print "Bail out!\n";
}

diag( "Testing JGoff::Games::HexGrid $JGoff::Games::HexGrid::VERSION, Perl $], $^X" );
