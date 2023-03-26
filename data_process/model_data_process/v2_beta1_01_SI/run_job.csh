#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=regrid0300
#SBATCH  --nodes=1
#SBATCH  --time=2:00:00
#SBATCH  --exclusive
#SBATCH -A ESMD
#SBATCH -p short

set jobdir = `pwd`
cd $jobdir

#Script name and path
set script_name = ncclimo
set ncrcat_name = ncrcat
set script_path = /share/apps/nco/4.7.9/bin

csh sbatch_regrid_climo_set1.csh & 
csh sbatch_regrid_climo_set2.csh &
csh sbatch_regrid_climo_set3.csh &
csh sbatch_regrid_climo_set4.csh &
csh sbatch_regrid_climo_set5.csh &
csh sbatch_regrid_climo_set6.csh &
csh sbatch_regrid_climo_set7.csh &
csh sbatch_regrid_climo_set8.csh &
csh sbatch_regrid_climo_set9.csh &
wait 
