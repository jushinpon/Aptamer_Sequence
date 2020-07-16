sub preprocessor{

#&preprocessor(\%system_para,\@indiv,\@binary,\@ternary,@x_min,@x_max);# PSO parameter setting

my ($system_para,$indiv,$binary,$ternary,$x_min,$x_max) = @_;
   
#### You need arrange your input data as the following format
#chomp ($system_para->{dataNo} = $input_array[0]);# total data number
#chomp ($system_para->{compNo} = $input_array[1]);# total number of compositional units
##chomp(my @temp = split(/\s+/,$input_array[2]));
##for (@temp){print "test $_\n";}
#chomp( $system_para->{typeID} = [split(/\s+/,$input_array[2])]);# total number of compositional units 
#chomp( $system_para->{types} = [split(/\s+/,$input_array[3])]);# total number of compositional units
#
#for (my $dataID=0; $dataID<$system_para->{dataNo};$dataID++){
#	chomp ($refdata->[$dataID] =  $input_array[4+$dataID*($system_para->{compNo}+1)]);# a set includes energy+ compositions
#		for (my $str=0;$str<$system_para->{compNo};$str++){
#			chomp ($refstr->[$dataID]->[$str] =  $input_array[4+$dataID*($system_para->{compNo}+1)+($str+1)]);#$str starts from 0
#		}
#}

my $eneSum = 0.0;

for (0..$#{$system_para->{dataNo}}){
	$eneSum +=  $refdata->[$_];
}
$test = @{$system_para->{dataNo}}+1;

my $aveEne = $eneSum/@{$system_para->{dataNo}};
print "$test $aveEne";
#$indiv[0][0]

}# sub	
1;# subroutine

