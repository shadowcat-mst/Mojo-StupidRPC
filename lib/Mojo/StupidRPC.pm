package Mojo::StupidRPC;

use Mojo::StupidRPC::Session;
use Mojo::StupidRPC::HandlerSet;

use Mojo::StupidRPC::Base -strict;

sub from_stream ($class, $stream, @args) {
  my $session = Mojo::StupidRPC::Session->new(@args);
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
  my $session = Mojo::StupidRPC::Session->new(@args);
  $tx->on(json => sub ($self, $json) {
    $session->receive(@$json);
  });
  $session->on(send => sub ($self, @send) {
    $tx->send({ json => \@send });
  });
  $session
}

sub handler_set ($class) {
  Mojo::StupidRPC::HandlerSet->new;
}

1;
