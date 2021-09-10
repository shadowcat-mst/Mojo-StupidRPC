package Mojo::StupidRPC::OutgoingCall;

use Mojo::StupidRPC::Base 'Mojo::EventEmitter';

with 'Mojo::StupidRPC::Outgoing';
with 'Mojo::StupidRPC::IsCall';

1;
