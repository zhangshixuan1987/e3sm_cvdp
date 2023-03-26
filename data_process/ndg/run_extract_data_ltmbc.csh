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
set script_path = /global/common/software/spackecp/cori/e4s-22.02/software/cray-cnl7-haswell/gcc-11.2.0/nco-5.0.1-clkqcrshmdwsfmovawgfs3br5us3gdvd/bin

#Set the minimal environment
#module purge
#unsetenv LD_LIBRARY_PATH
#module load intel/16.0.2
#module load mvapich2/2.2b

#Modify path so that ncclimo can find latest ncra and other nco utilities
set path = ( $script_path  $path )

set CASE_NAME  = v2.LR.amip_bcm3_F20TR_ne30pg2_EC30to60E2r2 
set OUT_NAME   = "v2.LR.amip.ltmbc"
set start_year = 2008
set end_year   = 2017
set time_tag   = `printf "%04d" $start_year`-`printf "%04d" $end_year`

#location of work directory 
set WORK_DIR      = /global/cfs/cdirs/e3sm/zhan391/data/E3SMv2/${OUT_NAME} 
#location of model history file
set RUN_FILE_DIR  = /global/cscratch1/sd/zhan391/DARPA_project/nudged_e3smv2_simulation/${CASE_NAME}/run

#Mapping file
set MAP_FILE = /global/cfs/cdirs/e3sm/zhan391/data/regrid_maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

set var3d_list = ("hyai","hybi","ilev","lev","P0","hybm","hyam","U","V","T","Q","RELHUM","OMEGA","CLDLIQ","CLDICE","CLOUD","NUMLIQ","NUMICE","Z3","QRL","QRS")
set var2d_list = ("LANDFRAC","OCNFRAC","ICEFRAC","area","PS","PSL","PHIS","P0","U10","LWCF","SWCF","PRECC","PRECL","AODVIS","TGCLDLWP","TGCLDIWP","CLDLOW","CLDMED","CLDHGH","CLDTOT","FLNT","FSNT","FLNTC","FSNTC","FLUT","FSUTOA","FSUTOAC","FLUTC","TMQ","TS","SHFLX","LHFLX","FSNTOA","FSNTOAC","FLNS","FLNSC","FLDS","FSNS","FSNSC","FSDS","FSDSC","SOLIN","TREFHT","TAUY","TAUX","QFLX","QREFHT","OMEGA500","PBLH","PRECSC","PRECSL","TAUGWX","TAUGWY","TGCLDCWP","TH7001000","TREFMNAV","TREFMXAV","TUQ","TVQ","TVH","TUH","TSMN","TSMX","SCO","TCO","SNOWHICE","SNOWHLND","O3_SRF")

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

set SE_FILE =  ${WORK_DIR}/SE/${OUT_NAME}_eam.h0_monthly_${time_tag}.nc
set FV_FILE =  ${WORK_DIR}/${OUT_NAME}_eam.h0_monthly_${time_tag}.nc

if ( ! -f ${SE_FILE} ) then
  ncrcat -d time,0, -v ${var3d_list},${var2d_list} $eam_files ${SE_FILE}
endif

if ( ! -f ${FV_FILE} ) then
  set CLIMO_SCRIPT = $script_path/$script_name
  $CLIMO_SCRIPT -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE}
endif
