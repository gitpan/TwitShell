package App::TwitShell::Resources::Shorten;

use App::TwitShell::Resources;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(shorten);

=head1 NAME

App::TwitShell::Resources::Shorten - Container for URL shortening functions.

=head1 VERSION

Version 4.09

=cut

our $VERSION = 4.09;

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

=head1 AUTHOR

Alessandro Ghedini, C<< <alexbio at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-twitshell at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=TwitShell>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::TwitShell::Resources::Shorten

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

1; # End of App::TwitShell::Resources::Shorten

