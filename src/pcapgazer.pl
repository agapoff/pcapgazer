#!/usr/bin/env perl
#use strict;
use warnings;
use Net::Pcap qw(:functions);
use NetPacket::Ethernet qw(:types);
use NetPacket::IP qw(:protos);
use NetPacket::UDP;
use NetPacket::TCP;
use POSIX qw(strftime);
use Data::Dumper;
use Fcntl qw( :flock );

BEGIN {
	use File::Basename;
	use lib dirname(__FILE__);
}

my $pcap_file = shift @ARGV;

unless ($pcap_file) {
	print "Please define PCAP file name\n";
	exit 2;
}

write_log("Opening file $pcap_file");

my $cfg = &read_config;
if (ref($cfg->{output}) ne 'ARRAY') {
	$cfg->{output} = [ $cfg->{output} ];
}

our %seqnum;
our $count = 0;
my $err;

my $pcap = Net::Pcap::open_offline($pcap_file, \$err) or die "Can't read '$pcap_file': $err\n";

foreach my $output ( @{$cfg->{output}} ) {
	print "Initializing destination $output...\n" if ($cfg->{debug});
	write_log("Initializing destination $output...");

	my $module = "Output/$output.pm";
	if (eval { require $module; 1; }) {
		print "Module $output.pm loaded ok\n" if ($cfg->{debug});
		write_log ("Module $output.pm loaded ok");
		unless ("Output::${output}::init"->($cfg->{$output},\&write_log)) {
			$cfg->{$output}->{disabled} = 1;
			print "Module $output init failed. Disabling...\n";
			write_log("Module $output init failed. Disabling...");
		}
	} else {
		print "Could not load $output.pm. Error Message: $@\n";
		write_log ("Could not load $output.pm. Error Message: $@");
		exit;
	}
}


Net::Pcap::loop($pcap, 0, \&process_packet, '');
Net::Pcap::close($pcap);

print "Found and sent $count events\n" if ($cfg->{debug});
write_log("Found and sent $count events");
exit;

sub process_packet {
	my ($user_data, $header, $packet) = @_;

	my $eth_data = NetPacket::Ethernet::strip($packet);

	# Here goes a hack to support dumps taken with "-i any"
	# the problem is that there are two extra bytes between eth header and IP header
	my $first_byte = substr($eth_data, 0, 1); 
	if (ord($first_byte) >> 4 != 4) { # First 4 bits of IPv4 header should be 4
		my $third_byte = substr($eth_data, 2, 1);
		if (ord($third_byte) >> 4 == 4) {
			$eth_data = substr($eth_data, 2);
		} else {
			return;
		}
	}
	my $ip = NetPacket::IP->decode($eth_data);
	if ($ip->{proto} == IP_PROTO_TCP) {
		my $tcp = NetPacket::TCP->decode($ip->{data});
		my $key = $ip->{src_ip}.':'.$tcp->{src_port}.' '.$ip->{dest_ip}.':'.$tcp->{dest_port};
		if (defined $seqnum{$key} && $tcp->{seqnum} <= $seqnum{$key} && $tcp->{seqnum} > $seqnum{$key}/2) {

			my %event = (
				timestamp => $header->{tv_sec},
				src_ip   => $ip->{src_ip},
				src_port => $tcp->{src_port},
				dest_ip    => $ip->{dest_ip},
				dest_port  => $tcp->{dest_port},
				type       => 'retransmit'
			);


			foreach my $output (@{$cfg->{output}} ) {
				next if ($cfg->{$output}->{disabled});
				my $resp = "Output::${output}::push"->(\%event, $cfg->{$output},\&write_log);
			}
			$count++;

		} else {
			$seqnum{$key} = $tcp->{seqnum};
		}
	} else {

	}
}


sub read_config {
	use File::Basename;
	my $myPath = dirname(__FILE__);
	my %var;
	my $cf = $myPath."/config.ini"; 
	my $block;
	if (-s $cf and open(CONF, "<$cf")) {
		while (<CONF>) {
			chomp;
			next if /^\s*(#.*)*$/o; # skip comments and empty lines
			if (/^\[(.+)\]\s*$/) {
				$block = $1;
			}
			next unless /^(\S+)\s*=\s*([^#]*)/o;

			my ($key, $val) = ($1, $2);
			if ($val =~ /,/o) {
				if ($block) {
					$var{$block}->{$key} = [ split(/,\s/, $val) ];
				} else {
					$var{$key} = [ split(/,\s?/, $val) ];
				}
				next;
			}
			elsif ($val =~ /^'(.*)'$/o) {
				$val = $1;
			}
			elsif ($val =~ /^"(.*)"$/o) {
				$val = $1;
			}
			if ($block) {
				$var{$block}->{$key} = $val;
			} else {
				$var{$key} = $val;
			}
		}
		close(CONF);
	}
	return \%var;
}

sub open_log ($;$) {
	my $filename = shift;
	my $lock = shift;
	my $tmpfh;
	defined($filename) or croak("no filename given to open_log()");
	open $tmpfh, ">>$filename" or die(3, "Error: failed to open file '$filename': $!");
	if($lock){
		flock($tmpfh, LOCK_EX | LOCK_NB) or die "Failed to aquire a lock on file '$filename', another instance of this code may be running?";
	}
	return $tmpfh;
}


sub write_log {
	my $text = shift;
	my $logfh = open_log("/var/log/pcapgazer/pcapgazer.log",1);
	my $date = strftime "%Y-%m-%d %H:%M:%S", localtime;
	print $logfh $date.' '.$text."\n";
	close $logfh;
	return;
}

