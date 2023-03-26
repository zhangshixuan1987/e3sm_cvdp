#!/bin/csh
#SBATCH --account=m3525
#SBATCH -J era5-process
#SBATCH -q flex
#SBATCH -C knl
#SBATCH -N 1
#SBATCH --time=48:00:00      #the max walltime allowed for flex QOS jobs
#SBATCH --time-min=2:00:00   #the minimum amount of time the job should run
#SBATCH --error=%x%j.err 
#SBATCH --output=%x%j.out 

#module load cdo
#module load nco

set remap    = ncremap #${script_path}/${script_name}
set MAP_FILE = "/global/cfs/cdirs/e3sm/zhan391/data/regrid_maps/era5_cmip6_to_360x180_Rect_bilinear.nc"

set expnam   = "ERA5"
set freq     = "6hourly"
set data_dir = "/global/cfs/projectdirs/m3522/cmip6/${expnam}"
set out_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/${expnam}.${freq}"

set syear    = 2001
set eyear    = 2017
set enstr    = "en00"

set out_hres = ${out_dir}/${expnam}_0.25deg
set out_lres = ${out_dir}

if ( ! -d  $out_hres) then 
  mkdir -p $out_hres 
endif 

if ( ! -d  $out_lres) then 
  mkdir -p $out_lres 
endif 

set var_List  = ( "VIKEE"    "VIKEN"     "VIGE"    "VIGN"  "VITOEE" "VITOEN" "VITHEE"    "VITHEN"     "QFLX" )     #"VIWVE"     "VIWVN"      "U10"    "V10"    "PSL" )
set var_ERA5  = ( "vikee"    "viken"     "vige"    "vign"  "vitoee" "vitoen" "vithee"    "vithen"     "ie"   )    #"viwve"     "viwvn"      "10u"    "10v"    "msl" )
set var_key   = ( "an.vinteg" "an.vinteg"  "an.vinteg" "an.vinteg" "an.vinteg" "an.vinteg" "an.vinteg" "an.vinteg"  "an.sfc" )  #"an.vinteg" "an.vinteg"  "an.sfc" "an.sfc" "an.sfc" ) 
set nvars     = $#var_List

set iyear = $syear
while ($iyear <= $eyear)

  set iv = 1
  while ( $iv <= $nvars ) 
   set vout = $var_List[$iv]
   set vint = $var_ERA5[$iv]
   set vkey = $var_key[$iv]
   rm -rvf $out_hres/${vout}_${iyear}.nc
   set file_list = `echo ${data_dir}/e5.oper.${vkey}/${iyear}*/e5.oper.${vkey}.*_${vint}.*.nc`   
   echo $file_list
   if($vout == "PSL") then 
     ncrcat -d time,,,6 -v MSL     $file_list $out_hres/${vout}_${iyear}.nc & 
   else if($vout == "U10") then
     ncrcat -d time,,,6 -v VAR_10U $file_list $out_hres/${vout}_${iyear}.nc & 
   else if($vout == "V10") then
     ncrcat -d time,,,6 -v VAR_10V $file_list $out_hres/${vout}_${iyear}.nc & 
   else if($vout == "QFLX") then
     ncrcat -d time,,,6 -v IE $file_list $out_hres/${vout}_${iyear}.nc &
   else
     ncrcat -d time,,,6 -v $vout   $file_list $out_hres/${vout}_${iyear}.nc & 
   endif 
   @ iv++  
  end 

  wait 

  set iv = 1
  while ( $iv <= $nvars )
   set vout = $var_List[$iv]
   set vint = $var_ERA5[$iv]
   set vkey = $var_key[$iv]
   if($vout == "PSL") then
     ncrename -v MSL,PSL     $out_hres/${vout}_${iyear}.nc
   else if($vout == "U10") then
     ncrename -v VAR_10U,U10 $out_hres/${vout}_${iyear}.nc
   else if($vout == "V10") then
     ncrename -v VAR_10V,V10 $out_hres/${vout}_${iyear}.nc
   else if($vout == "QFLX") then
     ncrename -v IE,QFLX $out_hres/${vout}_${iyear}.nc
   endif
   set outfile = "$out_lres/$expnam.$freq.$enstr.${vout}.${iyear}.nc"
   rm -rvf $outfile
   $remap -R "--rgr lat_nm=latitude --rgr lon_nm=longitude" -m $MAP_FILE -i $out_hres/${vout}_${iyear}.nc -o $outfile 

   @ iv++
  end 

 @ iyear++
end

