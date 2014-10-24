#!/usr/local/ActivePerl-5.8/bin/perl -w
use strict;

use Net::RDEP;
use XML::Idiom;
use Data::Dumper;

#my $RDEP_HOST='208.221.18.61';
my $RDEP_HOST='10.1.37.1';
my $RDEP_USER='open';
my $RDEP_PASS='op3n=9!';
my $RDEP_TYPE='subscription';

#
# Obviously, we'll want to do some *real* event processing here...
sub printEvent {
	my $event_ref = shift;

	print "##########\nEVENT:\n";
	print Dumper($event_ref);
	print "\n##########\n";
}


my $r = Net::RDEP->new();

$r->Username($RDEP_USER);
$r->Password($RDEP_PASS);
$r->Server($RDEP_HOST);
$r->Type($RDEP_TYPE);

my $idiom = XML::Idiom->new();
print "Checking Query\n";
my $idiom_xml = $r->get;
if (defined($r->error)) {
	print $r->errorString . "\n" if (defined($r->error));
} else {
	$idiom->consume($idiom_xml);
	if (defined($idiom->isError())) {
		print "ERROR TYPE: " . $idiom->errorType . "\n";
		print "ERROR Content: " . $idiom->errorContent . "\n";
	} else {
		while (my $e = $idiom->getNextEvent()) {
			printEvent($e);
		}
	}
}
