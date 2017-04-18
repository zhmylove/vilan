#!/usr/bin/perl

use strict;
use v5.18;
use warnings;
no warnings 'experimental';
use utf8;
binmode STDOUT, ':utf8';

use adc::common;

=encoding utf-8

=head1 NAME

=head1 FUNCTIONS

=over 4

=cut

package linux_generic;

=item B<new()>

   return: an instance of self object

This function is ctor.

=cut

sub new {
   my $self = shift;
   return bless {}, $self;
}

sub check {
   return `uname -s` =~ "Linux";
}

sub get_self {
   my (%self, %reachable_ips, %own_ips);
   chomp(my @self_addr = `(ip a || ifconfig -a) 2>/dev/null |awk '!/127.0.0.1/ && \$1=="inet"{print}'`);

# find all visible ips
   for (@self_addr) {
      my ($ip, $mask, $mask_for_nmap);

      ($ip, $mask) = m{addr:([\d.]+).*mask:([\d.]+)}i unless $ip;
      ($ip, $mask) = m{inet ([\d.]+)/([\d]+)}i unless $ip;
      next unless $ip;

      $mask = common->mask_to_ip($mask);

      $mask_for_nmap = common->ip_to_mask($mask);
      `nmap -sn $ip\/$mask_for_nmap`;
      chomp(my @arp = `arp -n |awk 'NR>1 && !/incomplete/ {print \$1}'`);
      $reachable_ips{$_} = $mask for @arp;

      $own_ips{$ip} = $mask;
   }
   $self{reachable_ips} = \%reachable_ips;
   $self{own_ips} = \%own_ips;

# determine default GWs
   chomp(my @gws = `route -n |awk 'NR>2 && \$2!="0.0.0.0"{print \$2}'`);
   $self{gws} = \@gws;

   return \%self;
}

1;

=back

=cut
