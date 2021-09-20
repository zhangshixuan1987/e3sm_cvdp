#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=regrid0300
#SBATCH  --nodes=1
#SBATCH  --time=2:00:00
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

set CASE_NAME  = v2.LR.historical_0101
set start_year = 1985
set end_year   = 2014
set time_tag   = `printf "%04d" $start_year`-`printf "%04d" $end_year`

#location of work directory 
set WORK_DIR      = /lcrc/group/acme/ac.szhang/acme_scratch/data/polar_diag
#location of model history file (run directory or model output directory)
set RUN_FILE_DIR  = /lcrc/group/acme/ac.szhang/acme_scratch/polar_diag/my_run_script/e3sm_process/${CASE_NAME}/data
#Mapping file
set MAP_FILE      = /lcrc/group/acme/ac.szhang/acme_scratch/data/regrid_maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

set var3d_list = ("hyai","hybi","ilev","lev","P0","hybm","hyam","U","V","T","Q","RELHUM","OMEGA","CLDLIQ","CLDICE","CLOUD","NUMLIQ","NUMICE","Z3","QRL","QRS")
set var2d_list = ("LANDFRAC","OCNFRAC","ICEFRAC","area","PS","PSL","PHIS","P0","U10","LWCF","SWCF","PRECC","PRECL","AODVIS","AODDUST","TGCLDLWP","TGCLDIWP","CLDLOW","CLDMED","CLDHGH","CLDTOT","FLNT","FSNT","FLNTC","FSNTC","FLUT","FSUTOA","FSUTOAC","FLUTC","TMQ","TS","SHFLX","LHFLX","FSNTOA","FSNTOAC","FLNS","FLNSC","FLDS","FSNS","FSNSC","FSDS","FSDSC","SOLIN","TREFHT","TAUY","TAUX","QFLX","QREFHT","OMEGA500","PBLH","PRECSC","PRECSL","TAUGWX","TAUGWY","TGCLDCWP","TH7001000","TREFMNAV","TREFMXAV","TUQ","TVQ","TVH","TUH","TSMN","TSMX")

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

set SE_FILE =  ${WORK_DIR}/SE/${CASE_NAME}_eam.h0_monthly_${time_tag}.nc
set FV_FILE =  ${WORK_DIR}/${CASE_NAME}_eam.h0_monthly_${time_tag}.nc

rm -rvf $SE_FILE
rm -rvf $FV_FILE
ncrcat -d time,0, -v ${var3d_list},${var2d_list} $eam_files ${SE_FILE}

set CLIMO_SCRIPT = $script_path/$script_name
$CLIMO_SCRIPT -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE}
