# June 06th 2018
# Read the brite ordered module list and compare module definition vs available KOs to determine the completeness of the module

#! /usr/bin/perl -w
use strict;

#my $filein="/home/mnguyen/Research/Albert/Pathways_from18May2018/KOALAGhost/Anamu/Anamu_KEGG_module_table_29May2018_test.txt"; #input file with these information #LevelA	LevelB	LevelC	Module_Id	Module name	Module definition	Available KOs	Module completeness
#my $filein="/home/mnguyen/Research/Albert/Pathways_from18May2018/KOALAGhost/Anamu/test_1.txt";
#my $fileout="/home/mnguyen/Research/Albert/Pathways_from18May2018/KOALAGhost/Anamu/test.txt";

#my $filein="/home/mnguyen/07J/ANF_pathway/Pathways_from18May2018/KOALAGhost/Anamu/test_1.txt";
#my $fileout="/home/mnguyen/07J/ANF_pathway/Pathways_from18May2018/KOALAGhost/Anamu/test.txt";

my $filein="test_1.txt";
my $fileout="test.txt";

open(In,"<$filein") || die "Cannot open file $filein";
open(Out,">$fileout") || die "Cannot open file $fileout";
my %hash_available_KOs=();
while (<In>)
{
	$_=~s/\s*$//;
	if ($_=~/^\#/){print Out "$_\tTotal_steps\tMissing_steps\tAvailable_steps\tCompleteness\n";next;}
	my @cols=split(/\t/,$_);
	my $module_id=$cols[3];
	my $module_definition=$cols[5];
	my $available_KOs=$cols[6];
	$available_KOs=~s/\s*//g;
	$module_definition=~s/^\s*//;
	$module_definition=~s/\s*$//;
	
	#print "\n$module_definition\n";exit;
	my $completeness="";
	if ($available_KOs)
	{
		if ($module_definition)
		{
			##############################################################################
			# see which KOs are available
			%hash_available_KOs=();
			my @arr_available_kos=split(/\;/,$available_KOs);
			foreach my $each_ko (@arr_available_kos){$hash_available_KOs{$each_ko}++;}
			##############################################################################
			
			##############################################################################
			# check module definition to see which steps have missing genes
			#print "\n$module_definition\n";
			my @steps=&Separate_steps($module_definition);
			my $total_steps=scalar(@steps);
			print "\nModule definition ($module_id): $module_definition\n";
			print "\n--------------\nTotal steps: $total_steps\n";
			foreach my $x (@steps){print "$x\n";}
			my $missing_step=0;
			my $available_step=0;
			foreach my $step (@steps)
			{
				print "\n^^$step:\n";			
				if ($step=~/\(/)
				{
					my $step_availability=&Check_step($step);
					if ($step_availability eq "available"){$available_step++;}
					else{$missing_step++;}
				}
				else
				{
					my @proteins=split(/[\-\+]/,$step);
					my $total_proteins=scalar(@proteins);
					my $available_proteins=0;
					print "\nstep not check: $step\n";
					foreach my $protein (@proteins)
					{
						#print "protein: $protein\n";
						my $availability=$hash_available_KOs{$protein};
						if($availability){$available_proteins++;}
					}
					
					if ($available_proteins==$total_proteins){$available_step++;}
					else{$missing_step++;}
				}
			}
			if ($missing_step>0){$completeness="not complete";}
			else{$completeness="complete";}
			print Out "$_\t$total_steps\t$missing_step\t$available_step\t$completeness\n";
			##############################################################################
		}else{print "\nError (line ".__LINE__."): no definition found for this module: $module_id\n";exit;}
	}else
	{
		$completeness="no gene found";
		print Out "$_\tNA\tNA\tNA\t$completeness\n";
	}
}
close(In);
close(Out);

##########################################################################################################
sub Check_step
{
			
	my $ways_in_step=$_[0];print "\n++++Check step: $ways_in_step:\n";	
	$ways_in_step=~s/^\(//;
	$ways_in_step=~s/\)$//;
	my @ways=&Separate_steps($ways_in_step);
	my $availability_status="";
	foreach my $way (@ways)
	{
		print "\n--------------$way--\n";		
		if ($way=~/\(/)	{$availability_status=&Check_step($way);}
		elsif ($way=~/\,/){$availability_status=&Check_step($way);}
		elsif ($way=~/ /){$availability_status=&Check_step($way);}
		else
		{
			my @proteins=split(/[\-\+]/,$way);
			my $total_proteins=scalar(@proteins);
			my $available_proteins=0;
			foreach my $protein (@proteins)
			{
				my $availability=$hash_available_KOs{$protein};
				if($availability){$available_proteins++;}
			}
			if ($available_proteins==$total_proteins){$availability_status="available";last;}
		}
	}
	return($availability_status);
}
##########################################################################################################


##########################################################################################################
sub Separate_steps
{
	my $module=$_[0];
	#print "\nSeparate step: $module\n";
	my @separated_steps="";
	my $step_count=0;
	my $element="";
	my $open_paranthese_count=0;
	my $close_paranthese_count=0;
	
	if ($module=~/\(/)
	{
		#print "\nCheck sub: $module\n";		
		my $module_string_len=length($module);
		for (my $i=0;$i<$module_string_len;$i++)
		{
			#print "\nModule string length: $module_string_len\ni: $i\n";			
			my $character=substr($module,$i,1);#print "\nFirst character: $character\n";exit;
			if ($character eq "(")
			{
				$element=$element.$character;
				$open_paranthese_count++;
			}elsif($character eq ")")
			{
				$element=$element.$character;
				$close_paranthese_count++;
			}elsif ($character eq ",")
			{
				
			}
			elsif($character eq " ")
			{
				if ($close_paranthese_count==$open_paranthese_count)
				{
					$separated_steps[$step_count]=$element;
					$step_count++;
					$element="";
					$open_paranthese_count=0;
					$close_paranthese_count=0;
				}else{$element=$element.$character;}
			}else{$element=$element.$character;}
		}
		$separated_steps[$step_count]=$element;
	}elsif ($module=~/\,/){@separated_steps=split(/\,/,$module);}
	else{@separated_steps=split(/ /,$module);}
	return(@separated_steps);
}
##########################################################################################################


