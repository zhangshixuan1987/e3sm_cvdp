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

module load cdo
module load nco
set remap    = ncremap #${script_path}/${script_name}
set MAP_FILE = /global/cfs/cdirs/e3sm/zhan391/data/regrid_maps/era5_cmip6_to_360x180_Rect_bilinear.nc

set expnam   = "ERA5"
set freq     = "6hourly"
set data_dir = "/global/cfs/projectdirs/m3522/cmip6/${expnam}"
set out_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/${expnam}.${freq}"
set syear    = 1979
set eyear    = 2019

set out_hres = ${out_dir}/${expnam}_0.25deg
set out_lres = ${out_dir}

if ( ! -d  $out_hres) then 
  mkdir -p $out_hres 
endif 

if ( ! -d  $out_lres) then 
  mkdir -p $out_lres 
endif 

set var_List = ( "Z"     "U"     "V"     "T"     "Q"     "VO"     "D"     "W"     )
set var_ERA5 = ( "z"     "u"     "v"     "t"     "q"     "vo"     "d"     "w"     )
set var_key  = ( "an.pl" "an.pl" "an.pl" "an.pl" "an.pl" "an.pl"  "an.pl" "an.pl" )
set nvars    = $#var_List

#ERA5 levels: 1, 2, 3, 5, 7, 10, 20, 30, 50, 70, 100, 125, 150, 175, 200, 225,
#             250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 775, 800, 825,
#             850, 875, 900, 925, 950, 975, 1000
#set lev_Indx = ( 11  15  18  20  22  24  26  31  ) # -F 
set lev_Indx = ( 10  14  17  19  21  23  25  30  33)  # lev -1 
set lev_List = ( 100 200 300 400 500 600 700 850 925)
set nlevs    = $#lev_List

set iyear = $syear
while ($iyear <= $eyear)

 set il  = 9
 while ( $il <= $nlevs )
   set kl   = $lev_Indx[$il]
   set pres = $lev_List[$il]
   set iv = 1
   while ( $iv <= $nvars ) 
    set vout = $var_List[$iv]
    set vint = $var_ERA5[$iv]
    set vkey = $var_key[$iv]
    set vnew = "${vout}${pres}"
    rm -rvf ${out_hres}/${vout}_${iyear}.nc
    rm -rvf ${out_hres}/${vnew}_${iyear}.nc
    set file_list = `echo ${data_dir}/e5.oper.${vkey}/${iyear}*/e5.oper.${vkey}.*_${vint}.*.nc`   
    echo $file_list
    ncrcat -d time,,,6 -d level,$kl,$kl -v $vout $file_list ${out_hres}/${vnew}_${iyear}.nc &
    @ iv++  
   end 

   wait 

   set iv = 1
   while ( $iv <= $nvars )
    set vout = $var_List[$iv]
    set vint = $var_ERA5[$iv]
    set vkey = $var_key[$iv]
    set vnew = "${vout}${pres}"
    ncrename -v $vout,$vnew ${out_hres}/${vnew}_${iyear}.nc 
    set outfile = "$out_lres/${expnam}.${freq}.en00.${vnew}.${iyear}01-${iyear}12.nc"
    $remap -R "--rgr lat_nm=latitude --rgr lon_nm=longitude" -m $MAP_FILE -i ${out_hres}/${vnew}_${iyear}.nc -o ${outfile}
    rm -rvf $out_hres/${vnew}_${iyear}.nc
    @ iv++
   end 

   wait 
   
   @ il++
  end
 
 @ iyear++
end
exit
