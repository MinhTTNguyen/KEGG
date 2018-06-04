# 29th May 2018
# Read list of KOs assigned for proteins of interest from GhostKOALA, then see which modules in BRITE module list is complete
# Output file
# #LevelA	LevelB	LevelC	ModuleId	Module name	Module definition	Available KOs	Module completeness

#! /usr/perl/bin -w
use strict;

my $filein_module_def="/home/mnguyen/Research/KEGG_23May2018/KEGG_module_definition.txt";
my $filein_protid_ko="/home/mnguyen/Research/Albert/Pathways_from18May2018/KOALAGhost/Anamu/Anamu_KO_all_proteins_18May2018.txt";
my $filein_brite_modules="/home/mnguyen/Research/KEGG_23May2018/BRITE/KEGG_Modules_ko00002.keg";
my $fileout="/home/mnguyen/Research/Albert/Pathways_from18May2018/KOALAGhost/Anamu/Anamu_KEGG_module_table_29May2018_test.txt";
##################################################################################################################################################
# Get definition (KOs) of all modules
open(MOD_DEF,"<$filein_module_def") || die "Cannot open file $filein_module_def";
my %hash_mod_def;
while (<MOD_DEF>)
{
	$_=~s/\s*$//;
	if ($_!~/^#/)
	{
		my @cols=split(/\t/,$_);
		my $module_id=$cols[0];
		my $definition=$cols[3];
		$hash_mod_def{$module_id}=$definition;
	}
}
close(MOD_DEF);
##################################################################################################################################################


##################################################################################################################################################
# Read file containing KO ID assigned for each protein ID (output file from GhostKOALA)
my %hash_koid_protids;
open(PROT_KO,"<$filein_protid_ko") || die "Cannot open file $filein_protid_ko";
while (<PROT_KO>)
{
	$_=~s/\s*$//;
	my @cols=split(/\t/,$_);
	my $protein_id=$cols[0];
	my $KO_ID=$cols[1];
	$protein_id=~s/\s*//g;
	$KO_ID=~s/\s*//g;
	if ($KO_ID)
	{
		if ($hash_koid_protids{$KO_ID}){$hash_koid_protids{$KO_ID}=$hash_koid_protids{$KO_ID}.";".$protein_id;}
		else{$hash_koid_protids{$KO_ID}=$protein_id;}
	}
}
close(PROT_KO);
##################################################################################################################################################


##################################################################################################################################################
# read list of modules in BRITE and print output
open(BRITE_MOD,"<$filein_brite_modules") || die "Cannot open file $filein_brite_modules";
open(Out,">$fileout") || die "Cannot open file $fileout";
print Out "#LevelA\tLevelB\tLevelC\tModule_Id\tModule name\tModule definition\tAvailable KOs\tModule completeness\n";
my $levelA="";
my $levelB="";
my $levelC="";
my $mod_id="";
my $mod_name="";
my $mod_def="";
my $available_KOs="";
while (<BRITE_MOD>)
{
	$_=~s/\s*$//;
	if ($_=~/^A\<b\>(.+)\<\/b\>/){$levelA=$1;next;}
	if ($_=~/^B\s*\<b\>(.+)\<\/b\>/){$levelB=$1;next;}
	if ($_=~/^C\s*(.+)\s*$/){$levelC=$1;next;}
	if ($_=~/^D\s*(M\d+)\s*(.+)\s*/)
	{
		if ($levelA)
		{
			if ($available_KOs)
			{
				#my $completeness=&Check_module_compleness($available_KOs,$mod_def);
				my $completeness="will check later";
				print Out "$levelA\t$levelB\t$levelC\t$mod_id\t$mod_name\t$mod_def\t$available_KOs\t$completeness\n";
			}else
			{
				print Out "$levelA\t$levelB\t$levelC\t$mod_id\t$mod_name\t$mod_def\t$available_KOs\tempty\n";
			}
		}
		$mod_id=$1;$mod_name=$2;$mod_def=$hash_mod_def{$mod_id};
		$available_KOs="";
		next;
	}
	if ($_=~/^E\s*(K\d+)/)
	{
		my $ko_id=$1;
		if ($hash_koid_protids{$ko_id})
		{
			if ($available_KOs){$available_KOs=$available_KOs.";".$ko_id;}
			else{$available_KOs=$ko_id;}
		}
		next;
	}
}

if ($available_KOs)
{
	my $completeness="will check later";
	print Out "$levelA\t$levelB\t$levelC\t$mod_id\t$mod_name\t$mod_def\t$available_KOs\t$completeness\n";
}
else{print Out "$levelA\t$levelB\t$levelC\t$mod_id\t$mod_name\t$mod_def\t$available_KOs\tempty\n";}

close(Out);
close(BRITE_MOD);
##################################################################################################################################################
