package Mojo::StupidRPC::HasHandlers;

use Mojo::StupidRPC::Base -role;

has handlers => sub { {} };

sub handle_call { shift->_handler(call => @_) }
sub handle_listen { shift->_handler(listen => @_) }
sub handle_trap { shift->_handler(trap => @_) }

sub _handler ($self, $type, $name, $handler) {
  $self->handlers->{$type}{$name} = $handler;
}

1;
