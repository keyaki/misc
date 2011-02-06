package Smokeping::probes::Skype;

=head1 301 Moved Permanently

This is a Smokeping probe module. Please use the command

C<smokeping -man Smokeping::probes::Skype>

to view the documentation or the command

C<smokeping -makepod Smokeping::probes::Skype>

to generate the POD document.

=cut

use strict;
use base qw(Smokeping::probes::basefork);
use Carp;
use LWP::Simple;
use Digest::MD5 qw(md5_hex);

my %onlinemark = (
	_url => 'http://mystatus.skype.com/balloon/%s',
	_hash => {
		'f979d3763b891bd2c30e2b599ba4f5af' => 1,
		'012119d09d44d760e7400380f2061655' => 0.5,
		'8dfd7dc1919b4294ceac1143166e1d13' => 0.75,
		'81c441da042351607ed83313087c03e4' => 0,
		},
    # Japanese hashes only.
    # TODO: Add hashes of non-Japanese icons. 
);

sub pod_hash {
        return {
                name => <<DOC,
Smokeping::probes::Skype - Skype Probe for Smokeping
DOC
                description => <<DOC,
This module probes for users' online status on Skype.
DOC
                authors => <<'DOC',
 keyaki <keyaki.no.kokage@gmail.com>,
DOC
        };
}

sub new($$$)
{
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = $class->SUPER::new(@_);

    unless ($ENV{SERVER_SOFTWARE}) {
	# TODO
    }

    return $self;
}

sub targetvars {
    my $class = shift;
    return $class->_makevars($class->SUPER::targetvars, {
        _mandatory => ['id'],
        id => {
            _doc => "Skype Name",
            _example => 'skypename',
        },
    });
}

sub ProbeDesc($){
    my $self = shift;
    return "Skype online status";
}

sub pingone ($){
    my $self = shift;
    my $target = shift;

    my $id = $target->{vars}{id};
	my $url = sprintf $onlinemark{_url}, $id;

	my $ret = get( $url );
	my $ret_hash = md5_hex($ret);

    my $status = 0;
	if ( exists($onlinemark{_hash}{$ret_hash}) ) {
		$status = $onlinemark{_hash}{$ret_hash};
	}

    my @times;
    my $count = $self->pings($target);
    for (1 .. $count) {
        push @times, $status;
    }

    return @times;
}

1;

# vim: set expandtab ts=4 sw=4 tw=0:
