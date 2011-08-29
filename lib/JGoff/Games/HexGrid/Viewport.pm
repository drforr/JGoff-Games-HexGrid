package JGoff::Games::HexGrid::Viewport;

use Moose;

has world => ( is => 'rw', isa => 'ArrayRef' ); # W H
has viewport => ( is => 'rw', isa => 'ArrayRef' ); # X Y W H
#
# X Y (relative to viewport)
#
has cursor => ( is => 'rw', isa => 'ArrayRef', default => sub { [ 0, 0 ] } );

# {{{ center

sub center {
  my $self = shift;

  $self->viewport->[0] =
    int( ( $self->world->[0] - $self->viewport->[2] ) / 2 );
  $self->viewport->[1] =
    int( ( $self->world->[1] - $self->viewport->[3] ) / 2 );

  $self->cursor->[0] = int( $self->viewport->[2] / 2 );
  $self->cursor->[1] = int( $self->viewport->[3] / 2 );
}

# }}}

# {{{ move( direction => $direction )
#
#  i     o
#   5   0
#    \ /
# j4--*--1l
#    / \
#   3   2
#  m     ,
#
sub move {
  my $self = shift;
  my %args = @_;
  my $direction = $args{direction};

  if ( $direction == 0 ) {
    if ( $self->viewport->[1] + $self->viewport->[3] < $self->world->[1] ) {
      if ( $self->cursor->[1] < $self->viewport->[1] / 2 ) {
        $self->cursor->[1]--;
        $self->cursor->[0]++ unless $self->cursor->[1] % 2
      }
      else {
        $self->viewport->[1]--;
        $self->viewport->[0]++ unless $self->viewport->[1] % 2
      }
    }
    else {
      $self->cursor->[1]--;
      $self->cursor->[0]++ unless $self->cursor->[1] % 2
    }
  }
  elsif ( $direction == 1 ) { # XXX
    if ( $self->viewport->[0] + $self->viewport->[2] < $self->world->[0] ) {
      if ( $self->cursor->[0] < int( $self->viewport->[2] / 2 ) ) {
        $self->cursor->[0]++
      }
      else {
        $self->viewport->[0]++
      }
    }
    else {
      $self->cursor->[0]++
    }
  }
  elsif ( $direction == 2 ) {
    if ( $self->viewport->[1] + $self->viewport->[3] < $self->world->[1] ) {
      if ( $self->cursor->[1] < int( $self->viewport->[1] / 2 ) ) {
        $self->cursor->[1]++;
        $self->cursor->[0]++ unless $self->cursor->[1] % 2
      }
      else {
        $self->viewport->[1]++;
        $self->viewport->[0]++ unless $self->viewport->[1] % 2
      }
    }
    else {
      $self->cursor->[1]++;
      $self->cursor->[0]++ unless $self->cursor->[1] % 2
    }
  }
  elsif ( $direction == 3 ) {
    if ( $self->viewport->[1] + $self->viewport->[3] < $self->world->[1] ) {
      if ( $self->cursor->[1] < int( $self->viewport->[1] / 2 ) ) {
        $self->cursor->[1]++;
        $self->cursor->[0]-- if $self->cursor->[1] % 2
      }
      else {
        $self->viewport->[1]++;
        $self->viewport->[0]-- if $self->viewport->[1] % 2
      }
    }
    else {
      $self->cursor->[1]++;
      $self->cursor->[0]-- if $self->cursor->[1] % 2
    }
  }
  elsif ( $direction == 4 ) { # XXX
    if ( $self->viewport->[0] > 0 ) {
      if ( $self->cursor->[0] > int( $self->viewport->[2] / 2 ) ) {
        $self->cursor->[0]--
      }
      else {
        $self->viewport->[0]--
      }
    }
    else {
      $self->cursor->[0]--
    }
  }
  elsif ( $direction == 5 ) {
    if ( $self->viewport->[1] + $self->viewport->[3] < $self->world->[1] ) {
      if ( $self->cursor->[1] < int( $self->viewport->[1] / 2 ) ) {
        $self->cursor->[1]--;
        $self->cursor->[0]-- if $self->cursor->[1] % 2
      }
      else {
        $self->viewport->[1]--;
        $self->viewport->[0]-- if $self->viewport->[1] % 2
      }
    }
    else {
      $self->cursor->[1]--;
      $self->cursor->[0]-- if $self->cursor->[1] % 2
    }
  }

  $self->viewport->[0] = 0 if $self->viewport->[0] < 0;
  $self->viewport->[1] = 0 if $self->viewport->[1] < 0;
}

# }}}

1; # End of JGoff::Games::HexGrid::Viewport
