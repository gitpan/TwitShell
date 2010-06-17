package App::TwitShell::Resources::Get;

use App::TwitShell::Resources;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(get_single_post get_user_posts get_friends_posts
		 get_inbox get_outbox);

=head1 NAME

App::TwitShell::Resources::Get - Container for data retrieving function (API
interface).

=head1 VERSION

Version 4.08

=cut

our $VERSION = 4.08;

=head1 SYNOPSIS

App::TwitShell::Resources::Get is the Twitter's API interface for data
retrieving.

=head1 FUNCTIONS

=head2 get_single_post( $id, $network )

Retrieve a single post.

=cut

sub get_single_post {
	my $client = shift;
	my $data = $client -> get_data;

	my $api = get_api($data -> {'network'});
	
	my $url = $api -> {'url'}."/statuses/show/".$data -> {'id'}.".json";

	my $response  = get_request($url);
	my $json_text = parse_response($response);
	
	my $posts = parse_post_hash($json_text, 'status');
	
	return $posts;
}

=head2 get_user_posts( $id, $screen_name, $count, $network )

Retrieve given user's post (user_timeline).

=cut

sub get_user_posts {
	my $client = shift;
	my $data = $client -> get_data;

	my $api = get_api($data -> {'network'});

	my $options = "screen_name=".$data -> {'screen_name'}."&count=".$data -> {'count'};
	my $url = $api -> {'url'}."/statuses/user_timeline.json";
	
	my $response  = get_request("$url?$options");
	my $json_text = parse_response($response);
	
	my $posts = parse_post_hash($json_text, 'status');
	
	return $posts;
}

=head2 get_friends_posts( $username, $password, $count, $network )

Retrieve given user's friends post (friends_timeline). Require authentication.

=cut

sub get_friends_posts {
	my $client = shift;
	my $data = $client -> get_data;

	my $api = get_api($data -> {'network'});

	my $url = $api -> {'url'}."/statuses/friends_timeline.json?count=".$data -> {'count'};

	my $response  = auth_get_request($url, $data -> {'username'},
					 $data -> {'password'}, $api);

	my $json_text = parse_response($response);
	
	my $posts = parse_post_hash($json_text, 'status');
	
	return $posts;
}

=head2 get_inbox( $username, $password, $count, $network )

Retrieve given user's received direct messages (direct_messages). Require authentication.

=cut

sub get_inbox {
	my $client = shift;
	my $data = $client -> get_data;

	my $api = get_api($data -> {'network'});

	my $url = $api -> {'url'}."/direct_messages.json?count=".$data -> {'count'};
	
	my $response  = auth_get_request($url, $data -> {'username'},
					 $data -> {'password'}, $api);

	my $json_text = parse_response($response);
	
	my $posts = parse_post_hash($json_text, 'dm');
	
	return $posts;
}

=head2 get_outbox( $username, $password, $count, $network )

Retrieve given user's sent direct messages (direct_messages/sent).
Require authentication.

=cut

sub get_outbox {
	my $client = shift;
	my $data = $client -> get_data;

	my $api = get_api($data -> {'network'});
	
	my $url = $api -> {'url'}."/direct_messages/sent.json?count=".$data -> {'count'};
	
	my $response  = auth_get_request($url, $data -> {'username'},
					 $data -> {'password'}, $api);

	my $json_text = parse_response($response);
	
	my $posts = parse_post_hash($json_text, 'dm');
	
	return $posts;
}

=head1 AUTHOR

Alessandro Ghedini, C<< <alexbio at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-twitshell at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=TwitShell>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::TwitShell::Resources::Get

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

1; # End of App::TwitShell::Resources::Get

