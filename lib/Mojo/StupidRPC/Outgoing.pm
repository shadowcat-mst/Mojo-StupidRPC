package Mojo::StupidRPC::Outgoing;

use Mojo::StupidRPC::Base -role;

sub store_type { 'outgoing' }

sub _send { shift->emit(@_) }

sub start ($class, $session, $tag, @start) {
  my \%tags = $session->outgoing;
  die "Tag ${tag} in use" if $tags{$tag};
  $session->send($class->type, $tag, @start);
  $tags{$tag} = $class->new(session => $session, tag => $tag);
}


1;
