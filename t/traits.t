use strict;
use warnings;
use Class::Lambda;
use Test::More;

ok my $class_point = Class::Lambda::new_class(
  'Point',
  {
    x => undef,
    y => undef,
  },
  {
    to_string => sub { "x: $_[0]->{x}, y: $_[0]->{y}" },
    x         => sub { shift->{x} },
    y         => sub { shift->{y} },
  }),
  'creates a Point class';

ok my $trait_sum = Class::Lambda::new_trait('Sum', { sum => sub {
      my $self = shift;
      $self->{x} + $self->{y}; } }, ['x','y']),
   'create Sum trait';

is $trait_sum->('name'), 'Sum', 'name returns the trait name';
is join(',', $trait_sum->('requires')), 'x,y', 'requires x & y methods';
$class_point->('compose', $trait_sum);
is scalar $class_point->('traits'), 1, 'adds trait to trait list';
$class_point->('compose', $trait_sum);
is scalar $class_point->('traits'), 1, 'ignores duplicate trait';

ok my $point = $class_point->('new', { x => 1, y => 2 }),
  'creates a Point object';

is $point->('sum'), 3, 'sum returns x + y';

ok my $trait_die = Class::Lambda::new_trait('Die', { foo => sub {} }, ['z']),
  'create Die trait';

eval { $class_point->('compose', $trait_die) };
like $@, qr/^Cannot compose Die as Point is missing: z/,
  'compose dies on missing required method';

done_testing;
