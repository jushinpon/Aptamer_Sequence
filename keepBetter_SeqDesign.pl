 sub keepBetter_SeqDesign{

use strict;
use warnings;
#&keepBetter($fitness,$i,$iteration,\@{$x[$i]},\@gBest,\@refdata,\@fittedData,\@para_set,$summary); #passing ram address
my ($system_para,$fitness,$i,$iteration,$gBest,$summary) = @_; #passing ram address

print $summary "**Lower global fitness: $fitness, Iteration: $iteration, Particle: $i\n";
#print "******** Current Best iteration: $iteration,  Particle ID: $i\n";
#print "Current Best fitness: $fitness\n";
#print "\n\n";

#unlink "00Comparison4Best.txt";
#open my $comp,"> 00Comparison4Best.txt"; # write data into BestCrystal.dat
#print $comp "StructureID, refdata, fitted data, error\n";
#
##$refdata,$fittedData
#for (0..$#{$refdata}){
#    chomp;
#    chomp $fittedData->[$_];
#    chomp $refdata->[$_];
#
#    if($refdata->[$_] != 0.0){
#        my $percent = (($fittedData->[$_]/$refdata->[$_]) - 1)*100.0;
#        chomp $percent;
#        print $comp "$_ $refdata->[$_] $fittedData->[$_] $percent\% \n";}
#    else{
#        print $comp "$_ $refdata->[$_] $fittedData->[$_] NULL\n";
#    }
#}
#close($comp);
#unlink "00para_ar ray.dat";
#open my $bestpara , "> 00BestSeq_I$iteration"."_P$i.dat"; 
#print $bestpara "Current lowest fitness:$fitness\n";
print $summary "*Sequence:";

for (@{$gBest}){
   chomp $system_para->{types}->[$_];
   print $summary $system_para->{types}->[$_];
}
   
   print $summary "\n";
#   print "\n";
#close $bestpara;

## for rerun
#unlink "00para_array.dat";
#open my $paraarray , "> 00para_array.dat";  	
#for (@{$gBest}){
#    chomp $system_para->{types}->[$_];
#    print $paraarray $system_para->{types}->[$_];
#}
#close $paraarray;


       
}# sub	
1;# subroutine