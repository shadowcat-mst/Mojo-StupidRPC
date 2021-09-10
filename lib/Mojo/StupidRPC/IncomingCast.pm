package Mojo::StupidRPC::IncomingCast;

use Mojo::StupidRPC::Base;

with 'Mojo::StupidRPC::Incoming';
with 'Mojo::StupidRPC::IsCall';

sub _send { }

sub _register { }

sub _unregister { }

1;
