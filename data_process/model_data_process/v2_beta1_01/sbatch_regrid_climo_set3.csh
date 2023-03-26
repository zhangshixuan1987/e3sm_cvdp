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

#Set the minimal environment
#module purge
#unsetenv LD_LIBRARY_PATH
#module load intel/16.0.2
#module load mvapich2/2.2b

#Modify path so that ncclimo can find latest ncra and other nco utilities
set path = ( $script_path  $path )

#set CASE_NAME  = 20201211.beta1_01.piControl.compy
set CASE_NAME  = 20201022.alpha5_v1p-1_fallback.piControl.ne30pg2_r05_EC30to60E2r2-1900_ICG.compy
set start_year = 171
set end_year   = 180 #200

#location of work directory 
set WORK_DIR   = /compyfs/zhan391/Cryosphere_project/diag_package/data/$CASE_NAME
#location of model history file
set RUN_FILE_DIR  = /compyfs/gola749/E3SM_simulations/${CASE_NAME}/archive/atm/hist/
#Mapping file
set MAP_FILE    = /qfs/people/zender/data/maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

if ( ! -d $WORK_DIR ) then
 mkdir -p $WORK_DIR
endif  

while ($start_year <= ${end_year} )

echo "work on the $start_year "

#Output climo files in SE grid
set OUT_DIR       = ${WORK_DIR}/se_climo/${start_year}to${start_year}yrs/

#Output climo files in FV grid
set REGRIDDED_DIR = ${WORK_DIR}/climo/${start_year}to${start_year}yrs/

set CLIMO_SCRIPT = $script_path/$script_name
$CLIMO_SCRIPT -m eam -i $RUN_FILE_DIR -c $CASE_NAME -O $REGRIDDED_DIR -o $OUT_DIR -r $MAP_FILE -s $start_year -e $start_year #-p mpi

@ start_year = $start_year + 1

end
