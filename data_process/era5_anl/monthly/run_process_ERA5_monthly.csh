#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH -A esmd
#SBATCH -p short
#SBATCH -t 2:00:00
#SBATCH -N 4
#SBATCH  --job-name=ncclimo_ctrl

module load nco 
module load cdo 
#set script_name = ncremap
#set script_path = /share/apps/nco/4.7.9/bin 
#set path        = ( ${script_path}  ${path} )
set remap       = ncremap #${script_path}/${script_name}
set MAP_FILE    = /global/cscratch1/sd/zhan391/DARPA_project/post_process/data/maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

set expnam      = "ERA5"
set outnam      = "ERA5"
set out_dir     = "/global/cscratch1/sd/zhan391/DARPA_project/post_process/data/model_output"

set syear       = 1979
set eyear       = 2017
set mon_list    = ( 1 2 3 4 5 6 7 8 9 10 11 12 )
set nmon        = $#mon_list

set ens_list    = ( 0 1 2 3 4 5 6 7 8 9 10 )
set nens        = $#ens_list

set iy = $syear 
while ( $iy <= $eyear ) 
   
  set iyear = `printf "%04d" $iy` 
  @ iypre =  $iy - 1

  #process monthly mean#
  set run_dir = "/global/cfs/cdirs/e3sm/zhan391/data/ERA5/monthly"
  set ie = 1
  while ( $ie <= $nens ) 
    set enstr = `printf "%02d" $ens_list[$ie]`
    if ( $ens_list[$ie] == 0 ) then 
      set files = "${run_dir}/ERA5_analysis_monthly_1979-2019_1x1.nc"
    else 
      set files = "${run_dir}/ERA5_ens${enstr}_monthly_1979-2019_1x1.nc"
    endif 
    #echo $files
  
    set hfile = "h0"
    set freq  = "monthly"
    mkdir -p ${out_dir}/${outnam}/${freq}
    set outfile = ${out_dir}/${outnam}/${freq}/${iyear}_${hfile}_ens${enstr}.nc

    cdo selyear,${iyear}/${iyear} $files $outfile 
    #ncrcat -d time,${iyear}'-01-01',${iyear}'-12-01'  $files $outfile 
   @ ie++ 
  end 

 @ iy++ 
end 

