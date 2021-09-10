package Mojo::StupidRPC::OutgoingWrap;

use Mojo::StupidRPC::Base 'Mojo::EventEmitter';

with 'Mojo::StupidRPC::Outgoing';
with 'Mojo::StupidRPC::IsCall';
with 'Mojo::StupidRPC::BecomesActive';

1;
