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
set exp_name   = v2.LR.historical.6hourly
set model_case = (v2.LR.historical_0101 v2.LR.historical_0151 v2.LR.historical_0201 v2.LR.historical_0251 v2.LR.historical_0301)
set ncase = $#model_case

set var2d_list = ("FLUT" "OMEGA500" "PRECT" "U200")
set nvars      = $#var2d_list

set start_year = 1979
set end_year   = 2014
set time_tag   = `printf "%04d" $start_year`-`printf "%04d" $end_year`

#location of work directory 
set WORK_DIR  = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD/${exp_name}
#Mapping file
set MAP_FILE  = /lcrc/group/acme/ac.szhang/acme_scratch/data/regrid_maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

if( ! -d $WORK_DIR )then
 mkdir -p $WORK_DIR
endif

if( ! -d ${WORK_DIR}/SE )then
  mkdir -p ${WORK_DIR}/SE
endif

set i = 1
while ( $i <= $ncase )

 set CASE_NAME  = $model_case[$i]
 set iy = $start_year
 set RUN_FILE_DIR = /lcrc/group/e3sm/ac.forsyth2/E3SMv2/${CASE_NAME}/archive/atm/hist

 while ($iy <= $end_year)

    @ ym1  = $iy - 1 
    @ yp1  = $iy + 1
 
 
    set eam_files = ($RUN_FILE_DIR/*eam.h3*`printf "%04d" $ym1`-12*)
    set eam_files = ($eam_files $RUN_FILE_DIR/*eam.h3*`printf "%04d" $iy`*)
    if ( $iy < $end_year ) then
      set eam_files = ($eam_files $RUN_FILE_DIR/*eam.h3*`printf "%04d" $yp1`-01*)
    endif

    set j = 1
    while ( $j <= $nvars )
      set var  = $var2d_list[$j]
      @ ens    = $i - 1 
      set ensr = en`printf "%02d" $ens`
      set SE_FILE = ${WORK_DIR}/SE/${exp_name}.${ensr}.${var}.${iy}.nc
      rm -rvf $SE_FILE
      set timstr1  = "${iy}-01-01 00:00:0.0"
      set timstr2  = "${iy}-12-31 21:00:0.0"
      ncrcat -d time,"${timstr1}","${timstr2}",1 -v $var $eam_files ${SE_FILE} & 
     @ j++ 
    end 
    wait 

    set j = 1
    while ( $j <= $nvars )
      set var  = $var2d_list[$j]
      @ ens  = $i - 1
      set ensr = en`printf "%02d" $ens`
      set SE_FILE = ${WORK_DIR}/SE/${exp_name}.${ensr}.${var}.${iy}.nc
      set FV_FILE = ${WORK_DIR}/${exp_name}.${ensr}.${var}.${iy}.nc
      rm -rvf $FV_FILE
      ncremap -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE} & 
     @ j++
    end

    wait 

  @ iy ++
 end

 @ i++ 
end

##finish the process and remove the temp data
rm -rvf ${WORK_DIR}/SE
echo "done"

exit

 
