package App::TwitShell;

use App::TwitShell::Resources;
use App::TwitShell::Resources::Get;
use App::TwitShell::Resources::Send;

use Getopt::Long;

use strict;

=head1 NAME

App::TwitShell - Container for TwitShell objects's functions.

=head1 VERSION

Version 4.07

=cut

our $VERSION = 4.07;

=head1 SYNOPSIS

App::TwitShell contains some common functions used with the TwitShell
client object.

=head1 METHODS

=head2 CLASS -> new()

Create an instance of the Twitter client and assign some default values.

=cut

sub new {
	my ($class) = @_;
 
	my $self = bless({}, $class);

	$self -> {'configfile'} = $ENV{'HOME'}.'/.twitshellrc';
	$self -> {'count'}   	= 20;
	$self -> {'network'} 	= 'twitter';
	$self -> {'shorten'} 	= 0;
	$self -> {'refresh'} 	= 0;
	$self -> {'secs'}    	= 45;

	return $self;
}

=head2 CLASS -> parse_config()

Parse the .twitshellrc file.

=cut

sub parse_config {
	my $self = shift;

	open(CONFIG, $self -> {'configfile'}) or error ("$!");
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

=head2 CLASS -> parse_arguments()

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
	);
}

=head2 CLASS -> run()

Execute the action contant in CLASS -> {'action'}.

=cut

sub run {
	my $self = shift;

	error("Missing 'username'") if $self -> {'username'} eq '';
	error("Missing 'network'")  if $self -> {'network'}  eq '';
	
	if ($self -> {'action'} eq 'user') {
		$self -> {'posts'} =
			App::TwitShell::Resources::Get ->
				get_user_posts($self -> {'username'},
					       $self -> {'count'},
					       $self -> {'network'}
					      );
							       
	} elsif ($self -> {'action'} eq 'friends') {
		$self -> {'posts'} =
			App::TwitShell::Resources::Get ->
				get_friends_posts($self -> {'username'},
						  $self -> {'password'},
						  $self -> {'count'},
						  $self -> {'network'}
						 );

	} elsif ($self -> {'action'} eq 'inbox') {
		$self -> {'posts'} =
			App::TwitShell::Resources::Get ->
				get_inbox($self -> {'username'},
					  $self -> {'password'},
					  $self -> {'count'},
					  $self -> {'network'}
					 );

	} elsif ($self -> {'action'} eq 'outbox') {
		$self -> {'posts'} =
			App::TwitShell::Resources::Get ->
				get_outbox($self -> {'username'},
					   $self -> {'password'},
					   $self -> {'count'},
					   $self -> {'network'}
					  );

	} elsif ($self -> {'action'} eq 'single') {
		error("Missing 'id'") if $self -> {'id'} eq '';
		
		$self -> {'posts'} =
			App::TwitShell::Resources::Get ->
				get_single_post($self -> {'id'},
						$self -> {'network'}
					       );

	} elsif ($self -> {'action'} eq 'update') {
		error("Missing 'msg'") if $self -> {'msg'} eq '';
		
		$self -> {'posts'} =
			App::TwitShell::Resources::Send ->
				update($self -> {'username'},
				       $self -> {'password'},
				       $self -> {'msg'},
				       $self -> {'shorten'},
				       $self -> {'network'}
				      );
	} elsif ($self -> {'action'} eq 'send') {
		error("Missing 'msg'")       if $self -> {'msg'}       eq '';
		error("Missing 'recipient'") if $self -> {'recipient'} eq '';
		
		$self -> {'posts'} =
			App::TwitShell::Resources::Send ->
				send($self -> {'username'},
				       $self -> {'password'},
				       $self -> {'msg'},
				       $self -> {'recipient'},
				       $self -> {'shorten'},
				       $self -> {'network'}
				      );
	}
}

=head2 CLASS -> verify_credentials()

Verify the user's credentials via the web APIs, using CLASS -> {'username'}
and CLASS -> {'password'}.

=cut

sub verify_credentials {
	my $self = shift;

	my $api = App::TwitShell::Resources -> get_api($self -> {'network'});

	my $url 	= $api -> {'url'}."/account/verify_credentials.json";
	my $response 	= App::TwitShell::Resources ->
		auth_get_request($url, $self -> {'username'}, $self -> {'password'}, $api);
	
	my $json_text 	= App::TwitShell::Resources -> parse_response($response);

	my $error 	= $json_text -> {error};

	error("$error") if ($error ne '');
}

=head2 CLASS -> get_pwd()

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

=head2 CLASS -> error()

Print formatted errors and die().

=cut

sub error {
	my $msg = shift;

	die "ERROR: $msg\n";
}

1;
