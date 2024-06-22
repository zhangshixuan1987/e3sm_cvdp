#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=regrid0300
#SBATCH  --nodes=1
#SBATCH  --time=12:00:00
#SBATCH  --exclusive
#SBATCH -A condo
#SBATCH -p acme-small

source /lcrc/soft/climate/e3sm-unified/load_latest_e3sm_unified_anvil.csh

set workdir = `pwd`
set syear = 1850
set eyear = 2014

set www     = "globus://9cd89cfd-6d04-11e5-ba46-22000b92c6ec"
#set www     = "globus:globus://nersc"
set hpssdir = "/home/projects/e3sm/www/WaterCycle/E3SMv2/LR"
set model   = "v2.LR"
set type    = "historical"
set rundir  = "archive/archive/ice/hist"

cd $workdir

foreach ens ( "0101" "0151" "0201" "0251" "0301")
  set case  = "${model}.${type}"
  set ddir  = "${www}${hpssdir}/${case}_${ens}"
  echo $ddir
  zstash extract --hpss=$ddir -v "*eam.h0.????-??.nc" >& zstash.atm.${case}_${ens}.log&

#  set iy    = $syear
#  while ( $iy <= $eyear )
#    set yst = `printf "%04d" $iy`
#    zstash extract --hpss=$ddir -v "*mpassi.hist.am.timeSeriesStatsMonthly.${yst}*.nc" #& 
#    exit
#
#   @ iy++
#  end
end

