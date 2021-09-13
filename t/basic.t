use Mojolicious::Lite;
use Test::More;
use Test::Mojo;
use Mojo::StupidRPC::HandlerSet;
use Mojo::StupidRPC;

use Mojo::StupidRPC::Base -strict;

my $h = Mojo::StupidRPC::HandlerSet->new;

$h->call(foo => sub ($call, @args) {
  return $call->fail('no') unless @args;
  $call->done('yes', @args)
});

$h->call(slow_foo => sub ($call, @) {
  Mojo::IOLoop->timer(1, sub { $call->done('slow_foo') });
});

websocket '/' => sub ($c) {
  Mojo::StupidRPC->from_websocket($c, $h);
};

my $t = Test::Mojo->new;

$t->websocket_ok('/')
  ->send_ok({ json => [ call => A => foo => 1, 2 ] })
  ->message_ok
  ->json_message_is([ done => A => yes => 1, 2 ])
  ->send_ok({ json => [ call => A => bar => ] })
  ->message_ok
  ->json_message_is([ fail => A => undef ])
  ->send_ok({ json => [ call => A => foo => ] })
  ->message_ok
  ->json_message_is([ fail => A => no => ])
  ->send_ok({ json => [ call => A => slow_foo => ] })
  ->message_ok
  ->json_message_is([ done => A => 'slow_foo' ])
  ->finish_ok;

done_testing;

1;
