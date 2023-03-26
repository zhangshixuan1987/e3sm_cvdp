#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH -A m2977
#SBATCH -q regular
#SBATCH -t 4:00:00
#SBATCH -N 1
#SBATCH  --job-name=ncclimo_ctrl
#SBATCH  --output=job%j 
#SBATCH  --exclusive 
#SBATCH  --constraint=knl,quad,cache

set jobdir = `pwd`
cd $jobdir
#Script name and path
set script_name = ncclimo
set ncrcat_name = ncrcat
set script_path = /global/u1/z/zender/bin_cori
csh sbatch_combine_to_one_climo_set1.csh &
csh sbatch_combine_to_one_climo_set2.csh &
csh sbatch_combine_to_one_climo_set3.csh &
csh sbatch_combine_to_one_climo_set4.csh &
wait 
