#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=combine
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
csh sbatch_combine_to_one_climo_set1.csh &
csh sbatch_combine_to_one_climo_set2.csh &
csh sbatch_combine_to_one_climo_set3.csh &
csh sbatch_combine_to_one_climo_set4.csh &
wait
