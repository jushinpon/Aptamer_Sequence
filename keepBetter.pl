 sub keepBetter{

use strict;
use warnings;
#&keepBetter($fitness,$i,$iteration,\@{$x[$i]},\@gBest,\@refdata,\@fittedData,\@para_set,$summary); #passing ram address
my ($fitness,$i,$iteration,$xi,$gBest,$refdata,$fittedData,$para_set,$summary) = @_; #passing ram address

print $summary "Lower global fitness: $fitness, Iteration: $iteration, Particle: $i\n";
#print "******** Current Best iteration: $iteration,  Particle ID: $i\n";
#print "Current Best fitness: $fitness\n";
#print "\n\n";

unlink "00Comparison4Best.txt";
open my $comp,"> 00Comparison4Best.txt"; # write data into BestCrystal.dat
print $comp "StructureID, refdata, fitted data, error\n";

#$refdata,$fittedData
for (0..$#{$refdata}){
    chomp;
    chomp $fittedData->[$_];
    chomp $refdata->[$_];

    if($refdata->[$_] != 0.0){
        my $percent = (($fittedData->[$_]/$refdata->[$_]) - 1)*100.0;
        chomp $percent;
        print $comp "$_ $refdata->[$_] $fittedData->[$_] $percent\% \n";}
    else{
        print $comp "$_ $refdata->[$_] $fittedData->[$_] NULL\n";
    }
}
close($comp);
#unlink "00para_array.dat";
open my $bestpara , "> 00Bestpara_I$iteration"."_P$i.dat"; 
for (0..$#{$xi}){
    $gBest->[$_] = $xi->[$_];
    chomp $gBest->[$_];
    chomp $para_set->[$_];    
    print $bestpara "$para_set->[$_] $gBest->[$_]\n";
}
close $bestpara;

# for rerun
unlink "00para_array.dat";
open my $paraarray , "> 00para_array.dat";  	
for (0..$#{$xi}){
    $gBest->[$_] = $xi->[$_];
    chomp $gBest->[$_];
    chomp $para_set->[$_];    
    print $paraarray "$para_set->[$_] $gBest->[$_]\n";
}
close $paraarray;


       
}# sub	
1;# subroutine