package Mojo::StupidRPC::Request;

use Mojo::StupidRPC::Base -role;

has protocol_tag => undef;
has store_tag => undef;
has session => undef, weak => 1;
has request_complete => 0;
has name => undef;
has args => undef;

requires 'store_type';
requires '_send';

sub type ($proto) { (ref($proto) || $proto) =~ /([A-Z][a-z]+)$/; lc($1) }

sub _register ($self) {
  $self->session->${\$self->store_type}->{$self->store_tag} = $self;
  $self
}

sub _unregister ($self) {
  delete $self->session->${\$self->store_type}->{$self->store_tag};
  $self
}

sub _request_completed ($self, @) {
  $self->_unregister
       ->request_complete(1)
       ->tap(sub ($self) { $self->emit('complete') if $self->can('emit') });
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
