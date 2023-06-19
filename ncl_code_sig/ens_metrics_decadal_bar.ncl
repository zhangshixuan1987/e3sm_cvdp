; This script calculates various metrics scores. 
;
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: ens_metrics_decadal_bar.ncl")
  OUTDIR = getenv("OUTDIR")  
  OBS = getenv("OBS")

  SCALE_TIMESERIES = getenv("SCALE_TIMESERIES")
  OUTPUT_DATA      = getenv("OUTPUT_DATA")
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OPT_CLIMO        = getenv("OPT_CLIMO")
  CLIMO_SYEAR      = toint(getenv("CLIMO_SYEAR"))
  CLIMO_EYEAR      = toint(getenv("CLIMO_EYEAR"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE")
  COLORMAP         = getenv("COLORMAP")

  if (OBS.eq."False") then
    print("ens_metrics_decadal_bar.ncl: Observations not present.")
    print("Exiting: ens_metrics_decadal_bar.ncl")    
  end if

  nclver = stringtochar(get_ncl_version())   ; check NCL version to turn off error messages
  num0 = toint(tostring(nclver(0)))    
  num1 = toint(tostring(nclver(2)))
  errmsg = True
  if (num0.le.5) then
     errmsg = False
  end if
  if (num0.eq.6) then
     if (num1.le.4) then
        errmsg = False
     else
        errmsg = True
     end if
  end if  
  if (num0.ge.7) then
     errmsg = True
  end if
  delete([/num0,num1/])

;---------------------
  nsim  = numAsciiRow("namelist_byvar/namelist_ts")
  na    = asciiread("namelist_byvar/namelist_ts",(/nsim/),"string")
  names = new(nsim,"string")
  syear = new(nsim,"integer",-999)
  eyear = new(nsim,"integer",-999)
  names_EM = new(nsim,"string")
  EM_num = new(nsim,"integer",-999)
  delim = "|"

  do ee = 0,nsim-1
     names(ee) = str_strip(str_get_field(na(ee),1,delim))
     syear(ee) = stringtointeger(str_strip(str_get_field(na(ee),3,delim)))
     eyear(ee) = stringtointeger(str_strip(str_get_field(na(ee),4,delim)))
     temp      = str_split(str_strip(str_get_field(na(ee),5,delim)),"-")
     EM_num(ee)    = toint(temp(0))
     names_EM(ee)  = str_join(temp(1:),"-")
     delete(temp)
  end do
  modname = str_sub_str(names," ","_")
  bc = (/"/","'","(",")"/)
  do ff = 0,dimsizes(modname)-1
     do ee = 0,dimsizes(bc)-1
        modname(ff) = str_sub_str(modname(ff),bc(ee),"_")
     end do
  end do

  nsim_tas = numAsciiRow("namelist_byvar/namelist_trefht")
  na_tas = asciiread("namelist_byvar/namelist_trefht",(/nsim_tas/),"string")
  names_tas = new(nsim_tas,"string")
  paths_tas = new(nsim_tas,"string")
  syear_tas = new(nsim_tas,"integer",-999)
  eyear_tas = new(nsim_tas,"integer",-999)
  do gg = 0,nsim_tas-1
     names_tas(gg) = str_strip(str_get_field(na_tas(gg),1,delim))
     paths_tas(gg) = str_strip(str_get_field(na_tas(gg),2,delim))
     syear_tas(gg) = stringtointeger(str_strip(str_get_field(na_tas(gg),3,delim)))
     eyear_tas(gg) = stringtointeger(str_strip(str_get_field(na_tas(gg),4,delim)))
  end do
  modname_tas = str_sub_str(names_tas," ","_")
  do ff = 0,dimsizes(modname_tas)-1
     do gg = 0,dimsizes(bc)-1
        modname_tas(ff) = str_sub_str(modname_tas(ff),bc(gg),"_")
     end do
  end do
  delete(na_tas)

  nsim_pr = numAsciiRow("namelist_byvar/namelist_prect")
  na_pr = asciiread("namelist_byvar/namelist_prect",(/nsim_pr/),"string")
  names_pr = new(nsim_pr,"string")
  paths_pr = new(nsim_pr,"string")
  syear_pr = new(nsim_pr,"integer",-999)
  eyear_pr = new(nsim_pr,"integer",-999)

  do gg = 0,nsim_pr-1
     names_pr(gg) = str_strip(str_get_field(na_pr(gg),1,delim))
     paths_pr(gg) = str_strip(str_get_field(na_pr(gg),2,delim))
     syear_pr(gg) = stringtointeger(str_strip(str_get_field(na_pr(gg),3,delim)))
     eyear_pr(gg) = stringtointeger(str_strip(str_get_field(na_pr(gg),4,delim)))
  end do
  modname_pr = str_sub_str(names_pr," ","_")
  do ff = 0,dimsizes(modname_pr)-1
     do gg = 0,dimsizes(bc)-1
        modname_pr(ff) = str_sub_str(modname_pr(ff),bc(gg),"_")
     end do
  end do
  delete(na_pr)

  nsim_psl = numAsciiRow("namelist_byvar/namelist_psl")
  na_psl = asciiread("namelist_byvar/namelist_psl",(/nsim_psl/),"string")
  names_psl = new(nsim_psl,"string")
  paths_psl = new(nsim_psl,"string")
  syear_psl = new(nsim_psl,"integer",-999)
  eyear_psl = new(nsim_psl,"integer",-999)

  do gg = 0,nsim_psl-1
     names_psl(gg) = str_strip(str_get_field(na_psl(gg),1,delim))
     paths_psl(gg) = str_strip(str_get_field(na_psl(gg),2,delim))
     syear_psl(gg) = stringtointeger(str_strip(str_get_field(na_psl(gg),3,delim)))
     eyear_psl(gg) = stringtointeger(str_strip(str_get_field(na_psl(gg),4,delim)))
  end do
  modname_psl = str_sub_str(names_psl," ","_")
  do ff = 0,dimsizes(modname_psl)-1
     do gg = 0,dimsizes(bc)-1
        modname_psl(ff) = str_sub_str(modname_psl(ff),bc(gg),"_")
     end do
  end do
  delete(na_psl)

  csubexp          = (/"OBS"  ,"CMIP6","E3SMv3dev", "E3SMv2.1","E3SMv2.CRYO"/)
  csubexp_color    = (/"Black","Grey25","firebrick2","deepskyblue4","Green4"/)
  csubgroup        = (/"OBS"  ,"HISTORICAL", "piControl","SORRM"/)
  csubgroup_marker = (/7,4,16,3/)
  csubtitle_color  = set_subtitle_colors(max(EM_num))
  csubtitle        = new(max(EM_num),string)

;---------------------------------------------------------------------------------------------------------
  cr = "~C~"
  varlist = (/"amo_pattern_mon",  "amo_pattern_lowpass_mon", \
              "pdo_pattern_mon",  "ipo_pattern_mon"/)
  varlist_obs = varlist
  ncol_labels = (/"AMO",\
                  "AMO Low-Pass",\
                  "PDO", \
                  "IPO", \
                  "Mean Score"/) 
  ncol_units  = (/"~S~o~N~C",\
                 "~S~o~N~C",\
                 "~S~o~N~C",\
                 "~S~o~N~C",\
                  "unintless"/)
  varlist_fn = (/"amo",\
                 "amo",\
                 "pdo",\
                 "ipo"/)
  domain = (/"globalA",\
             "globalA",\
             "global",\
             "global"/)
  variable = (/"sst",\
               "sst",\
               "sst",\
               "sst"/)

  finobs0_rmssf  = new(dimsizes(varlist),double,9.99)   ; calculate spatial RMS for the first OBS dataset for each metric (following Deser et al 2020)
  do cc = 0,dimsizes(varlist)-1   
     if (variable(cc).eq."tas") then
        syearT = syear_tas(0)
        eyearT = eyear_tas(0)
        modnameT = modname_tas(0)
     end if
     if (variable(cc).eq."sst") then
        syearT = syear(0)
        eyearT = eyear(0)
        modnameT = modname(0)
     end if
     if (variable(cc).eq."psl") then
        syearT = syear_psl(0)
        eyearT = eyear_psl(0)
        modnameT = modname_psl(0)
     end if
     if (variable(cc).eq."pr") then
        syearT = syear_pr(0)
        eyearT = eyear_pr(0)
        modnameT = modname_pr(0)
     end if

     fnt = getenv("OUTDIR")+modnameT+".cvdp_data."+varlist_fn(cc)+"."+syearT+"-"+eyearT+".nc"
     fnt2 = getenv("OUTDIR")+modnameT+".cvdp_data."+syearT+"-"+eyearT+".nc"
     obs0 := read_cvdp_le_data(fnt,fnt2,varlist_obs(cc))
     if (isatt(obs0,"is_all_missing")) then
        continue
     end if
     if (domain(cc).ne."hov") then
        clat_obs0 := cos(0.01745329*obs0&lat)
        clat_obs0!0 = "lat"
        clat_obs0&lat = obs0&lat
     end if
     if (domain(cc).eq."global") then
        finobs0_rmssf(cc) = (/ sqrt(wgt_areaave(obs0^2,clat_obs0,1.0,0)) /)
     end if
     if (domain(cc).eq."globalA") then
        finobs0_rmssf(cc) = (/ sqrt(wgt_areaave(obs0({-63:65},:)^2,clat_obs0({-63:65}),1.0,0)) /)
     end if
     if (domain(cc).eq."NHext") then
        finobs0_rmssf(cc) = (/ sqrt(wgt_areaave(obs0({20:},:)^2,clat_obs0({20:}),1.0,0)) /)
     end if
     if (domain(cc).eq."SHext") then
        finobs0_rmssf(cc) = (/ sqrt(wgt_areaave(obs0({:-20},:)^2,clat_obs0({:-20}),1.0,0)) /)
     end if
     if (domain(cc).eq."hov") then
        finobs0_rmssf(cc) = (/ sqrt(wgt_areaave(obs0(:,24:52)^2,1.0,1.0,0)) /)
     end if
  end do

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  nEM           = max(EM_num)
  finEM_names   = new(nEM+1,string)
  finname_mod   = new(nsim-1,string)
  finpc         = new((/nsim-1,dimsizes(varlist)+1/),double,9.99)
  finrms        = finpc
  dimquery      = dimsizes(finpc)
  do dd = 0,dimsizes(varlist)-1  
     if (variable(dd).eq."tas") then
        syearT = syear_tas(0)
        eyearT = eyear_tas(0)
        modnameT = modname_tas(0)
     end if
     if (variable(dd).eq."sst") then
        syearT = syear(0)
        eyearT = eyear(0)
        modnameT = modname(0)
     end if
     if (variable(dd).eq."psl") then
        syearT = syear_psl(0)
        eyearT = eyear_psl(0)
        modnameT = modname_psl(0)
     end if
     if (variable(dd).eq."pr") then
        syearT = syear_pr(0)
        eyearT = eyear_pr(0)
        modnameT = modname_pr(0)
     end if

     fnt = getenv("OUTDIR")+modnameT+".cvdp_data."+varlist_fn(dd)+"."+syearT+"-"+eyearT+".nc"
     fnt2 = getenv("OUTDIR")+modnameT+".cvdp_data."+syearT+"-"+eyearT+".nc"
     obs0 := read_cvdp_le_data(fnt,fnt2,varlist_obs(dd))
     if (isatt(obs0,"is_all_missing")) then
        continue
     end if
     if (domain(dd).eq."hov") then
       obs0!0 = "time_mon1"
       obs0!1 = "lon0"
     end if
     cntr_EM = 0
     cntr = 1
     numobs = num(EM_num.eq.0) 
     if (numobs.ge.2) then     ; plot obs #2-
        if (ismissing(finEM_names(0))) then
           finEM_names(0) = "Observations"
        end if
        do ff = 1,numobs-1
           if (variable(dd).eq."tas") then
              syearT = syear_tas(cntr)
              eyearT = eyear_tas(cntr)
              modnameT = modname_tas(cntr)
           end if
           if (variable(dd).eq."sst") then
              syearT = syear(cntr)
              eyearT = eyear(cntr)
              modnameT = modname(cntr)
           end if
           if (variable(dd).eq."psl") then
              syearT = syear_psl(cntr)
              eyearT = eyear_psl(cntr)
              modnameT = modname_psl(cntr)
           end if
           if (variable(dd).eq."pr") then
              syearT = syear_pr(cntr)
              eyearT = eyear_pr(cntr)
              modnameT = modname_pr(cntr)
           end if

           fnt = getenv("OUTDIR")+modnameT+".cvdp_data."+varlist_fn(dd)+"."+syearT+"-"+eyearT+".nc"
           fnt2 = getenv("OUTDIR")+modnameT+".cvdp_data."+syearT+"-"+eyearT+".nc"
           arr := read_cvdp_le_data(fnt,fnt2,varlist_obs(dd))
           if (isatt(arr,"is_all_missing")) then 
              cntr = cntr+1
              continue
           end if
           if (domain(dd).eq."hov") then
              arr!0 = "time_mon1"
              arr!1 = "lon0"
           end if
           if (domain(dd).eq."hov") then
              obs0_rg := arr
              obs0_rg  = obs0_rg@_FillValue 
              do hh = 0,dimsizes(arr&time_mon1)-1
                 obs0_rg(hh,:) = (/ linint1(obs0&lon0,obs0(hh,:),False,arr&lon0,0) /)
              end do
           else
              clat := cos(0.01745329*arr&lat)
              clat!0 = "lat"
              clat&lat = arr&lat
              obs0_rg := linint2_Wrap(obs0&lon,obs0&lat,obs0,True,arr&lon,arr&lat,0)
           end if

           finname_mod(ff-1) = "Observations"
           if (domain(dd).eq."global") then
              finpc(ff-1,dd)  = (/ pattern_cor(obs0_rg,arr,clat,0)  /)
              finrms(ff-1,dd) = (/ wgt_arearmse(obs0_rg,arr,clat,1.0,0)  /)
           end if
           if (domain(dd).eq."globalA") then
              finpc(ff-1,dd)  = (/ pattern_cor(obs0_rg({-63:65},:),arr({-63:65},:),clat({-63:65}),0)  /)
              finrms(ff-1,dd) = (/ wgt_arearmse(obs0_rg({-63:65},:),arr({-63:65},:),clat({-63:65}),1.0,0)  /)
           end if
           if (domain(dd).eq."NHext") then
              finpc(ff-1,dd)  = (/ pattern_cor(obs0_rg({20:},:),arr({20:},:),clat({20:}),0)  /)
              finrms(ff-1,dd) = (/ wgt_arearmse(obs0_rg({20:},:),arr({20:},:),clat({20:}),1.0,0)  /)
           end if
           if (domain(dd).eq."SHext") then
              finpc(ff-1,dd)  = (/ pattern_cor(obs0_rg({:-20},:),arr({:-20},:),clat({:-20}),0)  /)
              finrms(ff-1,dd) = (/ wgt_arearmse(obs0_rg({:-20},:),arr({:-20},:),clat({:-20}),1.0,0)  /)
           end if
           if (domain(dd).eq."hov") then
              finpc(ff-1,dd)  = (/ pattern_cor(obs0_rg(:,24:52),arr(:,24:52),1.0,0)  /)
              finrms(ff-1,dd) = (/ wgt_arearmse(obs0_rg(:,24:52),arr(:,24:52),1.0,1.0,0)  /)
           end if
           cntr = cntr+1
        end do
     end if

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
     do gg = 1,nEM  ; operate on each ensemble mean
        nens = num(EM_num.eq.gg) ; determines how many model simulations in each ensemble
        cntr_ens := ind(EM_num.eq.gg)   ; cntr_ens(hh) are the indices where each ensemble member of an ensemble reside 
        if (ismissing(finEM_names(gg))) then
           finEM_names(gg) = names_EM(cntr_ens(0))   
        end if
        do hh = 0,nens-1
           modname_mod  = modname(cntr_ens(hh))
           syear_mod    = syear(cntr_ens(hh))
           eyear_mod    = eyear(cntr_ens(hh))
           names_mod    = names(cntr_ens(hh))
           fnt = getenv("OUTDIR")+modname_mod+".cvdp_data."+varlist_fn(dd)+"."+syear_mod+"-"+eyear_mod+".nc"
           fnt2 = getenv("OUTDIR")+modname_mod+".cvdp_data."+syear_mod+"-"+eyear_mod+".nc"
           arr := read_cvdp_le_data(fnt,fnt2,varlist(dd))
           if (isatt(arr,"is_all_missing")) then 
              continue
           end if
           if (domain(dd).eq."hov") then
              arr!0 = "time_mon1"
              arr!1 = "lon0"
           end if
           if (domain(dd).eq."hov") then
              obs0_rg := arr
              obs0_rg  = obs0_rg@_FillValue 
              do ii = 0,dimsizes(arr&time_mon1)-1
                 obs0_rg(ii,:) = (/ linint1(obs0&lon0,obs0(ii,:),False,arr&lon0,0) /)
              end do
           else
              clat := cos(0.01745329*arr&lat)
              clat!0 = "lat"
              clat&lat = arr&lat
              obs0_rg := linint2_Wrap(obs0&lon,obs0&lat,obs0,True,arr&lon,arr&lat,0)
           end if

           finname_mod(cntr_ens(hh)-1) = (/names_EM(cntr_ens(hh))/)
           if (domain(dd).eq."global") then
              finpc(cntr_ens(hh)-1,dd)  = (/ pattern_cor(obs0_rg,arr,clat,0)  /)
              finrms(cntr_ens(hh)-1,dd) = (/ wgt_arearmse(obs0_rg,arr,clat,1.0,0)  /)
           end if
           if (domain(dd).eq."globalA") then
              finpc(cntr_ens(hh)-1,dd)  = (/ pattern_cor(obs0_rg({-63:65},:),arr({-63:65},:),clat({-63:65}),0)  /)
              finrms(cntr_ens(hh)-1,dd) = (/ wgt_arearmse(obs0_rg({-63:65},:),arr({-63:65},:),clat({-63:65}),1.0,0)  /)
           end if
           if (domain(dd).eq."NHext") then
              finpc(cntr_ens(hh)-1,dd)  = (/ pattern_cor(obs0_rg({20:},:),arr({20:},:),clat({20:}),0)  /)
              finrms(cntr_ens(hh)-1,dd) = (/ wgt_arearmse(obs0_rg({20:},:),arr({20:},:),clat({20:}),1.0,0)  /)
           end if
           if (domain(dd).eq."SHext") then
              finpc(cntr_ens(hh)-1,dd)  = (/ pattern_cor(obs0_rg({:-20},:),arr({:-20},:),clat({:-20}),0)  /)
              finrms(cntr_ens(hh)-1,dd) = (/ wgt_arearmse(obs0_rg({:-20},:),arr({:-20},:),clat({:-20}),1.0,0)  /)
           end if
           if (domain(dd).eq."hov") then
              finpc(cntr_ens(hh)-1,dd)  = (/ pattern_cor(obs0_rg(:,24:52),arr(:,24:52),1.0,0)  /)
              finrms(cntr_ens(hh)-1,dd) = (/ wgt_arearmse(obs0_rg(:,24:52),arr(:,24:52),1.0,1.0,0)  /)
           end if
        end do   
     end do   ; gg loop (each EM)
  end do   ; dd loop (each metric)

; --- each pc/rms calculated for each metric, now calculate mean scores for each observation/model
  finrms_norm = finrms ; normalize the individual metric rms scores by the first observational dataset's spatial rms value
  finrms_norm = finrms_norm@_FillValue   
  do dd = 0,dimsizes(varlist)-1  
     finrms_norm(:,dd) = (/ finrms(:,dd)/(finobs0_rmssf(dd)) /)
  end do
  do ss = 0,dimquery(0)-1
     if (.not.any(ismissing(finrms_norm(ss,:dimsizes(varlist)-1)))) then
        finrms(ss,dimsizes(varlist)) = (/ dim_avg(finrms_norm(ss,:)) /)
     end if
  end do
  delete(finrms_norm) 

  finpc = where(finpc.eq.1, 1.001,finpc)
  finpcT := 0.5*(log( (1+finpc) / (1-finpc) ))
  do ss = 0,dimquery(0)-1
     if (.not.any(ismissing(finpcT(ss,:dimsizes(varlist)-1)))) then
        finpc(ss,dimsizes(varlist)) = (/ ((2.71828^(2*avg(finpcT(ss,:))))-1)/ ((2.71828^(2*avg(finpcT(ss,:))))+1) /) 
     end if
  end do
;------------------------------------
  if (any(isnan_ieee(finpc))) then
      replace_ieeenan (finpc, finpc@_FillValue, 0)
  end if

  varlist_plt = new(dimsizes(varlist)+1,typeof(varlist))
  npltvar     = dimsizes(varlist_plt)
  varlist_plt(0:npltvar-2) = varlist
  varlist_plt(npltvar-1)   = "Overall_Decadal"

  do kk = 0,dimsizes(varlist_plt)-1

    submec     = (/"PC","RMSE"/)
    nsmec      = dimsizes(submec)
    subgrp     = (/"CMIP6-HISTORICAL","E3SM-HISTORICAL"/) 
    hstcor_rms = new((/nsmec,dimsizes(subgrp),1000/),float,-9999)
    patcor_rms = new((/nsmec,nEM+1,6/),float)

    do ff = 0,nsmec-1
     do hh = 0,dimsizes(subgrp)-1
       if(subgrp(hh).eq."E3SM-HISTORICAL") then
         cntr_ens := ind(finname_mod.eq."v3-HISTORICAL".or. \
                         finname_mod.eq."v2.1-HISTORICAL".or. \
                         finname_mod.eq."v2-HISTORICAL".or. \
                         finname_mod.eq."v3-piControl".or. \
                         finname_mod.eq."v2.1-piControl".or. \
                         finname_mod.eq."v2.SORRM.CRYO1950".or. \
                         finname_mod.eq."v2-piControl")
       else
         cntr_ens := ind(finname_mod.eq.subgrp(hh))
       end if

       if(submec(ff).eq."PC") then
         hstcor_rms(ff,hh,0:dimsizes(cntr_ens)-1) = tofloat(finpc(cntr_ens,kk))
       else
         hstcor_rms(ff,hh,0:dimsizes(cntr_ens)-1) = tofloat(finrms(cntr_ens,kk))
       end if
     end do
     ; operate on each ensemble mean
     do gg = 0,nEM ; operate on each ensemble mean
      cntr_ens := ind(finname_mod.eq.finEM_names(gg))
      opt = False ;
      opt@PrintStat = False
      if(submec(ff).eq."PC") then 
        xsort = tofloat(finpc(cntr_ens,kk))
      else
        xsort = tofloat(finrms(cntr_ens,kk))
      end if 
      qsort(xsort)
      nx    = dimsizes(xsort)
      patcor_rms(ff,gg,0) = xsort(toint(0.1*nx))
      patcor_rms(ff,gg,1) = xsort(toint(0.25*nx))
      patcor_rms(ff,gg,2) = xsort(toint(0.5*nx))
      patcor_rms(ff,gg,3) = xsort(toint(0.75*nx))
      patcor_rms(ff,gg,4) = xsort(toint(0.9*nx))
      patcor_rms(ff,gg,5) = avg(xsort)
      delete([/xsort,nx/])
     ;patcor_rms(ff,gg,0) = g(2)  ; min
     ;patcor_rms(ff,gg,1) = g(7)  ; 25th percentile
     ;patcor_rms(ff,gg,2) = g(8)  ; median
     ;patcor_rms(ff,gg,3) = g(9)  ; 75th percentile
     ;patcor_rms(ff,gg,4) = g(14) ; max
     ;patcor_rms(ff,gg,5) = g(0)  ; max
     ;delete([/g/])
     end do
    end do 
   ;======================================================================
   ; Create ensemble summary graphics
   if (nEM.le.3) then
     ph = .95
   end if
   if (nEM.ge.4.and.nEM.lt.7) then
     ph = .85
   end if
   if (nEM.ge.7.and.nEM.lt.10) then
     ph = .7
   end if
   if (nEM.ge.10) then
     ph = .55
   end if

   do ii = 0,nsmec-1,1

    wks_type = OUTPUT_TYPE
    if (wks_type.eq."png") then
       wks_type@wkWidth = 3000*PNG_SCALE
       wks_type@wkHeight = 3000*PNG_SCALE
    end if
    dum1 = new(nEM,graphic)
    wks = gsn_open_wks(wks_type,OUTDIR+"skill_decadal_metrics_ens")

   fin_EM    = patcor_rms(ii,:,:)
   fin_EM@_FillValue = -9999
   if(submec(ii).eq."PC") then
      ymin = min(fin_EM) - max(fin_EM)/10.0
      ymax = max(fin_EM) + max(fin_EM)/10.0
      if (ymin.lt.0) then
        ymin = 0.0
      end if
      if (ymax.gt.1) then
        ymax = 1.0
      end if
   else
      ymin = min(fin_EM) - max(fin_EM)/50.0
      ymax = max(fin_EM) + max(fin_EM)/50.0
   end if

   ;---Create a histogram
    res                             = True
    res@gsnMaximize                 = False 
    res@vpHeightF                   = ph
    res@vpWidthF                    = ph*1.3

    if(submec(ii).eq."PC") then 
      res@tiYAxisString  = submec(ii)+" score"
    else 
      res@tiYAxisString  = submec(ii)+" score (" +ncol_units(kk)+")"
    end if 
    res@tiXAxisString    = "Fraction of ensemble" 
    res@tiMainString     = ncol_labels(kk)
 
    res@tmBorderLineColor   = "black"
    res@tmXBMajorLineColor  = "black"
    res@tmXBMinorLineColor  = "black"
    res@tmYLMajorLineColor  = "black"
    res@tmYLMinorLineColor  = "black"

    res@pmTitleDisplayMode  = "Always"                   ; allow titles
    res@tiMainOn            = True

    lthick = 5.0
    res@tmBorderThicknessF  = lthick
    res@tmXBMajorThicknessF = lthick
    res@tmXBMinorThicknessF = lthick
    res@tmYLMajorThicknessF = lthick
    res@tmYLMinorThicknessF = lthick
    res@tmYRMajorThicknessF = lthick
    res@tmYRMinorThicknessF = lthick

    FontHeightF = 0.020
    res@tmXBLabelFontHeightF= FontHeightF*1.2
    res@tmYLLabelFontHeightF= FontHeightF*1.2
    res@tiMainFontHeightF   = FontHeightF*1.2
    res@tiXAxisFontHeightF  = FontHeightF*1.2
    res@tiYAxisFontHeightF  = FontHeightF*1.2

    res@tmXBMajorOutwardLengthF = 0.016        ; set tickmarks
    res@tmXBMinorOutwardLengthF = 0.010
    res@tmXBMajorLengthF = 0.016
    res@tmXBMinorLengthF = 0.009

    res@tmYLMajorOutwardLengthF = 0.016       ; set tickmarks
    res@tmYLMinorOutwardLengthF = 0.010
    res@tmYLMajorLengthF = 0.016
    res@tmYLMinorLengthF = 0.009

    ;create the pdf of the CMIP6 data
    opt = True
    opt@bin_min  = ymin 
    opt@bin_max  = ymax 
    nbin         = 21
    ypdf         = new((/dimsizes(subgrp),nbin/),float)
    xpdf         = new((/dimsizes(subgrp),nbin/),float)
    do mm = 0,dimsizes(subgrp)-1
      pp = hstcor_rms(ii,mm,:)
      indm = ind(.not.ismissing(pp))
      pdf        = pdfx(pp(indm),nbin,opt)
      xpdf(mm,:) = tofloat(pdf@bin_center)
      ypdf(mm,:) = tofloat(pdf)/100.0
      xpdf(mm,:) = xpdf(mm,:) + 0.015*(mm-dimsizes(subgrp)*0.5) 
      delete([/pdf,indm,pp/])
    end do
       
    hres = res
    hres@gsnDraw          = False
    hres@gsnFrame         = False

    hres@trYMinF          = ymin - ymin/10.0
    hres@trYMaxF          = ymax + ymax/10.0
    hres@trXMinF          = 0         ; MÃ­nimo valor do eixo y.
    hres@trXMaxF          = 0.7

    hres@tmXBOn           = True
    hres@tmXBLabelsOn     = True
    hres@tmXBMode         = "Explicit"   ; Eixo y esquerdo (YL) de forma manual.
    hres@tmXBValues       = fspan(0,1.0,6)
    hres@tmXBMinorValues  = fspan(0,1.0,16)
    hres@tmXBLabels       = " " + hres@tmXBValues
    hres@gsnXRefLine      = -1. ; reference line

    hres@gsnXYBarChart               = True              ; Create bar plot
    hres@gsnXYBarChartOutlineOnly    = False
    hres@tmXTOn                      = False
    hres@tmYROn                      = False
    hres@tmYLMinorOn                 = True
    hres@tmYLOn                      = True
    hres@tmXBOn                      = True
    hres@tmXBLabelsOn                = True
    hres@tmXBMinorOn                 = True
    dum = new(dimsizes(subgrp),graphic)

    colors = (/csubexp_color(1), "Cyan2"/)
    labels = (/"CMIP6 (HISTORICAL)", "E3SM (ALL)"/)
    do mm = 0,dimsizes(subgrp)-1
      hres@xyLineThicknesses          = 3.0     ;lthick(mm)
      hres@xyLineColors               = "black" ;colors(mm)
      if(submec(ii).eq."PC") then
        hres@gsnXYBarChartBarWidth  = 0.02
      else
        hres@gsnXYBarChartBarWidth  = 0.03
      end if 
      hres@gsnXYBarChartFillOpacityF  = 1.0
      hres@gsnLeftXRefLineBarColors   = colors(mm)
      hres@gsnLeftXRefLineBarPatterns = 0 
      hres@gsnRightXRefLineBarColors  = colors(mm)
      hres@gsnRightXRefLineBarPatterns= 0
      if(mm.eq.0) then 
        hres@gsnXYBarChart = True              ; Create bar plot
        plot = gsn_csm_xy (wks,ypdf(mm,:),xpdf(mm,:),hres)
      else 
        hres2 = hres
        hres2@gsnXYBarChart      = False              ; Create bar plot
        hres2@xyLineThicknesses  = 8.0     ;lthick(mm)
        hres2@gsnXYFillColors    = colors(mm) 
        hres2@gsnXYFillOpacities = 0.2
        hres2@xyLineColors      := (/"transparent",colors(mm)/)
        yyx = new((/2,dimsizes(ypdf(mm,:))/),typeof(ypdf))
        yyx(0,:) = 0.0 
        yyx(1,:) = ypdf(mm,:)
        dum(mm) = gsn_csm_xy (wks,yyx(0:1,:),xpdf(mm,:),hres2)
        overlay(plot,dum(mm))
        delete([/hres2,yyx/])
      end if 
    end do
    ; Create some labelbars for a legend
    lbres                    = True             ; labelbar only resources
    lbres@vpWidthF           = 0.12             ; labelbar width
    lbres@vpHeightF          = 0.08             ; labelbar height
    lbres@lbBoxMajorExtentF  = 0.12             ; puts space between color boxes
    lbres@lbMonoFillPattern  = True             ; Solid fill pattern
    lbres@lbLabelFontHeightF = FontHeightF*0.65  ; font height. default is small
    lbres@lbLabelJust        = "CenterLeft"     ; left justify labels
    lbres@lbPerimOn          = False
    colors = (/csubexp_color(1), "Cyan2"/)
    labels = (/"CMIP6 (Couple)", "E3SM (Couple)"/)
    xpos   = (/0.15, 0.15/) + 0.25
    ypos   = (/0.57, 0.57/) - 0.2
    do mm=0,dimsizes(subgrp)-1
      lbres@lbFillColors = colors(mm)
      gsn_labelbar_ndc(wks,1,labels(mm),xpos(mm),ypos(mm)+mm*0.03,lbres)
    end do	

   ;Creat box plot 
   boxColors = new(dimsizes(fin_EM(:,0)),string)
   boxMarker = new(dimsizes(fin_EM(:,0)),integer)
   lopacs    = new(dimsizes(fin_EM(:,0)),float)
   lopacs    = 1.0

   do jj = 0,nEM,1
     if(finEM_names(jj).eq."Observations") then
       boxColors(jj) = csubexp_color(0)
     else if (isStrSubset(finEM_names(jj),"CMIP6")) then
       boxColors(jj) = csubexp_color(1)
     else if (isStrSubset(finEM_names(jj),"v3-")) then
       boxColors(jj) = csubexp_color(2)
     else if (isStrSubset(finEM_names(jj),"v2.1-")) then
       boxColors(jj) = csubexp_color(3)
     else if (isStrSubset(finEM_names(jj),"SORRM.CRYO")) then
       boxColors(jj) = csubexp_color(4)
     else
       boxColors(jj) = csubtitle_color(jj)
       csubtitle(jj) = finEM_names(jj)
     end if
     end if
     end if
     end if
     end if

     if(finEM_names(jj).eq."Observations") then
       boxMarker(jj) = csubgroup_marker(0)
     else if (isStrSubset(finEM_names(jj),csubgroup(1))) then
       boxMarker(jj) = csubgroup_marker(1)
     else if (isStrSubset(finEM_names(jj),csubgroup(2))) then
       boxMarker(jj) = csubgroup_marker(2)
     else if (isStrSubset(finEM_names(jj),csubgroup(3))) then
       boxMarker(jj) = csubgroup_marker(3)
     else
       boxMarker(jj) = csubgroup_marker(4)
     end if
     end if
     end if
     end if
    end do 

    llres                   = True     ; PersonalizaÃ§Ã£o das linhas do boxplot.
   ;llres@gsLineOpacityF    = lopacs
    llres@gsLineThicknessF  = 10.0

    opti           = True ; Habilita personalizaÃ§Ã£o da caixa.
    opti@boxWidth  = 0.02 ; Largura da caixa. Quanto maior o valor, mais larga serÃ¡ a caixa.
    opti@boxColors = boxColors
  
    res1 = res
    res1@tiXAxisString     = ""
    res1@tiYAxisString     = ""
    res1@trYMinF           = hres@trYMinF
    res1@trYMaxF           = hres@trYMaxF 
    res1@trXMinF           = hres@trXMinF         ; MÃ­nimo valor do eixo y.
    res1@trXMaxF           = hres@trXMaxF
    res1@tmXBOn            = False
   ;res1@tmXBMode          = "Explicit"   ; Eixo y esquerdo (YL) de forma manual.
   ;res1@tmXBValues        = fspan(0,1.0,11)
   ;res1@tmXBMinorValues   = fspan(0,1.0,21)
   ;res1@tmXBLabels        = " " + res@tmXBValues
    res1@tmYRBorderOn      = True         ; Habilita a borda do eixo y direito (YR).
    res1@tmXTBorderOn      = True         ; Habilita a borda do eixo x superior (XB).
    res1@tmXBLabelsOn      = False
    res1@tmYLLabelsOn      = True
    res1@tmYLMinorOn       = False
    res1@tmYLOn            = False
    res1@tmXTOn            = False
    res1@tmYROn            = False
    res1@tmXBOn            = False
    res1@tmXBLabelsOn      = False
    res1@tmXBMinorOn       = False

    dima = dimsizes(fin_EM(0,:))
    xx   = fspan(hres@trXMaxF-0.25,hres@trXMaxF-0.05,dimsizes(fin_EM(:,0)))
    yy   = fin_EM(:,0:dima-2) 
    pdum = boxplot(wks,xx,yy,opti,res1,llres)

    ;***********************************************
    ; add some polymarkers
    ;***********************************************
    mres               = True                     ; marker mods desired
    mres@gsMarkerSizeF = 10.                       ; polymarker size
    mres@gsMarkerThicknessF = 6.                       ; polymarker size
    if(.not.isvar("dum2")) then 
      dum2=new(dimsizes(fin_EM(:,0)),graphic)
    end if 
    do ff = 0,dimsizes(fin_EM(:,0))-1,1
      mres@gsMarkerIndex = boxMarker(ff)       ; polymarker style
      mres@gsMarkerColor = boxColors(ff)       ; polymarker color
      dum2(ff) = gsn_add_polymarker(wks,pdum,xx(ff),fin_EM(ff,dima-1),mres)
    end do
    delete([/xx,yy/])
    overlay(plot,pdum)

    gsres               = True
    txres               = True
    txres@txJust        = "bottomleft"
    txres@txFontHeightF = FontHeightF*0.65
    do i = 0, dimsizes(csubexp)-1
     xtxt = 0.15 + 0.25
     ytxt = 0.58 + i * 0.025
     txres@txFontColor = csubexp_color(i)
     gsn_text_ndc (wks,csubexp(i),xtxt,ytxt,txres)
    end do

    do i = 0, dimsizes(csubgroup)-1
     xleg = 0.15 + 0.25
     xtxt = 0.17 + 0.25
     yleg = 0.72 + i * 0.025
     ytxt = 0.72 + i * 0.025
     gsres@gsMarkerIndex      = csubgroup_marker(i)
     gsres@gsMarkerColor      = "Black" ;colors(i)
     gsres@gsMarkerThicknessF = 6.0  ;*(i+1)
     gsres@gsMarkerSizeF      = 10.
     gsn_polymarker_ndc(wks,          xleg,yleg,gsres)
     txres@txJust      = "centerleft"
     txres@txFontColor = "Black"
     gsn_text_ndc      (wks,csubgroup(i),xtxt,ytxt,txres)
    end do

    panres = True
    panres@gsnPanelYWhiteSpacePercent = 4.0
    gsn_panel(wks,plot,(/1,1/),panres)
    delete(wks)
    ofile = submec(ii) + "_ensemble_metrics_" +varlist_plt(kk)
    system("convert -density 2400 -trim +repage -border 40 -bordercolor white "+OUTDIR+"skill_decadal_metrics_ens."+wks_type+" "+OUTDIR+ofile+"_ensemble.png")
    system("rm "+OUTDIR+"skill_decadal_metrics_ens.png")
    delete([/fin_EM,plot/])
    delete(res1)
    delete([/llres,opti/])
   end do ; metrics
  end do ; variables
  print("Finished: ens_metrics_decadal_bar.ncl")
end
