#!/usr/bin/perl -w

use Text::CSV;
use Template;
use encoding 'utf8';
use strict;

my $inputfile = 'kohaman.txt';
my %categories;

# Read the input file
my $csv = Text::CSV->new ( { 
  binary   => 1, 
  sep_char => ',',
} ) or die "Cannot use CSV: ".Text::CSV->error_diag ();
open my $fh, "<:encoding(utf8)", $inputfile or die "$inputfile: $!";
$csv->column_names("category","command","description","synopsis");
my $commands = $csv->getline_hr_all($fh);
$csv->eof or $csv->error_diag();
close $fh;

# Set up TT
my $template = Template->new();

# Build a structure for categories
foreach my $command ( @{$commands} ) {
  push @{$categories{$command->{'category'}}}, $command->{'command'};
}

# Output pages for individual commands
my $count = 0;
foreach my $command ( @{$commands} ) {

  # print $command->{'command'}, "\n"; 
	$count++;
	
	# Sort the commands we wat to list under "See also"
	my @similar = sort @{$categories{$command->{'category'}}};
	
	my $vars = {
    'c'  => $command,
    'so' => \@similar,
  };
  $template->process('command.tt', $vars, "output/$command->{'command'}.xml") 
    || die $template->error();
	
}

# Now do koha-create
my $vars = {
  'commands'   => \@{$commands},
  'categories' => \%categories,
};
$template->process('koha-common.tt', $vars, "output/koha-common.xml") 
  || die $template->error();

print "$count commands processed\n";
