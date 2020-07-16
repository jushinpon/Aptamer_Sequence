sub PSO_fitness{
use strict;
use warnings;
#PSO_fitness(\@{$x[$i]},\@refdata,\@eval_array,\@fittedData);
my ($xi,$refdata,$eval_array,$fittedData) = @_;
my $fitness = 0.0; 
#$eval_array array ref for all required paramete ID to calculate
#$xi array ref for all parameters of particle i
for my $etemp (0..$#{$eval_array}){
	#print "*****Structure ID: $etemp\n";
  my $tempE = 0.0 ;
  my $counter = -1;
	for my $etemp1  (@{$eval_array->[$etemp]}){#$etemp1: the corresponding ID of xi array ref
      $counter += 1;
	  #print "etemp: $etemp, etemp1: $etemp1, tempE: $tempE,counter: $counter\n";
	  $tempE += $xi->[$etemp1]; 
	}
 $fittedData->[$etemp] = $tempE;
 #print "fittedData: $fittedData->[$etemp]\n";
 #$fitness += ( 1 - $tempE/$refdata->[$etemp])*( 1 - $tempE/$refdata->[$etemp]);  
 $fitness += ( $tempE- $refdata->[$etemp])*( $tempE - $refdata->[$etemp]);  
}
#sleep(100);
return $fitness;   	
  
}# sub	
1;# subroutine