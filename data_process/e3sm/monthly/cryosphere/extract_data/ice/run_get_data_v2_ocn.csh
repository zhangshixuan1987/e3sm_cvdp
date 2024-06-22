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
set hpssdir = "/home/projects/e3sm/www/WaterCycle/E3SMv2/LR"
set case    = "v2.LR.piControl"
set rundir  = "archive/archive/ice/hist"

cd $workdir
set ddir  = "${www}${hpssdir}/${case}"
echo $ddir
zstash extract --hpss=$ddir -v "*mpassi.hist.am.timeSeriesStatsMonthly.????-??-??.nc" >& zstash_${case}.log&
