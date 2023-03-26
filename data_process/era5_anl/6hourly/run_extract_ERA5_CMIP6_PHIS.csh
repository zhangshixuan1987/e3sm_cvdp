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
set MAP_FILE = /global/cscratch1/sd/zhan391/DARPA_project/post_process/map_file/era5_cmip6_to_360x180_Rect_bilinear.nc

set expnam   = "ERA5"
set data_dir = "/global/cfs/projectdirs/m3522/cmip6/${expnam}"
set out_dir  = "/global/cscratch1/sd/zhan391/DARPA_project/post_process/data/model_output"

set syear    = 1979
set eyear    = 2017
set freq     = "6hourly"

set out_hres = ${out_dir}/${expnam}_0.25deg/${freq} 
set out_lres = ${out_dir}/${expnam}/${freq}

if ( ! -d  $out_hres) then 
  mkdir -p $out_hres 
endif 

if ( ! -d  $out_lres) then 
  mkdir -p $out_lres 
endif 

#process PHIS which is time invariant 
set vout = "PHIS" 
set vint = "z" 
set vkey = "invariant" 
set file_list = `echo ${data_dir}/e5.oper.${vkey}/197901/e5.oper.${vkey}.*_z.*.nc`
rm -rvf $out_hres/${vout}.nc
cdo select,name=Z $file_list $out_hres/${vout}.nc
ncwa -a time $out_hres/${vout}.nc $out_hres/out.nc
mv $out_hres/out.nc $out_hres/${vout}.nc 
ncrename -v Z,PHIS  $out_hres/${vout}.nc
$remap -m $MAP_FILE -i $out_hres/${vout}.nc -o $out_lres/${vout}.nc 

