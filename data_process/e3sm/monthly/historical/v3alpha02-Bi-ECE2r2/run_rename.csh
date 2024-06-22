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

set exp_name   = v3alpha2.LR.historical
set model_case = (20230704.v3alpha02.historical_0101.chrysalis)
set ncase = $#model_case
set rundir = "/lcrc/group/e3sm/ac.xzheng/E3SMv3_dev"

set exp_key  = "historical" 
set new_name = `pwd`
set new_name = `basename $new_name`
set new_name = ${new_name}.${exp_key}

echo $exp_name $new_name

foreach file (*.ncl sbatch*.csh) 
  echo $file 
  sed -i "s/$exp_name/$new_name/g" $file 
end 

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

