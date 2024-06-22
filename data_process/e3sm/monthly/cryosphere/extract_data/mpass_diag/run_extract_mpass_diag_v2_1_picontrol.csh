#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH -A m3525
#SBATCH -C cpu
#SBATCH -q regular
#SBATCH -t 12:00:00
#SBATCH -N 2
#SBATCH  --job-name=ncclimo_ctrl
#SBATCH  --output=job%j 

#source /global/common/software/e3sm/anaconda_envs/load_latest_e3sm_unified_pm-cpu.csh
source /lcrc/soft/climate/e3sm-unified/load_latest_e3sm_unified_anvil.csh

set workdir = `pwd`
set syear = 500
set eyear = 1000

set www     = "globus://9cd89cfd-6d04-11e5-ba46-22000b92c6ec"
set hpssdir = "/home/projects/m3412"
set case    = "20221116.CRYO1950.ne30pg2_SOwISC12to60E2r4.N2Dependent.submeso.chrysalis"
set rundir  = "archive/archive/ice/hist"
set subdir  = "post/analysis/mpas_analysis/ts_0001-0500_climo_0451-0500/timeseries"

if ( ! -d $rundir ) then 
  mkdir -p $rundir 
endif

cd $rundir 
set ddir  = "${hpssdir}/${case}"
set fil1   = "$subdir/moc/mocTimeSeries_????-????.nc"
set fil2   = "$subdir/transport/transport_????-????.nc"
zstash extract --hpss=$ddir -v "$fil1" "$fil2" >& zstash.log & 
exit
