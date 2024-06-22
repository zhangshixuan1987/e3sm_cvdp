#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=regrid0300
#SBATCH  --nodes=4
#SBATCH  --time=12:00:00
#SBATCH  --exclusive
#SBATCH -A condo
#SBATCH -p acme-small

set jobdir = `pwd`
cd $jobdir

#Script name and path
set script_name = ncremap
set ncrcat_name = ncrcat
set script_path = /blues/gpfs/home/software/spack-0.10.1/opt/spack/linux-centos7-x86_64/intel-17.0.4/nco-4.7.4-x4y66ep2ydoyegnckicvv5ljwrheniun/bin

#Set the minimal environment
#module purge
#unsetenv LD_LIBRARY_PATH
#module load intel/16.0.2
#module load mvapich2/2.2b

#Modify path so that ncclimo can find latest ncra and other nco utilities
set path = ( $script_path  $path )

foreach model_case (v2.LR.hist-aer_0251 v2.LR.hist-aer_0201 v2.LR.hist-GHG_0251 v2.LR.hist-GHG_0201 \
                    v2.LR.hist-all-xGHG-xaer_0251 v2.LR.hist-all-xGHG-xaer_0201)

set CASE_NAME  = $model_case
set start_year = 1979
set end_year   = 2014
set time_tag   = `printf "%04d" $start_year`-`printf "%04d" $end_year`

#location of work directory 
set WORK_DIR      = /lcrc/group/acme/ac.szhang/acme_scratch/data/polar_diag
#location of model history file (run directory or model output directory)
set RUN_FILE_DIR  = /lcrc/group/e3sm/ac.forsyth2/E3SMv2/${CASE_NAME}/archive/atm/hist
#Mapping file
set MAP_FILE      = /lcrc/group/acme/ac.szhang/acme_scratch/data/regrid_maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

if( ! -d $WORK_DIR )then
 mkdir -p $WORK_DIR
endif

set iy  = $start_year
set ix  = 1
set eam_files =
while ($iy <= $end_year)
 set eam_files = ($eam_files $RUN_FILE_DIR/*eam.h0*`printf "%04d" $iy`*)
 @ iy ++
 @ ix ++
end

if( ! -d ${WORK_DIR}/SE )then
  mkdir -p ${WORK_DIR}/SE
endif

foreach var ( O3 )
  set SE_FILE =  ${WORK_DIR}/SE/${CASE_NAME}_${var}_eam.h0_monthly_${time_tag}.nc
  set FV_FILE =  ${WORK_DIR}/${CASE_NAME}_${var}_eam.h0_monthly_${time_tag}.nc
  rm -rvf $SE_FILE
  rm -rvf $FV_FILE
  ncrcat -d time,0, -v ${var} $eam_files ${SE_FILE}
  set CLIMO_SCRIPT = $script_path/$script_name
  $CLIMO_SCRIPT -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE}
end 

end 

