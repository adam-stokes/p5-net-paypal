#!/usr/bin/env perl
#
# refresh_token example
#
# ./eg/refresh_token.pl

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Mojolicious::Lite;
use Net::PayPal;
use DDP;

my $refresh_token = $ENV{"PPREFRESH_TOKEN"};

my $sf = Net::PayPal->new(
    'key' => $ENV{PPKEY},
    'secret' => $ENV{PPSECRET},
    'redirect_uri' => 'http://localhost:3000/authorize/callback'
);

my $payload = $sf->refresh($ENV{PPREFRESH_TOKEN});

p $payload;
