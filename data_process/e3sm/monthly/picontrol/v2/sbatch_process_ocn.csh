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

set exp_name   = v2.LR.piControl
set model_case = (v2.LR.piControl)
set model_ennm = ("en00")
set ncase = $#model_case
echo $ncase

set var2d_name = ("MOC") 
set var2d_frac = (1.0  )
set var2d_unit = ("Sv" )
set var2d_list = ("binBoundaryMocStreamfunction" \
                  "timeMonthly_counter" \
                  "xtime_startMonthly" \
                  "xtime_endMonthly" \
                  "timeMonthly_avg_daysSinceStartOfSim" \
                  "timeMonthly_avg_mocStreamvalLatAndDepthRegion" \
                  "timeMonthly_avg_mocStreamvalLatAndDepth")
set nvars      = $#var2d_list

set start_year = 1
set end_year   = 350 
set nyint      = 10
@ nyr = ( $end_year - $start_year + 1 ) / $nyint
@ yed = $start_year + $nyr * $nyint - 1
if ($yed < $end_year) then
  @ nyr = $nyr + 1
endif

#location of work directory 
set WORK_DIR  = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD/${exp_name}
#Mapping file
set MAP_FILE  = /lcrc/group/acme/ac.szhang/acme_scratch/data/regrid_maps/map_EC30to60E2r2_to_1.0x1.0degree_conserve.nc

if( ! -d $WORK_DIR )then
 mkdir -p $WORK_DIR
endif

if( ! -d ${WORK_DIR}/SE_OCN )then
  mkdir -p ${WORK_DIR}/SE_OCN
endif

set i = 1
while ( $i <= $ncase )

 set CASE_NAME  = $model_case[$i]
 echo $CASE_NAME
 #set RUN_FILE_DIR = /lcrc/group/e3sm/ac.forsyth2/E3SMv2/${CASE_NAME}/archive/ice/hist
 set RUN_FILE_DIR = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD/zstash/v2_amoc/piControl/archive/ocn/hist 

 if ( -d $RUN_FILE_DIR ) then
   set iy = 1
   while ($iy <= $nyr )
    @ yst = $start_year + ( $iy - 1 ) * $nyint
    @ yed = $start_year + $iy * $nyint - 1
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
      set eam_files = ($eam_files $RUN_FILE_DIR/*mpaso.hist.am.timeSeriesStatsMonthly*`printf "%04d" $ix`*)
     @ ix ++
    end
    #echo $eam_files

    set vou  = $var2d_name
    set ensr = $model_ennm[$i]
    set j = 1
    while ( $j <= $nvars )
     if ( $j == 1 )  then 
      set var = $var2d_list[1]
     else 
      set var = $var,$var2d_list[$j] 
     endif 
     @ j ++
    end  

    set SE_FILE = ${WORK_DIR}/SE_OCN/${exp_name}.${ensr}.${vou}.${time_tag}.nc
    rm -rvf $SE_FILE
    if ( ! -f $SE_FILE ) then
      ncrcat -d Time,0, -v $var $eam_files ${SE_FILE}
    endif

    @ iy ++
   end

 endif 

 @ i++ 
end

echo "done"

exit
