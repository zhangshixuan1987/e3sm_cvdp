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

set run_dir    = "/lcrc/group/acme/ac.dcomeau/scratch/chrys/E3SMv2_1/"
set exp_name   = v2_1.SORRM.historical
set model_tag  = ( "0701" "0751" "0801" )
set model_ennm = ( "en00" "en01" "en02" )
set model_case =
foreach tag ( $model_tag )
  set model_case = ( ${model_case} ${exp_name}_${tag} )
end
set ncase = $#model_case
echo $ncase
set start_year = 1950
set end_year   = 2014

set var2d_name = ("U" "V" "T" "Q" "Z3")
set var2d_list = ( $var2d_name )
set nvars      = $#var2d_list

@ nyr = ( $end_year - $start_year + 1 ) / 50
@ yed = $start_year + $nyr * 50 - 1
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

 if( ! -d ${WORK_DIR}/SE_ATM_3D )then
   mkdir -p ${WORK_DIR}/SE_ATM_3D
 endif

 if( ! -d ${WORK_DIR}/ATM_3D )then
   mkdir -p ${WORK_DIR}/ATM_3D
 endif

 set CASE_NAME  = $model_case[$i] 
 echo $CASE_NAME
 set RUN_FILE_DIR = ${run_dir}/${CASE_NAME}/archive/atm/hist

 if ( -d $RUN_FILE_DIR ) then 

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
      set eam_files = ( $eam_files $RUN_FILE_DIR/*eam.h0*`printf "%04d" $ix`* )
      #echo $RUN_FILE_DIR/*eam.h0*`printf "%04d" $ix`*
     @ ix ++
    end

    set j = 1
    while ( $j <= $nvars )
      echo $j
     set var  = $var2d_list[$j]
     set vou  = $var2d_name[$j]
     set ensr = $model_ennm[$i] 
     set SE_FILE = ${WORK_DIR}/SE_ATM_3D/${exp_name}.${ensr}.${vou}.${time_tag}.nc
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
     set ensr = $model_ennm[$i] 
     set SE_FILE = ${WORK_DIR}/SE_ATM_3D/${exp_name}.${ensr}.${vou}.${time_tag}.nc
     set FV_FILE = ${WORK_DIR}/ATM_3D/${exp_name}.${ensr}.${vou}.${time_tag}.nc
     if( ! -f $FV_FILE ) then
       rm -rvf ${WORK_DIR}/SE_ATM_3D/tmp_atm_out.nc
       ncremap -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE}
       rm -rvf ${WORK_DIR}/SE_ATM_3D/tmp_atm_out.nc
     endif
     @ j++
    end
    wait
    @ iy ++
   end

 endif 

 @ i++ 
end

##finish the process and remove the temp data
rm -rvf ${WORK_DIR}/SE_ATM_3D
echo "done"

exit

 
