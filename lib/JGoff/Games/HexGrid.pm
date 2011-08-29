package JGoff::Games::HexGrid;

use Moose;

has cells => ( is => 'rw', isa => 'ArrayRef' );
has cell_size => ( is => 'rw', isa => 'ArrayRef' );

# {{{ _bounding_box( coordinate => [ 2, 3 ] )

sub _bounding_box {
  my $self = shift;
  my %args = @_;

  my @coordinate = @{ $args{coordinate} };

  return if $coordinate[0] > $self->cells->[0];
  return if $coordinate[1] > $self->cells->[1];

  return if $coordinate[0] < 0;
  return if $coordinate[1] < 0;

  my @center = (
    $coordinate[0] * $self->cell_size->[0] +
    $self->cell_size->[0] * 0.5,
    $coordinate[1] * $self->cell_size->[1] * 0.75 +
    $self->cell_size->[1] * 0.5
  );
  $center[0] += $self->cell_size->[0] * 0.5 if $coordinate[1] % 2;

  return (
    $center[0] - $self->cell_size->[0] * 0.5,
    $center[1] - $self->cell_size->[1] * 0.5,
    $self->cell_size->[0],
    $self->cell_size->[1]
  );
}

# }}}

# {{{ _hexagon

sub _hexagon {
  my $self = shift;
  my %args = @_;

  my @coordinate = @{ $args{coordinate} };

  return if $coordinate[0] > $self->cells->[0];
  return if $coordinate[1] > $self->cells->[1];

  return if $coordinate[0] < 0;
  return if $coordinate[1] < 0;

  my @origin = (
    $coordinate[0] * $self->cell_size->[0],
    $coordinate[1] * $self->cell_size->[1] * 0.75
  );
  $origin[0] += $self->cell_size->[0] * 0.5 if $coordinate[1] % 2;

  # + 0
  #  / \
  # 5   1
  # | + |
  # 4   2
  #  \ /
  #   3

  return (
    [ $origin[0] + $self->cell_size->[0] * 0.5,
      $origin[1] ],
    [ $origin[0] + $self->cell_size->[0],
      $origin[1] + $self->cell_size->[1] * 0.25 ],
    [ $origin[0] + $self->cell_size->[0],
      $origin[1] + $self->cell_size->[1] * 0.75 ],
    [ $origin[0] + $self->cell_size->[0] * 0.5,
      $origin[1] + $self->cell_size->[1] ],
    [ $origin[0],
      $origin[1] + $self->cell_size->[1] * 0.75 ],
    [ $origin[0],
      $origin[1] + $self->cell_size->[1] * 0.25 ],
  );

  # + 0---1
  #  /     \
  # 5   +   2
  #  \     /
  #   4---3

#  return (
#    [ $origin[0] + $self->cell_size->[0] * 0.25,
#      $origin[1] ],
#    [ $origin[0] + $self->cell_size->[0] * 0.75,
#      $origin[1] ],
#    [ $origin[0] + $self->cell_size->[0],
#      $origin[1] + $self->cell_size->[1] * 0.5 ],
#    [ $origin[0] + $self->cell_size->[0] * 0.75,
#      $origin[0] + $self->cell_size->[1] ],
#    [ $origin[0] + $self->cell_size->[0] * 0.25,
#      $origin[0] + $self->cell_size->[1] ],
#    [ $origin[0],
#      $origin[1] + $self->cell_size->[1] * 0.5 ],
#  );
}

# }}}

# {{{ _point_in_poly( polygon => [ ], point => [ 1, 72 ] )

sub _point_in_poly {
  my $self = shift;
  my %args = @_;

  my @polygon = @{ $args{polygon} };
  my @point = @{ $args{point} };

  my ( $i, $j, $c ); $c = 0;
  for ( $i = 0, $j = $#polygon; $i < $#polygon ; $j = $i++ ) {
    if ( ( ( $polygon[$i][1] > $point[1] ) != ( $polygon[$j][1] > $point[1] ) ) &&
	 ( $point[0] < ( $polygon[$j][0] - $polygon[$i][0] ) * ( $point[1] - $polygon[$i][1] ) / ( $polygon[$j][1] - $polygon[$i][1] ) + $polygon[$i][0] ) ) {
      $c = $c == 0 ? 1 : 0;
    }
  }

  return $c == 1 ? 1 : undef;

#int pnpoly(int nvert, float *vertx, float *verty, float testx, float testy)
#{
#  for (i = 0, j = nvert-1; i < nvert; j = i++) {
#    if ( ((verty[i]>testy) != (verty[j]>testy)) &&
#	 (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
#       c = !c;
#  }
#  return c;
#}

}

# }}}

=head1 NAME

JGoff::Games::HexGrid::Draw - Draw a hexagonal grid

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use JGoff::Games::HexGrid;

    my $foo = JGoff::Games::HexGrid->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Jeff Goff, C<< <jgoff at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-jgoff-games-hexgrid at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=JGoff-Games-HexGrid>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc JGoff::Games::HexGrid


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=JGoff-Games-HexGrid>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/JGoff-Games-HexGrid>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/JGoff-Games-HexGrid>

=item * Search CPAN

L<http://search.cpan.org/dist/JGoff-Games-HexGrid/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Jeff Goff.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of JGoff::Games::HexGrid
