package Smokeping::probes::ymsgr;

=head1 301 Moved Permanently

This is a Smokeping probe module. Please use the command

C<smokeping -man Smokeping::probes::ymsgr>

to view the documentation or the command

C<smokeping -makepod Smokeping::probes::ymsgr>

to generate the POD document.

=cut

use strict;
use base qw(Smokeping::probes::basefork);
use Carp;
use LWP::Simple;
use Digest::MD5 qw(md5_hex);

my %onlinemark = (
	'default' => {
		_url => 'http://opi.yahoo.com/online?u=%s&m=g&t=0',
		_hash => '9e31b63daa88647ead982d2c7598e634'
		},
	'jp'      => {
		_url => 'http://opi.yahoo.co.jp/online?u=%s&m=g&t=0',
		_hash => 'e7610ba7de23d5d08d7770f0d7aefcb7'
		},
);

sub pod_hash {
        return {
                name => <<DOC,
Smokeping::probes::ymsgr - Yahoo! Messenger Probe for Smokeping
DOC
                description => <<DOC,
This module probes for users' online status of Yahoo! Messenger.
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
        _mandatory => ['yid'],
        yid => {
            _doc => "Yahoo! ID",
            _example => '[username]',
            _re => '^[a-z][0-9a-z_]{3,30}$',
        },
        type => {
            _doc => "ID Type (default = Yahoo! ID, jp = Yahoo! JAPAN ID)",
            _default => 'default',
            _sub => sub {
                my $type = shift;
                if ( ! exists($onlinemark{$type}) ) {
                    return "ERROR: Invalid type parameter";
                }
                return undef;
            },
        },
    });
}

sub ProbeDesc($){
    my $self = shift;
    return "Yahoo! Messenger online status";
}

sub pingone ($){
    my $self = shift;
    my $target = shift;

    my $yid = $target->{vars}{yid};
    my $type = $target->{vars}{type};
    my $url = sprintf $onlinemark{$type}{_url}, $yid;

    my @times;
    my $count = $self->pings($target);
    for (1 .. $count) {
        sleep 1;

        my $ret = get( $url );
        my $ret_hash = md5_hex($ret);

        my $status = 0;
        if ( $ret_hash eq $onlinemark{$type}{_hash} ) {
            $status = 1;
        }

        push @times, $status;
    }

    return @times;
}

1;

# vim: set expandtab ts=4 sw=4 tw=0:
