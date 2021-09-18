package Mojo::StupidRPC::OutgoingWrap;

use Mojo::StupidRPC::Base 'Mojo::EventEmitter';

with 'Mojo::StupidRPC::Outgoing';
with 'Mojo::StupidRPC::Request';
with 'Mojo::StupidRPC::BecomesActive';

1;
