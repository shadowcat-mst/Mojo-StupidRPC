package Mojo::StupidRPC::HandlerSet;

use Mojo::StupidRPC::Base;

with 'Mojo::StupidRPC::HasHandlers';

sub call { shift->handle_call(@_) }
sub listen { shift->handle_listen(@_) }
sub wrap { shift->handle_wrap(@_) }

1;
