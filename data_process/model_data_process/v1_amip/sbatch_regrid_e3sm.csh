#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=regrid0300
#SBATCH  --nodes=1
#SBATCH  --time=24:00:00
#SBATCH  --exclusive
#SBATCH -A ESMD
#SBATCH -p slurm

#Script name and path
#Script name and path
set script_name = ncremap
set ncrcat_name = ncrcat
set script_path = /global/u1/z/zender/bin_cori

#Set the minimal environment
#module purge
#unsetenv LD_LIBRARY_PATH
#module load intel/16.0.2
#module load mvapich2/2.2b

#Modify path so that ncclimo can find latest ncra and other nco utilities
set path = ( $script_path  $path )

set CASE_NAME  = 20180316.DECKv1b_A1.ne30_oEC.edison
set start_year = 1981
set end_year   = 2010
set time_tag   = `printf "%04d" $start_year`-`printf "%04d" $end_year`

#location of work directory 
set WORK_DIR      = /global/cfs/cdirs/e3sm/zhan391/data/polar_diag
#location of model history file
set RUN_FILE_DIR  = /global/homes/w/wlin/pe3sm/E3SM_simulations/DECKv1/${CASE_NAME}/archive/atm/hist

#Mapping file
set MAP_FILE      = /global/cfs/cdirs/e3sm/zhan391/data/regrid_maps/map_ne30np4_to_cmip6_180x360_aave.20181001.nc

set var3d_list = ("hyai","hybi","ilev","lev","P0","hybm","hyam","U","V","T","Q","RELHUM","OMEGA","CLDLIQ","CLDICE","CLOUD","NUMLIQ","NUMICE","Z3","QRL","QRS")
set var2d_list = ("LANDFRAC","OCNFRAC","ICEFRAC","area","PS","PSL","PHIS","P0","U10","LWCF","SWCF","PRECC","PRECL","AODVIS","AODDUST","TGCLDLWP","TGCLDIWP","CLDLOW","CLDMED","CLDHGH","CLDTOT","FLNT","FSNT","FLNTC","FSNTC","FLUT","FSUTOA","FSUTOAC","FLUTC","TMQ","TS","SHFLX","LHFLX","FSNTOA","FSNTOAC","FLNS","FLNSC","FLDS","FSNS","FSNSC","FSDS","FSDSC","SOLIN","TREFHT","TAUY","TAUX","QFLX","QREFHT","OMEGA500","PBLH","PRECSC","PRECSL","TAUGWX","TAUGWY","TGCLDCWP","TH7001000","TUQ","TVQ","TVH","TUH")

if( ! -d $WORK_DIR )then
 mkdir -p $WORK_DIR
endif 

set iy  = $start_year
set ix  = 1
set cam_files = 
while ($iy <= $end_year) 
 set cam_files = ($cam_files $RUN_FILE_DIR/*cam.h0*`printf "%04d" $iy`*)
 @ iy ++ 
 @ ix ++
end

if( ! -d ${WORK_DIR}/SE )then
  mkdir -p ${WORK_DIR}/SE
endif

set SE_FILE =  ${WORK_DIR}/SE/${CASE_NAME}_cam.h0_monthly_${time_tag}.nc
set FV_FILE =  ${WORK_DIR}/${CASE_NAME}_cam.h0_monthly_${time_tag}.nc

rm -rvf $SE_FILE
rm -rvf $FV_FILE
ncrcat -d time,0, -v ${var3d_list},${var2d_list} $cam_files ${SE_FILE}

set CLIMO_SCRIPT = $script_path/$script_name
$CLIMO_SCRIPT -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE}

