package Mojo::StupidRPC::Outgoing;

use Mojo::StupidRPC::Base -role;

sub store_type { 'outgoing' }

sub _send { shift->emit(@_) }

sub start ($self) {
  $self->session->send(
    $self->type,
    $self->protocol_tag,
    $self->name,
    @{$self->args}
  );
  $self->_register;
  $self;
}

sub _report_cancel ($self) {
  $self->session->send('un'.$self->type, $self->name);
}

1;
