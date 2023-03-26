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

  fili     = "./cmip_derived_var_info.txt"
  dstr     = asciiread(fili, -1, "string")
  delim    = ","
  varList  = str_squeeze(str_get_field(dstr, 1, delim))
  untList  = str_squeeze(str_get_field(dstr, 2, delim))
  facList  = stringtofloat(str_get_field(dstr, 3, delim))
  nvars    = dimsizes(varList)
  var_lev  = "sfc"
  
  cmip_var = (/"rlut","FLUTC","FLDS","rldscs","FSDS", \
               "FSDSC","rsus","rsuscs","rlus","rsdt", \
               "rsut","rsutcs","rtmt","TAUX","TAUY","TS"/)
  ncmp_var = dimsizes(cmip_var)

 ;time range for climo forcing 
  csym    = 197901
  ceym    = 201412
  nyrs    = ceym/100 - csym/100 + 1
  nmon    = nyrs * 12
  crange  = csym + "-" + ceym

  cpath   = outdir + "/" + scenario
  models  = systemfunc("cd " + cpath+"; ls -d *")
  nmodel  = dimsizes(models)

  do ie = 0,10,1 
   
   do im = 0,nmodel-1,1

    modout = models(im)
    enstr     = "en"+sprinti("%02d",ie)

    do iv = 0,nvars-1,1

     varnam = varList(iv)
     varout = varList(iv)
     system("rm -rvf " + cpath+"/"+modout+ "/"+modout+"."+scenario+".*."+varout+"."+crange+".nc")
    end do 

   end do 
  end do ; end of ensemble 
end
