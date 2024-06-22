#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=regrid0350
#SBATCH  --nodes=1
#SBATCH  --time=12:00:00
#SBATCH  --exclusive
#SBATCH -A condo
#SBATCH -p acme-small

set jobdir = `pwd`
cd $jobdir
source /lcrc/soft/climate/e3sm-unified/load_latest_e3sm_unified_anvil.csh

#module load  intel-parallel-studio/cluster.2017.4-wyg4gfu intel-parallel-studio/cluster.2017.4-wyg4gfu  intel-mpi/2017.3-dfphq6k intel/17.0.4-74uvhji  intel-mpi/2017.3-dfphq6k nco/4.7.4-x4y66ep netcdf/4.6.1-c2mecde 
set exp_name   = v3alpha04-Bi-ECE2r2.piControl
set model_case = (20230918.v3alpha04_bigrid.piControl.chrysalis)
set ncase = $#model_case
set rundir = "/lcrc/group/e3sm2/ac.golaz/E3SMv3_dev"

set var2d_name = ( "UM10" "LANDFRAC" "OCNFRAC" "ICEFRAC" "PS" "PSL" "LWCF" "SWCF" "PRECC" "PRECL" "AODVIS" "AODDUST" "TGCLDLWP" "CLDLOW" "CLDMED" "CLDHGH" "CLDTOT" "FLNT" "FSNT"  "FLUT" "FLUTC" "TMQ" "TS" "FSNTOA" "FSNTOAC" "FLNS" "FLNSC" "FLDS" "FSNS" "FSNSC" "FSDS" "FSDSC" "SOLIN" "TREFHT" "TREFMNAV" "TREFMXAV" "TAUY" "TAUX" "QFLX" "QREFHT" "PRECSC" "PRECSL" "SCO" "TCO" "O3_SRF" "SHFLX" )
set var2d_name    = ( "UM10")
set var2d_list    = ( $var2d_name )
set var2d_list[1] = "U10"
set nvars      = $#var2d_list
#echo $var2d_list

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
 echo $RUN_FILE_DIR

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
  echo $eam_files

  if( ! -d ${WORK_DIR}/SE_ATM2D )then
    mkdir -p ${WORK_DIR}/SE_ATM2D
  endif

  if( ! -d ${WORK_DIR}/ATM_2D )then
    mkdir -p ${WORK_DIR}/ATM_2D
  endif

  set varlist = $var2d_list[1]
  set j  = 1
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
