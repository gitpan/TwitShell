package App::TwitShell::Resources;

use HTTP::Request::Common;
use LWP::UserAgent;
use JSON;
use DateTime::Format::HTTP;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(get_api parse_response parse_post_hash 
		 get_request auth_get_request auth_post_request);

=head1 NAME

App::TwitShell::Resources - Container for resources retrieving and parsing
functions.

=head1 VERSION

Version 4.10

=cut

our $VERSION = 4.10;

=head1 SYNOPSIS

App::TwitShell::Resources contains every common function for HTTP
request and data parsing/formatting.

=head1 FUNCTIONS

=head2 get_request( $url )

Execute a simple GET request.

=cut

sub get_request {
	my $url = shift;
	my $ua = LWP::UserAgent -> new;

	my $response = $ua -> request(GET $url) -> as_string;

	return $response;
}

=head2 auth_get_request( $url, $usr, $pwd, $api )

Execute a GET request with HTTP authorization.

=cut

sub auth_get_request {
	my ($url, $usr, $pwd, $api) = @_;
	my $ua = LWP::UserAgent -> new;
	
	$ua -> credentials($api -> {'endpoint'}, $api -> {'realm'}, $usr, $pwd);
	my $response = $ua -> request(GET $url) -> as_string;

	return $response;
}

=head2 auth_post_request( $url, $usr, $pwd, \%request, $api )

Execute a POST request with HTTP authorization.

=cut

sub auth_post_request {
	my ($url, $usr, $pwd, $request, $api) = @_;
	my $ua = LWP::UserAgent->new;

	$ua -> credentials($api -> {'endpoint'}, $api -> {'realm'}, $usr, $pwd);
	my $response = $ua -> request(POST $url, [%$request]) -> as_string;

	return $response;
}

=head2 parse_response( $data )

Parse a HTTP response splitting JSON data, and return a JSON object.

=cut

sub parse_response {
	my @data = split('\n\n', shift);
	
	my $json = new JSON;
	my $json_text = $json -> decode($data[1]);

	if (ref $json_text ne "ARRAY") {
		die("ERROR: ".$json_text -> {'error'}."\n") if $json_text -> {'error'};
	}
	
	return $json_text;
}

=head2 parse_post_hash( $data, $type )

Parse a JSON object, and return an array of posts.

=cut

sub parse_post_hash {
	my ($data, $type) = @_;

	my @posts;
	
	if ($data =~ /array/i) {
		foreach my $status(@{$data}) {
			my $post = format_post($status, $type);
			push(@posts, $post);	
		}
	} else {
		my $post = format_post($data, $type);
		push(@posts, $post);
	}

	return \@posts;
}

=head2 get_api( $network )

Return an API hash based on selected network.

=cut

sub get_api {
	my $network = shift;

	my %api;
	
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
	my ($status, $type) = @_;

	my %out;

	if ($status -> {'error'}) {
		$out{'err'} = 1;
		$out{'err_msg'} = $status -> {error};
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

=head1 AUTHOR

Alessandro Ghedini, C<< <alexbio at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-twitshell at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=TwitShell>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::TwitShell::Resources

You can also look for information at:

=over 4

=item * TwitShell homepage

L<http://alexlog.co.cc/projects/twitshell>

=item * GitHub page

L<http://github.com/AlexBio/TwitShell>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=TwitShell>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/TwitShell>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/TwitShell>

=item * Search CPAN

L<http://search.cpan.org/dist/TwitShell/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of App::TwitShell::Resources
