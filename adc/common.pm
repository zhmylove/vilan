#!/usr/bin/perl

package common;

my %subnet_to_num = (
   '0.0.0.0' => 0,
   '128.0.0.0' => 1,
   '192.0.0.0' => 2,
   '224.0.0.0' => 3,
   '240.0.0.0' => 4,
   '248.0.0.0' => 5,
   '252.0.0.0' => 6,
   '254.0.0.0' => 7,
   '255.0.0.0' => 8,
   '255.128.0.0' => 9,
   '255.192.0.0' => 10,
   '255.224.0.0' => 11,
   '255.240.0.0' => 12,
   '255.248.0.0' => 13,
   '255.252.0.0' => 14,
   '255.254.0.0' => 15,
   '255.255.0.0' => 16,
   '255.255.128.0' => 17,
   '255.255.192.0' => 18,
   '255.255.224.0' => 19,
   '255.255.240.0' => 20,
   '255.255.248.0' => 21,
   '255.255.252.0' => 22,
   '255.255.254.0' => 23,
   '255.255.255.0' => 24,
   '255.255.255.128' => 25,
   '255.255.255.192' => 26,
   '255.255.255.224' => 27,
   '255.255.255.240' => 28,
   '255.255.255.248' => 29,
   '255.255.255.252' => 30,
   '255.255.255.254' => 31,
   '255.255.255.255' => 32,
);

my %subnet_to_ip = (
   0 => '0.0.0.0',
   1 => '128.0.0.0',
   2 => '192.0.0.0',
   3 => '224.0.0.0',
   4 => '240.0.0.0',
   5 => '248.0.0.0',
   6 => '252.0.0.0',
   7 => '254.0.0.0',
   8 => '255.0.0.0',
   9 => '255.128.0.0',
   10 => '255.192.0.0',
   11 => '255.224.0.0',
   12 => '255.240.0.0',
   13 => '255.248.0.0',
   14 => '255.252.0.0',
   15 => '255.254.0.0',
   16 => '255.255.0.0',
   17 => '255.255.128.0',
   18 => '255.255.192.0',
   19 => '255.255.224.0',
   20 => '255.255.240.0',
   21 => '255.255.248.0',
   22 => '255.255.252.0',
   23 => '255.255.254.0',
   24 => '255.255.255.0',
   25 => '255.255.255.128',
   26 => '255.255.255.192',
   27 => '255.255.255.224',
   28 => '255.255.255.240',
   29 => '255.255.255.248',
   30 => '255.255.255.252',
   31 => '255.255.255.254',
   32 => '255.255.255.255',
   '0x00000000' => '0.0.0.0',     
   '0x80000000' => '128.0.0.0',
   '0xc0000000' => '192.0.0.0',
   '0xe0000000' => '224.0.0.0',
   '0xf0000000' => '240.0.0.0',
   '0xf8000000' => '248.0.0.0',
   '0xfc000000' => '252.0.0.0',
   '0xfe000000' => '254.0.0.0',
   '0xff000000' => '255.0.0.0',      
   '0xff800000' => '255.128.0.0',
   '0xffc00000' => '255.192.0.0',
   '0xffe00000' => '255.224.0.0',
   '0xfff00000' => '255.240.0.0',
   '0xfff80000' => '255.248.0.0',
   '0xfffc0000' => '255.252.0.0',
   '0xfffe0000' => '255.254.0.0',
   '0xffff0000' => '255.255.0.0',    
   '0xffff8000' => '255.255.128.0',
   '0xffffc000' => '255.255.192.0',
   '0xffffe000' => '255.255.224.0',
   '0xfffff000' => '255.255.240.0',
   '0xfffff800' => '255.255.248.0',
   '0xfffffc00' => '255.255.252.0',
   '0xfffffe00' => '255.255.254.0',
   '0xffffff00' => '255.255.255.0',     
   '0xffffff80' => '255.255.255.128',
   '0xffffffc0' => '255.255.255.192',
   '0xffffffe0' => '255.255.255.224',
   '0xfffffff0' => '255.255.255.240',
   '0xfffffff8' => '255.255.255.248',
   '0xfffffffc' => '255.255.255.252',
   '0xfffffffe' => '255.255.255.254',
   '0xffffffff' => '255.255.255.255',      
);

sub ip_to_mask($$) {
   shift; #self
   return $subnet_to_num{$_[0]} // $_[0];
}

sub mask_to_ip($$) {
   shift; #self
   return $subnet_to_ip{$_[0]} // $_[0];
}


sub print_table_ip_mask($\%) {
   shift; #self
   printf "[%s] [%s]\n", $_, $_[0]->{$_} for keys %{ $_[0] };
   printf "Total alive hosts: %s\n",  scalar(keys($_[0]));
}

sub print_gws($\@) {
   shift; #self
   my @gws = @{+shift};
   $" = ' ';
   print "Gateways are:\n@gws\n";
}

sub apply_mask($$$) {
   shift; #self
   my $ip = shift;
   my $mask = shift;
   my $i = 0;
   join ".", map { int($_) & int((split /\./, $mask)[$i++]) } (split /\./, $ip);
}

# ret array
# arg0: self
# arg1: net ip
# arg2: net mask
# arg3: hash with ip => mask
sub find_ips_in_subnet($$$\%) {
   shift; #self
   my $net_ip = shift;
   my $net_mask = shift;
   my $subnet = common->apply_mask($net_ip, $net_mask);
   my @ips;

   #TODO compare masks
   my %ips = %{+shift};
   while (my ($ip, $mask) = each %ips) {
      push @ips, $ip if $subnet eq common->apply_mask($ip, $mask);
   }

   return @ips;
}

1;
