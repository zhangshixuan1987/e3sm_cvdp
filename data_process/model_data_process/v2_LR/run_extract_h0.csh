#!/bin/bash

# Extract atm hist from HPSS. Update the HPSS path accordingly

 source /global/common/software/e3sm/anaconda_envs/load_latest_e3sm_unified_cori-haswell.sh

 CASEID=v2.LR.abrupt-4xCO2_0101

 zstash extract --hpss=/home/g/golaz/E3SMv2/$CASEID "archive/atm/hist/$CASEID.eam.h0.*"
  
 exit
