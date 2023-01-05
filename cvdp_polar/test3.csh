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

ncl polar_ninoreg_pattern.ncl
exit

ncl metrics_ninoregv.ncl 

#ncl nino34.sfcvar_regr.ncl 

exit

ncl polar.sstgrady_bias.ncl 
ncl polar.pslgrady_bias.ncl & 
ncl polar.sstgrady_bias.ncl & 
ncl polar.thgrady_bias.ncl  
ncl polar.tasgrady_bias.ncl &  
exit

ncl polar.thmean_bias.ncl &

ncl polar.tas_bias.ncl 

ncl polar.pslmean_bias.ncl & 

#polar.sstmean_bias.ncl

#ncl polar.swcre_bias.ncl & 
#ncl polar.lwcre_bias.ncl & 
wait 

#ncl polar.hflx_bias.ncl  & 
#ncl polar.qrad_bias.ncl  &
#ncl polar.qnet_bias.ncl  

exit

foreach file (polar.*_bias.ncl) 
  echo $file 
  ncl $file 
end 

#ncl polar.hflx1_bias.ncl

#ncl polar.qnet_bias.ncl & 
#ncl polar.swcre_bias.ncl & 
#ncl polar.lwcre_bias.ncl

#ncl polar.hflx_bias.ncl & 
#ncl polar.qrad_bias.ncl 
#ncl polar.qnet_bias.ncl & 
#ncl polar.swcre_bias.ncl
#ncl polar.sstgrady_bias.ncl

#ncl th850.mean_gradient.ncl

#ncl polar.eth_eof.ncl

#ncl polar.sstmean_bias.ncl &

#ncl polar.thgrady_bias.ncl 

#ncl polar.swcre_bias.ncl #polar.sstgrady_bias.ncl 
# ncl swcre.mean_stddev.ncl 

#polar.pslmean_bias.ncl

wait

#ncl ta.zonalmean_bias.ncl

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
#ncl  metrics.ncl

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
