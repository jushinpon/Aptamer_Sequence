sub read_ref{

#&read_ref(\%system_para,\@indiv,\@binary,\@ternary);
my ($system_para,$refdata,$refstr) = @_;
open my $ss,"< ./input_information.dat"; #From preprocessor
my @input_array=<$ss>;
close $ss;   
#### You need arrange your input data as the following format
chomp ($system_para->{dataNo} = $input_array[0]);# total data number
chomp ($system_para->{compNo} = $input_array[1]);# total number of compositional units
#chomp(my @temp = split(/\s+/,$input_array[2]));
#for (@temp){print "test $_\n";}
chomp( $system_para->{typeID} = [split(/\s+/,$input_array[2])]);# total number of compositional units 
#### the following is to make the smallest value from 0 (1 is used in input_information.dat)
for (0..$#{$system_para->{typeID}}) {
$system_para->{typeID}->[$_] = 	$system_para->{typeID}->[$_] - 1;
}

chomp( $system_para->{types} = [split(/\s+/,$input_array[3])]);# total number of compositional units

for (my $dataID=0; $dataID<$system_para->{dataNo};$dataID++){
	chomp ($refdata->[$dataID] =  $input_array[4+$dataID*($system_para->{compNo}+1)]);# a set includes energy+ compositions
		for (my $str=0;$str<$system_para->{compNo};$str++){
			chomp ( $refstr->[$dataID]->[$str] =  $input_array[4+$dataID*($system_para->{compNo}+1)+($str+1)] -1 );#$str starts from 0 (-1 is to make type from 0)
		}
}

}# sub	
1;# subroutine

