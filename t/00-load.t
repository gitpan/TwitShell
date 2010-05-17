#!perl -T

use Test::More tests => 5;

BEGIN {
    use_ok( 'App::TwitShell' ) 			   || print "Bail out!\n";;
    use_ok( 'App::TwitShell::Resources' ) 	   || print "Bail out!\n";;
    use_ok( 'App::TwitShell::Resources::Get' ) 	   || print "Bail out!\n";;
    use_ok( 'App::TwitShell::Resources::Send' )    || print "Bail out!\n";;
    use_ok( 'App::TwitShell::Resources::Shorten' ) || print "Bail out!\n";;
}

diag( "Testing App::TwitShell $App::TwitShell::VERSION,
App::TwitShell::Resources $App::TwitShell::Resources::VERSION,
pp::TwitShell::Resources::Get $App::TwitShell::Resources::Get::VERSION,
App::TwitShell::Resources::Send $App::TwitShell::Resources::Send::VERSION,
App::TwitShell::Resources::Shorten $App::TwitShell::Resources::Shorten::VERSION,
Perl $], $^X" );
