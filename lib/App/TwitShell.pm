package App::TwitShell;

use App::TwitShell::Resources;
use App::TwitShell::Resources::Get;
use App::TwitShell::Resources::Send;

use Getopt::Long;

use strict;
use warnings;

=head1 NAME

App::TwitShell - Container for TwitShell objects's functions.

=head1 VERSION

Version 4.09

=cut

our $VERSION = 4.09;

=head1 SYNOPSIS

App::TwitShell contains some common functions used with the TwitShell
client object.

=head1 METHODS

=head2 new()

Create an instance of the Twitter client and assign some default values.

=cut

sub new {
	my ($class) = @_;
	
	my $self = bless({configfile => $ENV{'HOME'}.'/.twitshellrc',
			  count	     => 20,
			  network    => 'twitter',
			  shorten    => 0,
			  refresh    => 0,
			  secs       => 45
			 }, $class);
	return $self;
}

=head2 parse_config()

Parse the .twitshellrc file.

=cut

sub parse_config {
	my $self = shift;

	open(CONFIG, $self -> {'configfile'}) or error("$!");
	while (<CONFIG>) {
		chomp;                  # no newline
		s/#.*//;                # no comments
		s/^\s+//;               # no leading white
		s/\s+$//;               # no trailing white
		next unless length;     # anything left?
		my ($var, $value) = split(/\s*=\s*/, $_, 2);
		$self -> {$var} = $value;
	}
}

=head2 parse_arguments()

Parse the command-line arguments.

=cut

sub parse_arguments {
	my $self = shift;
	
	my $getopt  = Getopt::Long::GetOptions(
			'action=s'   => \$self -> {'action'},
			'id=i' 	     => \$self -> {'id'},
			'msg=s'      => \$self -> {'msg'},
			'username=s' => \$self -> {'username'},
			'network=s'  => \$self -> {'network'},
			'count=i'    => \$self -> {'count'},
			'refresh=i'  => \$self -> {'refresh'},
			'secs=i'     => \$self -> {'username'},
			'shorten=i'  => \$self -> {'username'},
			'recipient=s'=> \$self -> {'recipient'}
	);
}

=head2 run()

Execute the action contant in 'action'.

=cut

sub run {
	my $self = shift;

	error("Missing 'username'") if $self -> {'username'} eq '';
	error("Missing 'network'")  if $self -> {'network'}  eq '';
	
	if ($self -> {'action'} eq 'user') {
		$self -> {'posts'} = get_user_posts($self);
							       
	} elsif ($self -> {'action'} eq 'friends') {
		$self -> {'posts'} = get_friends_posts($self);

	} elsif ($self -> {'action'} eq 'inbox') {
		$self -> {'posts'} = get_inbox($self);

	} elsif ($self -> {'action'} eq 'outbox') {
		$self -> {'posts'} = get_outbox($self);

	} elsif ($self -> {'action'} eq 'single') {
		error("Missing 'id'") if $self -> {'id'} eq '';
		
		$self -> {'posts'} = get_single_post($self);

	} elsif ($self -> {'action'} eq 'update') {
		error("Missing 'msg'") if $self -> {'msg'} eq '';
		
		$self -> {'posts'} = update($self);

	} elsif ($self -> {'action'} eq 'send') {
		error("Missing 'msg'")       if $self -> {'msg'}       eq '';
		error("Missing 'recipient'") if $self -> {'recipient'} eq '';
		
		$self -> {'posts'} = send_dm($self);
	}
}

=head2 verify_credentials()

Verify the user's credentials via the web APIs, using 'username'
and 'password'.

=cut

sub verify_credentials {
	my $self = shift;

	my $api = get_api($self -> {'network'});

	my $url 	= $api -> {'url'}."/account/verify_credentials.json";
	my $response 	= auth_get_request($url, $self -> {'username'}, $self -> {'password'}, $api);
	
	my $json_text 	= parse_response($response);

	my $error 	= $json_text -> {error};

	error("$error") if ($error);
}

=head2 get_pwd()

Request user's password.

=cut

sub get_pwd {
	my $self = shift;
	
	print "Password: ";
	system('stty','-echo');
	chop(my $pwd=<STDIN>);
	system('stty','echo');
	print "\n";
	
	$self -> {'password'} = $pwd;
}

=head2 error( $msg )

Print formatted errors and die

=cut

sub error {
	my $msg = shift;

	die "ERROR: $msg\n";
}

=head2 get_data()

Return content of a TwitShell object

=cut

sub get_data {
	my $self = shift;

	my %data = %$self;

	return \%data;
}

=head1 AUTHOR

Alessandro Ghedini, C<< <alexbio at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-twitshell at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=TwitShell>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::TwitShell

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

1; # End of App::TwitShell
