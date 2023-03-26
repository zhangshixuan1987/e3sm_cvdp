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
set script_path = /blues/gpfs/home/software/spack-0.10.1/opt/spack/linux-centos7-x86_64/intel-17.0.4/nco-4.7.4-x4y66ep2ydoyegnckicvv5ljwrheniun/bin

#Set the minimal environment
#module purge
#unsetenv LD_LIBRARY_PATH
#module load intel/16.0.2
#module load mvapich2/2.2b

#Modify path so that ncclimo can find latest ncra and other nco utilities
set path = ( $script_path  $path )

set CASE_NAME  = 20210120.A_WCYCL1850S_CMIP6.ne30pg2_SOwISC12to60E2r4.beta1.maptest.anvil
set start_year = 17#11
set end_year   = 17#20

#location of work directory 
set WORK_DIR   = /lcrc/group/acme/ac.szhang/acme_scratch/data/E3SM/$CASE_NAME
#location of model history file
set RUN_FILE_DIR  = /lcrc/group/acme/ac.dcomeau/scratch/anvil/${CASE_NAME}/run
#Mapping file
set MAP_FILE    = /lcrc/group/acme/ac.szhang/acme_scratch/data/regrid_maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

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
