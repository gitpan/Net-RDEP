#!/usr/local/ActivePerl-5.8/bin/perl -w
use strict;

use Net::RDEP;
use XML::Idiom;
use Data::Dumper;

my $RDEP_HOST='208.221.18.61';
my $RDEP_USER='open';
my $RDEP_PASS='op3n=9!';
my $RDEP_TYPE='subscription';

my $RDEP_POLL_INTERVAL=10;

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
print "Checking Subscription\n";
while(sleep $RDEP_POLL_INTERVAL) {
	my $idiom_xml = $r->get;
	if (defined($r->error)) {
		# probably an HTTP problem at this point
		print $r->errorString . "\n";
		$r->close();
	} elsif(defined($idiom_xml)) {
		$idiom->consume($idiom_xml);
		if (defined($idiom->isError())) {
			my $h = $idiom->getError();
			my $name = $h->{ 'name' };
			my $cont = $h->{ 'content' };
			print "Name: $name\n";
			print "Content: $cont\n";
			# probably a protocol issue at this point
			$r->close();
		} else {
			my $number_of_events = $idiom->getNumberOfEvents();
			print "RCVD $number_of_events number of events\n";
			while(my $e = $idiom->getNextEvent()) {
				printEvent($e);
			}
		}
	} else {
		print "No events\n";
	}
	print "Sleeping...\n";
	#sleep $RDEP_POLL_INTERVAL;
}
$r->close;
