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

#Set the minimal environment
#module purge
#unsetenv LD_LIBRARY_PATH
#module load intel/16.0.2
#module load mvapich2/2.2b

#Modify path so that ncclimo can find latest ncra and other nco utilities
set path = ( $script_path  $path )

set CASE_NAME  = InteRFACE1alphaC
set start_year = 1
set end_year   = 10

#location of work directory 
set WORK_DIR      = /global/cfs/cdirs/e3sm/zhan391/data/E3SM/${CASE_NAME}
#location of model history file
set RUN_FILE_DIR  = /global/cscratch1/sd/afrobert/e3sm_scratch/cori-knl/${CASE_NAME}/archive/atm/hist
#Mapping file
set MAP_FILE      = /global/cfs/cdirs/e3sm/zhan391/data/regrid_maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

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
