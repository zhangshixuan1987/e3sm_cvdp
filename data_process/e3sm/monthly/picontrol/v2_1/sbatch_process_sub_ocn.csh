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

set exp_name   = v2_1.LR.piControl
set model_case = (v2_1.LR.piControl)
set model_ennm = ("en00")
set ncase = $#model_case
echo $ncase

set var2d_name = ("SSS" "SST" "SITIMEFRAC" "SICONC" "SITHICK" \
                  "SISNTHICK" "SIMASS"  "OICHFLX" "OLHFLX" "OSHFLX" \
                  "OFSWDN" "OFLWUP" "OFLWDN")
set nvars      = $#var2d_name

set start_year = 1
set end_year   = 250
set time_tag   = `printf "%04d" $start_year`01-`printf "%04d" $end_year`12
@ ym1 = $start_year - 1
set time_unt   = "months since `printf "%04d" $ym1`-12-15 00:00:0.0"

#location of work directory 
set WORK_DIR     = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD/${exp_name}
set RUN_FILE_DIR = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD/${exp_name}/0001-0500

set i = 1
while ( $i <= $ncase )

 set CASE_NAME  = $model_case[$i]
 echo $CASE_NAME
 set j = 1
 while ( $j <= $nvars )
   set var  = $var2d_name[$j]
   set ensr = $model_ennm[$i] 
   set SE_FILE = ${RUN_FILE_DIR}/${exp_name}.${ensr}.${var}.*.nc
   set FV_FILE = ${WORK_DIR}/${exp_name}.${ensr}.${var}.${time_tag}.nc
   rm -rvf ${FV_FILE}
   echo $SE_FILE
   ncrcat -d time,"0001-01-01 00:00:0.0","0252-01-01 00:00:0.0" ${SE_FILE} ${FV_FILE}  
  @ j++
 end

 @ i++ 
end

echo "done"

exit

 
