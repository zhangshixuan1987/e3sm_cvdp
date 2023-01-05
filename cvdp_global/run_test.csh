#!/bin/csh

setenv outnam "cvdp_exp1"
setenv OUTDIR  "/global/cfs/cdirs/e3sm/zhan391/polar_diag/work/${outnam}/"   
setenv CVDP_SCRIPTS  "/global/cfs/cdirs/e3sm/zhan391/polar_diag/cvdp_code/"
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

ncl sst.mean_stddev.ncl &
ncl sst.polar.mean_stddev.ncl &
ncl sst.polar.trends_timeseries.ncl &
ncl sst.trends_timeseries.ncl

