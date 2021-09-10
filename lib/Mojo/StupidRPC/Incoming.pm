package Mojo::StupidRPC::Incoming;

use Mojo::StupidRPC::Base -role;

sub store_type { 'incoming' }

sub _send ($self, $type, @payload) {
  $self->session->send($type => $self->tag => @payload)
}

sub start ($class, $session, $tag, $name, @args) {
  my \%tags = $session->incoming;
  die "Tag ${tag} in use" if $tags{$tag};
  return $session->fail($class->type => undef)
    unless my $handler = $session->handlers->{$class->type}{$name};
  $tags{$tag} = $class->new(session => $session, tag => $tag)
                      ->tap($handler => @args);
}


1;

