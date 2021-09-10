package Mojo::StupidRPC::IncomingCall;

use Mojo::StupidRPC::Base;

with 'Mojo::StupidRPC::Incoming';
with 'Mojo::StupidRPC::IsCall';

sub start ($class, $session, $tag, $name, @args) {
  my \%tags = $session->incoming;
  die "Tag ${tag} in use" if $tags{$tag};
  return $session->fail($class->type => undef)
    unless my $handler = $session->handlers->{$class->type}{$name};
  $tags{$tag} = $class->new(session => $session, tag => $tag)
                      ->tap($handler => @args);
}

1;
