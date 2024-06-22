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

set exp_name   = v2_CRYO1950.SORRM.piControl
set model_case = (20221116.CRYO1950.ne30pg2_SOwISC12to60E2r4.N2Dependent.submeso.chrysalis)
set ncase = $#model_case

#set var2d_name = ("sst" "sitimefrac" "siconc" "sithick" "sisnthick" "simass" "")
set var2d_name = ("SST" "SITIMEFRAC" "SICONC" "SITHICK" "SISNTHICK" "SIMASS" )
set nvars      = $#var2d_name

set start_year = 501
set end_year   = 600
set time_tag   = `printf "%04d" $start_year`01-`printf "%04d" $end_year`12
@ ym1 = $start_year - 1
set time_unt   = "months since `printf "%04d" $ym1`-12-15 00:00:0.0"

#location of work directory 
set WORK_DIR  = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD/${exp_name}
#Mapping file
set MAP_FILE  = /lcrc/group/acme/ac.szhang/acme_scratch/data/regrid_maps/E3SM_ocean_to_1x1_Rect_bilinear.nc

if( ! -d $WORK_DIR )then
 mkdir -p $WORK_DIR
endif

if( ! -d ${WORK_DIR}/SE_OCN )then
  mkdir -p ${WORK_DIR}/SE_OCN
endif

set i = 1
while ( $i <= $ncase )

 set CASE_NAME  = $model_case[$i]
 set iy = $start_year
 set RUN_FILE_DIR = /lcrc/group/acme/ac.dcomeau/scratch/chrys/${CASE_NAME}/archive/ice/hist

 set j = 1
 while ( $j <= $nvars )
   set vou  = $var2d_name[$j]
   
   @ ens  = $i - 1
   set ensr = en`printf "%02d" $ens`
   set SE_FILE = ${WORK_DIR}/bak_${exp_name}.${ensr}.${vou}.${time_tag}.nc
   set FV_FILE = ${WORK_DIR}/${exp_name}.${ensr}.${vou}.${time_tag}.nc
   if( ! -f $SE_FILE ) then 
      if ( -f $FV_FILE ) then 
        mv $FV_FILE $SE_FILE 
      endif
   endif 
   rm -rvf $FV_FILE  
   ncremap -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE}

  @ j++
 end

 @ i++ 
end

#finish the process and remove the temp data
rm -rvf ${WORK_DIR}/bak_*${time_tag}.nc
echo "done"

exit

