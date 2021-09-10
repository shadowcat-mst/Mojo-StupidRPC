package Mojo::StupidRPC::OutgoingListen;

use Mojo::StupidRPC::Base 'Mojo::EventEmitter';

with 'Mojo::StupidRPC::Outgoing';
with 'Mojo::StupidRPC::IsCall';
with 'Mojo::StupidRPC::BecomesActive';

sub notify ($self, @notify) { $self->emit(notify => @notify) }

1;
