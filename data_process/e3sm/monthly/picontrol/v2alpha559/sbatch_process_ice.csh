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

set exp_name   = v2alpha559.LR.piControl
set model_case = (20201124.alpha5_59_fallback.piControl.ne30pg2_r05_EC30to60E2r2-1900_ICG.compy )
set model_ennm = ("en00")
set ncase = $#model_case
echo $ncase

set var2d_name = ("SSS" "SST" "SITIMEFRAC" "SICONC" "SITHICK" \
                  "SISNTHICK" "SIMASS"  "OICHFLX" "OLHFLX" "OSHFLX" \
                  "OFSWDN" "OFLWUP" "OFLWDN")
set var2d_frac = (1.0  1.0    1.0  100.0 1.0  \
                  1.0  917.0  1.0  1.0   1.0 \
                  1.0  1.0    1.0)
set var2d_unit = ("g/kg" "degC"  "1"    "%"    "m"  \
                  "m"    "kg/m2" "W/m2" "W/m2" "W/m2" \
                  "W/m2" "W/m2"  "W/m2")
set var2d_list = ("timeMonthly_avg_seaSurfaceSalinity" \
                  "timeMonthly_avg_seaSurfaceTemperature" \
                  "timeMonthly_avg_icePresent"\
                  "timeMonthly_avg_iceAreaCell" \
                  "timeMonthly_avg_iceVolumeCell" \
                  "timeMonthly_avg_snowVolumeCell" \
                  "timeMonthly_avg_iceVolumeCell" \
                  "timeMonthly_avg_seaIceHeatFlux"  \
                  "timeMonthly_avg_latentHeatFlux"  \
                  "timeMonthly_avg_sensibleHeatFlux" \
                  "timeMonthly_avg_shortWaveHeatFlux" \
                  "timeMonthly_avg_longWaveHeatFluxUp" \
                  "timeMonthly_avg_longWaveHeatFluxDown" )
set nvars      = $#var2d_list

set start_year = 1
set end_year   = 400
set time_tag   = `printf "%04d" $start_year`01-`printf "%04d" $end_year`12
@ ym1 = $start_year - 1
set time_unt   = "months since `printf "%04d" $ym1`-12-15 00:00:0.0"

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
 set RUN_FILE_DIR = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD/zstash/v2alpha5_59/${CASE_NAME}/archive/ice/hist
 #ls $RUN_FILE_DIR

 if ( -d $RUN_FILE_DIR ) then
  set iy = $start_year
  set eam_files = 
  while ($iy <= $end_year)
   set eam_files = ($eam_files $RUN_FILE_DIR/*mpassi.hist.am.timeSeriesStatsMonthly*`printf "%04d" $iy`*)
   echo $eam_files

   @ iy ++
  end
  echo $eam_files

  set j = 1
  while ( $j <= $nvars )
   set var  = $var2d_list[$j]
   set vou  = $var2d_name[$j]
   set vfc  = $var2d_frac[$j]
   set ensr = $model_ennm[$i]
   set SE_FILE = ${WORK_DIR}/SE_OCN/${exp_name}.${ensr}.${vou}.${time_tag}.nc
   rm -rvf $SE_FILE
   ncrcat -d Time,0, -v $var $eam_files ${SE_FILE} & 
   @ j++ 
  end 

  wait

  set j = 1
  while ( $j <= $nvars )
   set var  = $var2d_list[$j]
   set vou  = $var2d_name[$j]
   set vfc  = $var2d_frac[$j]
   set vun  = $var2d_unit[$j]
   set ensr = $model_ennm[$i] 
   set SE_FILE = ${WORK_DIR}/SE_OCN/${exp_name}.${ensr}.${vou}.${time_tag}.nc
   set FV_FILE = ${WORK_DIR}/${exp_name}.${ensr}.${vou}.${time_tag}.nc
   rm -rvf $FV_FILE ${WORK_DIR}/tmp_ocn_out.nc ${WORK_DIR}/tmp_ocn_out1.nc ${WORK_DIR}/tmp_ocn_out2.nc
   ncremap -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE}
   ncrename -v $var,$vou -d Time,time ${FV_FILE}   ${WORK_DIR}/tmp_ocn_out.nc
   ncks --mk_rec_dmn time ${WORK_DIR}/tmp_ocn_out.nc ${WORK_DIR}/tmp_ocn_out1.nc
   ncap2 -s 'time=array(1,1,$time)' ${WORK_DIR}/tmp_ocn_out1.nc ${WORK_DIR}/tmp_ocn_out2.nc
   ncatted -a units,time,a,c,"$time_unt" ${WORK_DIR}/tmp_ocn_out2.nc
   ncap2 -s "$vou=$vou*$vfc" -v ${WORK_DIR}/tmp_ocn_out2.nc ${WORK_DIR}/ftmp_ocn_out.nc
   ncatted -a units,$vou,a,c,$vun ${WORK_DIR}/ftmp_ocn_out.nc
   ncatted -a long_name,$vou,a,c,$var ${WORK_DIR}/ftmp_ocn_out.nc
   mv ${WORK_DIR}/ftmp_ocn_out.nc ${FV_FILE}
   rm -rvf ${WORK_DIR}/tmp_ocn_out.nc ${WORK_DIR}/tmp_ocn_out1.nc ${WORK_DIR}/tmp_ocn_out2.nc
   @ j++
  end

 endif 

 @ i++ 
end

##finish the process and remove the temp data
rm -rvf ${WORK_DIR}/SE_OCN
echo "done"

exit

 
