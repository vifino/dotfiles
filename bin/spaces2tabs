#!/usr/bin/perl
# intended to be invoked from within vim
my $tabstop = @ARGV[0] || 4;
while (<>) {
  s/^((  )+)/"\t" x (length($1)\/$tabstop)/e;
  print;
}
