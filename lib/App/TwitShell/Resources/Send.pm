package App::TwitShell::Resources::Send;

use App::TwitShell::Resources;
use App::TwitShell::Resources::Shorten;

use strict;

=head1 NAME

App::TwitShell::Resources::Send - Container for data posting function (API
interface).

=head1 VERSION

Version 4.06

=cut

our $VERSION = 4.06;

=head1 SYNOPSIS

App::TwitShell::Resources::Send is the Twitter's API interface for data
posting.

=head1 FUNCTIONS

=head2 update( $username, $password, $msg, $shorten, $network )

Update authenticating user's status.

=cut

sub update {
	my ($self, $username, $password, $msg, $shorten, $network) = @_;
	
	my $api = App::TwitShell::Resources -> get_api($network);

	$msg = auto_shorten($msg) if ($shorten == 1);

	my $url = $api -> {'url'}."/statuses/update.json";

	my %request = ('status', $msg);
	my $response = App::TwitShell::Resources -> auth_post_request($url, $username,
								 $password, \%request, $api);
	
	my $json_text = App::TwitShell::Resources -> parse_response($response);
	
	my $posts = App::TwitShell::Resources -> parse_post_hash($json_text, 'status');
	
	return $posts;
}

=head2 send( $username, $password, $msg, $recipient, $shorten, $network )

Send a direct message from authenticating user.

=cut

sub send {
	my ($self, $username, $password, $msg, $recipient, $shorten, $network) = @_;
	
	my $api = App::TwitShell::Resources -> get_api($network);

	$msg = auto_shorten($msg) if ($shorten == 1);

	my $url = $api -> {'url'}."/direct_messages/new.json";

	my %request = ('user', $recipient, 'text', $msg);
	my $response = App::TwitShell::Resources -> auth_post_request($url, $username,
								 $password, \%request, $api);
	
	my $json_text = App::TwitShell::Resources -> parse_response($response);
	
	my $posts = App::TwitShell::Resources -> parse_post_hash($json_text, 'status');
	
	return $posts;
}

=head2 auto_shorten( $text )

Parse messages, extract URLs adn shorten them.

=cut	

sub auto_shorten() {
	my $text = shift;
	
	$text .= " "; # unelegant, but works well
	while ($text =~ m/(http\:\/\/.*?) /g) {
		if (index($1, "http://u.nu") == -1) {
			my $short = App::TwitShell::Resources::Shorten -> shorten($1, 'u.nu');
			$text =~ s/$1/$short/g;
		}
	}

	# remove trailing whitespace
	$/ = " ";
	chomp($text);

	return $text;
}

1;
