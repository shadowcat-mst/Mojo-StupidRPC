package Mojo::StupidRPC::OutgoingListen;

use Mojo::StupidRPC::Base 'Mojo::EventEmitter';

with 'Mojo::StupidRPC::Outgoing';
with 'Mojo::StupidRPC::Request';
with 'Mojo::StupidRPC::BecomesActive';

sub notify ($self, @notify) { $self->emit(notify => $self->name => @notify) }

1;
