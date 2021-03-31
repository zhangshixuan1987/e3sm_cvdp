#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=regrid0300
#SBATCH  --nodes=1
#SBATCH  --time=2:00:00
#SBATCH  --exclusive
#SBATCH -A condo
#SBATCH -p acme-small

set jobdir = `pwd`
cd $jobdir
#Script name and path
set script_name = ncclimo
set ncrcat_name = ncrcat
set script_path = /blues/gpfs/home/software/spack-0.10.1/opt/spack/linux-centos7-x86_64/intel-17.0.4/nco-4.7.4-x4y66ep2ydoyegnckicvv5ljwrheniun/bin

####generate year-to-year climo files#####
csh sbatch_regrid_climo.csh
wait

####combine the each year climo file to one 
csh sbatch_combine_to_one_climo_set1.csh 
wait 
