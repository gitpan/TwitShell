package App::TwitShell::Resources::Shorten;

use App::TwitShell::Resources;

use strict;

=head1 NAME

App::TwitShell::Resources::Shorten - Container for URL shortening functions.

=head1 VERSION

Version 4.06

=cut

our $VERSION = 4.06;

=head1 SYNOPSIS

App::TwitShell::Resources::Shorten is the Url shortening services' API
interface.

=head1 FUNCTIONS

=head2 shorten( $longurl, $service )

Shorten longurl using selected web service.

=cut

sub shorten {
	my ($self, $longurl, $service) = @_;

	my %services = ('u.nu' => "http://u.nu/unu-api-simple?url=$longurl");

	my $url = $services{$service};

	my @data = split('\n\n', App::TwitShell::Resources -> get_request($url));
	chomp($data[1]);

	return $data[1];
}

1;
