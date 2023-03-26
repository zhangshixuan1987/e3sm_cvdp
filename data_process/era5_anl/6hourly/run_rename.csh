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

set expnam   = "ERA5"
set nens     = 1
set data_dir = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/${expnam}.6hourly" 
set out_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/${expnam}.6hourly"

set syear    = 1979
set eyear    = 2017
set freq     = "6hourly"

set varList = ("Z100"  "Z200" "Z250" "Z300" "Z400" "Z500" "Z600" "Z700" "Z850" \
                "U100"  "U200" "U250" "U300" "U400" "U500" "U600" "U700" "U850" \
                "V100"  "V200" "V250" "V300" "V400" "V500" "V600" "V700" "V850" \
                "T100"  "T200" "T250" "T300" "T400" "T500" "T600" "T700" "T850" \
                "Q100"  "Q200" "Q250" "Q300" "Q400" "Q500" "Q600" "Q700" "Q850" \
                "VO100"  "VO200" "VO250" "VO300" "VO400" "VO500" "VO600" "VO700" "VO850" \
                "D100"  "D200" "D250" "D300" "D400" "D500" "D600" "D700" "D850" \
                "W100"  "W200" "W250" "W300" "W400" "W500" "W600" "W700" "W850" \
                "VIWVE"     "VIWVN"      "U10"    "V10"    "PSL" \
                "VITHEE"    "VITHEN"     "QFLX"   "WSH250" "WSH285" "WSH585") 

set nvar    = $#varList

set iyear = $syear 
while ( $iyear <= $eyear ) 
  set iv = 1
  while ( $iv <= $nvar ) 
    set ie = 0
    while ( $ie < $nens ) 
      set enstr   = en`printf "%02d" $ie`
      set vout    = $varList[$iv]
      set infil1  = $data_dir/${vout}_${iyear}.nc
      set infil2  = $data_dir/${expnam}.${freq}.${enstr}.${vout}.${iyear}.nc 
      set outfile = $data_dir/${expnam}.${freq}.${enstr}.${vout}.${iyear}01-${iyear}12.nc
      #echo $infil1 
      #echo $infil2
      #echo $outfile 
      if ( -f $infil1 ) then
        mv $infil1 $outfile 
      endif
      if ( -f $infil2 ) then
        mv $infil2 $outfile
      endif
      if( $vout == "W100") then
        set outfil1 = $data_dir/${expnam}.${freq}.${enstr}.OMEGA100.${iyear}01-${iyear}12.nc
        mv $outfile $outfil1
        ncrename -v $vout,OMEGA100  $outfil1
      else if( $vout == "W200") then
        set outfil1 = $data_dir/${expnam}.${freq}.${enstr}.OMEGA200.${iyear}01-${iyear}12.nc
        mv $outfile $outfil1
        ncrename -v $vout,OMEGA200  $outfil1
      else if( $vout == "W250") then
        set outfil1 = $data_dir/${expnam}.${freq}.${enstr}.OMEGA250.${iyear}01-${iyear}12.nc
        mv $outfile $outfil1
        ncrename -v $vout,OMEGA250  $outfil1
      else if( $vout == "W300") then
        set outfil1 = $data_dir/${expnam}.${freq}.${enstr}.OMEGA300.${iyear}01-${iyear}12.nc
        mv $outfile $outfil1
        ncrename -v $vout,OMEGA300  $outfil1
      else if( $vout == "W400") then
        set outfil1 = $data_dir/${expnam}.${freq}.${enstr}.OMEGA400.${iyear}01-${iyear}12.nc
        mv $outfile $outfil1
        ncrename -v $vout,OMEGA400  $outfil1
      else if( $vout == "W500") then
        set outfil1 = $data_dir/${expnam}.${freq}.${enstr}.OMEGA500.${iyear}01-${iyear}12.nc
        mv $outfile $outfil1
        ncrename -v $vout,OMEGA500  $outfil1
      else if( $vout == "W600") then
        set outfil1 = $data_dir/${expnam}.${freq}.${enstr}.OMEGA600.${iyear}01-${iyear}12.nc
        mv $outfile $outfil1
        ncrename -v $vout,OMEGA600  $outfil1
      else if( $vout == "W700") then
        set outfil1 = $data_dir/${expnam}.${freq}.${enstr}.OMEGA700.${iyear}01-${iyear}12.nc
        mv $outfile $outfil1
        ncrename -v $vout,OMEGA700  $outfil1
      else if( $vout == "W850") then
        set outfil1 = $data_dir/${expnam}.${freq}.${enstr}.OMEGA850.${iyear}01-${iyear}12.nc
        mv $outfile $outfil1
        ncrename -v $vout,OMEGA850  $outfil1
      endif

     @ ie ++ 
    end 
    @ iv++
  end  
 @ iyear++
end 
