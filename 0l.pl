
##### should add the above code for debugging

#@remove =(1..20);

#foreach (@remove){
#$temp=$_*50;
#system ("rmdir /s/q $temp");
#}
#unlink ("00PropertyT.dat");
system ('rmdir /s/q HEA_NPT');
#system ('rmdir /s/q testnvt');
#system ("lmp_mpi -in ZnO_box_MD.in"); # to generate a designed ZnONW with the size matching graphene box in Z dimension
#system ("lmp_mpi -in graphene_zx.in");
#system ("mpiexec -np 8 lmp_mpi -in ZnO_box_MD_readdump.in");
system ("lmp_serial -in NPT.in");

#system ("lmp_mpi -sf omp -pk omp 16 -in ZnO_box_MD_readdump.in");

#system ('"C:\Program Files\MPICH2\bin\mpiexec.exe" lmp_mpi -sf omp -pk omp 16 -in 00Tension_300.in');

 
#system ('"C:\Program Files\MPICH2\bin\mpiexec.exe" -np 8 lmp_mpi -in DPD_denopt.in');
#system ('mpiexec -np 6 lmp_mpi -in BH-NP.in');
#system ('lmp_serial -in BHH-tfmc.in');
print "all done";

