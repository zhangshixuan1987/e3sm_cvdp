#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=regrid0300
#SBATCH  --nodes=1
#SBATCH  --time=12:00:00
#SBATCH  --exclusive
#SBATCH -A condo
#SBATCH -p acme-small

set jobdir = `pwd`
cd $jobdir

module load  intel-parallel-studio/cluster.2017.4-wyg4gfu intel-parallel-studio/cluster.2017.4-wyg4gfu  intel-mpi/2017.3-dfphq6k intel/17.0.4-74uvhji  intel-mpi/2017.3-dfphq6k nco/4.7.4-x4y66ep netcdf/4.6.1-c2mecde 
set rundir     = "/lcrc/group/e3sm/ac.golaz/E3SMv3_dev"
set exp_name   = v3atm-v21ocn.piControl
set model_case = (20230224.v3atm_v21.piControl.chrysalis)
set ncase = $#model_case

#set var2d_name = ( "U" "V" "T" "Q" "RELHUM" "OMEGA" "CLDLIQ" "CLOUD" "Z3" "QRL" "QRS" 
set var2d_name = ( "UM10" "LANDFRAC" "OCNFRAC" "ICEFRAC" "PS" "PSL" "PHIS" "LWCF" "SWCF" "PRECC" "PRECL" "AODVIS" "AODDUST" "TGCLDLWP" "TGCLDIWP" "CLDLOW" "CLDMED" "CLDHGH" "CLDTOT" "FLNT" "FSNT" "FLNTC" "FSNTC" "FLUT" "FSUTOA" "FSUTOAC" "FLUTC" "TMQ" "TS" "SHFLX" "LHFLX" "FSNTOA" "FSNTOAC" "FLNS" "FLNSC" "FLDS" "FSNS" "FSNSC" "FSDS" "FSDSC" "SOLIN" "TREFHT" "TAUY" "TAUX" "QFLX" "QREFHT" "OMEGA500" "PBLH" "PRECSC" "PRECSL" "TAUGWX" "TAUGWY" "TGCLDCWP" "TH7001000" "TREFMNAV" "TREFMXAV" "TUQ" "TVQ" "TVH" "TUH" "TSMN" "TSMX" "SCO" "TCO" "SFO3" "SNOWHICE" "SNOWHLND" "O3_SRF" )
set var2d_list    = ( $var2d_name )
set var2d_list[1] = "U10"
set nvars      = $#var2d_list

set start_year = 1
set end_year   = 300

@ nyr = ( $end_year - $start_year + 1 ) / 50

#location of work directory 
set WORK_DIR  = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD/${exp_name}
#Mapping file
set MAP_FILE  = /lcrc/group/acme/ac.szhang/acme_scratch/data/regrid_maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

if( ! -d $WORK_DIR )then
 mkdir -p $WORK_DIR
endif

set i = 1
while ( $i <= $ncase )

 set CASE_NAME  = $model_case[$i]
 set iy = $start_year
 set RUN_FILE_DIR = ${rundir}/${CASE_NAME}/archive/atm/hist

 set iy = 1
 while ($iy <= $nyr )

  @ yst = $start_year + ( $iy - 1 ) * 50
  @ yed = $start_year + $iy * 50 - 1
  set time_tag   = `printf "%04d" $yst`01-`printf "%04d" $yed`12

  set eam_files =
  set ix = $yst
  while ($ix <= $yed)
    set eam_files = ($eam_files $RUN_FILE_DIR/*eam.h0*`printf "%04d" $ix`*)
   @ ix ++
  end

  if( ! -d ${WORK_DIR}/SE_ATM2D )then
    mkdir -p ${WORK_DIR}/SE_ATM2D
  endif

  if( ! -d ${WORK_DIR}/ATM_2D )then
    mkdir -p ${WORK_DIR}/ATM_2D
  endif

  set varlist = $var2d_list[1]
  set j  = 2
  while ( $j <= $nvars )
   set varlist = "$varlist,$var2d_list[$j]"
   @ j++
  end 
  echo $varlist

  @ ens = $i - 1
  set ensr = en`printf "%02d" $ens`
  set SE_FILE = ${WORK_DIR}/SE_ATM2D/${exp_name}.${ensr}.${time_tag}.nc
  set FV_FILE = ${WORK_DIR}/ATM_2D/${exp_name}.${ensr}.${time_tag}.nc
  rm -rvf $SE_FILE $FV_FILE
  ncrcat -d time,0, -v $varlist $eam_files ${SE_FILE}
  ncremap -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE}
  @ iy++
 end
 
 set j  = 1
 while ( $j <= $nvars )
  set var  = $var2d_list[$j]
  set vou  = $var2d_name[$j]
  @ ens    = $i - 1
  set ensr = en`printf "%02d" $ens`
  set eam_files = ${WORK_DIR}/ATM_2D/${exp_name}.${ensr}.*.nc
  set timstr    = `printf "%04d" $start_year`01-`printf "%04d" $end_year`12
  set FV_FILE   = ${WORK_DIR}/${exp_name}.${ensr}.${vou}.${timstr}.nc
  rm -rvf $FV_FILE
  ncrcat -d time,0, -v $var $eam_files ${FV_FILE}
  @ j++
 end

 @ i++
end
#finish the process and remove the temp data
rm -rvf ${WORK_DIR}/SE_ATM2D
echo "done"

exit
