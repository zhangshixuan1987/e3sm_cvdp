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
set MAP_FILE = /global/cfs/cdirs/e3sm/zhan391/data/regrid_maps/era5_cmip6_to_360x180_Rect_bilinear.nc

set expnam   = "ERA5"
set freq     = "6hourly"
set data_dir = "/global/cfs/projectdirs/m3522/cmip6/${expnam}"
set out_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/${expnam}.${freq}"

set syear    = 1979
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

set var_List  = ("PRECT")
set var_ERA5  = ("tp"   )
set var_key   = ("e5.accumulated_tp_6h")
set nvars     = $#var_List

set iyear = $syear
while ($iyear <= $eyear)

 set iv = 1
 while ( $iv <= $nvars ) 

   set vout = $var_List[$iv]
   set vint = $var_ERA5[$iv]
   set vkey = $var_key[$iv]

   rm -rvf $out_hres/${vout}_${iyear}.nc
   set file_list = `echo ${data_dir}/${vkey}/${vkey}*${iyear}*.nc`
   ncrcat -d time,,,1 -v tp  $file_list $out_hres/${vout}_${iyear}.nc
   ncrename -v tp,PRECT  $out_hres/${vout}_${iyear}.nc 

   set outfile = "$out_lres/$expnam.$freq.$enstr.${vout}.${iyear}01-${iyear}12.nc"
   rm -rvf $outfile 
   $remap -R "--rgr lat_nm=latitude --rgr lon_nm=longitude" -m $MAP_FILE -i $out_hres/${vout}_${iyear}.nc -o $outfile

  @ iv++
 end 

 @ iyear++
end

