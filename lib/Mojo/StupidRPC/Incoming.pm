package Mojo::StupidRPC::Incoming;

use Mojo::StupidRPC::Base -role;

sub store_type { 'incoming' }

sub _send ($self, $type, @payload) {
  $self->session->send($type => $self->protocol_tag => @payload);
  $self
}

sub start ($self) {
  return $self->_send(fail => undef)
    unless my $handler = $self->session->handlers->{$self->type}{$self->name};

  $self->_register
       ->tap($handler => @{$self->args});
}

sub _report_cancel ($self) { $self->emit('cancel') }

1;

