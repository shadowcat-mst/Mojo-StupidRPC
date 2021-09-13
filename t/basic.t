use Mojolicious::Lite;
use Test::More;
use Test::Mojo;
use Mojo::Util qw(dumper);
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

$h->listen(ticker => sub ($listen) {
  $listen->done;
  my $id = Mojo::IOLoop->recurring(1, sub { $listen->notify('tick') });
  $listen->on(cancel => sub { Mojo::IOLoop->remove($id) });
});

$t->websocket_ok('/')
  ->send_ok({ json => [ listen => A => 'ticker' ] })
  ->message_ok
  ->json_message_is([ done => 'A' ])
  ->message_ok
  ->json_message_is([ notify => ticker => 'tick' ])
  ->message_ok
  ->json_message_is([ notify => ticker => 'tick' ])
  ->send_ok({ json => [ unlisten => 'ticker' ] })
  ->send_ok({ json => [ call => A => foo => 1, 2 ] })
  ->message_ok
  ->json_message_is([ done => A => yes => 1, 2 ])
  ->finish_ok;

my %wrap_out;

$h->wrap(event => sub ($wrap, @) {
  $wrap->done;
  foreach my $iter (1 .. 4) {
    $wrap->call($iter)
         ->tap(on => done => sub { $wrap_out{$iter}{done}++ })
         ->tap(on => stop => sub { $wrap_out{$iter}{stop}++ })
         ->tap(on => next => sub ($, @next) {
             $wrap_out{$iter}{next} = \@next;
           });
  }
});

$t->websocket_ok('/')
  ->send_ok({ json => [ wrap => A => 'event' => 'wrapper' => 0 ] })
  ->message_ok
  ->json_message_is([ done => 'A' ])
  ->message_ok
  ->json_message_is([ call => A001 => wrapper => 0 => 1 ])
  ->message_ok
  ->json_message_is([ call => A002 => wrapper => 0 => 2 ])
  ->message_ok
  ->json_message_is([ call => A003 => wrapper => 0 => 3 ])
  ->message_ok
  ->json_message_is([ call => A004 => wrapper => 0 => 4 ])
  ->send_ok({ json => [ done => 'A001' ] })
  ->send_ok({ json => [ done => A002 => 'stop' ] })
  ->send_ok({ json => [ done => A003 => 'next' ] })
  ->send_ok({ json => [ done => A004 => 'next' => [ 5 ] ] })
  ->finish_ok;

my $expect = dumper({
  1 => { done => 1 },
  2 => { done => 1, stop => 1 },
  3 => { done => 1, next => [ 3 ] },
  4 => { done => 1, next => [ 5 ] },
});

is(dumper(\%wrap_out), $expect, 'wrap server side return values ok');

done_testing;
