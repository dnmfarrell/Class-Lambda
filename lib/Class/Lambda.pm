package Class::Lambda;
use warnings;
use v5.16.0;

sub new_class {
  my ($class_name, $properties, $methods, $superclass) = @_;
  my $traits = [];

  my $class_methods = {
    superclass => sub { $superclass },
    properties => sub { %$properties },
    subclass   => sub {
      my ($superclass, $class_name, $properties, $methods) = @_;
      $properties   = { $superclass->('properties'), %$properties };
      $methods      = {
      # prevent changes to subclass method changing the super
      (map { ref $_ ? _clone_method($_) : $_ } $superclass->('methods')),
      %$methods };
      new_class($class_name, $properties, $methods, $superclass);
    },
    compose    => sub {
      my ($class, @traits) = @_;
      for my $t (@traits) {
        next if $class->('does', $t->('name'));
        my @missing = grep { !$methods->{$_} } $t->('requires');
        die sprintf('Cannot compose %s as %s is missing: %s',
          $t->('name'), $class_name, join ',', @missing) if @missing;
        my %trait_methods = $t->('methods');
        for my $m (keys %trait_methods) {
          next if exists $methods->{$m}; # clashing methods are excluded
          # prevent changes to composed class method changing the trait
          $methods->{$m} = _clone_method($trait_methods{$m});
        }
        push @$traits, $t;
      }
    },
    methods    => sub { %$methods },
    traits     => sub { @$traits },
    before     => sub {
                    my ($class, $method_name, $sub) = @_;
                    my $original_method = $methods->{$method_name};
                    $methods->{$method_name} = sub {
                      my $self = shift;
                      my @args = $sub->($self, @_);
                      $original_method->($self, @args);
                    }},
    after      => sub {
                    my ($class, $method_name, $sub) = @_;
                    my $original_method = $methods->{$method_name};
                    $methods->{$method_name} = sub {
                      my @results = $original_method->(@_);
                      $sub->($_[0], @results);
                    }},
    name       => sub { $class_name },
    does       => sub {
                    my ($class, $trait_name) = @_;
                    grep { $trait_name eq $_->('name') } @$traits;
                  },
    new        => sub {
      my $class = $_[0];
      my %self;
      %self = (%$properties,
               %{$_[1]},
               self => sub {
                         my $method_name = shift;
                         $methods->{$method_name}->(\%self, @_);
                       });
      $self{self};
    },
  };
  my $class = sub {
    my ($method_name) = shift;
    $class_methods->{$method_name}->(__SUB__, @_);
  };
  $methods->{class} = sub { $class };
  $class;
}

sub _clone_method {
  my $sub = shift;
  sub { goto $sub };
}

sub new_trait {
  my ($trait_name, $methods, $requires) = @_;
  my $trait_methods = {
    requires => sub { @$requires },
    methods  => sub { %$methods },
    name     => sub { $trait_name },
  };
  sub {
    my $method_name = shift;
    $trait_methods->{$method_name}->();
  };
}

1;
