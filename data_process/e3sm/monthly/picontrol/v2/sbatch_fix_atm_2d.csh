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

set exp_name   = v2.LR.piControl
set model_case = (v2.LR.piControl)
set ncase = $#model_case

set model_ennm = ( "en00" )
set nens       = $#model_ennm

set start_year = 1
set end_year   = 350
set time_tag   = `printf "%04d" $start_year`01-`printf "%04d" $end_year`12

set ocn_var    = ("SST" "SSS" "SITIMEFRAC" "SICONC" "SITHICK" \
                  "SISNTHICK" "SIMASS"  "OICHFLX" "OLHFLX" "OSHFLX" \
                  "OFSWDN" "OFLWUP" "OFLWDN")
set nvar       = $#ocn_var
echo $nvar

#location of work directory 
set RUN_FILE_DIR = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD
#Mapping file
set MAP_FILE     = /lcrc/group/acme/ac.szhang/acme_scratch/data/regrid_maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc


set j = 1
while ( $j <= $nens ) 
 set enstr     = $model_ennm[$j]
 set all_files = "${RUN_FILE_DIR}/${exp_name}/${exp_name}.${enstr}.*.${time_tag}.nc"
 set fsample   = "${RUN_FILE_DIR}/${exp_name}/${exp_name}.${enstr}.SST.${time_tag}.nc"

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
   set ff1  = `basename ${file}`
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
   if ( -f ${file} ) then 
    if ( $var == "UM10" ) then 
      ncrename -v U10,UM10 ${file}
    endif 
    echo "working file: " ${file}
    ncks --mk_rec_dmn time ${file} ${file}.tmp
    mv ${file}.tmp ${file}
    ncatted -a history,global,d,, ${file} ${file}.tmp
    mv ${file}.tmp ${file}
    ncap2 -s 'time=double(time)' ${file} ${file}.tmp
    mv ${file}.tmp ${file}  
    ncap2 -s 'time=array(0,1,$time)*365.0/12+15' ${file} ${file}.tmp
    mv ${file}.tmp ${file}
    ncatted -a units,time,o,c,"days since `printf "%04d" ${start_year}`-01-01 00:00:0.0" ${file} ${file}.tmp
    mv ${file}.tmp ${file}
    ncatted -a calendar,time,o,c,365_day ${file}
    
    ncap2 -s "${var}=float(${var})"          ${file} ${file}.tmp
    mv ${file}.tmp ${file}
    ncatted -O -h -a _FillValue,,o,f,NaN     ${file} ${file}.tmp
    mv ${file}.tmp ${file}
    ncatted -O -h -a _FillValue,,m,f,-9999.0 ${file} ${file}.tmp
    mv ${file}.tmp ${file}
    ncap2 -O -s 'defdim("bnds",2); time_bnds=make_bounds(time,$bnds,"time_bnds")' ${file} ${file}.tmp
    mv ${file}.tmp ${file}
    #ncrename -v var,${var} ${file} 
   endif 
  endif 
  @ i++ 
 end
 @ j++ 
end 

echo "done"

exit
