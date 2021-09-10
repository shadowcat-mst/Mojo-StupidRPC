package Mojo::StupidRPC::Session;

use Mojo::JSON;
use Mojo::StupidRPC::Base 'Mojo::EventEmitter';

with 'Mojo::StupidRPC::HasHandlers';

has incoming => sub { {} };
has outgoing => sub { {} };

sub from_stream ($class, $stream, @args) {
  my $session = $class->new(@args);
  my $buf = '';
  $stream->on(read => sub ($self, $read) {
    $buf .= $read;
    while ($buf =~ s/^(.*)\r?\n//ms) {
      my $line = $1;
      $session->receive(@{decode_json($line)});
    }
    return
  });
  $session->on(send => sub ($self, @send) {
    $stream->write(encode_json(\@send)."\n");
  });
  $session
}

sub from_websocket ($class, $tx, @args) {
  my $session = $class->new(@args);
  $tx->on(json => sub ($self, $json) {
    $session->receive(@$json);
  });
  $session->on(send => sub ($self, @send) {
    $tx->send({ json => \@send });
  });
  $session
}

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

sub _start_incoming ($self, $type, @start) {
  _load_my('Incoming'.ucfirst($type))->start($self, @start);
}

sub _cancel_incoming ($self, $type, $name) {
  $type =~ s/^un//;
  $self->incoming->{join(':', $type, $name)}->cancel;
}

sub _inform_outgoing ($self, $type, $tag, @data) {
  $self->outgoing->{$tag}->$type(@data);
}

sub send ($self, @send) { $self->emit(send => @send) }

sub cast ($self, @cast) { $self->send(@cast) }

sub call ($self, @start) { $self->_start_outgoing(call => @start) }
sub listen ($self, @start) { $self->_start_outgoing(listen => @start) }
sub wrap ($self, @start) { $self->_start_outgoing(wrap => @start) }

sub unlisten ($self, $name) { $self->_cancel_outgoing(unlisten => $name) }
sub unwrap ($self, $name) { $self->_cancel_outgoing(unwrap => $name) }

sub _start_outgoing ($self, $type, @start) {
  _load_my('Outgoing'.ucfirst($type))->start($self, @start);
}

sub _cancel_outgoing ($self, $type, $name) {
  $type =~ s/^un//;
  $self->outgoing->{join(':', $type, $name)}->cancel;
}

1;
