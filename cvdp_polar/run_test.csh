#!/bin/csh

setenv outnam "cvdp_vs_era5"
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
setenv webpage_title "POLAR 1979-2014" 
#ncl sam_psa.ncl
#exit

#ncl webpage.ncl 
#exit
#
#ncl polar.ssterr_eof.ncl #terr.indices.ncl
#ncl sst.mean_stddev.ncl
#ncl sst.mean_gradient.ncl 

#ncl soi.ncl & 
#ncl tpdv.ncl & 
ncl  metrics.ncl

#ncl  webpage.ncl  #sst.indices.ncl
#" 'webtitle="+quote+webpage_title+quote+"' "+zp+"webpage.ncl"
#ncl webpage.ncl 
#exit

#ncl sst.indices.ncl
#ncl polar.sst_eof.ncl 
#ncl polar.sam.indices.ncl & 
#ncl polar.asl.indices.ncl
#ncl ncfiles.append.ncl

wait
