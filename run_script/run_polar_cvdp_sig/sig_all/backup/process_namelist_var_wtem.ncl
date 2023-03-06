refvar    = "PSL"
varlist   = (/"PRECT","PSL","TS","TREFHT","SHFLX","LHFLX",\
              "U10","V10","U850","V850","TAUX","TAUY",\
              "Qn_SRF","FLDS","FLDSC","FLNS","SWCRE","LWCRE", \
              "ETH12", "T850", "CLDTOT","Z500",\
              "U200","V200","PRECST","SF"/)
vartags   = (/"prect","psl","ts","trefht","sh","lh",\
              "u10","v10","u850","v850","taux","tauy",\
              "qnet","flds","fldsc","flns","swcre","lwcre",\
              "eth","th850","cldtot","z500",\
              "u200","v200","precst","zmsf"/)
nvars     = dimsizes(varlist)
ystr      = 1985
yend      = 2014

group_nam = "amip"
data_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD"
nml_dir   = "./namelist_byvar" 

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
  nens       = 11
 ;generate ensemble mean 
  fsr   = data_dir + "/" + model_name+"/" + model_name+".*."+varnm+".*.nc" 
  fls   = systemfunc("ls " + fsr) 
  outfl = str_sub_str(fls(0),"en00","enmn")
  system("if ! test -f " + outfl +" ; then ncea " + fsr + "   " +outfl + " ; fi")
 ;write to the namelist
  enstr    = "enmn"
  outnm    = model_name+"-"+varnm + "em"
  flm      = systemfunc("ls " + outfl)
  flag     = set+"-"+"Observations"
  if(isfilepresent(flm)) then
    lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
    write_table(outfile,"a",[/lines/],"%s")
    delete([/lines/])
  end if
  delete([/fls,fsr,outfl,enstr,outnm,flm,flag/])
 ;process each ensemble member and write to namelist 
  do j = 0, nens-1
    enstr = "en"+ sprinti("%02d",j)
    outnm = model_name+"-"+varnm + sprinti("%02d",j)
    flm   = systemfunc("ls " + data_dir + "/" + model_name+"/" + model_name+"." + enstr+"."+varnm+".*.nc")
    flag  = set+"-"+"Observations"
   ;print(flm)
    if(isfilepresent(flm)) then 
      lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
      write_table(outfile,"a",[/lines/],"%s")
      delete([/lines/])
    end if 
  end do
 ;output maximum number of obs 
  maxnumobs = nens
  asciiwrite(nml_dir+"obs_maxnum",maxnumobs)
  delete([/nens/])

  ;#Model#
  set        = 1
  model_name = "CMIP6_MME"
  ;generate ensemble mean
  fsr   = data_dir + "/" + model_name+"/" + group_nam+"/*/"+"*."+varnm+".*.nc"
  fls   = systemfunc("ls " + fsr)
  strs  = str_split(fls(0),"/")
  nstr  = dimsizes(strs)
  strs(nstr-1) = str_sub_str(strs(nstr-1),strs(nstr-2),model_name) 
  strs(nstr-2) = "CMIPMME"
  outdr = "/"+str_join(strs(0:nstr-2),"/")
  system("if ! test -d " + outdr +" ; then mkdir " + outdr + " ; fi")
  outfl = "/"+str_join(strs,"/")
  outfl = str_sub_str(outfl,"//","/")
  outfl = str_sub_str(outfl,"en00","enmn")
  system("if ! test -f " + outfl +" ; then ncea " + fsr + "   " +outfl + " ; fi")
  ;write to the namelist 
  enstr    = "enmn"
  outnm    = model_name+"-"+str_upper(group_nam) + "  #em" 
  flm      = systemfunc("ls " + outfl)
  flag     = set+"-"+model_name+"-"+str_upper(group_nam)
  if(isfilepresent(flm)) then
    lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
    write_table(outfile,"a",[/lines/],"%s")
    delete(lines)
  end if 
  delete([/fls,fsr,strs,outfl,enstr,outnm,flm,flag/])
 ;process each ensemble member and write to namelist
 ;exclude models that do not have required variables  
  exclmod  = (/"CMIPMME","NIMS-KMA_KACE-1-0-G","NOAA-GFDL_GFDL-ESM4","THU_CIESM", \ 
               "AS-RCEC_TaiESM1","CAMS_CAMS-CSM1-0","NCC_NorESM2-LM"/)
  tmp_name = systemfunc("cd " +data_dir + "/"+ model_name +"/"+group_nam+"; ls -d " + "*")
  indx     = get1Dindex_Exclude(tmp_name,exclmod)
  ens_name = tmp_name(indx)
  delete([/indx,tmp_name/])
  nens     = dimsizes(ens_name)
  ntens    = 0
  do j = 0,nens-1,1
    enstr    = "en"+ sprinti("%02d",0)
    outnm    = ens_name(j) ;model_name+"-"+str_upper(group_nam) + "  #" +sprinti("%02d",j) 
    flm      = systemfunc("ls " + data_dir + "/" + model_name+"/"+group_nam+"/"+ens_name(j)+"/" + ens_name(j)+"." + group_nam+"." + enstr+"."+varnm+".*.nc")
    flag     = set+"-"+model_name+"-"+str_upper(group_nam)
    if(isfilepresent(flm)) then
      lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
      write_table(outfile,"a",[/lines/],"%s")
      delete(lines)
      ntens = ntens + 1
    else
      enstr    =  "en"+ sprinti("%02d",1)
      flm      = systemfunc("ls " + data_dir + "/" + model_name+"/"+group_nam+"/"+ens_name(j)+"/" + ens_name(j)+"." + group_nam+"." + enstr+"."+varnm+".*.nc")
      if(isfilepresent(flm)) then
        lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
        write_table(outfile,"a",[/lines/],"%s")
        delete(lines)
        ntens = ntens + 1
      end if 
    end if
  end do
  if( ntens.ne. nens ) then 
    print("number of ensmeble for different variables is not consistent ... ")
    exit
  end if 
  delete([/nens,ens_name,model_name,ntens/])

  ;;E3SM model (set 2);;;;
  set        = 2
  model_name = "v1.LR"
  ens_name   = "v1.LR" + "." + group_nam 
  nens       = 4
 ;generate ensemble mean
  fsr   = data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+".*."+varnm+".*.nc" 
  fls   = systemfunc("ls " + fsr)
  outfl = str_sub_str(fls(0),"en00","enmn")
  system("if ! test -f " + outfl +" ; then ncea " + fsr + "   " +outfl + " ; fi")
 ;write to the namelist
  enstr    = "enmn"
  outnm    = model_name+"-"+str_upper(group_nam) + "  #em"
  flm      = systemfunc("ls " + outfl)
  flag     = set+"-"+model_name+"-"+str_upper(group_nam)
  if(isfilepresent(flm)) then
    lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
    write_table(outfile,"a",[/lines/],"%s")
    delete([/lines/])
  end if
  delete([/fls,fsr,outfl,enstr,outnm,flm,flag/])
 ;process each ensemble member and write to namelist
  do j = 0,nens-1,1
    enstr    =  "en"+ sprinti("%02d",j)
    outnm    = model_name+"-"+str_upper(group_nam) + "  #" +sprinti("%02d",j)
    flm      = systemfunc("ls " + data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+"." + enstr +"."+varnm+".*.nc")
    flag     = set+"-"+model_name+"-"+str_upper(group_nam)
    if(isfilepresent(flm)) then
      lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
      write_table(outfile,"a",[/lines/],"%s")
      delete(lines)
    end if
  end do
  delete([/nens,ens_name,model_name/])

  ;;E3SM model (set 3);;;;
  set        = 3
  model_name = "v2.LR"
  ens_name   = "v2.LR" + "." + group_nam
  nens       = 3
 ;generate ensemble mean
  fsr   = data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+".*."+varnm+".*.nc"
  fls   = systemfunc("ls " + fsr)
  outfl = str_sub_str(fls(0),"en00","enmn")
  system("if ! test -f " + outfl +" ; then ncea " + fsr + "   " +outfl + " ; fi")
 ;write to the namelist
  enstr    = "enmn"
  outnm    = model_name+"-"+str_upper(group_nam) + "  #em"
  flm      = systemfunc("ls " + outfl)
  flag     = set+"-"+model_name+"-"+str_upper(group_nam)
  if(isfilepresent(flm)) then
    lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
    write_table(outfile,"a",[/lines/],"%s")
    delete([/lines/])
  end if
  delete([/fls,fsr,outfl,enstr,outnm,flm,flag/])
 ;process each ensemble member and write to namelist
  do j = 0,nens-1,1
    enstr    =  "en"+ sprinti("%02d",j)
    outnm    = model_name+"-"+str_upper(group_nam) + "  #" +sprinti("%02d",j)
    flm      = systemfunc("ls " + data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+"." + enstr +"."+varnm+".*.nc")
    flag     = set+"-"+model_name+"-"+str_upper(group_nam)
    if(isfilepresent(flm)) then
      lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
      write_table(outfile,"a",[/lines/],"%s")
      delete(lines)
    end if
  end do
  delete([/nens,ens_name,model_name/])

  ;;E3SM model (set 3);;;;
  set        = 4
  model_name = "v3.LR"
  test_tag   = "FourthSmoke"
  ens_name   = "v3.LR" + "." + group_nam + "." + test_tag
  nens       = 1
  if ( nens.gt.1 ) then 
   ;generate ensemble mean
    fsr   = data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+".*."+varnm+".*.nc"
    fls   = systemfunc("ls " + fsr)
    outfl = str_sub_str(fls(0),"en00","enmn")
    system("if ! test -f " + outfl +" ; then ncea " + fsr + "   " +outfl + " ; fi")
   ;write to the namelist
    enstr    = "enmn"
    outnm    = model_name+"-"+str_upper(group_nam) + "  #em"
    flm      = systemfunc("ls " + outfl)
    flag     = set+"-"+model_name+"-"+str_upper(group_nam)
    if(isfilepresent(flm)) then
      lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
      write_table(outfile,"a",[/lines/],"%s")
      delete([/lines/])
    end if
    delete([/fls,fsr,outfl,enstr,outnm,flm,flag/])
  end if 
 ;process each ensemble member and write to namelist
  do j = 0,nens-1,1
    enstr    =  "en"+ sprinti("%02d",j)
    outnm    = model_name+"-"+str_upper(group_nam) + "  #" +sprinti("%02d",j)
    flm      = systemfunc("ls " + data_dir + "/" + ens_name+"/" +ens_name+"." + enstr +"."+varnm+".*.nc")
    flag     = set+"-"+model_name+"-"+str_upper(group_nam)
    if(isfilepresent(flm)) then
      lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
      write_table(outfile,"a",[/lines/],"%s")
      delete(lines)
    end if
  end do
  delete([/nens,ens_name,model_name/])

end do ; var loop

