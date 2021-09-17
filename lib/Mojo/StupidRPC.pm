package Mojo::StupidRPC;

use Mojo::IOLoop;
use Mojo::JSON qw(encode_json decode_json);
use Mojo::StupidRPC::Session;
use Mojo::StupidRPC::HandlerSet;

use Mojo::StupidRPC::Base -strict;

sub from_stream ($class, $stream, @args) {
  my $session = Mojo::StupidRPC::Session->new(@args);
  my $buf = '';
  $stream->on(read => sub ($self, $read) {
    $buf .= $read;
    while ($buf =~ s/^(.*)\r?\n//m) {
      my $line = $1;
      unless (eval { $session->receive(@{decode_json($line)}); 1 }) {
        die "Receive fail handling <<${line}>>: $@";
      }
    }
    return
  });
  my $cb = $session->on(send => sub ($self, @send) {
    $stream->write(encode_json(\@send)."\n");
  });
  $stream->on(close => sub { $session->unsubscribe(send => $cb) });
  $session
}

sub from_websocket ($class, $tx, @args) {
  my $session = Mojo::StupidRPC::Session->new(@args);
  $tx->on(json => sub ($self, $json) {
    $session->receive(@$json);
  });
  my $cb = $session->on(send => sub ($self, @send) {
    $tx->send({ json => \@send });
  });
  $tx->on(close => sub { $session->unsubscribe(send => $cb) });
  $session
}

sub handler_set ($class) {
  Mojo::StupidRPC::HandlerSet->new;
}

sub server ($class, $args, $session_args = {}) {
  Mojo::IOLoop->server($args => sub ($loop, $stream, $id) {
    $stream->timeout(0);
    $class->from_stream($stream, $session_args);
  });
}

sub client_p ($class, $args, $session_args = {}) {
  return $class->ws_client($args, $session_args) unless ref($args);
  Mojo::Promise->new->tap(sub ($p) {
    Mojo::IOLoop->client($args => sub ($loop, $err, $stream) {
      return $p->reject($err) if defined($err);
      $stream->timeout(0);
      $p->resolve($class->from_stream($stream, $session_args));
    });
  });
}

sub ws_client ($class, $url, $session_args, @ua_args) {
  state $loaded = require Mojo::UserAgent;
  Mojo::UserAgent->new(@ua_args)
    ->websocket($url, sub ($ua, $tx) {
        $class->from_websocket($tx, $session_args);
      });
  return;
}

1;
