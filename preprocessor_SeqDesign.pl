sub preprocessor_SeqDesign{

use strict;
use warnings;
#&preprocessor(\%system_para,\@refdata,\@refstr,\%indiv,\%binary,\%ternary,\@para_set,\@x_min,\@x_max,,\@eval_array);# PSO parameter setting

my ($system_para,$para_set) = @_;

# reading system information from input_information.dat
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

open my $fittedPara,"< 00fittedPara.dat"; #read fitted parameters
my @temp_paraArray = <$fittedPara>;
close $fittedPara;
my @raw_array=grep (($_!~m{^\s*$|^#}),@temp_paraArray); # remove blank lines
my @paraArray = map {$_  =~ s/^\s+|\s+$//;$_;} @raw_array;
#print "read para: @paraArray\n";  

for (@paraArray){
	my @temp = split(/\s+/,$_);
	chomp (@temp);
	#chomp,$temp[1]);
	$para_set->{$temp[0]} = $temp[1];
	#print "temp[0],$temp[0],temp[1],$temp[1]\n";
	#print $para_set->{$temp[0]}."output \n";
}

#print Dumper($eval_array);
}# sub	
1;# subroutine
