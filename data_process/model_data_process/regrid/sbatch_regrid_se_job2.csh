#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=regrid0300
#SBATCH  --nodes=1
#SBATCH  --time=24:00:00
#SBATCH  --exclusive
#SBATCH -A ESMD
#SBATCH -p slurm

#Script name and path
#Script name and path
set script_name = ncremap
set script_path = /global/u1/z/zender/bin_cori

#Modify path so that ncclimo can find latest ncra and other nco utilities
set path = ( $script_path  $path )

foreach model_case (v2.LR.piControl.CRYO)

foreach ystart (151 201 251)

@ yend   = $ystart + 49

set start_year = ${ystart}
set end_year   = ${yend}
set CASE_NAME  = ${model_case}

set time_tag   = `printf "%04d" $start_year`-`printf "%04d" $end_year`

#location of work directory 
set WORK_DIR      = /global/cfs/cdirs/e3sm/zhan391/data/polar_diag

#Mapping file
set MAP_FILE      = /global/cfs/cdirs/e3sm/zhan391/data/regrid_maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc

set SE_FILE =  ${WORK_DIR}/SE/${CASE_NAME}_eam.h0_monthly_${time_tag}.nc
set FV_FILE =  ${WORK_DIR}/${CASE_NAME}_eam.h0_monthly_${time_tag}.nc

set CLIMO_SCRIPT = $script_path/$script_name
$CLIMO_SCRIPT -i ${SE_FILE} -m ${MAP_FILE} -o ${FV_FILE}

end 

end 

