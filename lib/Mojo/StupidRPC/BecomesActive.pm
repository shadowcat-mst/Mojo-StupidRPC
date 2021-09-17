package Mojo::StupidRPC::BecomesActive;

use Mojo::StupidRPC::Base -role;

has active => 0;

# the next three lines are because I was getting perl panics; must investigate
# after done => sub ($self, @) {
around done => sub ($orig, $self, @args) {
  $self->$orig(@args);
  $self->protocol_tag($self->name);
  $self->store_tag(join(':', $self->type, $self->name));
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
