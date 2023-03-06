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
  system("if ! test -d " + nml_dir +" ; then mkdir " + nml_dir + " ; fi")
  system("rm -rvf " + outfile +"; touch " + outfile)

  ;#OBS#
  set        = 0
  model_name = "ERA5"
  nens       = 11
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

 ;#Model#
  set        = 1
  model_name = "CMIP6_MME"
 ;process each ensemble member and write to namelist
 ;exclude models that do not have required variables  
  exclmod  = (/"CMIPMME","NIMS-KMA_KACE-1-0-G","INM_INM-CM5-0",\
               "AWI_AWI-CM-1-1-MR", "INM_INM-CM4-8","CAS_FGOALS-g3", \
               "CSIRO_ACCESS-ESM1-5","CSIRO-ARCCSS_ACCESS-CM2", \
               "CAS_FGOALS-f3-L"/)
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
    print("Warnning: variable "+varnm+" has less ensmeble members ... ")
  end if 
  delete([/nens,ens_name,model_name,ntens/])

  ;;CESM model (set 2);;;;
  set        = 2
  ens_name   = "CESM_ENS"
  model_name = "NCAR_CESM2"
  nens       = 10
 ;process each ensemble member and write to namelist
  do j = 0,nens-1,1
    enstr    = "en"+ sprinti("%02d",j)
    outnm    = model_name+"-"+str_upper(group_nam) + "  #" + sprinti("%02d",j)
    flm      = systemfunc("ls " + data_dir + "/" + ens_name+"/"+group_nam+"/"+model_name+"/" + model_name+"." + group_nam+"." + enstr+"."+varnm+".*.nc")
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
  model_name = "v1.LR"
  ens_name   = "v1.LR" + "." + group_nam 
  nens       = 4
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

  ;;E3SM model (set 4);;;;
  set        = 4
  model_name = "v2.LR"
  ens_name   = "v2.LR" + "." + group_nam
  nens       = 3
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

  ;;E3SM model (set 5);;;;
  set        = 5
  model_name = "v3.LR"
  test_tag   = "FourthSmoke"
  ens_name   = "v3.LR" + "." + group_nam + "." + test_tag
  nens       = 1
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
