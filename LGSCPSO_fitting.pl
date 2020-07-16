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
#use MCE::Shared;
#use Parallel::ForkManager;

require './PSO_fitness.pl'; # get the fitness for each iteration
require './preprocessor.pl';#reference data reading and PSO setting
require './keepBetter.pl';#reference data reading and PSO setting

##### remove old files first
my @oldfiles = <00Bestpara_I*_P*.dat>;
for (@oldfiles){
	unlink $_;
	print "remove $_\n"; 	
}
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
#my @pfBest;#keep the best finess values for all particles
#my @pBest;#keep the best parameters values for all particles (2D array)
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

my $forkNo = 1;
#my $pm = Parallel::ForkManager->new("$forkNo");

# and see 00paraRange_informationModify.dat for real parameter range for PSO_fitting 
my $lowestfitID; # keep the particle ID for the lowest-fitness one 
my @refname; 
my @weight_value;
my @constraintID; # used if the parameters have some constraining conditions

#tie my @fitness,'MCE::Shared'; # fitness for each particle
#tie my @lmpdata, 'MCE::Shared';# lmp calculation results for each particle
my @fitness; # fitness for each particle
my @lmpdata;# lmp calculation results for each particle

my $Number_of_iterations= 50000;
my $Number_of_particles = 100;##@ p.132 c = 0.5 + ln2

# establish the neighborhood topology by SLR method
#k -> k-2, k+1, k+3, k-4 (4 neighbours of each particle k)
# if neighbour id <= 0, add total particle number to modify neighbour ids

my @SLR_table;#2D array, id, neighbours
my @SLR_operator = (-4,-2,1,3);
#print @SLR_operator."\n";
for my $pid (0..$Number_of_particles-1){
    for my $soid (0..$#SLR_operator){
        my $lid = $pid + $SLR_operator[$soid];
        if ($lid < 0){
            $lid = $lid + $Number_of_particles;
        }elsif($lid >= $Number_of_particles){
            $lid = $lid - $Number_of_particles;
        }
        $SLR_table[$pid][$soid] = $lid;
    }
}
#print "Sleep 1\n";
#sleep(100);

#tie my @pfBest, 'MCE::Shared';
#tie my @pBest, 'MCE::Shared';

my @pfBest;
my @pBest;

my @plfBest;# local group best
my @plBest;# parameters of local group best particle

my $gfBest=1e40; ##set a super large initial value for global minimum
my @gBest; 
#my $c1=2.; ##@
#my $c2=2.; ##@
my $c1= 1.49445; 
my $c2= 1.49445; 
my $alpha1 =  0.3;# weighting for particle best
my $alpha2 =  0.7;# weighting for local group best
# http://dx.doi.org/10.1155/2014/905712 
my $omega =  1.2; 
my $omega_max =  1.2; 
my $omega_min =  0.4; 
#my $half_omega = $omega/1.5; # can be tuned
# particle velocity
my @v_max; 
my @v_min; 
my @x_range;
my $v_scaler = 0.1;# scale range of each dimension

my $dimension =  @para_set;### parameter number to be fitted

open my $summary, ">fitting_summary.dat";

for (my $j=0; $j < $dimension; $j++){     	
         $x_range[$j] = $x_max[$j] - $x_min[$j];
         $v_max[$j]=($x_range[$j]/2.0) * $v_scaler;
         $v_min[$j]= (-$x_range[$j]/2.0) * $v_scaler;                 
}

for (my $i=0; $i<$Number_of_particles; $i++){
   $pfBest[$i]=1e40;## initial particle best fitness values for all particles
   $plfBest[$i]=1e40;## initial local best fitness values for all particles
}

for (my $i=0; $i<$Number_of_particles; $i++){
## setting initial values for all dimensions	
    for (my $j=0; $j < $dimension; $j++){  	
      $x[$i][$j]=$x_min[$j]+rand(1)*$x_range[$j]; ###initial values for parameters 
      $v[$i][$j]=$x_min[$j]+rand(1)*$x_range[$j];#($x_range[$j]/2.)*(2.*rand(1)-1)/100.; ###initial velocities for parameters 
    }
}

## rerun this script     
#### If we have got the best parameter already and want to rerun this fitting script
#    if($rerun eq "Yes"){
#    	print "**rerun work for the initial value of Particle 0***\n";
#		  my @temppara;
#		  unlink "para_array_rerun.dat";
#		  #system("copy para_array.dat para_array_rerun.dat");    	
#  		copy("para_array.dat","para_array_rerun.dat");
#  		open my $rerunarray , "<para_array_rerun.dat";
#  		@temppara=<$rerunarray>;
#  		close $rerunarray;
#  		for (my $j=0; $j < $dimension; $j++){
#			chomp $temppara[$j];	
#			$x[0][$j]=$temppara[$j];## assign last best parameters to the first particle 
#			#print "j $j $x[$i][$j] $temppara[$j]\n";
#       }
#    }

#####  iteration loop begins
for(my $iteration=1; $iteration <= $Number_of_iterations;  $iteration++){ 
	print "##### ****This is the iteration time for $iteration**** \n\n";
for (my $i=0 ; $i<$Number_of_particles; $i++){# the first particle loop begins for getting fitness from PSO_fitness.pl   	
   	#print "Current iteration: $iteration, Current Particle:$i\n";
# fork here
#$pm->start and next;   	
   	my @temp;   	
   	 for (my $ipush=0; $ipush<$dimension; $ipush++){
   	      $temp[$ipush]=$x[$i][$ipush];
   	 }
### get the fitness here
     #my $fitness;
     #my @lmpdata; #data from lmps calculation
     $fitness[$i] = &PSO_fitness(\@{$x[$i]},\@refdata,\@eval_array,\@fittedData);
     # print "print fittedData following @fittedData\n";
     # for (0..$#fittedData){
#
     # print "fitted data".$_."$fittedData[$_]\n";
#
     # }
     # print "sleeping\n";
      #sleep(100);
      #print "######Before If\n";
      #     	print "pfBest $i, $pfBest[$i],fitness:$fitness[$i] ######replaced local\n";
  
      if ($fitness[$i] < $pfBest[$i]){
          $pfBest[$i] = $fitness[$i];
          for (my $j=0; $j < $dimension; $j++){
               $pBest[$i][$j]=$x[$i][$j];
          }
      }
#$pm->finish;
}# end of the first particle loop for getting fitness from PSO_fitness.pl
#$pm->wait_all_children; 
#keep the lowest fitness among all particles between two particle loops

my @indices = sort { $fitness[$a] <=> $fitness[$b] }  0 .. $#fitness;
chomp ($lowestfitID = $indices[0]); 

print "***Iteration: $iteration,the lowest fitness Particle ID and fitness: $lowestfitID, $fitness[$lowestfitID]\n";

for my $ID (0..$#fitness){
	print "particleID, fitness: $ID, $fitness[$ID]\n";		
}
print "\n";
print "The current lowest:$gfBest\n ";
if ($fitness[$lowestfitID] <= $gfBest){
	$gfBest = $fitness[$lowestfitID];
	for (my $j=0; $j < $dimension; $j++){
		$gBest[$j]=$x[$lowestfitID][$j];
    }
	&keepBetter($gfBest,$lowestfitID,$iteration,\@{$x[$lowestfitID]},\@gBest,\@refdata,\@fittedData,\@para_set,$summary); #passing ram address
} 

## find the local best for all particles
#my @plfBest;
#my @plBest;#
#@SLR_table;
for my $pid (0..$#SLR_table){ # loop over all particles
    my @array4LBest;#keep the particle best fitnesses for 4 neighbours
    my @array4Pid;#keep the corresponding particle id for convertion
    for my $nebID (0..3){# consider 4 neighbour particles
        my $tempLB = $SLR_table[$pid][$nebID];# convert neighbour IDs
        $array4LBest[$nebID] = $pfBest[$tempLB];# convert fitness of each neighbour
        $array4Pid[$nebID] = $tempLB;# keep particle ids
        #print "***Particle $pid->nebID neb particle $tempLB\n";
    }
    my @localBest_indices = sort { $array4LBest[$a] <=> $array4LBest[$b] }  0 .. $#array4LBest;
    #$localBest_indices[0]: id of @array4LBest with the lowest fitness value among local group

    my $lowestLBID =  $array4Pid[$localBest_indices[0]]; # id with the lowest local fitness of a subgroup
    
    #print "\n***Particle $pid->lowestLBID,pfBest[$lowestLBID], $lowestLBID,$pfBest[$lowestLBID]\n";
    #print "***Particle $pid->old plfBest[$pid],$plfBest[$pid]\n\n";
    if ($pfBest[$lowestLBID] < $plfBest[$pid]){
        $plfBest[$pid] = $pfBest[$lowestLBID];# update local group best fitness 
        for (my $j=0; $j < $dimension; $j++){
               $plBest[$pid][$j]=$x[$lowestLBID][$j];# keep local group best parameters
          }
      }
} 
# second particle loop begin for adjust parameter values
$omega = $omega_max - $iteration*($omega_max - $omega_min)/$Number_of_iterations;# adjust omega dynamically

for (my $i=0; $i<$Number_of_particles; $i++){ 

    for (my $j=0; $j < $dimension; $j++){
      
			 $v[$i][$j] =$omega*$v[$i][$j] + $c1*rand(1)* ($alpha1*($pBest[$i][$j] - $x[$i][$j])
             + $alpha2*($plBest[$i][$j] - $x[$i][$j])) +  $c2*rand(1) * ($gBest[$j] - $x[$i][$j]);
          if ($v[$i][$j]<$v_min[$j])  { 
         	  $v[$i][$j]=$v_min[$j];         
         	 }
         		
          if ($v[$i][$j]>$v_max[$j])  { 
         	  $v[$i][$j]=$v_max[$j];
         	 }      
		     $x[$i][$j] = $x[$i][$j] + $v[$i][$j];
         
          if ($x[$i][$j]<$x_min[$j])  { 
         	  $x[$i][$j]=$x_min[$j];         
         	 }
         		
          if ($x[$i][$j]>$x_max[$j])  { 
         	  $x[$i][$j]=$x_max[$j];
         	 }

      } 
	#print "####Current Global best fitness: $gfBest\n";
    }# second particle loop
}#iteration loop

close $summary;
