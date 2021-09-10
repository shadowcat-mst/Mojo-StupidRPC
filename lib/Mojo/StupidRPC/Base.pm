package Mojo::StupidRPC::Base;

use curry;
use Import::Into;
use base qw(Exporter);
use Mojo::Base -strict, -signatures;

our @EXPORT = qw(_load_my);

sub import ($me, $base = '-base') {
  Carp->import::into(1, 'croak');
  unless ($base eq '-role') {
    Role::Tiny::With->import::into(1);
    Class::Method::Modifiers->import::into(1);
  }
  $me->export_to_level(1);
  Safe::Isa->import::into(1);
  Mojo::Base->import::into(1, $base, -signatures);
  warnings->import::into(1, FATAL => 'uninitialized');
  warnings->unimport::out_of(1, 'once');
  experimental->import::into(1, qw(declared_refs refaliasing));
}

sub _load_my ($name) {
  my $package = "Mojo::StupidRPC::${name}";
  require join('/', split '::', $package).'.pm';
  return $package;
}

1;
