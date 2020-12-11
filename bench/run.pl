use v5.16.0;
use warnings;

package Point;
sub new {
  my ($class, $args) = @_;
  bless {
    x => $args->{x},
    y => $args->{y},
  }, $class;
}

sub set_x {
  my ($self, $x) = @_;
  $self->{x} = $x;
}

sub x { $_[0]->{x} }
sub y { $_[0]->{y} }

package MoosePoint;
use Moose;

has x => (is => 'rw', isa => 'Int');
has y => (is => 'rw', isa => 'Int');

__PACKAGE__->meta->make_immutable;

package main;
use Class::Lambda;
use Benchmark 'cmpthese';

my $class_point = Class::Lambda::new_class(
  'Point',
  {
    x => undef,
    y => undef,
  },
  {
    set_x => sub {
      my ($self, $x) = @_;
      $self->{x} = $x;
    },
    x => sub { $_[0]->{x} },
    y => sub { $_[0]->{y} }});

cmpthese(-5, {
  'moose-new'   => sub { MoosePoint->new({ x => 1, y => 1}) },
  'builtin-new' => sub { Point->new({ x => 1, y => 1}) },
  'lambda-new' => sub { $class_point->('new', { x => 1, y => 1}) }});

my $point = Point->new({ x => 1, y => 1});
my $point_m = MoosePoint->new({ x => 1, y => 1});
my $point_l = $class_point->('new', { x => 1, y => 1});

cmpthese(-5, {
  'moose-get' => sub { $point_m->x },
  'builtin-get' => sub { $point->x },
  'lambda-get' => sub { $point_l->('x') }});

cmpthese(-5, {
  'moose-set' => sub { $point_m->x(5) },
  'builtin-set' => sub { $point->set_x(5) },
  'lambda-set' => sub { $point_l->('set_x', 5) }});
