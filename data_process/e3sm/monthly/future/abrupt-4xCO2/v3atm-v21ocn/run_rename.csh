#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH  --job-name=regrid0350
#SBATCH  --nodes=1
#SBATCH  --time=12:00:00
#SBATCH  --exclusive
#SBATCH -A condo
#SBATCH -p acme-small

set jobdir = `pwd`
cd $jobdir

set rundir     = "/lcrc/group/e3sm/ac.xzheng/E3SMv3_dev/"
set exp_name   = v3.LR.abrupt-4xCO2
set model_case = ("20230307.v3atm_v21.abrupt-4xCO2_0101.chrysalis")
set ncase = $#model_case

set exp_key  = "abrupt-4xCO2"
set new_name = `pwd`
set new_name = `basename $new_name`
set new_name = ${new_name}.${exp_key}

echo $exp_name $new_name

set WORK_DIR  = /lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD

if ( -d $WORK_DIR/${exp_name} ) then 
  mv $WORK_DIR/${exp_name} $WORK_DIR/${new_name}
endif 

cd $WORK_DIR/${new_name}
foreach dir (*) 
  if ( -d  $dir ) then 
    echo $dir
    cd $dir 
    foreach file (*.nc)
      set newfile = `echo $file | sed s/${exp_name}/${new_name}/g`
      echo $file  $newfile
      mv $file $newfile
    end
    cd ../
  endif 
end 

cd $WORK_DIR/${new_name}

foreach file (*.nc) 
  set newfile = `echo $file | sed s/${exp_name}/${new_name}/g` 
  echo $file  $newfile
  mv $file $newfile 
end 


exit

