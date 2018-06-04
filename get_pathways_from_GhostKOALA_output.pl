# Read output file from GhostKOALA and print out a summary table as below: 
# LevelA	LevelB	Pathway_ID	LevelC (Pathway name)	Total KOs	Total available KOs	Total unavailable KOs	Pathway completeness
# Metabolism	Carbohydrate metabolism	Glycolysis / Gluconeogenesis	ko00010	103	43	60	42%
# Also, print out list of mapped protein IDs with corresponding pathway information
# Protein Id	KO_ID	KO_desc	PathwayID	Pathway_name	LevelB	LevelA
# All KOs were ordered hierarchically in BRITE database of KEGG website and can be found in file KEGG_Orthology_ko00001.keg

#! /usr/perl/bin -w
use strict;

my $filein_protid_ko="/home/mnguyen/Research/Albert/Pathways_from18May2018/KOALAGhost/Anamu/Anamu_KO_all_proteins_18May2018.txt";
my $filein_brite_ko="/home/mnguyen/Research/KEGG_23May2018/BRITE/KEGG_Orthology_ko00001.keg";
my $fileout_table="/home/mnguyen/Research/Albert/Pathways_from18May2018/KOALAGhost/Anamu/Anamu_KEGG_pathway_table_29May2018.txt";
my $fileout_protlist="/home/mnguyen/Research/Albert/Pathways_from18May2018/KOALAGhost/Anamu/Anamu_KEGG_mapped_proteins_29May2018.txt";

################################################################################################################
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
################################################################################################################



################################################################################################################
# Read KO list hierarchially ordered in BRITE and print out pathway summary table
open(BRITE_KO,"<$filein_brite_ko") || die "Cannot open file $filein_brite_ko";
open(Out,">$fileout_table") || die "Cannot open file $fileout_table";
open(Out1,">$fileout_protlist") || die "Cannot open file $fileout_protlist";
print Out "#LevelA\tLevelB\tPathway_ID\tLevelC (Pathway name)\tTotal KOs\tTotal available KOs\tTotal unavailable KOs\tPathway completeness\n";
print Out1 "#Protein Id\tKO_ID\tKO_desc\tPathwayID\tPathway_name\tLevelB\tLevelA\n";
my $levelA="";
my $levelB="";
my $pathway_name="";
my $pathway_id="";
my $ko_id="";
my $ko_desc="";
my %hash_pwyid_total_kos;
my %hash_pwyid_total_available_kos;

while (<BRITE_KO>)
{
	$_=~s/\s*$//;
	if ($_=~/^A\<b\>(.+)\<\/b\>/){$levelA=$1;next;}
	if ($_=~/^B\s*\<b\>(.+)\<\/b\>/){$levelB=$1;next;}
	if ($_=~/^C\s*\d+\s*(.+)\s*\[PATH\:(ko\d+)\]/)
	{
		if ($ko_id)
		{
			my $total_NA_kos=$hash_pwyid_total_kos{$pathway_id}-$hash_pwyid_total_available_kos{$pathway_id};
			my $percent_complete="";
			if ($hash_pwyid_total_kos{$pathway_id}){$percent_complete=$hash_pwyid_total_available_kos{$pathway_id}/$hash_pwyid_total_kos{$pathway_id};}
			else{print "\nThis pathway has no KO: $pathway_id: $pathway_name\n";exit;}
			print Out "$levelA\t$levelB\t$pathway_id\t$pathway_name\t$hash_pwyid_total_kos{$pathway_id}\t$hash_pwyid_total_available_kos{$pathway_id}\t$total_NA_kos\t$percent_complete\n";
		}
		$ko_id="";$ko_desc="";
		$pathway_name=$1;$pathway_id=$2;
		next;
	}
	if ($_=~/^D\s*(K\d+)\s*(.+)\s*$/)
	{
		$ko_id=$1;$ko_desc=$2;
		$hash_pwyid_total_kos{$pathway_id}++;
		if ($hash_koid_protids{$ko_id})
		{
			$hash_pwyid_total_available_kos{$pathway_id}++;
			my @protein_ids=split(/\;/,$hash_koid_protids{$ko_id});
			foreach my $each_protid (@protein_ids)
			{
				print Out1 "$each_protid\t$ko_id\t$ko_desc\t$pathway_id\t$pathway_name\t$levelB\t$levelA\n";
			}
		}
		next;
	}
}
close(BRITE_KO);

my $total_NA_kos=$hash_pwyid_total_kos{$pathway_id}-$hash_pwyid_total_available_kos{$pathway_id};
my $percent_complete="";
if ($hash_pwyid_total_kos{$pathway_id}){$percent_complete=$hash_pwyid_total_available_kos{$pathway_id}/$hash_pwyid_total_kos{$pathway_id};}
else{print "\nThis pathway has no KO: $pathway_id: $pathway_name\n";exit;}
print Out "$levelA\t$levelB\t$pathway_id\t$pathway_name\t$hash_pwyid_total_kos{$pathway_id}\t$hash_pwyid_total_available_kos{$pathway_id}\t$total_NA_kos\t$percent_complete\n";

close(Out);
close(Out1);
################################################################################################################