sub PSO_fitness_SeqDesign{
use strict;
use warnings;
#PSO_fitness(\@{$x[$i]},\@refdata,\@eval_array,\@fittedData);
my ($xi,$fittedData,$para_set) = @_;

### analyze the local structures of each chain
my @eval_array;#keep all required infrmation for refernce data calculation (structure ID, and parameter ID) 
my $eval_counter = -1;

# # local environments $indiv
for my $temp (0..$#{$xi}){
	chomp $temp;
	#print "temp, $temp\n";
	my $hashKey = "Seq$temp-"."$xi->[$temp]";
	$eval_counter += 1;
	$eval_array[$eval_counter] = $hashKey;
}
# binary parameter analysis $binary
	for my $btemp (0..$#{$xi}-1){
			my $btemp1 = $btemp + 1;
			chomp $xi->[$btemp];
			chomp $xi->[$btemp1];
			my $hashKey;
			#if ($xi->[$btemp] <= $xi->[$btemp1]){
				 $hashKey ="Seqb$btemp-"."$xi->[$btemp]"."-"."$xi->[$btemp1]";#}
			#else {
			#	 $hashKey ="Seqb$btemp-"."$xi->[$btemp1]"."-"."$xi->[$btemp]";
			#}
			$eval_counter += 1;
			$eval_array[$eval_counter] = $hashKey;
		}

# ternary parameter analysis $binary
	for my $terj (1..$#{$xi}-1){
			my $teri = $terj - 1;
			my $terk = $terj + 1;
			chomp $xi->[$teri];
			chomp $xi->[$terj];
			chomp $xi->[$terk];
			my $hashKey;
			#if ($xi->[$teri] <= $xi->[$terk]){
				 $hashKey ="Seqt$terj-"."$xi->[$teri]"."-"."$xi->[$terj]".
				 "-"."$xi->[$terk]";#}
			#else {
			#	 $hashKey ="Seqt$terj-"."$xi->[$terk]"."-"."$xi->[$terj]".
			#	 "-"."$xi->[$teri]";
			#}
			$eval_counter += 1;
			$eval_array[$eval_counter] = $hashKey;
		}

my $fitness = 0.0; 
#$eval_array array ref for all required paramete ID to calculate
#$xi array ref for all parameters of particle i
for my $etemp (@eval_array){
#	print "etemp:$etemp, $para_set->{$etemp}\n";
	$fitness += $para_set->{$etemp};
}
#print "Sleeping now\n";
#sleep(100);
#sleep(100);
return $fitness;   	
  
}# sub	
1;# subroutine