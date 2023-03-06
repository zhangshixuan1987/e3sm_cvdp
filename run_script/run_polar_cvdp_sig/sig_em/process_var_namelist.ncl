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

group_nam = "amip"
data_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD"
nml_dir   = "./namelist_byvar" 

;clean up old file 
do i = 0, nvars-1
  tmpfil = "obs_"+vartags(i)
  system("rm -rvf " + tmpfil) 
end do 
;generate empty file for non-existing var
system("if ! test -d " + nml_dir +" ; then mkdir " + nml_dir + " ; fi")
vtag0 = (/"snowdp","moc","maxnum","aice_nh","aice_sh"/)
do i = 0, dimsizes(vtag0)-1
  obfile = "obs_"+vtag0(i)
  system("rm -rvf " + obfile +"; touch " + obfile)
  if(vtag0(i).ne."maxnum") then 
    nmfile = nml_dir+"/namelist_"+vtag0(i)
    system("rm -rvf " + nmfile +"; touch " + nmfile)
  end if 
end do

;generate namelist file 
do i = 0, nvars-1
  varnm = varlist(i)
  vtag  = vartags(i)

  outfile = nml_dir+"/namelist_"+vtag
 ;print(outfile)
  system("if ! test -d " + nml_dir +" ; then mkdir " + nml_dir + " ; fi")
  system("rm -rvf " + outfile +"; touch " + outfile)

 ;#OBS#
  set        = 0
  model_name = "ERA5"
  nens       = 1
 ;write to the namelist
  outnm    = model_name+"-"+varnm + "mmm"
  enstr    = "enmn"
  fsr      = data_dir + "/" + model_name+"/" + model_name+"."+enstr+"."+varnm+".*.nc"
  flm      = systemfunc("ls " + fsr)
  flag     = set+"-"+"Observations"
  if(isfilepresent(flm)) then
    lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
    write_table(outfile,"a",[/lines/],"%s")
    delete([/lines/])
  end if
  delete([/fsr,enstr,outnm,flm,flag/])

  ;#Model#
  set        = 1
  model_name = "CMIP6_MME"
  nens       = 1
 ;write to the namelist 
  outnm    = model_name+"-"+str_upper(group_nam) + "  mmm" 
  enstr    = "enmn"
  fsr      = data_dir + "/" + model_name+"/" +group_nam+"/CMIPMME/"+ model_name+"."+group_nam+"."+enstr+"."+varnm+".*.nc"
  flm      = systemfunc("ls " + fsr)
  flag     = set+"-"+model_name+"-"+str_upper(group_nam)
  if(isfilepresent(flm)) then
    lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
    write_table(outfile,"a",[/lines/],"%s")
    delete(lines)
  end if 
  delete([/fsr,enstr,outnm,flm,flag/])

  ;;CESM model (set 2);;;;
  set        = 2
  ens_name   = "CESM_ENS"
  model_name = "NCAR_CESM2"
  nens       = 1
 ;write to the namelist
  outnm    = model_name+"-"+str_upper(group_nam) + "  mmm"
  enstr    = "enmn"
  fsr      = data_dir + "/" + ens_name+"/" +group_nam+"/"+ model_name+"/"+model_name+"."+group_nam+"."+enstr+"."+varnm+".*.nc"
  flm      = systemfunc("ls " + fsr)
  flag     = set+"-"+model_name+"-"+str_upper(group_nam)
  if(isfilepresent(flm)) then
    lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
    write_table(outfile,"a",[/lines/],"%s")
    delete([/lines/])
  end if   
  delete([/fsr,enstr,outnm,flm,flag/])

  ;;E3SM model (set 3);;;;
  set        = 3
  model_name = "v1.LR"
  ens_name   = "v1.LR" + "." + group_nam 
  nens       = 1
 ;write to the namelist
  outnm    = model_name+"-"+str_upper(group_nam) + "  mmm"
  enstr    = "enmn"
  fsr      = data_dir + "/" + ens_name+"/" + model_name+"."+group_nam+"."+enstr+"."+varnm+".*.nc"
  flm      = systemfunc("ls " + fsr)
  flag     = set+"-"+model_name+"-"+str_upper(group_nam)
  if(isfilepresent(flm)) then
    lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
    write_table(outfile,"a",[/lines/],"%s")
    delete([/lines/])
  end if
  delete([/fsr,enstr,outnm,flm,flag/])

  ;;E3SM model (set 4);;;;
  set        = 4
  model_name = "v2.LR"
  ens_name   = "v2.LR" + "." + group_nam
  nens       = 1
 ;write to the namelist
  outnm    = model_name+"-"+str_upper(group_nam) + "  mmm"
  enstr    = "enmn"
  fsr      = data_dir + "/" + ens_name+"/" + model_name+"."+group_nam+"."+enstr+"."+varnm+".*.nc"
  flm      = systemfunc("ls " + fsr)
  flag     = set+"-"+model_name+"-"+str_upper(group_nam)
  if(isfilepresent(flm)) then
    lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
    write_table(outfile,"a",[/lines/],"%s")
    delete([/lines/])
  end if
  delete([/fsr,enstr,outnm,flm,flag/])

  ;;E3SM model (set 5);;;;
  set        = 5
  model_name = "v3.LR"
  test_tag   = "FourthSmoke"
  ens_name   = "v3.LR" + "." + group_nam + "." + test_tag
  nens       = 1
 ;write to the namelist
  outnm    = model_name+"-"+str_upper(group_nam) + "  mmm"
  enstr    = "en00"
  fsr      = data_dir + "/" + ens_name+"/" + model_name+"."+group_nam+"."+test_tag+"."+enstr+"."+varnm+".*.nc"
  flm      = systemfunc("ls " + fsr)
  flag     = set+"-"+model_name+"-"+str_upper(group_nam)
  if(isfilepresent(flm)) then
    lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
    write_table(outfile,"a",[/lines/],"%s")
    delete([/lines/])
  end if
  delete([/fsr,enstr,outnm,flm,flag/])

 ;generate the file required by cvdp metrics diag
  na = asciiread(outfile,-1,"string")
  maxnumobs  = 0 
  do k = 0,dimsizes(na)-1
   if (isStrSubset(na(k),"Observations").and.isStrSubset(na(k),varnm)) then 
     maxnumobs = maxnumobs + 1
   end if 
  end do 
  if(i.gt.1) then 
    numobs = asciiread("obs_maxnum",-1,"integer")
    if(maxnumobs .gt. numobs) then
      asciiwrite("obs_maxnum",maxnumobs)
    end if
    delete([/numobs/])   
  else 
    asciiwrite("obs_maxnum",maxnumobs)
  end if 
  asciiwrite("obs_"+vtag,na(0))
  delete([/na,maxnumobs/])
end do ; var loop
