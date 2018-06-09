#!/usr/bin/env perl
use Mojolicious::Lite;


my $common_url = 'https://api.ryanair.com/aggregate/3/common?embedded=airports,countries,cities,regions,nearbyAirports,defaultAirport&market=en-gb';

use Cwd; app->static->paths->[0] = getcwd . '/static';

get '/static/*file' => sub {
  my $self = shift;
  $self->reply->static($self->param('file'))
};

get '/' => sub {
  my $c = shift;
  $c->render(template => 'search');
};

get '/routes/:from' => [ format => [ 'json' ] ] => sub {
    my $c = shift;

    my $a = app->ua->get($common_url)->res->json;
    $c->render(json => [ grep { lc $_->{iataCode} eq lc $c->param('from') } @{$a->{airports}} ]->[0]->{routes} );
};

get '/mermaid';

get '/common' => sub {
    my $c = shift;

    my $a = app->ua->get($common_url)->res->json;
    $c->render(json => $a);
};

get '/common/:what' => sub {
    my $c = shift;
    my $a = app->ua->get($common_url)->res->json;
    my $what = $a->{$c->param('what')};

    if ($c->param('c')) { $what = [ grep { $_->{countryCode} eq (lc $c->param('c')) } @$what ] }
    
    $c->render( json => $what );
};

get '/foo/:bar/*baz' => [bar => ['bender', 'leela']] => sub {
    my $c = shift;
    $c->render(json => $c->param('bar'));

};

app->start;

__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<h1>Welcome to the Mojolicious real-time web framework!</h1>
To learn more, you can browse through the documentation
<%= link_to 'here' => '/perldoc' %>.

