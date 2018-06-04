# 29 May 2018
# Read module entries and print out:
# ModuleId	Name	Definition	Group

#! /usr/perl/bin -w
use strict;

my $folderin_module_entries="/home/mnguyen/Research/KEGG_23May2018/KEGG_module_entries";
my $fileout="/home/mnguyen/Research/KEGG_23May2018/KEGG_module_definition.txt";

opendir(DIR,"$folderin_module_entries") || die "Cannot open folder $folderin_module_entries";
my @files=readdir(DIR);
closedir(DIR);
open(Out,">$fileout") || die "Cannot open file $fileout";
print Out "#Module_ID\tName\tGroup\tDefinition\n";
foreach my $filein (@files)
{
	if (($filein ne ".") and ($filein ne ".."))
	{
		open(In,"<$folderin_module_entries/$filein") || die "Cannot open file $folderin_module_entries/$filein";
		my $module_id="";
		my $name="";
		my $group="";
		my $definition="";
		while (<In>)
		{
			$_=~s/\s*$//;
			
			if ($_=~/^ENTRY\s*(M\d+)\s*(.+)$/){$module_id=$1;$group=$2;next;}
			if ($_=~/^NAME\s*(.+)$/){$name=$1;next;}
			if ($_=~/^DEFINITION\s*(.+)$/)
			{
				$definition=$1;
				print Out "$module_id\t$name\t$group\t$definition\n";
				last;
			}
		}
		close(In);
	}
}
close(Out);