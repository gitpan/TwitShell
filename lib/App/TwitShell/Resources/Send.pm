package App::TwitShell::Resources::Send;

use App::TwitShell::Resources;
use App::TwitShell::Resources::Shorten;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(update send_dm);

=head1 NAME

App::TwitShell::Resources::Send - Container for data posting function (API
interface).

=head1 VERSION

Version 4.08

=cut

our $VERSION = 4.08;

=head1 SYNOPSIS

App::TwitShell::Resources::Send is the Twitter's API interface for data
posting.

=head1 FUNCTIONS

=head2 update( $client )

Update authenticating user's status.

=cut

sub update {
	my $client = shift;
	my $data = $client -> get_data;

	my $api = get_api($data -> {'network'});

	my $msg = auto_shorten($data -> {'msg'}) if ($data -> {'shorten'} == 1);

	my $url = $api -> {'url'}."/statuses/update.json";

	my %request = ('status', $msg);
	my $response  = auth_post_request($url, $data -> {'username'},
					  $data -> {'password'}, \%request, $api);
	
	my $json_text = parse_response($response);
	
	my $posts = parse_post_hash($json_text, 'status');
	
	return $posts;
}

=head2 send_dm( $username, $password, $msg, $recipient, $shorten, $network )

Send a direct message from authenticating user.

=cut

sub send_dm {
	my $client = shift;
	my $data = $client -> get_data;

	my $api = get_api($data -> {'network'});

	my $msg = auto_shorten($data -> {'msg'}) if ($data -> {'shorten'} == 1);

	my $url = $api -> {'url'}."/direct_messages/new.json?screen_name=".$data -> {'recipient'};

	my %request = ('text', $msg);
	my $response  = auth_post_request($url, $data -> {'username'},
					  $data -> {'password'}, \%request, $api);
	
	my $json_text = parse_response($response);
	
	my $posts = parse_post_hash($json_text, 'dm');
	
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

=head1 AUTHOR

Alessandro Ghedini, C<< <alexbio at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-twitshell at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=TwitShell>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::TwitShell::Resources::Send

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

1; # End of App::TwitShell::Resources::Send
