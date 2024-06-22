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

set exp_name   = v2_1.LR.historical
 
set model_case = (v2_1.LR.historical_0101 v2_1.LR.historical_0151 v2_1.LR.historical_0201 v2_1.LR.historical_0251 v2_1.LR.historical_0301)
set ncase = $#model_case

#set var2d_name = ( "U" "V" "T" "Q" "RELHUM" "OMEGA" "CLDLIQ" "CLOUD" "Z3" "QRL" "QRS")
set var2d_name = ( "LANDFRAC" "OCNFRAC" "ICEFRAC" "PS" "PSL" "U10" "LWCF" "SWCF" "PRECC" "PRECL" "AODVIS" "AODDUST" "TGCLDLWP" "TGCLDIWP" "CLDLOW" "CLDMED" "CLDHGH" "CLDTOT" "FLNT" "FSNT" "FLNTC" "FSNTC" "FLUT" "FSUTOA" "FSUTOAC" "FLUTC" "TMQ" "TS" "SHFLX" "LHFLX" "FSNTOA" "FSNTOAC" "FLNS" "FLNSC" "FLDS" "FSNS" "FSNSC" "FSDS" "FSDSC" "SOLIN" "TREFHT" "TAUY" "TAUX" "QFLX" "QREFHT" "OMEGA500" "PBLH" "PRECSC" "PRECSL" "TAUGWX" "TAUGWY" "TGCLDCWP" "TH7001000" "TREFMNAV" "TREFMXAV" "TUQ" "TVQ" "TVH" "TUH" "TSMN" "TSMX" "SCO" "TCO" "SFO3" "SNOWHICE" "SNOWHLND" )
set var2d_list = ( $var2d_name )
set nvars      = $#var2d_list

set start_year = 1915
set end_year   = 2014
set time_tag   = `printf "%04d" $start_year`01-`printf "%04d" $end_year`12

#location of work directory 
set WORK_DIR  = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD/${exp_name}
#Mapping file
set MAP_FILE  = /lcrc/group/acme/ac.szhang/acme_scratch/data/regrid_maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

if( ! -d $WORK_DIR )then
 mkdir -p $WORK_DIR
endif

if( ! -d ${WORK_DIR}/SE_ATM )then
  mkdir -p ${WORK_DIR}/SE_ATM
endif

set i = 1
while ( $i <= $ncase )

 set CASE_NAME  = $model_case[$i]
 set iy = $start_year
 set RUN_FILE_DIR = /lcrc/group/e3sm/ac.golaz/E3SMv2_1/${CASE_NAME}/archive/atm/hist
#ls $RUN_FILE_DIR

 set eam_files = 
 while ($iy <= $end_year)
   set eam_files = ($eam_files $RUN_FILE_DIR/*eam.h0*`printf "%04d" $iy`*)
  @ iy ++
 end

 set j = 1
 set kk = 0 
 while ( $j <= $nvars ) 
   set var  = $var2d_list[$j]
   set vou  = $var2d_name[$j]
   @ ens    = $i - 1 
   set ensr = en`printf "%02d" $ens`
   set SE_FILE = ${WORK_DIR}/SE_ATM/${exp_name}.${ensr}.${vou}.${time_tag}.nc
   rm -rvf $SE_FILE
   ncrcat -d time,0, -v $var $eam_files ${SE_FILE} & 
   if ( $kk > 5 ) then 
     wait 
     set kk = 0 
   endif 
  @ j++ 
  @ kk ++ 
 end 

 wait

 set j = 1
 while ( $j <= $nvars )
   set var  = $var2d_list[$j]
   set vou  = $var2d_name[$j]

   @ ens  = $i - 1
   set ensr = en`printf "%02d" $ens`
   set SE_FILE = ${WORK_DIR}/SE_ATM/${exp_name}.${ensr}.${vou}.${time_tag}.nc
   set FV_FILE = ${WORK_DIR}/${exp_name}.${ensr}.${vou}.${time_tag}.nc
   rm -rvf $FV_FILE tmp_atm_out.nc
   ncremap -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE} 
   rm -rvf tmp_atm_out.nc
  @ j++
 end

 @ i++ 
end

##finish the process and remove the temp data
rm -rvf ${WORK_DIR}/SE_ATM
echo "done"

exit

 
