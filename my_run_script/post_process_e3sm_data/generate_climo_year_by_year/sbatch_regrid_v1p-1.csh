#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=regrid0300
#SBATCH  --nodes=1
#SBATCH  --time=48:00:00
#SBATCH  --exclusive
#SBATCH -A ESMD
#SBATCH -p slurm

#Script name and path
set script_name = ncclimo
set ncrcat_name = ncrcat
set script_path = /share/apps/nco/4.7.9/bin 

#Set the minimal environment
#module purge
#unsetenv LD_LIBRARY_PATH
#module load intel/16.0.2
#module load mvapich2/2.2b

#Modify path so that ncclimo can find latest ncra and other nco utilities
set path = ( $script_path  $path )


set CASE_NAME  = 20201027.alpha5_v1p-1.amip.ne30pg2_r05_oECv3.compy
set start_year = 1981 #1990
set end_year   = 1981 #2010

#location of work directory 
set WORK_DIR   = /compyfs/zhan391/run_e3sm_cryosphere/diag_package/data/$CASE_NAME
#location of model history file
set RUN_FILE_DIR  = /compyfs/zhen797/E3SM_simulations/${CASE_NAME}/archive/atm/hist/
#Mapping file
set MAP_FILE    = /qfs/people/zender/data/maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

while ($start_year <= ${end_year} )

echo "work on the $start_year "

#Output climo files in SE grid
set OUT_DIR       = ${WORK_DIR}/se_climo/${start_year}to${start_year}yrs/

#Output climo files in FV grid
set REGRIDDED_DIR = ${WORK_DIR}/climo/${start_year}to${start_year}yrs/

set CLIMO_SCRIPT = $script_path/$script_name
#$CLIMO_SCRIPT -m eam -i $RUN_FILE_DIR -c $CASE_NAME -O $REGRIDDED_DIR -o $OUT_DIR -r $MAP_FILE -s $start_year -e $start_year #-p mpi

@ start_year = $start_year + 1

end

#combine the data into one;;;;;
foreach n (01 02 03 04 05 06 07 08 09 10 11 12 ANN DJF JJA MAM SON)
 echo $n
 set SE_FILES = ` ls ${WORK_DIR}/se_climo/*/*_${n}_*_*_climo.nc`
 set FV_FILES = ` ls ${WORK_DIR}/climo/*/*_${n}_*_*_climo.nc`
 echo $SE_FILES
 set OUT_SE_FILES = ${WORK_DIR}/se_climo/${CASE_NAME}_${n}_means.nc
 set OUT_FV_FILES = ${WORK_DIR}/climo/${CASE_NAME}_${n}_means.nc
 set CAT_SCRIPT = $script_path/$ncrcat_name
 $CAT_SCRIPT ${SE_FILES} $OUT_SE_FILES
 $CAT_SCRIPT ${FV_FILES} $OUT_FV_FILES
 rm -rvf ${SE_FILES}
 rm -rvf ${FV_FILES}
end
