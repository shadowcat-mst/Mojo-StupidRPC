package Mojo::StupidRPC::BecomesActive;

use Mojo::StupidRPC::Base -role;

has active => 0;

sub name ($self) { $self->tag =~ /:(.*)$/ }

after done => sub ($self, @) {
  $self->tag(join ':', $self->type, $self->name);
  $self->_register;
  $self->active(1);
};

sub cancel ($self) {
  die "Can't cancel inactive" unless $self->active;
  $self->active(0);
  $self->_unregister;
  $self->_report_cancel;
}

1;
