package Slim::Web::Settings::Server::Debugging;

# $Id$

# SqueezeCenter Copyright 2001-2007 Logitech.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License,
# version 2.

use strict;
use base qw(Slim::Web::Settings);

use Slim::Utils::Log;
use Slim::Utils::Strings qw(string);

sub name {
	return Slim::Web::HTTP::protectName('DEBUGGING_SETTINGS');
}

sub page {
	return Slim::Web::HTTP::protectURI('settings/server/debugging.html');
}

sub handler {
	my ($class, $client, $paramRef, $pageSetup) = @_;

	# If this is a settings update
	if ($paramRef->{'saveSettings'}) {

		my $categories = Slim::Utils::Log->allCategories;

		for my $category (keys %{$categories}) {

			Slim::Utils::Log->setLogLevelForCategory(
				$category, $paramRef->{$category}
			);
		}

		Slim::Utils::Log->persist($paramRef->{'persist'} ? 1 : 0);

		# $paramRef might have the overwriteCustomConfig flag.
		Slim::Utils::Log->reInit($paramRef);
	}

	# Pull in the dynamic debugging levels.
	my $debugCategories = Slim::Utils::Log->allCategories;
	my @validLogLevels  = Slim::Utils::Log->validLevels;
	my @categories      = (); 

	for my $debugCategory (sort keys %{$debugCategories}) {

		my $string = Slim::Utils::Log->descriptionForCategory($debugCategory);

		push @categories, {
			'label'   => Slim::Utils::Strings::getString($string),
			'name'    => $debugCategory,
			'current' => $debugCategories->{$debugCategory},
		};
	}

	#$paramRef->{'categories'} = [ sort { $a->{'label'} cmp $b->{'label'} } @categories ];
	$paramRef->{'categories'} = \@categories;
	$paramRef->{'logLevels'}  = \@validLogLevels;
	$paramRef->{'persist'}    = Slim::Utils::Log->persist;

	$paramRef->{'debugServerLog'}  = Slim::Utils::Log->serverLogFile;
	$paramRef->{'debugScannerLog'} = Slim::Utils::Log->scannerLogFile;
	$paramRef->{'debugPerfmonLog'} = Slim::Utils::Log->perfmonLogFile if $::perfmon;

	return $class->SUPER::handler($client, $paramRef, $pageSetup);
}

1;

__END__
