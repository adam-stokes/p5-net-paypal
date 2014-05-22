package Net::PayPal;

# ABSTRACT: oauth2 authentication library

use Mojo::Base -base;
use Mojo::UserAgent;
use Mojo::URL;
use Mojo::Parameters;
use DDP;

has 'key';

has 'secret';

has 'use_sandbox' => 1;

has 'redirect_uri' => 'http://localhost:3000/authorize/callback';

has 'authorization_endpoint' => sub {
  my $self = shift;
  if ($self->use_sandbox) {
    'https://www.sandbox.paypal.com/webapps/auth/protocol/openidconnect/v1/authorize';
  } else {
    'https://www.paypal.com/webapps/auth/protocol/openidconnect/v1/authorize';
  }
};

has 'tokenservice' => sub {
  my $self = shift;
  my $url = Mojo::URL->new;
  $url->scheme('https');
  $url->userinfo(sprintf("%s:%s", $self->key, $self->secret));
  $url->host($self->api_host);
  $url->path('v1/identity/openidconnect/tokenservice');
  return $url;
};

has 'api_host' => sub {
  my $self = shift;
  if ($self->use_sandbox) {
    'api.sandbox.paypal.com';
  } else {
    'api.paypal.com';
  }
};

has 'scope' => 'profile email address phone';

has 'response_type' => 'code';

has 'params' => sub {
    my $self = shift;
    return {
      redirect_uri => $self->redirect_uri
    };
};

has 'json' => sub {
    my $self = shift;
    my $json = Mojo::JSON->new;
    return $json;
};

has 'ua' => sub {
    my $self = shift;
    my $ua = Mojo::UserAgent->new;
    $ua->transactor->name("Net::PayPal/1.0");
    return $ua;
};

has 'nonce' => sub {
    my $self = shift;
    my @a = ('A' .. 'Z', 'a' .. 'z', 0 .. 9);
    my $nonce = '';
    for (0 .. 31) {
        $nonce .= $a[rand(scalar(@a))];
    }
    return $nonce;
};

sub refresh {
    my ($self, $refresh_token) = @_;
    $self->params->{refresh_token} = $refresh_token;
    $self->params->{grant_type} = 'refresh_token';
    my $tx =
      $self->ua->post(
        $self->tokenservice->to_string => form => $self->params);
    return $self->json->decode($tx->res->body);
}

sub authenticate {
    my ($self, $code) = @_;
    $self->params->{code}       = $code;
    $self->params->{grant_type} = 'authorization_code';
    my $tx =
      $self->ua->post(
        $self->tokenservice->to_string => form => $self->params);
    return $self->json->decode($tx->res->body);
}

sub authorize_url {
    my $self = shift;
    $self->params->{response_type} = 'code';
    $self->params->{client_id} = $self->key;
    $self->params->{scope} = $self->scope;
    $self->params->{nonce} = $self->nonce;
    my $url = Mojo::URL->new($self->authorization_endpoint)
      ->query($self->params);
    return $url->to_string;
}

1;
