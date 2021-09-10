package Mojo::StupidRPC::IncomingListen;

use Mojo::StupidRPC::Base 'Mojo::EventEmitter';

with 'Mojo::StupidRPC::Incoming';
with 'Mojo::StupidRPC::IsCall';
with 'Mojo::StupidRPC::BecomesActive';

sub notify ($self, @notify) {
  $self->session->send(notify => $self->name, @notify);
}

1;
