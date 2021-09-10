package Mojo::StupidRPC::Outgoing;

use Mojo::StupidRPC::Base -role;

sub store_type { 'outgoing' }

sub _send { shift->emit(@_) }

sub start ($class, $session, $tag, @start) {
  my \%tags = $session->outgoing;
  die "Tag ${tag} in use" if $tags{$tag};
  $session->send($class->type, $tag, @start);
  $class->new(session => $session, tag => $tag)
        ->_register;
}

sub _report_cancel ($self) {
  $self->session->send('un'.$self->type, $self->name);
}


1;
