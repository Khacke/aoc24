#!/usr/bin/perl

use strict;
use warnings;

if (!$ARGV[0]) {
    die("No filename provided");
}

my $filename = $ARGV[0];

open(my $file, '<', $filename) or die "Cannot open file: $!\n";

my $result = 0;

#bool
my $do = 1;

while (my $line = <$file>) {
    while($line =~ /(do\(\)|don't\(\)|mul\((\d{1,3}),(\d{1,3})\))/g) {
        if ($1 eq "do()") {
            $do = 1;
        } elsif ($1 eq "don\'t()") {
            $do = 0;
        } else {
            if ($do) {
                $result = $result + ($2 * $3);
            }
        }
    }
}
print "Result is $result\n";

close($file);
