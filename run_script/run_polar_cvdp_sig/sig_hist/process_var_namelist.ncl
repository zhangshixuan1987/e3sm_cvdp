varlist   = (/"SICONC","SICONC","PRECT","PSL","TS","TREFHT","SHFLX","LHFLX",\
              "U10","V10","U850","V850","TAUX","TAUY",\
              "Qn_SRF","OLR","FLDS","FLDSC","FLNS","SWCRE","LWCRE", \
              "ETH12", "T850", "CLDTOT","Z500",\
              "U200","V200","PRECST","SF"/)
vartags   = (/"aice_nh","aice_sh","prect","psl","ts","trefht","shflx","lhflx",\
              "u10","v10","u850","v850","taux","tauy",\
              "qnet","olr","flds","fldsc","flns","swcre","lwcre",\
              "eth","th850","cldtot","z500",\
              "u200","v200","precst","zmsf"/)
nvars     = dimsizes(varlist)
ystr      = 1985
yend      = 2014

data_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD"
nml_dir   = "./namelist_byvar" 
nml_mod   = "./namelist"
nml_obs   = "./namelist_obs"

;clean up old file
do i = 0, nvars-1
  tmpfil = "obs_"+vartags(i)
  system("rm -rvf " + tmpfil)
end do

;generate empty file for non-existing var
system("if ! test -d " + nml_dir +" ; then mkdir " + nml_dir + " ; fi")
vtag0 = (/"snowdp","moc","maxnum"/)
do i = 0, dimsizes(vtag0)-1
  obfile = "obs_"+vtag0(i)
  system("rm -rvf " + obfile +"; touch " + obfile)
  if(vtag0(i).ne."maxnum") then
    nmfile = nml_dir+"/namelist_"+vtag0(i)
    system("rm -rvf " + nmfile +"; touch " + nmfile)
  end if
end do
system("rm -rvf " + nml_mod + "; touch " + nml_mod)
system("rm -rvf " + nml_obs + "; touch " + nml_obs)

;generate namelist file
do i = 0, nvars-1
  varnm = varlist(i)
  vtag  = vartags(i)

  outfile = nml_dir+"/namelist_"+vtag
  system("if ! test -d " + nml_dir +" ; then mkdir " + nml_dir + " ; fi")
  system("rm -rvf " + outfile +"; touch " + outfile)

  if (varnm.eq."SICONC") then 
    ;#SEAICE OBS 
    set        = 0
    model_name = "NOAA_NSIDC_CDR"
    nens       = 1
    outnm      = model_name+"-"+varnm
    vstr       = str_split(vtag,"_")
    flm        = systemfunc("ls " + data_dir + "/" + model_name+"/" + "seaice_conc*_"+vstr(1)+"_*"+model_name+"*.nc")
    flag       = set+"-"+"Observations"
   ;print(flm)
    if(isfilepresent(flm)) then
      lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
      write_table(outfile,"a",[/lines/],"%s")
      write_table(nml_obs,"a",[/lines/],"%s")
      delete([/lines/])
    end if
   ;#SEAICE OBS
    set        = 0
    model_name = "HadSST"
    nens       = 1
    outnm      = model_name+"-"+varnm
    vstr       = str_split(vtag,"_")
    flm        = systemfunc("ls " + data_dir + "/"+model_name+"/"+model_name+".en00."+varnm+".*.nc")
    flag       = set+"-"+"Observations"
   ;print(flm)
    if(isfilepresent(flm)) then
      lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
      write_table(outfile,"a",[/lines/],"%s")
      write_table(nml_obs,"a",[/lines/],"%s")
      delete([/lines/])
    end if
  end if 

  ;#Anl#
  set        = 0
  model_name = "ERA5"
  nens       = 1
 ;process each ensemble member and write to namelist 
  do j = 0, nens-1
    enstr = "en"+ sprinti("%02d",j)
    outnm = model_name+"-"+varnm  ;+ sprinti("%02d",j)
    flm   = systemfunc("ls " + data_dir + "/" + model_name+"/" + model_name+"." + enstr+"."+varnm+".*.nc")
    flag  = set+"-"+"Observations"
   ;print(flm)
    if(isfilepresent(flm)) then 
      lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
      write_table(outfile,"a",[/lines/],"%s")
      write_table(nml_obs,"a",[/lines/],"%s")
      delete([/lines/])
    end if 
  end do

  ;;E3SM model (set 1);;;;
  set        = 1
  group_nam  = "amip"
  model_name = "v3.LR"
  test_tag   = "FourthSmoke"
  ens_name   = "v3.LR" + "." + group_nam + "." + test_tag
  nens       = 1
 ;process each ensemble member and write to namelist
  do j = 0,nens-1,1
    enstr    =  "en"+ sprinti("%02d",j)
    outnm    = model_name+"-"+str_upper(group_nam)  ;+ "  #" +sprinti("%02d",j)
    flm    = systemfunc("ls " + data_dir + "/" + ens_name+"/" +ens_name+"." + enstr +"."+varnm+".*.nc")
    flag     = set+"-"+model_name+"-"+str_upper(group_nam)
    if(isfilepresent(flm)) then
      lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
      write_table(outfile,"a",[/lines/],"%s")
      delete(lines)
    end if
    if(i.eq.0) then
      fl0   = data_dir + "/" + ens_name+"/" +ens_name+"." + enstr
      line0 =  outnm+ " | " + fl0 + " | " + ystr+ " | " + yend + " | " + flag
      write_table(nml_mod,"a",[/line0/],"%s")
      delete([/fl0,line0/])
    end if
  end do
  delete([/nens,ens_name,model_name/])

 ;E3SM model (set 2);;;;
  set        = 2
  group_nam  = "amip"
  model_name = "v2.LR"
  ens_name   = "v2.LR" + "." + group_nam
  nens       = 1
 ;process each ensemble member and write to namelist
  do j = 0,nens-1,1
    enstr    =  "en"+ sprinti("%02d",j)
    outnm    = model_name+"-"+str_upper(group_nam)  ;+ "  #" +sprinti("%02d",j)
    flm      = systemfunc("ls " + data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+"." + enstr +"."+varnm+".*.nc")
    flag     = set+"-"+model_name+"-"+str_upper(group_nam)
    if(isfilepresent(flm)) then
      lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
      write_table(outfile,"a",[/lines/],"%s")
      delete(lines)
    end if
    if(i.eq.0) then
      fl0   = data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+"." + enstr
      line0 =  outnm+ " | " + fl0 + " | " + ystr+ " | " + yend + " | " + flag
      write_table(nml_mod,"a",[/line0/],"%s")
      delete([/fl0,line0/])
    end if
  end do
  delete([/nens,ens_name,model_name/])

  ;;E3SM model (set 3);;;;
  set        = 3
  group_nam  = "amip"
  model_name = "v1.LR"
  ens_name   = "v1.LR" + "." + group_nam
  nens       = 1
 ;process each ensemble member and write to namelist
  do j = 0,nens-1,1
    enstr    =  "en"+ sprinti("%02d",j)
    outnm    = model_name+"-"+str_upper(group_nam)  ;+ "  #" +sprinti("%02d",j)
    flm      = systemfunc("ls " + data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+"." + enstr +"."+varnm+".*.nc")
    flag     = set+"-"+model_name+"-"+str_upper(group_nam)
    if(isfilepresent(flm)) then
      lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
      write_table(outfile,"a",[/lines/],"%s")
      delete(lines)
    end if
    if(i.eq.0) then
      fl0   = data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+"." + enstr
      line0 =  outnm+ " | " + fl0 + " | " + ystr+ " | " + yend + " | " + flag
      write_table(nml_mod,"a",[/line0/],"%s")
      delete([/fl0,line0/])
    end if
  end do
  delete([/nens,ens_name,model_name/])

  ;;E3SM model (set 4);;;;
  set        = 4
  group_nam  = "historical"
  model_name = "v2.LR"
  ens_name   = "v2.LR" + "." + group_nam
  nens       = 1
 ;process each ensemble member and write to namelist
  do j = 0,nens-1,1
    enstr    =  "en"+ sprinti("%02d",j)
    outnm    = model_name+"-"+str_upper(group_nam)  ;+ "  #" +sprinti("%02d",j)
    flm      = systemfunc("ls " + data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+"." + enstr +"."+varnm+".*.nc")
    flag     = set+"-"+model_name+"-"+str_upper(group_nam)
    if(isfilepresent(flm)) then
      lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
      write_table(outfile,"a",[/lines/],"%s")
      delete(lines)
    end if
    if(i.eq.0) then
      fl0   = data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+"." + enstr 
      line0 = outnm+ " | " + fl0 + " | " + ystr+ " | " + yend + " | " + flag
      write_table(nml_mod,"a",[/line0/],"%s")
      delete([/fl0,line0/])
    end if
  end do
  delete([/nens,ens_name,model_name/])

  ;;E3SM model (set 5);;;;
  set        = 5
  group_nam  = "historical"
  model_name = "v1.LR"
  ens_name   = "v1.LR" + "." + group_nam
  nens       = 1
 ;process each ensemble member and write to namelist
  do j = 0,nens-1,1
    enstr    =  "en"+ sprinti("%02d",j)
    outnm    = model_name+"-"+str_upper(group_nam)  ;+ "  #" +sprinti("%02d",j)
    flm      = systemfunc("ls " + data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+"." + enstr +"."+varnm+".*.nc")
    flag     = set+"-"+model_name+"-"+str_upper(group_nam)
    if(isfilepresent(flm)) then
      lines = outnm+ " | " + flm + " | " + ystr+ " | " + yend + " | " + flag
      write_table(outfile,"a",[/lines/],"%s")
      delete(lines)
    end if
    if(i.eq.0) then
      fl0   = data_dir + "/" + ens_name+"/" + model_name+"." + group_nam+"." + enstr 
      line0 = outnm+ " | " + fl0 + " | " + ystr+ " | " + yend + " | " + flag
      write_table(nml_mod,"a",[/line0/],"%s")
      delete([/fl0,line0/])
    end if
  end do
  delete([/nens,ens_name,model_name/])

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
