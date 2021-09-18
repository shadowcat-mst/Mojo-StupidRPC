package Mojo::StupidRPC::IncomingWrap;

use Mojo::StupidRPC::Base 'Mojo::EventEmitter';

with 'Mojo::StupidRPC::Incoming';
with 'Mojo::StupidRPC::Request';
with 'Mojo::StupidRPC::BecomesActive';

sub call ($self, @call) {
  $self->session
       ->call(@{$self->args}, @call)
       ->tap(on => done => sub ($self, @done) {
           return unless @done;
           $self->emit('stop') if $done[0] eq 'stop';
           $self->emit(next => @{$done[1]//\@call}) if $done[0] eq 'next';
           return;
         });
}

1;
