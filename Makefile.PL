use strict;
use warnings;
use ExtUtils::MakeMaker;
 
WriteMakefile(
	'NAME'		=> 'TwitShell',
	'AUTHOR' 	=> 'Alessandro Ghedini <al3xbio@gmail.com>',
	'ABSTRACT' 	=> 'Command-line microblogging client.',
	'LICENSE' 	=> 'GPLv3',
	'VERSION_FROM'	=> 'scripts/TwitShell',

	PM            	=> {
		'lib/App/TwitShell.pm'        		 => 'blib/lib/App/TwitShell.pm',
		'lib/App/TwitShell/Resources.pm'         => 'blib/lib/App/TwitShell/Resources.pm',
		'lib/App/TwitShell/Resources/Get.pm'     => 'blib/lib/App/TwitShell/Resources/Get.pm',
		'lib/App/TwitShell/Resources/Send.pm'    => 'blib/lib/App/TwitShell/Resources/Send.pm',
		'lib/App/TwitShell/Resources/Shorten.pm' => 'blib/lib/App/TwitShell/Resources/Shorten.pm',
	},

	EXE_FILES	=> [
		'scripts/TwitShell',
		'scripts/TwitCurses'
	],
 
	'MAN1PODS' 	=> {
		'scripts/TwitShell'  => 'blib/man1/TwitShell.1',
		'scripts/TwitCurses' => 'blib/man1/TwitCurses.1'
	},
	
	'PREREQ_PM'	=> {
		'HTTP::Request::Common'  => 0,
		'LWP::UserAgent' 	 => 0,
		'JSON' 			 => 0,
		'Time::Out' 		 => 0,
		'Curses' 		 => 0,
		'DateTime::Format::HTTP' => 0,
		'Getopt::Long'		 => 0
	},

);
