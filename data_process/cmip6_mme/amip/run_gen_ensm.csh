#!/bin/csh

# Extract atm hist from HPSS. Update the HPSS path accordingly

set datdir  = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/CMIP6_MME" 
set varlist = ( "U850" "U600" "U500" "U200" "V850" "V600" "V500" "V200" \
                "T850" "T500" "T300" "T200" "Z700" "Z500" "Z300" "Z200" )
