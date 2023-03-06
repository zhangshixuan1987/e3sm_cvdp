varlist   = (/"PRECT","PSL","TS","TREFHT","SHFLX","LHFLX",\
              "U10","V10","U850","V850","TAUX","TAUY",\
              "Qn_SRF","OLR","FLDS","FLDSC","FLNS","SWCRE","LWCRE", \
              "ETH12", "T850", "CLDTOT","Z500",\
              "U200","V200","PRECST","SF"/)
vartags   = (/"prect","psl","ts","trefht","sh","lh",\
              "u10","v10","u850","v850","taux","tauy",\
              "qnet","olr","flds","fldsc","flns","swcre","lwcre",\
              "eth","th850","cldtot","z500",\
              "u200","v200","precst","zmsf"/)
nvars     = dimsizes(varlist)
ystr      = 1985
yend      = 2014

group_nam = "historical"
data_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD"
nml_dir   = "./namelist_byvar" 

;generate namelist file 
do i = 0, nvars-1
  varnm = varlist(i)
  vtag  = vartags(i)

  ;#OBS#
  set        = 0
  model_name = "ERA5"
 ;generate ensemble mean 
  fsr   = data_dir + "/" + model_name+"/" + model_name+".*."+varnm+".*.nc" 
  fls   = systemfunc("ls " + fsr) 
  outfl = str_sub_str(fls(0),"en00","enmn")
  ;system("rm -rvf " + outfl)
  if(num(.not.ismissing(fls)).gt.1) then
    system("if ! test -f " + outfl +" ; then ncea -4 " + fsr + "   " +outfl + " ; fi")
  end if
  delete([/fls,fsr,outfl,model_name,set/])

  ;#Model#
  set        = 1
  model_name = "CMIP6_MME"
 ;generate ensemble mean
 ;exclude models that do not have required variables
  exclmod  = (/"CMIPMME","NIMS-KMA_KACE-1-0-G","INM_INM-CM5-0",\
               "AWI_AWI-CM-1-1-MR", "INM_INM-CM4-8","CAS_FGOALS-g3", \
               "CSIRO_ACCESS-ESM1-5","CSIRO-ARCCSS_ACCESS-CM2", \
               "CAS_FGOALS-f3-L"/) ;,\
              ;"CAS_CAS-ESM2-0","THU_CIESM","FIO-QLNM_FIO-ESM-2-0", \
              ;"E3SM-Project_E3SM-1-0", "E3SM-Project_E3SM-1-1-ECA", "E3SM-Project_E3SM-1-1"/)
  tmp_name = systemfunc("cd " +data_dir + "/"+ model_name +"/"+group_nam+"; ls -d " + "*")
  indx     = get1Dindex_Exclude(tmp_name,exclmod)
  ens_name = tmp_name(indx)
  delete([/indx,tmp_name/])
  fsr   = data_dir + "/" + model_name+"/" + group_nam+"/"+ens_name+"/"+"*en00*."+varnm+".*.nc"
  fls   = new(dimsizes(ens_name),"string")
  nens = 0
  do j = 0,dimsizes(ens_name)-1,1
   ftmp  = systemfunc("ls " + fsr(j)) 
   if(.not.ismissing(ftmp).and.isfilepresent(ftmp)) then 
     fls(nens) = ftmp
     nens = nens +1
   end if 
   delete(ftmp)
  end do 
  strs  = str_split(fls(0),"/")
  nstr  = dimsizes(strs)
  strs(nstr-1) = str_sub_str(strs(nstr-1),strs(nstr-2),model_name) 
  strs(nstr-2) = "CMIPMME"
  outdr = "/"+str_join(strs(0:nstr-2),"/")
  system("if ! test -d " + outdr +" ; then mkdir " + outdr + " ; fi")
  outfl = "/"+str_join(strs,"/")
  outfl = str_sub_str(outfl,"//","/")
  outfl = str_sub_str(outfl,"en00","enmn")
  system("rm -rvf " + outfl)
  if(num(.not.ismissing(fls(0:nens-1))).gt.1) then
    flstr = ""
    do k = 0,nens-1,1
     flstr = flstr + " " + fls(k)
    end do
    system("if ! test -f " + outfl +" ; then ncea -4 " + flstr + "   " +outfl + " ; fi")
  end if
  delete([/fls,fsr,outfl,flstr,strs,outdr,ens_name,model_name,set/])

  ;;CESM model (set 2);;;;
  set        = 2
  ens_name   = "CESM_ENS"
  model_name = "NCAR_CESM2"
 ;generate ensemble mean 
  fsr   = data_dir + "/" + ens_name+"/" + group_nam+ "/" + model_name+"/"+model_name+"." + group_nam +".*."+varnm+".*.nc"
  fls   = systemfunc("ls " + fsr)
  outfl = str_sub_str(fls(0),"en00","enmn")
  system("rm -rvf " + outfl)
  if(num(.not.ismissing(fls)).gt.1) then
    system("if ! test -f " + outfl +" ; then ncea -4 " + fsr + "   " +outfl + " ; fi")
  end if
  delete([/fls,fsr,outfl,ens_name,model_name,set/])

  ;;E3SM model (set 3);;;;
  set        = 3
  model_name = "v1.LR"
  ens_name   = "v1.LR" + "." + group_nam 
 ;generate ensemble mean
  fsr   = data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+".*."+varnm+".*.nc" 
  fls   = systemfunc("ls " + fsr)
  outfl = str_sub_str(fls(0),"en00","enmn")
  system("rm -rvf " + outfl)
  if(num(.not.ismissing(fls)).gt.1) then
    system("if ! test -f " + outfl +" ; then ncea -4 " + fsr + "   " +outfl + " ; fi")
  end if
  delete([/fls,fsr,outfl,ens_name,model_name,set/])

  ;;E3SM model (set 4);;;;
  set        = 4
  model_name = "v2.LR"
  ens_name   = "v2.LR" + "." + group_nam
 ;generate ensemble mean
  fsr   = data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+".*."+varnm+".*.nc"
  fls   = systemfunc("ls " + fsr)
  outfl = str_sub_str(fls(0),"en00","enmn")
  system("rm -rvf " + outfl)
  if(num(.not.ismissing(fls)).gt.1) then
    system("if ! test -f " + outfl +" ; then ncea -4 " + fsr + "   " +outfl + " ; fi")
  end if
  delete([/fls,fsr,outfl,ens_name,model_name,set/])

  ;;E3SM model (set 5);;;;
  set        = 5
  model_name = "v3.LR"
  test_tag   = "FourthSmoke"
  ens_name   = "v3.LR" + "." + group_nam + "." + test_tag
 ;generate ensemble mean
  fsr   = data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+".*."+varnm+".*.nc"
  fls   = systemfunc("ls " + fsr)
  outfl = str_sub_str(fls(0),"en00","enmn")
  system("rm -rvf " + outfl)
  if(num(.not.ismissing(fls)).gt.1) then
    system("if ! test -f " + outfl +" ; then ncea -4 " + fsr + "   " +outfl + " ; fi")
  end if
  delete([/fls,fsr,outfl,ens_name,model_name,set/])

end do ; var loop
