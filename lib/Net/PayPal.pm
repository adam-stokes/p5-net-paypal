package Net::PayPal;

# ABSTRACT: oauth2 authentication library

use Mojo::Base -base;
use Mojo::UserAgent;
use Mojo::URL;
use Mojo::Parameters;

has 'key';

has 'secret';

has 'redirect_uri' => 'http://localhost:8081/callback';

has 'api_host' => 'https://api.sandbox.paypal.com/';

has 'access_token_path' => 'v1/oauth2/token';

has 'authorize_path' => 'v1/oauth2/authorize';

has 'scope' => 'openid profile';

has 'response_type' => 'code';

has 'params' => sub {
    my $self = shift;
    return {
        client_id => $self->key,
        client_secret => $self->secret,
        redirect_uri => $self->redirect_uri,
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
    $ua->transactor->name("Net::PayPal/$Net::PayPal::VERSION");
    return $ua;
};

sub verify_signature {

    # TODO: fix verify
    my ($self, $payload) = @_;
    my $sha = Digest::SHA->new(256);
    $sha->hmac_sha256($self->secret);
    $sha->add($payload->{id});
    $sha->add($payload->{issued_at});
    $sha->b64digest eq $payload->{signature};
}

sub refresh {
    my ($self, $refresh_token) = @_;
    $self->params->{refresh_token} = $refresh_token;
    $self->params->{grant_type} = 'refresh_token';
    return $self->oauth2;
}

sub password {
    my $self = shift;
    $self->params->{grant_type} = 'password';
    return $self->oauth2;
}

sub authenticate {
    my ($self, $code) = @_;
    $self->params->{code} = $code;
    $self->params->{grant_type} = 'authorization_code';
    return $self->oauth2;
}

sub authorize_url {
    my $self = shift;
    $self->params->{response_type} = 'code';
    my $url = Mojo::URL->new($self->api_host)
      ->path($self->authorize_path)
      ->query($self->params);
    return $url->to_string;
}

sub access_token_url {
    my $self = shift;
    my $url = Mojo::URL->new($self->api_host)->path($self->access_token_path);
    return $url->to_string;
}

sub oauth2 {
    my $self = shift;

    $self->params->{grant_type} = 'client_credentials';

    my $tx =
      $self->ua->post($self->access_token_url => form => $self->params);

    die $tx->res->body unless $tx->success;

    my $payload = $self->json->decode($tx->res->body);

  # TODO: fix verify signature
  # die "Unable to verify signature" unless $self->verify_signature($payload);

    return $payload;
}
1;
