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

#module load  intel-parallel-studio/cluster.2017.4-wyg4gfu intel-parallel-studio/cluster.2017.4-wyg4gfu  intel-mpi/2017.3-dfphq6k intel/17.0.4-74uvhji  intel-mpi/2017.3-dfphq6k nco/4.7.4-x4y66ep netcdf/4.6.1-c2mecde 

set model_case = (20221116.CRYO1950.ne30pg2_SOwISC12to60E2r4.N2Dependent.submeso.chrysalis)
set exp_name   = v2_1.SORRM.p0.1950Control
set ncase = $#model_case

set ocn_var = ("SST" "SSS" "SITIMEFRAC" "SICONC" "SITHICK" \
               "SISNTHICK" "SIMASS"  "OICHFLX" "OLHFLX" "OSHFLX" \
               "OFSWDN" "OFLWUP" "OFLWDN")
set nvar    = $#ocn_var
echo $nvar

set CASE_NAME = "v2_CRYO1950.SORRM.piControl"
set CASE_DIR1 = "${CASE_NAME}_0501-0600"
set sig1_syear = 501
set sig1_eyear = 600
set sig1_ttag  = `printf "%04d" $sig1_syear`01-`printf "%04d" $sig1_eyear`12

set CASE_DIR2 = "${CASE_NAME}_0601-0700"
set sig2_syear = 601
set sig2_eyear = 700
set sig2_ttag  = `printf "%04d" $sig2_syear`01-`printf "%04d" $sig2_eyear`12

set start_year = ${sig1_syear}
set end_year   = ${sig2_eyear}
set time_tag   = `printf "%04d" $start_year`01-`printf "%04d" $end_year`12

#location of work directory 
set RUN_FILE_DIR = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD
set WORK_DIR     = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD/${exp_name}
#Mapping file
set MAP_FILE     = /lcrc/group/acme/ac.szhang/acme_scratch/data/regrid_maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

if ( ! -d $WORK_DIR ) then
  mkdir -p $WORK_DIR
endif

set all_files = "${RUN_FILE_DIR}/${CASE_DIR1}/${CASE_NAME}.en00.*.${sig1_ttag}.nc"
set fsample   = "${RUN_FILE_DIR}/${CASE_DIR1}/${CASE_NAME}.en00.SST.${sig1_ttag}.nc"

foreach file  ( ${all_files} ) 
 set i = 1
 set l_focn = .false.  
 while ( $i <= $nvar )
  set var0     = $ocn_var[$i]
  if ( ${file} =~ *".${var0}."* )  then 
    set l_focn = .true.
  endif 
  @ i++
 end 

 if ( $l_focn == .false. ) then 

  set fil0 = $file 
  set ff1  = `basename ${fil0}`
  set ff2  = `basename ${fsample}`
  set ff1  = (`echo $ff1 | sed "s/\./ /g"`)
  set ff2  = (`echo $ff2 | sed "s/\./ /g"`)
  set nstr = $#ff1
  set kk = 1
  while ( $kk <= $nstr ) 
    if ( $ff1[$kk] != $ff2[$kk] ) then   
      set var = "$ff1[$kk]"
    endif 
    @ kk++ 
  end 

  set fil1    = `echo $fil0 | sed "s/${sig1_ttag}/${sig2_ttag}/g"`
  set fil1    = `echo $fil1 | sed "s/${CASE_DIR1}/${CASE_DIR2}/g"`
  set outfile = `basename $file` 
  set outfile = `echo $outfile | sed "s/${sig1_ttag}/${time_tag}/g"` 
  set outfile = `echo $outfile | sed "s/${CASE_NAME}/${exp_name}/g"`
  set outfile = "${WORK_DIR}/${outfile}"

  if ( ( -f ${fil0} ) && ( -f ${fil1} ) ) then 
    echo "working file: " ${fil0}
    echo "working file: " ${fil1}
    echo "output  file: " ${outfile}
    
    ncks --mk_rec_dmn time ${fil0} ${fil0}.tmp
    mv ${fil0}.tmp ${fil0}
    ncatted -a history,global,d,, ${fil0} ${fil0}.tmp
    mv ${fil0}.tmp ${fil0}
    ncap2 -s 'time=double(time)' ${fil0} ${fil0}.tmp
    mv ${fil0}.tmp ${fil0}  
    ncap2 -s 'time=array(0,1,$time)*365.0/12+15' ${fil0} ${fil0}.tmp
    mv ${fil0}.tmp ${fil0}
    ncatted -a units,time,o,c,"days since `printf "%04d" ${sig1_syear}`-01-01 00:00:0.0" ${fil0} ${fil0}.tmp
    mv ${fil0}.tmp ${fil0}
    ncatted -a calendar,time,o,c,365_day ${fil0}
 
    ncks --mk_rec_dmn time ${fil1} ${fil1}.tmp
    mv ${fil1}.tmp ${fil1}
    ncatted -a history,global,d,, ${fil1} ${fil1}.tmp
    mv ${fil1}.tmp ${fil1}
    ncap2 -s 'time=double(time)' ${fil1} ${fil1}.tmp
    mv ${fil1}.tmp ${fil1}
    ncap2 -s 'time=array(0,1,$time)*365.0/12+15' ${fil1} ${fil1}.tmp
    mv ${fil1}.tmp ${fil1}
    ncatted -a units,time,o,c,"days since `printf "%04d" ${sig2_syear}`-01-01 00:00:0.0" ${fil1} ${fil1}.tmp
    mv ${fil1}.tmp ${fil1}
    ncatted -a calendar,time,o,c,365_day ${fil1}

    rm -rvf ${outfile}
    ncrcat -d time,0, ${fil0} ${fil1} ${outfile}
    ncap2 -s "${var}=float(${var})" ${outfile} ${outfile}.tmp
    mv ${outfile}.tmp ${outfile}
    ncatted -O -h -a _FillValue,,o,f,NaN     ${outfile} ${outfile}.tmp
    mv ${outfile}.tmp ${outfile}
    ncatted -O -h -a _FillValue,,m,f,-9999.0 ${outfile} ${outfile}.tmp
    mv ${outfile}.tmp ${outfile}
    ncap2 -O -s 'defdim("bnds",2); time_bnds=make_bounds(time,$bnds,"time_bnds")' ${outfile} ${outfile}.tmp
    mv ${outfile}.tmp ${outfile}
   #ncrename -v var,${var} ${outfile} 
  endif 
 endif 
 @ i++ 
end

echo "done"

exit
