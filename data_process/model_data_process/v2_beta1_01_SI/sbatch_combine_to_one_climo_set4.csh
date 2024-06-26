#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=regrid0300
#SBATCH  --nodes=1
#SBATCH  --time=2:00:00
#SBATCH  --exclusive
#SBATCH -A ESMD
#SBATCH -p short

set jobdir = `pwd`
cd $jobdir

#Script name and path
set script_name = ncclimo
set ncrcat_name = ncrcat
set script_path = /share/apps/nco/4.7.9/bin 

#Set the minimal environment
#module purge
#unsetenv LD_LIBRARY_PATH
#module load intel/16.0.2
#module load mvapich2/2.2b

#Modify path so that ncclimo can find latest ncra and other nco utilities
set path = ( $script_path  $path )

set CASE_NAME  = 20201217.beta1_01.piControlSI.compy
set start_year = 11
set end_year   = 40

#location of work directory 
set WORK_DIR   = /compyfs/zhan391/Cryosphere_project/diag_package/data/$CASE_NAME
set SE_OUTDIR  = $WORK_DIR/se_climo/combine_year${start_year}_year${end_year}
set FV_OUTDIR  = $WORK_DIR/climo/combine_year${start_year}_year${end_year}

if ( ! -d $WORK_DIR ) then
 mkdir -p $WORK_DIR
endif  

if ( ! -d $SE_OUTDIR ) then
 mkdir -p $SE_OUTDIR
endif  

if ( ! -d $FV_OUTDIR ) then
 mkdir -p $FV_OUTDIR
endif

#combine the data into one;;;;;
#foreach n (01 02 03 04 05 06 07 08 09 10 11 12 ANN DJF JJA MAM SON)
foreach n (ANN DJF JJA MAM SON)
 echo $n
 set SE_FILES = ""
 set FV_FILES = ""
 set i = $start_year
 while ($i <= $end_year )
   set sestr = ${WORK_DIR}/se_climo/${i}to${i}yrs/*_${n}_*_*_climo.nc
   set fvstr = ${WORK_DIR}/climo/${i}to${i}yrs/*_${n}_*_*_climo.nc
   set SE_FILES = ( $SE_FILES $sestr )
   set FV_FILES = ( $FV_FILES $fvstr )
   @ i++
 end
 set CAT_SCRIPT = $script_path/$ncrcat_name
 set OUT_SE_FILES = ${SE_OUTDIR}/${CASE_NAME}_${n}_means.nc
 set OUT_FV_FILES = ${FV_OUTDIR}/${CASE_NAME}_${n}_means.nc
 rm -rvf $OUT_SE_FILES $OUT_FV_FILES
 $CAT_SCRIPT ${SE_FILES} $OUT_SE_FILES &
 $CAT_SCRIPT ${FV_FILES} $OUT_FV_FILES &
 wait
end
