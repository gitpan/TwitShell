package App::TwitShell::Resources;

use HTTP::Request::Common;
use LWP::UserAgent;
use JSON -support_by_pp;
use DateTime::Format::HTTP;

use strict;

=head1 NAME

App::TwitShell::Resources - Container for resources retrieving and parsing
functions.

=head1 VERSION

Version 4.07

=cut

our $VERSION = 4.07;

=head1 SYNOPSIS

App::TwitShell::Resources contains every common function for HTTP
request and data parsing/formatting.

=head1 FUNCTIONS

=head2 get_request( $url )

Execute a simple GET request.

=cut

sub get_request {
	my ($self, $url) = @_;
	my $ua = LWP::UserAgent -> new;

	my $response = $ua -> request(GET $url) -> as_string;

	return $response;
}

=head2 auth_get_request( $url, $usr, $pwd, $api )

Execute a GET request with HTTP authorization.

=cut

sub auth_get_request {
	my ($self, $url, $usr, $pwd, $api) = @_;
	my $ua = LWP::UserAgent -> new;
	
	$ua -> credentials($api -> {'endpoint'}, $api -> {'realm'}, $usr, $pwd);
	my $response = $ua -> request(GET $url) -> as_string;

	return $response;
}

=head2 auth_post_request( $url, $usr, $pwd, \%request, $api )

Execute a POST request with HTTP authorization.

=cut

sub auth_post_request() {
	my ($self, $url, $usr, $pwd, $request, $api) = @_;
	my $ua = LWP::UserAgent->new;

	$ua -> credentials($api -> {'endpoint'}, $api -> {'realm'}, $usr, $pwd);
	my $response = $ua -> request(POST $url, [%$request]) -> as_string;

	return $response;
}

=head2 parse_response( $data )

Parse a HTTP response splitting JSON data, and return a JSON object.

=cut

sub parse_response {
	my $self = shift;
	my @data = split('\n\n', shift);
	
	my $json = new JSON;
	my $json_text = $json -> decode($data[1]);
	
	return $json_text;
}

=head2 parse_post_hash( $data, $type )

Parse a JSON object, and return an array of posts.

=cut

sub parse_post_hash {
	my ($self, $data, $type) = @_;

	my @posts;
	
	if ($data =~ /array/i) {
		foreach my $status(@{$data}) {
			my $post = App::TwitShell::Resources -> format_post($status, $type);
			push(@posts, $post);	
		}
	} else {
		my $post = App::TwitShell::Resources -> format_post($data, $type);
		push(@posts, $post);
	}

	return \@posts;
}

=head2 get_api( $network )

Return an API hash based on selected network.

=cut

sub get_api {
	my ($self, $network) = @_;

	my %api;

	my @networks = ('twitter', 'identi.ca');

	$network = 'twitter' unless (grep $_ eq $network, @networks);
	
	if ($network eq "twitter") {
		$api{'endpoint'} = "api.twitter.com:80";
		$api{'path'}     = "1";
		$api{'realm'}    = "Twitter API";
	} elsif ($network eq "identi.ca") {
		$api{'endpoint'} = "identi.ca:80";
		$api{'path'}     = "api";
		$api{'realm'}    = "Identi.ca API";
	}

	$api{'url'} = "http://".$api{'endpoint'}."/".$api{'path'};

	return \%api;
}

=head2 format_post( $status, $type )

Format a single post, from a hash, based on selected post type.

=cut

sub format_post {
	my ($self, $status, $type) = @_;

	my %out;

	if ((my $error = $status -> {error}) ne '') {
		$out{'err'} = 1;
		$out{'err_msg'} = $error;
	} else {
		$out{'err'} = 0;
		
		$out{'text'} 	 = $status -> {text};
		$out{'date'} 	 = $status -> {created_at};
		$out{'relative'} = relative_time($status -> {created_at});
		$out{'id'}   	 = $status -> {id};

		if ($type eq 'status') {
			$out{'user'} 	     = $status -> {user} -> {name};
			$out{'screen_name'}  = $status -> {user} -> {screen_name};
		} elsif ($type eq 'dm') {
			$out{'user'} 	     = $status -> {sender} -> {name};
			$out{'screen_name'}  = $status -> {sender} -> {screen_name};
		}
	}

	return \%out;
}

=head2 relative_time( $time_value )

Return the relative time from a standard data.

=cut

sub relative_time {
	my $time_value = shift;

	my $relative_to = DateTime -> now() -> epoch;
	
	$time_value =~ s/\+0000/GMT/;
	$time_value = DateTime::Format::HTTP -> parse_datetime($time_value) -> epoch;
	
	$relative_to = $relative_to -> epoch if ref($relative_to) =~ /DateTime/;
	my $delta = $relative_to - $time_value;
	
	if($delta < 60) {
		return 'less than a minute ago';
	} elsif($delta < 120) {
		return 'about a minute ago';
	} elsif($delta < (45*60)) {
		return int($delta / 60) . ' minutes ago';
	} elsif($delta < (90*60)) {
		return 'about an hour ago';
	} elsif($delta < (24*60*60)) {
		return 'about ' . int($delta / 3600) . ' hours ago';
	} elsif($delta < (48*60*60)) {
		return '1 day ago';
	} else {
		return int($delta / 86400) . ' days ago';
	}
}

1;
