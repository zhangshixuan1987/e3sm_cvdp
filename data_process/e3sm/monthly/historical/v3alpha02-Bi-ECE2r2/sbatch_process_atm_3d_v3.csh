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

set exp_name   = v3alpha02-Bi-ECE2r2.historical
set model_case = (20230704.v3alpha02.historical_0101.chrysalis)
set ncase = $#model_case

#set var2d_name = ("U" "V" "T" "Q" "RELHUM" "OMEGA" "CLDLIQ" "CLOUD" "Z3" "QRL" "QRS")
set var2d_name = ("U" "V" "T" "Q" "Z3")
set var2d_list = ( $var2d_name )
set nvars      = $#var2d_list

set start_year = 1850
set end_year   = 2014

@ nyr = ( $end_year - $start_year + 1 ) / 50

@ yed = $start_year + $nyr * 50 - 1
echo $yed  $nyr 
if ($yed < $end_year) then 
  @ nyr = $nyr + 1
endif
 
set time_tag   = `printf "%04d" $start_year`01-`printf "%04d" $end_year`12

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
 set RUN_FILE_DIR = /lcrc/group/e3sm/ac.xzheng/E3SMv3_dev/${CASE_NAME}/archive/atm/hist

 if( ! -d ${WORK_DIR}/SE_ATM )then
   mkdir -p ${WORK_DIR}/SE_ATM
 endif

 if( ! -d ${WORK_DIR}/ATM_3D )then
   mkdir -p ${WORK_DIR}/ATM_3D
 endif

 set iy = 1
 while ($iy <= $nyr )
  @ yst = $start_year + ( $iy - 1 ) * 50
  @ yed = $start_year + $iy * 50 - 1
  echo $yst $yed 
  if ($yst < $start_year) then 
    set yst = $start_year 
  endif 
  if ($yed > $end_year ) then 
    set yed = $end_year 
  endif 
  set time_tag  = `printf "%04d" $yst`01-`printf "%04d" $yed`12
  set eam_files =
  set ix = $yst
  while ($ix <= $yed)
    set eam_files = ($eam_files $RUN_FILE_DIR/*eam.h0*`printf "%04d" $ix`*)
   @ ix ++
  end

  set j = 1
  while ( $j <= $nvars ) 
   set var  = $var2d_list[$j]
   set vou  = $var2d_name[$j]
   @ ens    = $i - 1 
   set ensr = en`printf "%02d" $ens`
   set SE_FILE = ${WORK_DIR}/SE_ATM/${exp_name}.${ensr}.${vou}.${time_tag}.nc
   set FV_FILE = ${WORK_DIR}/ATM_3D/${exp_name}.${ensr}.${vou}.${time_tag}.nc
   rm -rvf $SE_FILE
   if ( ! -f $FV_FILE ) then 
     ncrcat -d time,0, -v $var $eam_files ${SE_FILE} & 
   endif 
   @ j++
  end 

  wait

  @ iy ++
 end

 set iy = 1
 while ($iy <= $nyr )

  @ yst = $start_year + ( $iy - 1 ) * 50
  @ yed = $start_year + $iy * 50 - 1
  echo $yst $yed
  if ($yst < $start_year) then
    set yst = $start_year
  endif
  if ($yed > $end_year ) then
    set yed = $end_year
  endif
  set time_tag  = `printf "%04d" $yst`01-`printf "%04d" $yed`12

  set j = 1
  while ( $j <= $nvars )
   set var  = $var2d_list[$j]
   set vou  = $var2d_name[$j]
   @ ens = $i - 1
   set ensr = en`printf "%02d" $ens`
   set SE_FILE = ${WORK_DIR}/SE_ATM/${exp_name}.${ensr}.${vou}.${time_tag}.nc
   set FV_FILE = ${WORK_DIR}/ATM_3D/${exp_name}.${ensr}.${vou}.${time_tag}.nc
   if( ! -f $FV_FILE ) then 
     rm -rvf ${WORK_DIR}/SE_ATM/tmp_atm_out.nc
     ncremap -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE} 
     rm -rvf ${WORK_DIR}/SE_ATM/tmp_atm_out.nc
   endif 
   @ j++
  end
  wait 
  @ iy ++ 
 end 

 ##finish the process and remove the temp data
 rm -rvf ${WORK_DIR}/SE_ATM

 @ i++ 
end

echo "done"

exit
