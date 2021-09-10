package Mojo::StupidRPC::IsCall;

use Mojo::StupidRPC::Base -role;

has tag => undef;
has session => undef, weak => 1;
has request_complete => 0;

requires 'store_type';
requires '_send';

sub type { 'call' }

sub _request_completed ($self, @) {
  delete $self->session->${\$self->store_type}->{$self->tag};
  $self->request_complete(1);
}

sub data ($self, @data) {
  croak "Request already completed" if $self->request_complete;
  $self->_send(data => @data);
}

sub done ($self, @done) {
  croak "Request already completed" if $self->request_complete;
  $self->_send(done => @done)->_request_completed;
}

sub fail ($self, $fail) {
  croak "Request already completed" if $self->request_complete;
  $self->_send(fail => $fail)->_request_completed;
}

1;
