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
set time_tag   = `printf "%04d" $start_year`01-`printf "%04d" $end_year`12

set var2d_name = ( "UM10" "LANDFRAC" "OCNFRAC" "ICEFRAC" "PS" "PSL" "PHIS" "LWCF" "SWCF" "PRECC" "PRECL" "AODVIS" "AODDUST" "TGCLDLWP" "TGCLDIWP" "CLDLOW" "CLDMED" "CLDHGH" "CLDTOT" "FLNT" "FSNT" "FLNTC" "FSNTC" "FLUT" "FSUTOA" "FSUTOAC" "FLUTC" "TMQ" "TS" "SHFLX" "LHFLX" "FSNTOA" "FSNTOAC" "FLNS" "FLNSC" "FLDS" "FSNS" "FSNSC" "FSDS" "FSDSC" "SOLIN" "TREFHT" "TAUY" "TAUX" "QFLX" "QREFHT" "OMEGA500" "PBLH" "PRECSC" "PRECSL" "TAUGWX" "TAUGWY" "TGCLDCWP" "TH7001000" "TREFMNAV" "TREFMXAV" "TUQ" "TVQ" "TVH" "TUH" "TSMN" "TSMX" "SCO" "TCO" "SFO3" "SNOWHICE" "SNOWHLND" "O3_SRF" )
set var2d_list    = ( $var2d_name )
set var2d_list[1] = "U10"
set nvars      = $#var2d_list
#echo $var2d_list

#location of work directory 
set WORK_DIR  = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD/${exp_name}
#Mapping file
set MAP_FILE  = /lcrc/group/acme/ac.szhang/acme_scratch/data/regrid_maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

if( ! -d $WORK_DIR )then
 mkdir -p $WORK_DIR
endif

if( ! -d ${WORK_DIR}/SE_ATM_2D )then
  mkdir -p ${WORK_DIR}/SE_ATM_2D
endif

set i = 1
while ( $i <= $ncase )

 set CASE_NAME  = $model_case[$i] 
 echo $CASE_NAME
 set RUN_FILE_DIR = ${run_dir}/${CASE_NAME}/archive/atm/hist

 if ( -d $RUN_FILE_DIR ) then 

   set iy = $start_year
   set eam_files = 
   while ($iy <= $end_year)
     set eam_files = ($eam_files $RUN_FILE_DIR/*eam.h0*`printf "%04d" $iy`*)
     echo $RUN_FILE_DIR/*eam.h0*`printf "%04d" $iy`*
     @ iy ++
   end

   set j = 1
   set kk = 0 
   while ( $j <= $nvars ) 
     set var  = $var2d_list[$j]
     set vou  = $var2d_name[$j]
     @ ens    = $i - 1 
     set ensr = en`printf "%02d" $ens`
     set SE_FILE = ${WORK_DIR}/SE_ATM_2D/${exp_name}.${ensr}.${vou}.${time_tag}.nc
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
     set ensr = $model_ennm[$i]
     set SE_FILE = ${WORK_DIR}/SE_ATM_2D/${exp_name}.${ensr}.${vou}.${time_tag}.nc
     set FV_FILE = ${WORK_DIR}/${exp_name}.${ensr}.${vou}.${time_tag}.nc
     rm -rvf $FV_FILE tmp_atm_out.nc
     ncremap -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE} 
     rm -rvf tmp_atm_out.nc
    @ j++
   end
 endif 

 @ i++ 
end

##finish the process and remove the temp data
rm -rvf ${WORK_DIR}/SE_ATM_2D
echo "done"

exit

 
