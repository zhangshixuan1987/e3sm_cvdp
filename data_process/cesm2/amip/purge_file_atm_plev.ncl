;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This script used to generate SST and Seaice ensemble forcing from CMIP6 scenario mip;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "./function.ncl"

begin

  cmipnam    = (/"CMIP"/)
  exps       = "r1i1p1f1"
  scenario   = "amip" ;"ssp245";"ssp585"
  outdir     = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/CESM_ENS"
  topdir     = "/global/cfs/projectdirs/m3522/cmip6/CMIP6"
  comdir     = "/global/cfs/cdirs/e3sm/zhan391/e3sm_cvdp/run_script/data_process/cmip6_mme/share_file"

 ;get CMIP6 model name
  model_dirs = systemfunc("cd " + topdir+ "/"+cmipnam+"; ls -d */*")
  model_name = model_dirs 
  nmodel     = dimsizes(model_name)
  delete([/model_dirs/])
 ;print(model_name)

  var_lev    = "plev"
  cmip_vnam  = (/"ua", "va", "ta", "zg", "wap", "hus"/)
  e3sm_vnam  = (/"U1000","U850", "U600", "U500", "U200", \
                 "V1000","V850", "V600", "V500", "V200", \
                 "T850", "T500", "T300", "T200", \ 
                 "Z700","Z500","Z300", "Z200","OMEGA500", \
                 "Q500","Q850","Q700", "Q200"/) 
  cmip_dnam  = e3sm_vnam
  cmip_dnam  = "Amon"
  nvars      = dimsizes(e3sm_vnam)

 ;time range for climo forcing 
  csym       = 197901
  ceym       = 201412
  nyrs       = ceym/100 - csym/100 + 1
  nmon       = nyrs * 12
  crange     = csym + "-" + ceym

  do im = 0,nmodel-1,1

    do iv = 0,nvars-1,1
     varout   = e3sm_vnam(iv)
     vardnm   = cmip_dnam(iv)
     modnam   = model_name(im)
     tmpnam   = str_split(modnam,"/")  
     if (tmpnam(0).eq."MPI-M") then
        modout = "DKRZ"+"_"+tmpnam(1)
     else 
        modout   = str_sub_str(modnam,"/","_")
     end if
     delete(tmpnam)
     ;output the files  
     odir = outdir + "/" + scenario+"/" + modout
     out_file  = odir+"/"+modout+"."+scenario+".en*."+varout+"."+crange+".nc"
     system("rm " + out_file)
   end do 
 end do 
end
