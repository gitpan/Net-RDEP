use strict;

use Net::RDEP;
use XML::Idiom;
use Data::Dumper;

my $RDEP_HOST='127.0.0.1';
my $RDEP_USER='rdepuser';
my $RDEP_PASS='rdeppass';
my $RDEP_TYPE='query';

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
if($r->Type eq 'subscription') {
	print "Checking Subscription\n";
	#while(sleep 1) {
	for(0..1) {
		my $idiom_xml = $r->get;
		if (defined($r->error)) {
			# probably an HTTP problem at this point
			print $r->errorString . "\n";
			$r->close();
		}
		if(defined($idiom_xml)) {
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
	}
	$r->close;
} else {
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
}
