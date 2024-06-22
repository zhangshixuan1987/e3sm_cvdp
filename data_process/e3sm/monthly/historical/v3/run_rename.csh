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

set model_case = (20231209.v3.LR.piControl-spinup.chrysalis)
set exp_name   = v3.LR.piControl
set new_name   = v3.LR.piControl-spinup
echo $exp_name $new_name

#foreach file (*.ncl sbatch*.csh ) 
#  echo $file 
#  sed -i "s/$exp_name/$new_name/g" $file 
#end 

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

