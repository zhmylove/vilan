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

sub check_local {
   return `uname -s` =~ "Linux";
}

sub check_remote($$) {
   shift; #self
   my $target_ip = shift;
   #TODO
}

sub get_self_local {
   my (%self, %reachable_ips, %own_ips);
   chomp(my @self_addrs = `(ip a || ifconfig -a) 2>/dev/null |awk '!/127.0.0.1/ && \$1=="inet"{print}'`);

# find all visible ips
   for (@self_addrs) {
      my ($ip, $mask, $mask_for_nmap);

      ($ip, $mask) = m{addr:([\d.]+).*mask:([\d.]+)}i unless $ip;
      ($ip, $mask) = m{inet ([\d.]+)/([\d]+)}i unless $ip;
      next unless $ip;

      $mask = common->mask_to_ip($mask);

      $mask_for_nmap = common->ip_to_mask($mask);
      `nmap -sn -n $ip\/$mask_for_nmap`;
      chomp(my @arp = `arp -n |awk 'NR>1 && !/incomplete/ {print \$1}'`);
      $reachable_ips{$_} = $mask for @arp;

      $own_ips{$ip} = $mask;
   }
   $self{reachable_ips} = \%reachable_ips;
   $self{own_ips} = \%own_ips;

# determine default GWs
   chomp(my @gws = `netstat -rn |awk '\$4~/G/{print \$2}'`);
   $self{gws} = \@gws;

# determine location of screen and openssh
   chomp(my $screen_location = `which screen`);
   chomp(my $openssh_location = `which ssh`);
   $self{screen} = $screen_location;
   $self{openssh} = $openssh_location;

   return \%self;
}

sub get_self_remote($$) {
   shift; #self
   my $target_ip = shift;
   #TODO
}


1;

=back

=cut
