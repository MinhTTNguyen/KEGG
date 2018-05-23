# May 23rd 2018
# Read kopathway entries and print out:
# PathwayId	Name	Description	Class	KO_IDs

#! /usr/perl/bin -w
use strict;

my $folderin_kopathway_entries="/home/mnguyen/Research/KEGG_23May2018/KEGG_KOPATHWAY_entries";
my $fileout="/home/mnguyen/Research/KEGG_23May2018/KEGG_KOPATHWAY_entries.tbl";

opendir(DIR,$folderin_kopathway_entries) || die "Cannot open folder $folderin_kopathway_entries";
my @files=readdir(DIR);
closedir(DIR);

open(Out,">$fileout") || die "Cannot open file $fileout";
print Out "#PathwayID\tNAME\tCLASS\tKO_IDs\tDESC\n";
foreach my $file (@files)
{
	if (($file ne ".") and ($file ne ".."))
	{
		open(In,"<$folderin_kopathway_entries/$file") || die "Cannot open file $folderin_kopathway_entries/$file";
		my $id="";
		my $name="";
		my $desc="";
		my $class="";
		my $ko_ids;
		my $ko_flag=0;
		while (<In>)
		{
			$_=~s/\s*$//;
			if ($_=~/^ENTRY/)
			{
				$_=~s/^ENTRY\s+//;
				$_=~s/\s+.+$//;
				$id=$_;
			}
			
			if ($_=~/^NAME/)
			{
				$_=~s/^NAME\s*//;
				$name=$_;
			}
			
			if ($_=~/^DESCRIPTION/)
			{
				$_=~s/^DESCRIPTION\s*//;
				$desc=$_;
			}
			
			if ($_=~/^CLASS/)
			{
				$_=~s/^CLASS\s*//;
				$class=$_;
			}
			
			if ($_=~/^ORTHOLOGY/)
			{
				$ko_flag++;
				$_=~s/^ORTHOLOGY\s*//;
				$_=~s/\s+.+$//;
				$ko_ids=$_;
				next;
			}
			
			if ($ko_flag>0)
			{
				if ($_=~/^\s+/)
				{
					$_=~s/^\s*//;
					$_=~s/\s+.+$//;
					$ko_ids=$ko_ids." ; ".$_;
				}else{$ko_flag=0;}
			}
			
			if ($_=~/\/\/\//){print Out "$id\t$name\t$class\t$ko_ids\t$desc\n";}
			
		}
		close(In);
	}
}

close(Out);