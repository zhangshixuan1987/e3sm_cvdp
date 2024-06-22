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

#Set the minimal environment
#module purge
#unsetenv LD_LIBRARY_PATH
#module load intel/16.0.2
#module load mvapich2/2.2b

#Modify path so that ncclimo can find latest ncra and other nco utilities
#set script_path = /blues/gpfs/home/software/spack-0.10.1/opt/spack/linux-centos7-x86_64/intel-17.0.4/nco-4.7.4-x4y66ep2ydoyegnckicvv5ljwrheniun/bin
#set path = ( $script_path  $path )

module load  intel-parallel-studio/cluster.2017.4-wyg4gfu intel-parallel-studio/cluster.2017.4-wyg4gfu  intel-mpi/2017.3-dfphq6k intel/17.0.4-74uvhji  intel-mpi/2017.3-dfphq6k nco/4.7.4-x4y66ep netcdf/4.6.1-c2mecde 

foreach model_case (v2.LR.amip_0101 \
                    v2.LR.amip_0201 \
                    v2.LR.amip_0301)

set CASE_NAME  = $model_case
set start_year = 1979
set end_year   = 2014
set time_tag   = `printf "%04d" $start_year`-`printf "%04d" $end_year`

#location of work directory 
set WORK_DIR     = /lcrc/group/acme/ac.szhang/acme_scratch/data/polar_diag
#location of model history file (run directory or model output directory)
set RUN_FILE_DIR = /lcrc/group/e3sm/ac.forsyth2/E3SMv2/${CASE_NAME}/archive/atm/hist/
#Mapping file
set MAP_FILE   = /lcrc/group/acme/ac.szhang/acme_scratch/data/regrid_maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

set var2d_list1 =("TOZ" "U010" "U001" "OMEGA500")
#set var2d_list1 = ("LHFLX" "SHFLX" "QREFHT" "TUQ" \
#                   "TVQ" "TS" "Z500" "U850" "V850" \
#                   "PS" "PRECT" "TREFHT" "TREFHTMN" "TREFHTMX") 
#"Z500","U850","V850","U250","T250","TREFHT","TREFHTMN","TREFHTMX","TS","TVQ","TUQ","OMEGA500","CLDTOT","FLNT","FSNT","FLNS","FLUT","FSNS","FLDS","FSDS","LHFLX","SHFLX","QREFHT","OMEGA500","PRECT","PS","UBOT","VBOT","TOZ","TMQ","TGCLDLWP","TGCLDIWP","TGCLDCWP")
set nvar1 = $#var2d_list1

echo $nvar1

set var2d_list2 = ("Z700" "PSL" "T200" "T500" "TBOT" "UBOT" "VBOT")
set nvar2 = 0 #$#var2d_list2

if( ! -d $WORK_DIR )then
 mkdir -p $WORK_DIR
endif

if( ! -d ${WORK_DIR}/SE )then
  mkdir -p ${WORK_DIR}/SE
endif

set iy  = $start_year
set ix  = 1 
set eam_files = 
while ($iy <= $end_year)
 set eam_files = ($eam_files $RUN_FILE_DIR/*eam.h1*`printf "%04d" $iy`*)
 @ iy ++
 @ ix ++
end
set iv = 1 
while ($iv <= $nvar1) 
 set var = $var2d_list1[$iv] 
 echo $var 
 set SE_FILE =  ${WORK_DIR}/SE/${CASE_NAME}_{$var}_daily_${time_tag}.nc
 set FV_FILE =  ${WORK_DIR}/${CASE_NAME}_{$var}_daily_${time_tag}.nc
 rm -rvf $SE_FILE
 rm -rvf $FV_FILE
 ncrcat -d time,0, -v $var $eam_files ${SE_FILE}
 ncremap -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE}
 @ iv++
end 

set iy  = $start_year
set ix  = 1
set eam_files =
while ($iy <= $end_year)
 set eam_files = ($eam_files $RUN_FILE_DIR/*eam.h2*`printf "%04d" $iy`*)
 @ iy ++
 @ ix ++
end

set iv = 1
while ($iv <= $nvar2) 
 rm -rvf tmp_${CASE_NAME}_eam.h2.nc tmp_${CASE_NAME}_daily.nc
 set var = $var2d_list2[$iv]
 echo $var
 set SE_FILE =  ${WORK_DIR}/SE/${CASE_NAME}_{$var}_daily_${time_tag}.nc
 set FV_FILE =  ${WORK_DIR}/${CASE_NAME}_{$var}_daily_${time_tag}.nc
 rm -rvf $SE_FILE
 rm -rvf $FV_FILE
 ncrcat -d time,0, -v $var $eam_files tmp_${CASE_NAME}_eam.h2.nc 
 ncra --mro -d time,,,4,4 tmp_${CASE_NAME}_eam.h2.nc ${SE_FILE}
 #ncks -A  tmp_${CASE_NAME}_daily.nc ${SE_FILE} 
 ncremap -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE}
 @ iv++ 
end

end 

