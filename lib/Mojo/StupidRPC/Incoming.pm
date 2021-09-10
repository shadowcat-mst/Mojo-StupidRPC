package Mojo::StupidRPC::Incoming;

use Mojo::StupidRPC::Base -role;

sub store_type { 'incoming' }

sub _send ($self, $type, @payload) {
  $self->session->send($type => $self->tag => @payload)
}

sub start ($class, $session, $tag, $name, @args) {
  die "Tag ${tag} in use" if $session->incoming->{$tag};
  return $session->fail($class->type => undef)
    unless my $handler = $session->handlers->{$class->type}{$name};
  $class->new(session => $session, tag => $tag, args => \@args)
        ->_register
        ->tap($handler => @args);
}

sub _report_cancel ($self) { $self->emit('cancel') }

1;

