package JGoff::Games::HexGrid::Draw;

use SDL; # XXX Excise later
use Carp qw( croak );

use Moose;
extends 'JGoff::Games::HexGrid';

# {{{ tile_surface( color => $color, depth => $depth )

sub tile_surface {
  my $self = shift;
  my %args = @_;

  my $color = $args{color};
  my $depth = $args{depth};

  my @bounding_box = $self->_bounding_box( coordinate => [ 0, 0 ] );
  my $tile = SDL::Surface->new(
    0, $bounding_box[2], $bounding_box[3], $depth, 0
  );
  SDL::Video::fill_rect(
    $tile,
    SDL::Rect->new( 0, 0, $tile->w, $tile->h ),
    SDL::Video::map_RGBA( $tile->format(), 0, 0, 0, 0 ),
  );
  my $mapped = SDL::Video::map_RGBA( $tile->format(), @$color );
  $self->fill_hexagon(
    coordinate => [ 0, 0 ],
    surface => $tile,
    color => $mapped
  );
  return $tile;
}

# }}}

# {{{ draw_bounding_box( coordinate => .., surface => .., color => .. )

sub draw_bounding_box {
  my $self = shift;
  my %args = @_;

  my @coordinate = @{ $args{coordinate} };
  my $surface = $args{surface};
  my $color = $args{color};

  my @bounding_box = $self->_bounding_box( coordinate => \@coordinate );
  return unless @bounding_box;

  $self->_bresenham_polygon(
    points => [
      [ $bounding_box[0], $bounding_box[1] ],
      [ $bounding_box[0] + $bounding_box[2], $bounding_box[1] ],
      [ $bounding_box[0] + $bounding_box[2],
        $bounding_box[1] + $bounding_box[3] ],
      [ $bounding_box[0], $bounding_box[1] + $bounding_box[3] ]
    ],
    surface => $surface,
    color => $color
  );
}

# }}}

# {{{ draw_hexagon( coordinate => .., surface => .., color => .. )

sub draw_hexagon {
  my $self = shift;
  my %args = @_;

  my @coordinate = @{ $args{coordinate} };
  my $surface = $args{surface};
  my $color = $args{color};

  my @hexagon = $self->_hexagon( coordinate => \@coordinate );
  return unless @hexagon;

  $self->_bresenham_polygon(
    points => \@hexagon,
    surface => $surface,
    color => $color
  );
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
    if ( ( ( $polygon[$i][1] > $point[1] ) !=
           ( $polygon[$j][1] > $point[1] ) ) &&
	 ( $point[0] < ( $polygon[$j][0] - $polygon[$i][0] ) *
                       ( $point[1] - $polygon[$i][1] ) /
                       ( $polygon[$j][1] - $polygon[$i][1] ) + $polygon[$i][0] ) ) {
      $c = $c == 0 ? 1 : 0;
    }
  }

  return $c == 1 ? 1 : undef;
}

# }}}

# {{{ fill_hexagon( coordinate => .., surface => .., color => .. )

sub fill_hexagon {
  my $self = shift;
  my %args = @_;

  my @coordinate = @{ $args{coordinate} };
  my $surface = $args{surface};
  my $color = $args{color};

  my @bounding_box = $self->_bounding_box( coordinate => \@coordinate );
  return unless @bounding_box;
  my @hexagon = $self->_hexagon( coordinate => \@coordinate );
  return unless @hexagon;

  for my $x ( $bounding_box[0] .. $bounding_box[0] + $bounding_box[2] ) {
    for my $y ( $bounding_box[1] .. $bounding_box[1] + $bounding_box[3] ) {
      next unless $self->_point_in_poly(
        polygon => \@hexagon,
        point => [ $x, $y ]
      );
      $surface->set_pixels( $x + $y * $surface->w, $color ); 
    }
  }
}

# }}}

# {{{ draw_actor( coordinate => .., surface => .., color => .. )

sub draw_actor {
  my $self = shift;
  my %args = @_;

  my @coordinate = @{ $args{coordinate} };
  my $surface = $args{surface};
  my $color = $args{color};

  return if $coordinate[0] > $self->cells->[0];
  return if $coordinate[1] > $self->cells->[1];

  return if $coordinate[0] < 0;
  return if $coordinate[1] < 0;

  my @center = (
    $coordinate[0] * $self->cell_size->[0] +
    $self->cell_size->[0] * 0.5,
    $coordinate[1] * $self->cell_size->[1] * 0.75 +
    $self->cell_size->[1] * 0.5,
  );
  $center[0] += $self->cell_size->[0] * 0.5 if $coordinate[1] % 2;

  $self->_bresenham_line(
    x0 => $center[0] - 4,
    y0 => $center[1],
    x1 => $center[0] + 4,
    y1 => $center[1],
    surface => $surface,
    color => $color,
  );
  $self->_bresenham_line(
    x0 => $center[0],
    y0 => $center[1] - 4,
    x1 => $center[0],
    y1 => $center[1] + 4,
    surface => $surface,
    color => $color,
  );
}

# }}}

# {{{ draw( surface => $surface, color => $color, viewport => $vp )

sub draw {
  my $self = shift;
  my %args = @_;

  my $surface = $args{surface};
  my $color = $args{color};

  my @cells = @{ $self->cells };
  my @cell_size = @{ $self->cell_size };
  
  #   +
  #  / \
  # +   +

  my @top_border =
    (
      [
        0,
        $cell_size[1] * 0.25
      ]
    );
  for my $x ( 0 .. $cells[0] - 1 ) {
    push @top_border, (
      [
        $x * $cell_size[0] + $cell_size[0] * 0.5,
        0,
      ],
      [
        ( $x + 1 ) * $cell_size[0],
        $cell_size[1] * 0.25
      ]
    );
  }

  # +   +
  #  \ /
  #   +

  my @bottom_border = ();
  for my $x ( 0 .. $cells[0] - 1 ) {
    my $top = $cells[1] * $cell_size[1] * 0.75;
    push @bottom_border, (
      [
        $x * $cell_size[0] + $cell_size [0] * 0.5,
        $top
      ],
      [
        ( $x + 1 ) * $cell_size[0],
        $top + $cell_size[1] * 0.25
      ],
    );
  }

  # +
  # |
  # +
  #  \
  #   +
  #   |
  #   +
  #  /
  # +

  my @right_border = (
  );

  for my $y ( 0 .. int( ( $cells[1] - 1 ) / 2 ) ) {
    my $top = $y * $cell_size[1] * 1.5;
    my $bottom = ( $y + 1 ) * $cell_size[1] * 1.5;
    push @right_border, (
      [
        $cells[0] * $cell_size[0],
        $top + $cell_size[1] * 0.25
      ],
      [
        $cells[0] * $cell_size[0],
        $top + $cell_size[1] * 0.75
      ],
      [
        $cells[0] * $cell_size[0] + $cell_size[0] * 0.5,
        $top + $cell_size[1]
      ],
      [
        $cells[0] * $cell_size[0] + $cell_size[0] * 0.5,
        $bottom
      ],
      [
        $cells[0] * $cell_size[0],
        $bottom + $cell_size[1] * 0.25
      ],
    )
  }

  my @left_border = (
  );

  for my $y ( 0 .. int( ( $cells[1] - 1 ) / 2 ) ) {
    my $top = $y * $cell_size[1] * 1.5;
    my $bottom = ( $y + 1 ) * $cell_size[1] * 1.5;
    push @left_border, (
      [
        0,
        $top + $cell_size[1] * 0.25
      ],
      [
        0,
        $top + $cell_size[1] * 0.75
      ],
      [
        $cell_size[0] * 0.5,
        $top + $cell_size[1]
      ],
      [
        $cell_size[0] * 0.5,
        $bottom
      ],
      [
        0,
        $bottom + $cell_size[1] * 0.25
      ],
    )
  }
  pop @left_border;

  #   +
  #  / \
  # +    +
  # |    |
  # +    +
  #     / \
  #    +   +
  #        |
  #        +

  for my $x ( 0 .. $cells[0] - 1 ) {
    for my $y ( 0 .. int( ( $cells[1] - 1 ) / 2 ) ) {
      my $top = $y * $cell_size[1] * 1.5;
      my $bottom = ( $y + 1 ) * $cell_size[1] * 1.5;
      my @points = (
        [
          ( $x + 1 ) * $cell_size[0],
          $top + $cell_size[1] * 0.25
        ],
        [
          ( $x + 1 ) * $cell_size[0],
          $top + $cell_size[1] * 0.75
        ],
        [
          ( $x * $cell_size[0] ) + $cell_size[0] * 0.5,
          $top + $cell_size[1]
        ],
      );
      $self->_bresenham_polyline(
        points => \@points,
        surface => $surface,
        color => $color
      );
      @points = (
        [
          ( $x + 1 ) * $cell_size[0],
          $top + $cell_size[1] * 0.75
        ],
        [
          ( $x * $cell_size[0] ) + $cell_size[0] * 1.5,
          $top + $cell_size[1]
        ],
        [
          ( $x * $cell_size[0] ) + $cell_size[0] * 1.5,
          $bottom
        ],
        [
          ( $x * $cell_size[0] ) + $cell_size[0],
          $bottom + $cell_size[1] * 0.25
        ],
        [
          ( $x * $cell_size[0] ) + $cell_size[0] * 0.5,
          $bottom
        ],
      );
      $self->_bresenham_polyline(
        points => \@points,
        surface => $surface,
        color => $color
      );
    }
  }

  $self->_bresenham_polyline(
    points => \@top_border,
    surface => $surface,
    color => $color
  );

  $self->_bresenham_polyline(
    points => \@left_border,
    surface => $surface,
    color => $color
  );
}

# }}}

# {{{ _wu_line( surface => $surface, x1 => $x1, .. color => $color )

sub _ipart { return int( $_[0] ) }
sub _round { return _ipart( $_[0] + 0.5 ) }
sub _fpart { return abs( $_[0] ) - int( abs( $_[0] ) ) }
sub _rfpart { return 1 - _fpart( $_[0] ) }

sub _wu_line {
  my $self = shift;
  my %args = @_;

  my $surface = $args{surface};
  my $x0 = $args{x0};
  my $y0 = $args{y0};
  my $x1 = $args{x1};
  my $y1 = $args{y1};
  my $color = $args{color};

  my $dx = $x1 - $x0;
  my $dy = $y1 - $y0;

  my $plot_reversed;
  if ( abs( $dx ) < abs( $dy ) ) {
    $plot_reversed = 1;
  }

  if ( abs( $dx ) < abs( $dy ) ) {
    ( $x0, $y0 ) = ( $y0, $x0 ); #swap x0, y0
    ( $x1, $y1 ) = ( $y1, $x1 ); #swap x1, y1
    ( $dx, $dy ) = ( $dy, $dx ); #swap dx, dy
  }
  if ( $x1 < $x0 ) {
    ( $x0, $x1 ) = ( $x1, $x0 ); #swap x0, x1
    ( $y0, $y1 ) = ( $y1, $y0 ); #swap y0, y1
  }
  my $gradient = $dy / $dx;
    
  # handle first endpoint
  my $xend = _round( $x0 );
  my $yend = $y0 + $gradient * ( $xend - $x0 );
  my $xgap = _rfpart( $x0 + 0.5 );
  my $xpxl1 = $xend;  # this will be used in the main loop
  my $ypxl1 = _ipart( $yend );
my $aopaque = ( _rfpart($yend) * $xgap ) * 256;
my $bopaque = ( _fpart($yend) * $xgap ) * 256;
my $acolor = SDL::Video::map_RGBA( $surface->format(), 0, 0, 255, $aopaque );
my $bcolor = SDL::Video::map_RGBA( $surface->format(), 0, 0, 255, $bopaque );
#   plot($xpxl1, $ypxl1, _rfpart($yend) * $xgap);
#   plot($xpxl1, $ypxl1 + 1, _fpart($yend) * $xgap);
  if ( $plot_reversed ) {
    $surface->set_pixels( $ypxl1 + $xpxl1 * $surface->w, $acolor ); 
    $surface->set_pixels( ( $ypxl1 + 1 ) + $xpxl1 * $surface->w, $bcolor ); 
  }
  else {
    $surface->set_pixels( $xpxl1 + $ypxl1 * $surface->w, $acolor ); 
    $surface->set_pixels( $xpxl1 + ( $ypxl1 + 1 ) * $surface->w, $bcolor ); 
  }
  my $intery = $yend + $gradient; # first y-intersection for the main loop
    
  # handle second endpoint
  $xend = _round( $x1 );
  $yend = $y1 + $gradient * ( $xend - $x1 );
  $xgap = _fpart( $x1 + 0.5 );
  my $xpxl2 = $xend; # this will be used in the main loop
  my $ypxl2 = _ipart ( $yend );
$aopaque = ( _rfpart($yend) * $xgap ) * 256;
$bopaque = ( _fpart($yend) * $xgap ) * 256;
$acolor = SDL::Video::map_RGBA( $surface->format(), 0, 0, 255, $aopaque );
$bcolor = SDL::Video::map_RGBA( $surface->format(), 0, 0, 255, $bopaque );
#  plot ($xpxl2, $ypxl2, _rfpart ($yend) * $xgap);
#  plot ($xpxl2, $ypxl2 + 1, _fpart ($yend) * $xgap);
  if ( $plot_reversed ) {
    $surface->set_pixels( $ypxl2 + $xpxl2 * $surface->w, $acolor ); 
    $surface->set_pixels( ( $ypxl2 + 1) + $xpxl2 * $surface->w, $acolor ); 
  }
  else {
    $surface->set_pixels( $xpxl2 + $ypxl2 * $surface->w, $acolor ); 
    $surface->set_pixels( $xpxl2 + ( $ypxl2 + 1 ) * $surface->w, $bcolor ); 
  }
    
  # main loop
  for my $x ( $xpxl1 + 1 .. $xpxl2 - 1 ) {
$aopaque = _rfpart($intery) * 256;
$bopaque = _fpart($intery) * 256;
$acolor = SDL::Video::map_RGBA( $surface->format(), 0, 0, 255, $aopaque );
$bcolor = SDL::Video::map_RGBA( $surface->format(), 0, 0, 255, $bopaque );
#    plot ($x, _ipart ($intery), _rfpart ($intery))
#    plot ($x, _ipart ($intery) + 1, _fpart ($intery))
    if ( $plot_reversed ) {
      $surface->set_pixels( _ipart ( $intery ) + $x * $surface->w, $acolor ); 
      $surface->set_pixels( ( _ipart ( $intery ) + 1 ) + $x * $surface->w, $bcolor ); 
    }
    else {
      $surface->set_pixels( $x + _ipart ( $intery ) * $surface->w, $acolor ); 
      $surface->set_pixels( $x + ( _ipart ( $intery ) + 1 ) * $surface->w, $bcolor ); 
    }
    $intery = $intery + $gradient;
  }
}

# }}}

# {{{ _bresenham_line( surface => $surface, x1 => $x1, .. color => $color )

sub _bresenham_line {
  my $self = shift;
  my %args = @_;

  my $surface = $args{surface};
  my $x0 = $args{x0};
  my $y0 = $args{y0};
  my $x1 = $args{x1};
  my $y1 = $args{y1};
  my $color = $args{color};

  croak "*** Starting X left of surface!" unless
    $x0 >= 0;
  croak "*** Starting X right of surface!" unless
    $x0 < $surface->w;
  croak "*** Starting Y above surface!" unless
    $y0 >= 0;
  croak "*** Starting Y below surface!" unless
    $y0 < $surface->h;

  croak "*** Ending X left of surface!" unless
    $x1 >= 0;
  croak "*** Ending X right of surface!" unless
    $x1 < $surface->w;
  croak "*** Ending Y above surface!" unless
    $y1 >= 0;
  croak "*** Ending Y below surface!" unless
    $y1 < $surface->h;

  my $dx = abs( $x1 - $x0 );
  my $dy = abs( $y1 - $y0 );
  my $sx = $x0 < $x1 ? 1 : -1;
  my $sy = $y0 < $y1 ? 1 : -1;
  my $err = $dx-$dy;

  while ( 1 ) {
    $surface->set_pixels( $x0 + $y0 * $surface->w, $color ); 
    last if $x0 == $x1 and $y0 == $y1;
    my $e2 = 2*$err;
    if ( $e2 > -$dy ) {
      $err = $err - $dy;
      $x0 = $x0 + $sx;
    }
    if ( $e2 < $dx ) {
      $err = $err + $dx;
      $y0 = $y0 + $sy;
    }
  }
}

# }}}

# {{{ _bresenham_polyline( surface => $surface, points => [ .. ], color => $color )

sub _bresenham_polyline {
  my $self = shift;
  my %args = @_;

  my $surface = $args{surface};
  my @points = @{ $args{points} };
  my $color = $args{color};

  for my $idx ( 0 .. $#points - 1 ) {
    $self->_bresenham_line(
      x0 => $points[$idx][0],
      y0 => $points[$idx][1],
      x1 => $points[$idx+1][0],
      y1 => $points[$idx+1][1],
      surface => $surface,
      color => $color
    );
  }
}

# }}}

# {{{ _bresenham_polygon( surface => $surface, vertices => [ .. ], color => $color )

sub _bresenham_polygon {
  my $self = shift;
  my %args = @_;

  my $surface = $args{surface};
  my @points = @{ $args{points} };
  my $color = $args{color};

  $self->_bresenham_polyline(
    points => \@points,
    surface => $surface,
    color => $color
  );
  $self->_bresenham_line(
    x0 => $points[$#points][0],
    y0 => $points[$#points][1],
    x1 => $points[0][0],
    y1 => $points[0][1],
    surface => $surface,
    color => $color
  );
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
