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

is $class_point->('name'), 'Point', 'class name is Point';

ok my $point = $class_point->('new', { x => 1, y => 2 }),
  'creates a Point object';

is $point->('class')->('name'), 'Point', 'object is of class Point';
is $point->('x'), 1, 'get x';
is $point->('y'), 2, 'get y';
is $point->('to_string'), 'x: 1, y: 2', 'formats string of xy coords';


ok my $class_point3d = $class_point->('subclass',
  'Point3D',
  { z => undef },
  {
    to_string => sub { "x: $_[0]->{x}, y: $_[0]->{y}, z: $_[0]->{z}" },
    z         => sub { shift->{z} },
  }),
  'creates a Point3D class';

is $class_point3d->('name'), 'Point3D', 'class name is Point3D';
is(($class_point3d->('superclass'))[0]->('name'), 'Point',
  'inherits from Point');

ok my $point3d = $class_point3d->('new', { x => 1, y => 2, z => 3 }),
  'creates a Point3D object';

is $point3d->('x'), 1, 'get x';
is $point3d->('z'), 3, 'get z';
is $point3d->('to_string'), 'x: 1, y: 2, z: 3',
  'overridden to_string formats string of xyz coords';

done_testing;
