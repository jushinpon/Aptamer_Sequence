use strict;
use warnings;
#&preprocessor(\%system_para,\@refdata,\@refstr,\%indiv,\%binary,\%ternary,\@para_set,\@x_min,\@x_max,,\@eval_array);# PSO parameter setting

my ($system_para,$refdata,$refstr,$indiv,$binary,$ternary,$para_set,$x_min,$x_max,$eval_array) = @_;

# reading reference data from input_information.dat
open my $ss,"< input_information.dat"; #From preprocessor
my @temp_array=<$ss>;
close $ss;  
my @input_array=grep (($_!~m{^\s*$|^#}),@temp_array); # remove blank lines
for (@input_array){$_  =~ s/^\s+|\s+$//;}

#### You need arrange your input data as the following format
chomp ($system_para->{dataNo} = $input_array[0]);# total data number
chomp ($system_para->{compNo} = $input_array[1]);# total number of compositional units
my @temp = grep ( ($_!~m{^\s*$|^#}), split(/\s+/,$input_array[2]) );
for (0..$#temp){$temp[$_] -= 1;} # make the type ID from 0
chomp( $system_para->{typeID} = [@temp]);# all type IDs in compositional units 
#### the following is to make the smallest value from 0 (1 is used in input_information.dat)
#for (0..$#{$system_para->{typeID}}) {
#$system_para->{typeID}->[$_] = 	$system_para->{typeID}->[$_] - 1;
#}

@temp = grep ( ($_!~m{^\s*$|^#}),split(/\s+/,$input_array[3]) );
chomp( $system_para->{types} = [@temp]);# characters

for (my $dataID=0; $dataID<$system_para->{dataNo};$dataID++){
	# get the energy first
    my $temp = 4 + $dataID*($system_para->{compNo} + 1);# a set includes energy+ compositions
	chomp ($refdata->[$dataID] =  $input_array[$temp]);
	# get the structure information to the above energy by the following loop
		for (my $str=0;$str<$system_para->{compNo};$str++){
			my $temp1 = $temp + $str + 1;
			chomp ( $refstr->[$dataID]->[$str] =  $input_array[$temp1] -1);#$str starts from 0 (-1 is to make type from 0)
		}
}   

# PSO setting begins

my $eneSum = 0.0;
for (my $counter = 0 ; $counter< $system_para->{dataNo} ; $counter++) {$eneSum +=  $refdata->[$counter];}
#get the average energy for each unit first
my $aveEnePerUnit = $eneSum/($system_para->{dataNo}*$system_para->{compNo}); # reference data No x unit Number of a chain


print "average energy: $aveEnePerUnit\n";

# build lookup tables for all parameters 
#,$indiv,$binary,$ternary,$x_min,$x_max
my $alltypeCounter = -1;# id counter for PSO fitted parameters

# local environments
for (my $str=0;$str<$system_para->{compNo};$str++){
	for my $type (0..$#{$system_para->{typeID}}){
		$alltypeCounter += 1;
		chomp ($str,$type,$alltypeCounter);
		$indiv->{"Seq$str-$type"} = $alltypeCounter;
		$para_set->[$alltypeCounter] = "Seq$str-$type";
	}
}

#for (my $str=0; $str<($system_para->{compNo} - 1); $str++){
for my $type1 (0..$#{$system_para->{typeID}} ){
	for my $type2 ($type1..$#{$system_para->{typeID}}){
		$alltypeCounter += 1;
		chomp ($type1,$type2,$alltypeCounter);
		$binary->{"$type1-$type2"} = $alltypeCounter;
		$para_set->[$alltypeCounter] = "$type1-$type2";        
	}
}
#}
for my $type2 (0..$#{$system_para->{typeID}}){
	for my $type1 (0..$#{$system_para->{typeID}}){
		for my $type3 ($type1..$#{$system_para->{typeID}}){
		 	$alltypeCounter += 1;
		    chomp ($type1,$type2,$type3,$alltypeCounter);
		 	$ternary->{"$type1-$type2-$type3"} = $alltypeCounter;
    		$para_set->[$alltypeCounter] = "$type1-$type2-$type3";        
		}
	}
}
#}
print "totoal PSO parameter Number: $alltypeCounter + 1 \n";

# assign upper and lower bounds for parameters

for (0..$alltypeCounter){
	if($para_set->[$_] =~ "Seq.+"){# "$para_set->[$_]\n";}
		$x_min->[$_] = 1.2*$aveEnePerUnit;# negative
		$x_max->[$_] = 0.0*$aveEnePerUnit;
	}else{
		$x_min->[$_] = 0.1*$aveEnePerUnit;# negative
		$x_max->[$_] = 0.0*$aveEnePerUnit;
	}
}
#print "sleeping\n";
#sleep(100);
### analyze the local structures of each chain

#print Dumper($refstr);
for my $strID (0..$#{$refstr}){
	chomp $strID;
	#print "######structure ID: $strID \n";
	my $eval_counter = -1;
# # local environments $indiv
		for my $temp (0..$#{$refstr->[$strID]}){
			chomp $temp;
			my $hashKey = "Seq$temp-"."$refstr->[$strID]->[$temp]";
			$eval_counter += 1;
			$eval_array->[$strID]->[$eval_counter] = $indiv->{$hashKey};
		}
# binary parameter analysis $binary
	for my $btemp (0..$#{$refstr->[$strID]}-1){
			my $btemp1 = $btemp + 1;
			chomp $refstr->[$strID]->[$btemp];
			chomp $refstr->[$strID]->[$btemp1];
			my $hashKey;
			if ($refstr->[$strID]->[$btemp] <= $refstr->[$strID]->[$btemp1]){
				 $hashKey = "$refstr->[$strID]->[$btemp]"."-"."$refstr->[$strID]->[$btemp1]";}
			else {
				 $hashKey = "$refstr->[$strID]->[$btemp1]"."-"."$refstr->[$strID]->[$btemp]";
			}
			
			$eval_counter += 1;
			$eval_array->[$strID]->[$eval_counter] = $binary->{$hashKey};
		}

# ternary parameter analysis $binary
	for my $terj (1..$#{$refstr->[$strID]}-1){
			my $teri = $terj - 1;
			my $terk = $terj + 1;
			chomp $refstr->[$strID]->[$teri];
			chomp $refstr->[$strID]->[$terj];
			chomp $refstr->[$strID]->[$terk];
			my $hashKey;
			if ($refstr->[$strID]->[$teri] <= $refstr->[$strID]->[$terk]){
				 $hashKey = "$refstr->[$strID]->[$teri]"."-"."$refstr->[$strID]->[$terj]".
				 "-"."$refstr->[$strID]->[$terk]";}
			else {
				 $hashKey = "$refstr->[$strID]->[$terk]"."-"."$refstr->[$strID]->[$terj]".
				 "-"."$refstr->[$strID]->[$teri]";
			}
			$eval_counter += 1;
			$eval_array->[$strID]->[$eval_counter] = $ternary->{$hashKey};
		}

}

#for my $etemp (0..$#{$eval_array}){
#	print "*****Structure ID: $etemp\n";
#	for my $etemp1  (@{$eval_array->[$etemp]}){
#    print $para_set->[$etemp1]."\n";
#	}
#}

#print Dumper($eval_array);

