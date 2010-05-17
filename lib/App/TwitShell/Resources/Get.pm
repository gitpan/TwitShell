package App::TwitShell::Resources::Get;

use App::TwitShell::Resources;

use strict;

=head1 NAME

App::TwitShell::Resources::Get - Container for data retrieving function (API
interface).

=head1 VERSION

Version 4.06

=cut

our $VERSION = 4.06;

=head1 SYNOPSIS

App::TwitShell::Resources::Get is the Twitter's API interface for data
retrieving.

=head1 FUNCTIONS

=head2 get_single_post( $id, $network )

Retrieve a single post.

=cut

sub get_single_post {
	my ($self, $id, $network) = @_;

	my $api = App::TwitShell::Resources -> get_api($network);
	
	my $url = $api -> {'url'}."/statuses/show/$id.json";

	my $response  = App::TwitShell::Resources -> get_request($url);
	my $json_text = App::TwitShell::Resources -> parse_response($response);
	
	my $posts = App::TwitShell::Resources -> parse_post_hash($json_text, 'status');
	
	return $posts;
}

=head2 get_user_posts( $id, $screen_name, $count, $network )

Retrieve given user's post (user_timeline).

=cut

sub get_user_posts {
	my ($self, $screen_name, $count, $network) = @_;

	my $api = App::TwitShell::Resources -> get_api($network);
	
	my $url = $api -> {'url'}."/statuses/user_timeline.json?screen_name=$screen_name&count=$count";
	
	my $response  = App::TwitShell::Resources -> get_request($url);
	my $json_text = App::TwitShell::Resources -> parse_response($response);
	
	my $posts = App::TwitShell::Resources -> parse_post_hash($json_text, 'status');
	
	return $posts;
}

=head2 get_friends_posts( $username, $password, $count, $network )

Retrieve given user's friends post (friends_timeline). Require authentication.

=cut

sub get_friends_posts {
	my ($self, $username, $password, $count, $network) = @_;

	my $api = App::TwitShell::Resources -> get_api($network);

	my $url = $api -> {'url'}."/statuses/friends_timeline.json?count=$count";

	my $response  = App::TwitShell::Resources -> auth_get_request($url, $username, $password, $api);
	my $json_text = App::TwitShell::Resources -> parse_response($response);

	my $posts = App::TwitShell::Resources -> parse_post_hash($json_text, 'status');
	
	return $posts;
}

=head2 get_inbox( $username, $password, $count, $network )

Retrieve given user's received direct messages (direct_messages). Require authentication.

=cut

sub get_inbox {
	my ($self, $username, $password, $count, $network) = @_;

	my $api = App::TwitShell::Resources -> get_api($network);

	my $url = $api -> {'url'}."/direct_messages.json?count=$count";
	
	my $response  = App::TwitShell::Resources -> auth_get_request($url, $username, $password, $api);
	my $json_text = App::TwitShell::Resources -> parse_response($response);
	
	my $posts = App::TwitShell::Resources -> parse_post_hash($json_text, 'dm');
	
	return $posts;
}

=head2 get_outbox( $username, $password, $count, $network )

Retrieve given user's sent direct messages (direct_messages/sent).
Require authentication.

=cut

sub get_outbox {
	my ($self, $username, $password, $count, $network) = @_;

	my $api = App::TwitShell::Resources -> get_api($network);
	
	my $url = $api -> {'url'}."/direct_messages/sent.json?count=$count";
	
	my $response  = App::TwitShell::Resources -> auth_get_request($url, $username, $password, $api);
	my $json_text = App::TwitShell::Resources -> parse_response($response);
	
	my $posts = App::TwitShell::Resources -> parse_post_hash($json_text, 'dm');
	
	return $posts;
}

1;
