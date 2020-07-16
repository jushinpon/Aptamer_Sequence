use strict;
use warnings;

my (%system_para,%para_set,@refdata,@refstr);

# reading system information and predction data for evaluation
open my $ss,"< prediction_set.dat";
my @temp_array=<$ss>;
close $ss;  
my @input_array=grep (($_!~m{^\s*$|^#}),@temp_array); # remove blank lines
for (@input_array){$_  =~ s/^\s+|\s+$//;}

#### You need arrange your input data as the following format
chomp ($system_para{dataNo} = $input_array[0]);# total data number
chomp ($system_para{compNo} = $input_array[1]);# total number of compositional units
my @temp = grep ( ($_!~m{^\s*$|^#}), split(/\s+/,$input_array[2]) );
for (0..$#temp){$temp[$_] -= 1;} # make the type ID from 0
chomp( $system_para{typeID} = [@temp]);# all type IDs in compositional units 

@temp = grep ( ($_!~m{^\s*$|^#}),split(/\s+/,$input_array[3]) );
chomp( $system_para{types} = [@temp]);# characters

for (my $dataID=0; $dataID<$system_para{dataNo};$dataID++){
	# get the energy first
    my $temp = 4 + $dataID*($system_para{compNo} + 1);# a set includes energy+ compositions
	chomp ($refdata[$dataID] =  $input_array[$temp]);
	# get the structure information to the above energy by the following loop
		for (my $str=0;$str<$system_para{compNo};$str++){
			my $temp1 = $temp + $str + 1;
			chomp ( $refstr[$dataID][$str] =  $input_array[$temp1] -1);#$str starts from 0 (-1 is to make type from 0)
		}
}   

open my $fittedPara,"< 00fittedPara.dat"; #read fitted parameters
my @temp_paraArray = <$fittedPara>;
close $fittedPara;
my @raw_array=grep (($_!~m{^\s*$|^#}),@temp_paraArray); # remove blank lines
my @paraArray = map {$_  =~ s/^\s+|\s+$//;$_;} @raw_array;

for (@paraArray){
	my @temp = split(/\s+/,$_);
	chomp (@temp);
	$para_set{$temp[0]} = $temp[1];
	#print "$temp[0] $temp[1]\n";
}

## Begin 
open my $eval,"> 00EvalueOut.dat"; #output evaluation result
print  $eval "Reference Predicton error(%)\n";
for (my $dataID=0; $dataID<$system_para{dataNo};$dataID++){
    my @eval_array;#keep all required infrmation for refernce data calculation (structure ID, and parameter ID) 
    my $eval_counter = -1;

    # # local environments $indiv
    #print " sys_para $system_para{compNo}\n";
    #sleep(100);
    for my $temp (0..$system_para{compNo} - 1){
    	chomp $temp;
    	#print "temp, $temp\n";
    	my $hashKey = "Seq$temp-"."$refstr[$dataID][$temp]";
    	$eval_counter += 1;
    	$eval_array[$eval_counter] = $hashKey;
    }
#print "sleep\n";
#sleep(100);
# binary parameter analysis $binary
    	for my $btemp (0..$system_para{compNo} - 2){
    			my $btemp1 = $btemp + 1;
    			chomp $refstr[$dataID][$btemp];
    			chomp $refstr[$dataID][$btemp1];
    			my $hashKey;
    			#if ($refstr[$dataID][$btemp] <= $refstr[$dataID][$btemp1]){
    				 $hashKey = "Seqb$btemp-"."$refstr[$dataID][$btemp]"."-"."$refstr[$dataID][$btemp1]";#}
    			#else {
    			#     $hashKey = "$refstr[$dataID][$btemp1]"."-"."$refstr[$dataID][$btemp]";
                #}
    			$eval_counter += 1;
    			$eval_array[$eval_counter] = $hashKey;
    		}

    # ternary parameter analysis $binary
    	for my $terj (1..$system_para{compNo} - 2){
    			my $teri = $terj - 1;
    			my $terk = $terj + 1;
    			chomp $refstr[$dataID][$teri];
    			chomp $refstr[$dataID][$terj];
    			chomp $refstr[$dataID][$terk];
    			my $hashKey;
    			#if ($refstr[$dataID][$teri] <= $refstr[$dataID][$terk]){
    				 $hashKey = "Seqt$terj-"."$refstr[$dataID][$teri]"."-"."$refstr[$dataID][$terj]".
    				 "-"."$refstr[$dataID][$terk]";#}
    			#else {
    			#	 $hashKey = "$refstr[$dataID][$terk]"."-"."$refstr[$dataID][$terj]".
    			#	 "-"."$refstr[$dataID][$teri]";
    			#}
    			$eval_counter += 1;
    			$eval_array[$eval_counter] = $hashKey;
    		}

    my $fitness = 0.0; 
    #$eval_array array ref for all required paramete ID to calculate
    #$xi array ref for all parameters of particle i
    for my $etemp (@eval_array){
    	#print "etemp:$etemp, $para_set{$etemp}\n";
    	$fitness += $para_set{$etemp};
    }
    my $error = ($fitness - $refdata[$dataID])*100./$refdata[$dataID];
    print  $eval "$refdata[$dataID] $fitness $error\n";
}
close  $eval;