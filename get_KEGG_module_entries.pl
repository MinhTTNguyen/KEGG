# May 23rd 2018
# Download all KEGG module entries

#! /usr/perl/bin -w
use strict;
use File::Fetch;

my $folder_module_entries="/home/mnguyen/Research/KEGG_23May2018/KEGG_module_entries";
my $fileout_module_list="/home/mnguyen/Research/KEGG_23May2018/All_Module_IDs.txt";
my $failed_ids="/home/mnguyen/Research/KEGG_23May2018/KEGG_module_entries_failed.txt";
open(Fail,">$failed_ids") || die "Cannot open file $failed_ids";
mkdir $folder_module_entries;
open(List,"<$fileout_module_list") || die "Cannot open file $fileout_module_list";
chdir $folder_module_entries;
while (<List>)
{
	my $module_pwy_id=$_;
	$module_pwy_id=~s/\s*//g;
	print "\n$module_pwy_id: ";
	my $entry_url='http://rest.kegg.jp/get/'.$module_pwy_id;
	my $file_entry=File::Fetch->new(uri=>$entry_url);
	my $fileout_entry=$file_entry->fetch();# || die $file_entry->error;
	if (-e $fileout_entry){print " succeeded\n";}
	else{print Fail "$module_pwy_id\n";print " failed\n";}
}
close(List);
close(Fail);

