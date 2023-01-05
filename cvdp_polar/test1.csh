#!/bin/csh

setenv outnam "cvdp_fnl3"
setenv OUTDIR  "/global/cfs/cdirs/e3sm/zhan391/polar_diag/work/${outnam}/"   
setenv CVDP_SCRIPTS  "/global/cfs/cdirs/e3sm/zhan391/polar_diag/cvdp_polar/"
setenv CREATE_GRAPHICS  True
setenv OUTPUT_TYPE  "png"
setenv MACHINE  True 
setenv COLORMAP  0 
setenv MAX_TASKS  1
setenv PNG_SCALE_SUMMARY  75
setenv PNG_SCALE  3
setenv VERSION  1.0.0
setenv OBS  True 
setenv POLAR "SH"
setenv webpage_title "POLAR 1979-2014" 

ncl sam_psa.sfcvar_regr.ncl &
ncl samind.sfcvar_regr.ncl  & 
ncl nino34.sfcvar_regr.ncl

wait 

exit
