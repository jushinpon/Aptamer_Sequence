=b
PSO for general fitting purpose developed by Prof. Shin-Pon Ju at NSYSU on 2020/01/30
This script is not allowed to use outside MEL group or without Prof. Ju's permission.

The PSO parameter setting refers to the following paper:
OPTI 2014, "An International Conference on Engineering and Applied Sciences Optimization",
M. Papadrakakis, M.G. Karlaftis, N.D. Lagaros (eds.),Kos Island, Greece, 4-6, June 2014

2020/05/27 use new PSO for balancing global and local search
Local and Global Search Based PSO Algorithm (LGPSO),  
Y. Tan, Y. Shi, and H. Mo (Eds.): ICSI 2013, Part I, LNCS 7928, pp. 129–136, 2013. © Springer-Verlag Berlin Heidelberg 2013 

=cut

##*****************************
##Things should be noted


use strict;
use warnings;
use Data::Dumper;
use File::Copy;


#require './PSO_fitness.pl'; # get the fitness for each iteration
require './preprocessor.pl';#reference data reading and PSO setting
require './keepBetter.pl';#reference data reading and PSO setting

my $rerun = "No"; ##********* If you make it to "Yes",change para_array.dat to para_array_rerun.dat

#########################**** You need to modify the following if you use 
# energy terms:
my %ternary;#for the interaction among three bases (three dimensions [3][3][3], could be 4 D [x][3][3][3])
my %binary;#for the interaction between two bases (two dimensions [3][3], could be 3 D [x][3][3])
my %indiv; # for each base at different position (mainly for local environment) 
my @para_set;# sequential number of all parameter names
#system parameters
my %system_para;
my @refdata;# reference data of the corresponding structures
my @refstr;# the  structure information of all reference data
my @x_min; # lower bounds for all parameters 
my @x_max;# uper bounds for all parameters 
my @eval_array;#keep all required infrmation for refernce data calculation (structure ID, and parameter ID) 
my @pfBest;#keep the best finess values for all particles
my @pBest;#keep the best parameters values for all particles (2D array)
my @x;# the fitted parameters sets for all particles (2D array)
my @v;# the PSO velocity terms 
my @fittedData;# the data by fitted parameters from PSO_fitness
&preprocessor(\%system_para,\@refdata,\@refstr,\%indiv,\%binary,\%ternary,\@para_set,\@x_min,\@x_max,\@eval_array);
# the following is used for checking parameters
## the following is used for checking parametersfor (keys %indiv){chomp;
#print Dumper(\@para_set);

=better to do the input data check using the following bloack when you first conduct this script!!!!

for my $key (keys %system_para){
	print "key and value: $key -> $system_para{$key}\n";
	if (ref $system_para{$key} eq "ARRAY"){
		for my $element (@{$system_para{$key}}){ 
			print "key $key element: $element\n";
		}
               
	}
}

#foreach my $dataID (0..$#refdata){
#	print "****\n No. $dataID: $refdata[$dataID]\n";
#		for (my $seq=0;$seq <$system_para{compNo};$seq++){
#			print "refstr $dataID ID $seq: $refstr[$dataID][$seq]\n";
#		}
#		print "\n";
#}

print "If your input data is correct, you may mark out this block.\n";
sleep(1);
=cut 

my $Number_of_iterations=5000;
# $alphaincr=(0.9-0.4)/$Number_of_iterations; 
 
my $dimension= @para_set;### parameter number to be fitted
my $Number_of_particles=10;# particles number is 4 times dimensions
my $gfBest=1e40; ##set a super large initial value for global minimum
my @gBest; #keep the parameter set for gfBest
my $c1= 0.5 + 0.6932; ##@ p.132 c = 0.5 + ln2
my $c2= 0.5 + 0.6932; ##@ p.132 c = 0.5 + ln2; ##@
my $omega =  0.7213; ##@ p.132 omega = 1/(2*ln2)
# particle velocity
my @v_max; ##@
my @v_min; ##@
my @x_range; ##@

open my $summary, "> fitting_summary.dat";

for (my $j=0; $j < $dimension; $j++){     	
         $x_range[$j] = $x_max[$j] - $x_min[$j];
         $v_max[$j]=$x_max[$j];
         $v_min[$j]=$x_min[$j];                 
}

for (my $i=0; $i<$Number_of_particles; $i++){
   $pfBest[$i]=1e40;## initial fitness values for all particles
}

for (my $i=0; $i<$Number_of_particles; $i++){
## setting initial values for all dimensions	
    for (my $j=0; $j < $dimension; $j++){  	
      $x[$i][$j]=$x_min[$j]+rand(1)*$x_range[$j]; ###initial values for parameters 
	}
}

## rerun this script     
#### If we have got the best parameter already and want to rerun this fitting script
if($rerun eq "Yes" or $rerun eq "yes"){
	print "**rerun work for the initial value of Particle 0***\n";
	unlink "para_array_rerun.dat";#keep old best parameters
	copy("./00para_array.dat","./00para_array_rerun.dat");    	
	open my $rerunarray , "< 00para_array_rerun.dat" or die "No rerun data to read";
	my @temppara=<$rerunarray>;
	close $rerunarray;
	my @para_input=grep (($_!~m/^\s*$/),@temppara);	
	for (0..$#para_input){
	   $x[0][$_]=$para_input[$_];
	   #print "j $j $x[$i][$j] $temppara[$j]\n";
	  }	
}
##### PSO iteration begin

for(my $iteration=1; $iteration <= $Number_of_iterations;  $iteration++){
	for ( my $i=0 ; $i<$Number_of_particles; $i++){   	
### get the fitness here
      my $fitness = &PSO_fitness(\@{$x[$i]},\@refdata,\@eval_array,\@fittedData); #passing ram address
      if ($fitness < $pfBest[$i]){
#      	print "replaced local\n";
          $pfBest[$i]=$fitness;
          for (my $j=0; $j < $dimension; $j++){
               $pBest[$i][$j]=$x[$i][$j];
          }
      }
## print some information for better results of global fitness
	if ($fitness < $gfBest){
		$gfBest=$fitness;
		&keepBetter($fitness,$i,$iteration,\@{$x[$i]},\@gBest,\@refdata,\@fittedData,\@para_set,$summary); #passing ram address
	}
   } # end of first particle loop
  #print "$iteration: $Number_of_iterations 2\n";

# Begin the second particle loop (update parameters)
   for (my $i=0; $i<$Number_of_particles; $i++)
   {

     # $r1=$c1*rand(1);
     # $r2=$c2*rand(1);
   
      for (my $j=0; $j < $dimension; $j++)
      {
         $v[$i][$j] =$c1*rand(1)* ($pBest[$i][$j] - $x[$i][$j]) +  $c2*rand(1) * ($gBest[$j] - $x[$i][$j]); 
         if($v[$i][$j] < 1e-10){
		 $x[$i][$j] = $x[$i][$j] + $v[$i][$j];
		 }
         
          if ($x[$i][$j]<$x_min[$j])  { 
         	  $x[$i][$j]=$x_min[$j];         
         	 }
         		
          if ($x[$i][$j]>$x_max[$j])  { 
         	  $x[$i][$j]=$x_max[$j];
         	 }
      } # dimension loop
  
#########
		if($iteration%100 == 0 or $pfBest[$i] == $gfBest ){
            if($pfBest[$i] == $gfBest){print "#####*********particle $i: gbest $pfBest[$i] == $gfBest pbest\n";};
              
            if ($i == 0)  { 
            print "*********MAKE ALL PARTICLES in RANDOM for iteration $iteration\n";}
            	#print "********* $i local: $pfBest[$i]  glo: $gfBest $i\n\n";
            	#print "********* currentbestP: $currentbestP ## iteration: $iteration\n";
         	    #$tempi = rand(1);
         	    #$tempdr = (rand(2)-1.0)/100.0;
         	    #$r1=$c1*rand(1);
              #$r2=$c2*rand(1);
         	    for ($j=0; $j < $dimension; $j++)
         	   {                 
                $x[$i][$j]=$x_min[$j]+rand(1)*$x_range[$j];
    						
    						######################***********************
                $pBest[$i][$j] = $x_min[$j]+rand(1)*$x_range[$j];
                 
                 if($x_max[$j] == $Cmaxupbond) {
    						}              
              }

             $pfBest[$i]=1e40;## make all Particle best accepted after the random parameters generation
         	 }
 } #particle loop

}# PSO iteration loop

close summary;
