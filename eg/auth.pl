#!/usr/bin/env perl
#

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Mojolicious::Lite;
use Net::PayPal;
use Mojo::URL;
use DDP;

app->helper(
    'pp' => sub {
        my $self = shift;
        Net::PayPal->new(
            sandbox => 0,
            'key' => $ENV{PPKEY},
            'secret' => $ENV{PPSECRET},
            'redirect_uri' => 'http://localhost:3000/authorize/callback',
        );
    }
);

get '/' => sub {
  my ($c) = @_;
} => 'index';

post '/authorize' => sub {
    my ($c) = @_;
    return $c->redirect_to(app->pp->authorize_url);
};

get '/authorize/callback' => sub {
  my ($c) = @_;
  my $authorization_code = $c->param('code');
  my $payload = app->pp->authenticate($authorization_code);
  $c->stash(oauth => $payload);
} => 'authenticated';

app->start;

__DATA__

@@ index.html.ep
<html><head><title>index</title></head>
<body>
<form method="post" action="/authorize">
<button type="submit">Auth</button>
</form>
</body>
</html>

@@ authenticated.html.ep
% use DDP;
% p $oauth;
<html><head><title>Callback</title></head>
<body>
<h1>Authenticated</h1>
<p>Your access_token is: <%= $oauth->{access_token} %></p>
<p>Your refresh_token is: <%= $oauth->{refresh_token} %></p>
</body>
</html>
