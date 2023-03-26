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

set expnam   = "v2.LR.amip.6hourly"
set nens     = 3 
set data_dir = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/${expnam}" 
set out_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/${expnam}"

set syear    = 1979
set eyear    = 2017
set freq     = "6hourly"

set varList  = ("PSL" "UBOT" "VBOT" "TREFHT" "TBOT" "U850" "V850" "Z700" "T200" "T500" "FLUT" "OMEGA500" "PRECT" "U200" "PRECC" "PRECT" "QFLX" "SHFLX" "TUQ" "TVQ")
set nvar     = $#varList

set iyear = $syear 
while ( $iyear <= $eyear ) 
 set ie = 0 
 while ($ie < $nens) 
  set enstr = en`printf "%02d" $ie`
  set iv = 1
  while ( $iv <= $nvar )
    set vout = $varList[$iv]
    set infil1  = $data_dir/${expnam}.${enstr}.${vout}.${iyear}.nc
    echo $infil1
    set outfile = $data_dir/${expnam}.${enstr}.${vout}.${iyear}01-${iyear}12.nc
    if ( -f $infil1 ) then
      mv $infil1 $outfile
    endif
    @ iv++
  end
  @ ie ++
 end 
 @ iyear++
end 
