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

set exp_name   = v3.LR.historical
set model_case = (20230307.v3atm_v21.historical_0101.chrysalis)
set ncase = $#model_case

#set var2d_name = ("sst" "sitimefrac" "siconc" "sithick" "sisnthick" "simass" "")
set var2d_name = ("SNFRAC" "SNOWDP" "SNOW"   "SOILWATER")
set var2d_frac = ( 1.0     1.0      86400.0  1.0        )
set var2d_unit = ("1"      "m"      "mm/day" "kg/m2"    )
set var2d_desc = ("Fraction of ground covered by snow" \
                  "Water equivalent snow depth" \
                  "Atmospheric snow rate" \
                  "soil water (liquid + ice) in top 10cm of soil")
set var2d_list = ("FSNO" "SNOWDP" "SNOW" "SOILWATER_10CM")
set nvars      = $#var2d_list

set start_year = 1915
set end_year   = 2014
set time_tag   = `printf "%04d" $start_year`01-`printf "%04d" $end_year`12
@ ym1 = $start_year - 1
set time_unt   = "months since `printf "%04d" $ym1`-12-15 00:00:0.0"

#location of work directory 
set WORK_DIR  = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD/${exp_name}
#Mapping file
set MAP_FILE  = /lcrc/group/acme/ac.szhang/acme_scratch/data/regrid_maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

if( ! -d $WORK_DIR )then
 mkdir -p $WORK_DIR
endif

if( ! -d ${WORK_DIR}/SE_LND )then
  mkdir -p ${WORK_DIR}/SE_LND
endif

set i = 1
while ( $i <= $ncase )

 set CASE_NAME  = $model_case[$i]
 set iy = $start_year
 set RUN_FILE_DIR = /lcrc/group/e3sm/ac.xzheng/E3SMv3_dev/${CASE_NAME}/archive/lnd/hist_backup

 set eam_files = 
 while ($iy <= $end_year)
   set eam_files = ($eam_files $RUN_FILE_DIR/*elm.h0*`printf "%04d" $iy`*)
  @ iy ++
 end

 set j = 1
 while ( $j <= $nvars )
   set var  = $var2d_list[$j]
   set vou  = $var2d_name[$j]
   set vfc  = $var2d_frac[$j]
   @ ens    = $i - 1 
   set ensr = en`printf "%02d" $ens`
   set SE_FILE = ${WORK_DIR}/SE_LND/${exp_name}.${ensr}.${vou}.${time_tag}.nc
   rm -rvf $SE_FILE
   ncrcat -d time,0, -v $var $eam_files ${SE_FILE} & 
  @ j++ 
 end 

 wait

 set j = 1
 while ( $j <= $nvars )
   set var  = $var2d_list[$j]
   set vou  = $var2d_name[$j]
   set vfc  = $var2d_frac[$j]
   set vun  = $var2d_unit[$j]

   @ ens  = $i - 1
   set ensr = en`printf "%02d" $ens`
   set SE_FILE = ${WORK_DIR}/SE_LND/${exp_name}.${ensr}.${vou}.${time_tag}.nc
   set FV_FILE = ${WORK_DIR}/${exp_name}.${ensr}.${vou}.${time_tag}.nc
   rm -rvf $FV_FILE
   ncremap -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE}
   if( $var != $vou ) then
     ncrename -v $var,$vou  ${FV_FILE}
   endif
   ncap2 -O -h -v -s "$vou=$vou*$vfc"  ${FV_FILE} ${WORK_DIR}/SE_LND/tmp_lnd.nc
   mv ${WORK_DIR}/SE_LND/tmp_lnd.nc ${FV_FILE} 
   ncatted -O -a units,$vou,m,c,$vun ${FV_FILE}
  @ j++
 end

 @ i++ 
end

##finish the process and remove the temp data
rm -rvf ${WORK_DIR}/SE_LND
echo "done"

exit
