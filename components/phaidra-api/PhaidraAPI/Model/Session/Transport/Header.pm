package PhaidraAPI::Model::Session::Transport::Header;

use strict;
use warnings;
use Data::Dumper;

use base 'MojoX::Session::Transport';

__PACKAGE__->attr('header_name');
__PACKAGE__->attr('cookie_name');
__PACKAGE__->attr('log');

sub get {
  my ($self) = @_;

  #$self->log->debug("Loading header=".$self->name.": ".$self->tx->req->headers->header($self->name));
  my $token = $self->tx->req->headers->header($self->header_name);
  if ($token) {

    # $self->log->debug("Found token in ".$self->name." header");
  }
  else {
    my $cookies = $self->tx->req->cookies;
    for my $cookie (@{$cookies}) {
      if ($cookie->name eq $self->cookie_name) {

        # $self->log->debug("Found token in ".$self->name." cookie");
        $token = $cookie->value;
      }
    }
  }
  return $token;
}

# we don't set anything, the token is sent via cookie only on login and then kept on client side
sub set {
  my ($self, $sid, $expires) = @_;
}

1;
__END__
