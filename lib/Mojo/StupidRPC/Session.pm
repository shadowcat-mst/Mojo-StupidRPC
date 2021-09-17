package Mojo::StupidRPC::Session;

use Mojo::JSON;
use Mojo::StupidRPC::Base 'Mojo::EventEmitter';

with 'Mojo::StupidRPC::HasHandlers';

has incoming => sub { {} };
has outgoing => sub { {} };

has tag_sequence => undef;

around new => sub ($orig, $self, @args) {
  if (@args == 1 and $args[0]->$_isa('Mojo::StupidRPC::HandlerSet')) {
    @args = (handlers => $args[0]->handlers);
  }
  $self->$orig(@args);
};

sub receive ($self, $type, @msg) {
  state %dispatch = (
    (map +($_ => '_start_incoming'), qw(cast call listen wrap)),
    (map +($_ => '_cancel_incoming'), qw(unlisten unwrap)),
    (map +($_ => '_inform_outgoing'), qw(done fail data notify)),
  );
  if (my $method = $dispatch{$type}) {
    $self->$method($type => @msg);
  } else {
    die;
  }
}

sub _start_incoming ($self, $type, $tag, $name, @args) {
  my $store_tag = join(':', call => $tag);
  die "Tag ${tag} in use" if $self->outgoing->{$store_tag};
  _load_my('Incoming'.ucfirst($type))->new(
    store_tag => $store_tag,
    protocol_tag => $tag,
    session => $self,
    name => $name,
    args => \@args,
  )->start;
}

sub _cancel_incoming ($self, $type, $name) {
  $type =~ s/^un//;
  $self->incoming->{join(':', $type, $name)}->cancel;
}

sub _inform_outgoing ($self, $type, $protocol_tag, @data) {
  my $outgoing = $self->outgoing->{join(':', call => $protocol_tag)};
  unless ($outgoing) {
    die
      "Unable to find live call for ${protocol_tag}, "
      ."current candidates are: ".join(', ', sort keys %{$self->outgoing});
  }
  $outgoing->$type(@data);
}

sub send ($self, @send) { $self->emit(send => @send) }

sub cast ($self, @cast) { $self->send(@cast) }

sub call ($self, @start) { $self->_start_outgoing(call => @start) }
sub listen ($self, @start) { $self->_start_outgoing(listen => @start) }
sub wrap ($self, @start) { $self->_start_outgoing(wrap => @start) }

sub unlisten ($self, $name) { $self->_cancel_outgoing(unlisten => $name) }
sub unwrap ($self, $name) { $self->_cancel_outgoing(unwrap => $name) }

sub _start_outgoing ($self, $type, $name, @args) {
  my $tag = ($self->{tag_sequence} //= 'A001')++;
  my $store_tag = join(':', call => $tag);
  die "Tag ${tag} in use" if $self->outgoing->{$store_tag};
  _load_my('Outgoing'.ucfirst($type))->new(
    store_tag => $store_tag,
    protocol_tag => $tag,
    session => $self,
    name => $name,
    args => \@args,
  )->start;
}

sub _cancel_outgoing ($self, $type, $name) {
  $type =~ s/^un//;
  $self->outgoing->{join(':', $type, $name)}->cancel;
}

1;
