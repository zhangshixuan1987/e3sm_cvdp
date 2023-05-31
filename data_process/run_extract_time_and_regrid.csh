#!/bin/csh
#SBATCH  --job-name=era5-down
#SBATCH -n 1
##SBATCH --ntasks-per-node=4
##SBATCH --mem=8G
#SBATCH -t 24:00:00
#SBATCH -A ESMD
#SBATCH -p slurm
#SBATCH -e err_dera5.%J
#SBATCH -o out_dera5.%J
#SBATCH --ntasks=12

#module load anaconda3
#source /share/apps/anaconda3/2019.03/etc/profile.d/conda.csh
#conda activate eralib

module load nco

set grid      = "1x1" # 1.9x2.5
set MAP_FILE  = RSS_1x1_to_${grid}_Rect_bilinear.nc
set workdir   = `pwd`
cd $workdir

set yst = 1988
set yed = 2019

set data_file = "raw_data/tpw_v07r01_198801_202008.nc4.nc"

cdo selyear,$yst/$yed $data_file tmp.nc

set ouput = "RSS_TWP_monthly_${yst}-${yed}_${grid}.nc"

ncremap -m $MAP_FILE -i tmp.nc  -o $ouput

rm -rvf tmp.nc

wait

exit

