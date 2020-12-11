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

$class_point->('before', 'x', sub { shift->{x} += 10 });
$class_point->('after', 'x', sub { shift->{x} += 5 });

ok my $point = $class_point->('new', { x => 1, y => 2 }),
  'creates a Point object';

is $point->('x'), 16, 'before & after increases x\'s value';

done_testing;
