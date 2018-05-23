# May 23rd 2018
# Download all KEGG KO entries

#! /usr/perl/bin -w
use strict;
use File::Fetch;

my $folder_KO_entries="/home/mnguyen/Research/KEGG_23May2018/KEGG_KO_entries";
my $fileout_ko_list="/home/mnguyen/Research/KEGG_23May2018/All_KO_IDs.txt";
mkdir $folder_KO_entries;
open(List,"<$fileout_ko_list") || die "Cannot open file $fileout_ko_list";
chdir $folder_KO_entries;
while (<List>)
{
	my $ko_id=$_;
	$ko_id=~s/\s*//g;
	#print "\n$ko_id\n";exit;
	my $entry_url='http://rest.kegg.jp/get/'.$ko_id;
	my $file_entry=File::Fetch->new(uri=>$entry_url);
	my $fileout_entry=$file_entry->fetch() || die $file_entry->error;
}
close(List);

