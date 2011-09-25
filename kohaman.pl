#!/usr/bin/perl -w

use Text::CSV;
use Template;
use encoding 'utf8';
use strict;

my $inputfile = 'kohaman.txt';

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

my $count = 0;
foreach my $command ( @{$commands} ) {

  print $command->{'command'}, "\n"; 
	$count++;
	
	my $vars = {
    'c' => $command,
  };
  $template->process('command.tt', $vars, "output/$command->{'command'}.xml") 
    || die $template->error();
	
}

print "$count commands processed\n";
