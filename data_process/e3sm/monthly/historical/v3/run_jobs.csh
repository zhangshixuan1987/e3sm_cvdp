#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=regrid0300
#SBATCH  --nodes=1
#SBATCH  --time=12:00:00
#SBATCH  --exclusive
#SBATCH -A condo
#SBATCH -p acme-small

#module load ncl 
#module load nco 

ncl  1_gen_atm_2d.ncl  >& ncl1.log &
ncl  1_gen_atm_3d.ncl >& ncl2.log &

wait

exit 
