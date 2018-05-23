# May 23rd 2018
# Download all KEGG KO entries

#! /usr/perl/bin -w
use strict;
use File::Fetch;

my $folder_KO_entries="/home/mnguyen/Research/KEGG_23May2018/KEGG_KOPATHWAY_entries";
my $fileout_ko_list="/home/mnguyen/Research/KEGG_23May2018/All_kopathway_IDs.txt";
my $failed_ids="/home/mnguyen/Research/KEGG_23May2018/KEGG_KOPATHWAY_entries_failed.txt";
open(Fail,">$failed_ids") || die "Cannot open file $failed_ids";
mkdir $folder_KO_entries;
open(List,"<$fileout_ko_list") || die "Cannot open file $fileout_ko_list";
chdir $folder_KO_entries;
while (<List>)
{
	my $ko_pwy_id=$_;
	$ko_pwy_id=~s/\s*//g;
	print "\n$ko_pwy_id: ";
	my $entry_url='http://rest.kegg.jp/get/'.$ko_pwy_id;
	my $file_entry=File::Fetch->new(uri=>$entry_url);
	my $fileout_entry=$file_entry->fetch();# || die $file_entry->error;
	if (-e $fileout_entry){print " succeeded\n";}
	else{print Fail "$ko_pwy_id\n";print " failed\n";}
}
close(List);
close(Fail);

