; This script calculates various metrics scores. 
;
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: ens_metrics_pattern.ncl")
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
    print("ens_metrics_pattern.ncl: Observations not present.")
    print("Exiting: ens_metrics_pattern.ncl")    
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

  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1200*PNG_SCALE
     wks_type@wkHeight = 1200*PNG_SCALE
  end if

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

;---------------------------------------------------------------------------------------------------------
  cr = "~C~"
  varlist = (/"nino34_hov_elnino",\
              "nino34_hov_lanina"/)
  varlist_obs = varlist
  ncol_labels = (/"El Nin~H-13V2F35~D~FV-2H3F21~o Hovmo~H-14V2F35~H~FV-2H3~ller",\
                  "La Nin~H-13V2F35~D~FV-2H3F21~a Hovmo~H-14V2F35~H~FV-2H3~ller"/)
  ncol_units = (/"~S~o~N~C",\
                 "~S~o~N~C"/)
  varlist_fn = (/"sst.indices",\
                 "sst.indices"/)
  domain   = (/"hov",\
               "hov"/)
  variable = (/"sst",\
               "sst"/)
  varfacts = (/1.0,\
               1.0/)

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
     finobs0_rmssf(cc) = (/ sqrt(wgt_areaave(obs0(:,24:52)^2,1.0,1.0,0)) /)
  end do

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  nEM           = max(EM_num)
  finEM_names   = new(nEM+2,string)
  metrics       = (/"Mean Bias","Std Bias ","Bias EOF1","Bias EOF2"/)
  cmip_plot     = new(9,graphic)
  esm_plot      = new(9,graphic)
  dum           = new(9,graphic)

 ;eof option
  option        = True
  option@jopt   = 0  ; use covariance matrix
  option@pcrit  = 80

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
     obs0!0  = "time_mon1"
     obs0!1  = "lon0"
     time_mon1 = ispan(0,dimsizes(obs0&time_mon1)-1,1)
     time_mon1@units = "months since 0000-01-01 00:00:00"
     time_mon1@long_name = "Time"
     time_mon1@standard_name = "time"
     time_mon1@calendar = "standard"
     time_mon1!0 = "time_mon1"
     time_mon1&time_mon1 = time_mon1
     lon0 = obs0&lon0
     lon0@standard_name = "longitude"
     obs0&lon0 = lon0
     obs0&time_mon1 = time_mon1
     delete([/time_mon1,lon0/])

     cntr_EM = 0
     cntr    = 1     
     numobs = num(EM_num.eq.0) 
     if (numobs.ge.2) then     ; plot obs #2-
        if (.not.isvar("finname_obs")) then
           finname_obs := new((/numobs-1/),string)
        end if
        if (ismissing(finEM_names(cntr_EM))) then
           finEM_names(cntr_EM) = (/names_EM(cntr) /)
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

           finname_obs(ff-1) = (/ modnameT /)

           fnt = getenv("OUTDIR")+modnameT+".cvdp_data."+varlist_fn(dd)+"."+syearT+"-"+eyearT+".nc"
           fnt2 = getenv("OUTDIR")+modnameT+".cvdp_data."+syearT+"-"+eyearT+".nc"
           arr := read_cvdp_le_data(fnt,fnt2,varlist_obs(dd))
           if (isatt(arr,"is_all_missing")) then 
              cntr = cntr+1
              continue
           end if
           arr!0  = "time_mon1"
           arr!1  = "lon0"
           arr_rg = obs0
           arr_rg = arr_rg@_FillValue 
           do hh = 0,dimsizes(arr&time_mon1)-1
              arr_rg(hh,:) = (/ linint1(arr&lon0,arr(hh,:),False,obs0&lon0,0) /)
           end do
           arr_dff = arr_rg
           arr_dff = arr_dff - obs0
           if(.not.isvar("arr_obs")) then
             dima = dimsizes(arr_dff)
             arr_obs = new((/numobs-1,dima(0),dima(1)/),typeof(obs0))
             delete(dima)
           end if  
           arr_obs!0 = "ens"
           arr_obs!1 = "time_mon1"
           arr_obs!2 = "lon0"
           arr_obs&time_mon1=arr&time_mon1
           arr_obs&lon0=arr_dff&lon0
           arr_obs(ff-1,:,:) = (/arr_dff(:,:)/)
           delete([/arr_dff,arr_rg,arr/])
           cntr = cntr+1
        end do
        evecv = eofunc(arr_obs(time_mon1|:,lon0|:,ens|:),2,option)
        pcts  = eofunc_ts(arr_obs(time_mon1|:,lon0|:,ens|:),evecv,False)
        pcnom   = dim_standardize_n_Wrap(pcts,0,1)
        if(.not.isvar("finspec_EM")) then
          dima = dimsizes(arr_obs(0,:,:))
          finspec_EM = new((/nEM+2,4,dima(0),dima(1)/),typeof(obs0))
          finspec_EM!0 = "ens"
          finspec_EM!1 = "var"
          finspec_EM!2 = "time_mon1"
          finspec_EM!3 = "lon0"
          finspec_EM&time_mon1=obs0&time_mon1
          finspec_EM&lon0=arr_obs&lon0
          finspec_EM@eof1_pcvar     = new((/nEM+2/),string)
          finspec_EM@eof2_pcvar     = new((/nEM+2/),string)
          finspec_EM@eof1_pctsm     = new((/nEM+2/),string)
          finspec_EM@eof2_pctsm     = new((/nEM+2/),string)
          delete(dima)
        end if
        finspec_EM(cntr_EM,0,:,:) = (/dim_avg_n(arr_obs,0)/)
        finspec_EM(cntr_EM,1,:,:) = (/dim_stddev_n(arr_obs,0)/) 
        finspec_EM(cntr_EM,2,:,:) = (/regCoef_n(pcnom(0,:),arr_obs,0,0)/)
        finspec_EM(cntr_EM,3,:,:) = (/regCoef_n(pcnom(1,:),arr_obs,0,0)/)
        finspec_EM@eof1_pcvar(cntr_EM) = sprintf("%.1f%",evecv@pcvar(0))
        finspec_EM@eof2_pcvar(cntr_EM) = sprintf("%.1f%",evecv@pcvar(1))
        do mm = 0,1
          x = pcnom(mm,:) 
          qsort(x)
          ntt = dimsizes(x)
          ssr = ""
          do nn = 0,2
            nn1 = toint(nn*ntt/3.0)
            nn2 = toint((nn+1)*ntt/3.0)-1 
            ssr = ssr + sprintf("%.2f",avg(x(nn1:nn2))) + ";"
          end do
          if(mm.eq.0) then 
            finspec_EM@eof1_pctsm(cntr_EM) = ssr 
          else
            finspec_EM@eof2_pctsm(cntr_EM) = ssr
          end if 
          delete([/x,ntt,ssr,nn1,nn2/])
        end do
        delete([/evecv,pcts,pcnom,arr_obs/])
     end if

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
     ;process model bias pattern and summary plot ;;; 
     do gg = 1,nEM+1   ; operate on each ensemble mean
      if(gg.le.nEM-1) then 
        nens = num(EM_num.eq.gg) ; determines how many model simulations in each ensemble
        cntr_ens := ind(EM_num.eq.gg)   ; cntr_ens(hh) are the indices where each ensemble member of an ensemble reside
        if (ismissing(finEM_names(gg))) then
           finEM_names(gg) = names_EM(cntr_ens(0))
        end if
      else if (gg.eq.nEM) then
        cntr_ens := ind(names_EM.eq."v3-HISTORICAL".or. \
                        names_EM.eq."v2.1-HISTORICAL".or. \
                        names_EM.eq."v2-HISTORICAL")
        nens = dimsizes(cntr_ens)
        finEM_names(gg) = "E3SM-HISTORICAL"
      else
        cntr_ens := ind(names_EM.eq."v3-AMIP".or. \
                        names_EM.eq."v2.1-AMIP".or. \
                        names_EM.eq."v2-AMIP")
        nens = dimsizes(cntr_ens)
        finEM_names(gg) = "E3SM-AMIP"
      end if 
      end if 
      do hh = 0,nens-1
        modname_mod = modname(cntr_ens(hh))
        syear_mod = syear(cntr_ens(hh))
        eyear_mod = eyear(cntr_ens(hh))
        names_mod = names(cntr_ens(hh))
        names_EM_mod = names_EM(cntr_ens(hh))

        fnt = getenv("OUTDIR")+modname_mod+".cvdp_data."+varlist_fn(dd)+"."+syear_mod+"-"+eyear_mod+".nc"
        fnt2 = getenv("OUTDIR")+modname_mod+".cvdp_data."+syear_mod+"-"+eyear_mod+".nc"
        arr := read_cvdp_le_data(fnt,fnt2,varlist(dd))

        if (isatt(arr,"is_all_missing")) then
           continue
        end if
        arr!0 = "time_mon1"
        arr!1 = "lon0"
        arr_rg := arr
        arr_rg  = arr_rg@_FillValue
        do ii = 0,dimsizes(arr&time_mon1)-1
           arr_rg(ii,:) = (/ linint1(arr&lon0,arr(ii,:),False,obs0&lon0,0) /)
        end do
        arr_dff  = arr_rg
        arr_dff  = arr_dff - obs0
        if(.not.isvar("arr_mod")) then
          dima = dimsizes(arr_dff)
          arr_mod = new((/nens,dima(0),dima(1)/),typeof(obs0))
          arr_mod!0 = "ens"
          arr_mod!1 = "time_mon1"
          arr_mod!2 = "lon0"
          arr_mod&time_mon1=arr&time_mon1
          arr_mod&lon0=arr_dff&lon0
          delete(dima)
        end if
        arr_mod(hh,:,:) = (/arr_dff(:,:)/)
        delete([/arr_dff,arr_rg,arr/])
       end do 
       ;average bias pattern and standard deviation
       cntr_EM = cntr_EM + 1
       finspec_EM(cntr_EM,0,:,:) = (/dim_avg_n(arr_mod,0)/)
       finspec_EM(cntr_EM,1,:,:) = (/dim_stddev_n(arr_mod,0)/)
       ;do eof on the ensemble members 
       if(nens.ge.5) then 
         evecv = eofunc(arr_mod(time_mon1|:,lon0|:,ens|:),2,option)
         pcts  = eofunc_ts(arr_mod(time_mon1|:,lon0|:,ens|:),evecv,False)
         pcnom = dim_standardize_n_Wrap(pcts,0,1)
         finspec_EM(cntr_EM,2,:,:) = (/regCoef_n(pcnom(0,:),arr_mod,0,0)/)
         finspec_EM(cntr_EM,3,:,:) = (/regCoef_n(pcnom(1,:),arr_mod,0,0)/)
         finspec_EM@eof1_pcvar(cntr_EM) = sprintf("%.1f%",evecv@pcvar(0))
         finspec_EM@eof2_pcvar(cntr_EM) = sprintf("%.1f%",evecv@pcvar(1))
         do mm = 0,1
           x = pcnom(mm,:)
           qsort(x)
           ntt = dimsizes(x)
           ssr = ""
           do nn = 0,2
             nn1 = toint(nn*ntt/3.0)
             nn2 = toint((nn+1)*ntt/3.0)-1
             ssr = ssr + sprintf("%.2f",avg(x(nn1:nn2))) + ";"
           end do
           if(mm.eq.0) then
             finspec_EM@eof1_pctsm(cntr_EM) = ssr
           else
             finspec_EM@eof2_pctsm(cntr_EM) = ssr
           end if
           delete([/x,ntt,ssr,nn1,nn2/])
         end do
         delete([/evecv,pcts,pcnom/])
       end if 
       delete([/arr_mod/])
     end do 

    ;;;;plot the CMIP6 data 
     wks_cmip  = gsn_open_wks(wks_type,getenv("OUTDIR")+"cmip.hov.pattern_bias" )
     wks_esm   = gsn_open_wks(wks_type,getenv("OUTDIR")+"esm.hov.pattern_bias" )
     if (COLORMAP.eq.0) then
       gsn_merge_colormaps(wks_cmip,"BlueDarkRed18",(/"gray30","gray50","gray70"/))
       gsn_merge_colormaps(wks_esm,"BlueDarkRed18",(/"gray30","gray50","gray70"/))
     end if
     if (COLORMAP.eq.1) then
       gsn_merge_colormaps(wks_cmip,"BlueDarkRed18",(/"gray30","gray50","gray70"/))
       gsn_merge_colormaps(wks_esm,"BlueDarkRed18",(/"gray30","gray50","gray70"/))
     end if

     FontHeightF = 0.017

     res = True
     res@vpHeightF = 0.4
     res@vpWidthF  = 0.6
     res@gsnFrame  = False
     res@gsnDraw   = False

     res@tmXTOn = False 
     res@tmYROn = False
     res@tmXTLabelsOn = False
     res@tmXUseBottom = False

     res@tmYLMode   = "Explicit"
     res@trYMinF    = 0
     res@trYMaxF    = 28
     res@tmYLValues = ispan(0,28,4)
     res@tmYLLabels = (/"Jan~S~0~N~","May~S~0~N~","Sep~S~0~N~","Jan~S~+1~N~", \
                        "May~S~+1~N~","Sep~S~+1~N~","Jan~S~+2~N~","May~S~+2~N~"/)
     res@tmYLMinorValues = ispan(2,30,2)
     res@tmYLLabelJust   = "CenterCenter"
     res@tmYLLabelDeltaF = 1.3    ;0.05
     res@cnFillOn        = True
     res@gsnSpreadColors = True
     res@gsnSpreadColorEnd = 19

     res@lbLabelBarOn = False

     res@tiMainOn = False
     res@cnInfoLabelOn = False
     res@cnLinesOn = True
     res@cnLevelSelectionMode = "ExplicitLevels"
     res@cnLevels = fspan(-1,1,21) 
     res@cnLevels = res@cnLevels* varfacts(dd) 

     carr = new(dimsizes(res@cnLevels),"string")
     carr = "transparent"
     carr(8) = "gray50"
     res@cnMonoLineColor = False
     res@cnLineColors = carr
     res@cnLineLabelsOn = False
     res@tmYLLabelFontHeightF = FontHeightF * 0.85
     res@tmXBLabelFontHeightF = FontHeightF * 0.85
     res@gsnMajorLonSpacing = 30.
     res@gsnMinorLonSpacing = 10.
     res@tiYAxisOn = False

     if (wks_type.eq."png") then
        res@cnLineThicknessF = 2.
     else
        res@cnLineThicknessF = 1.
     end if
     res@gsnCenterStringOrthogonalPosF = 0.015
     res@gsnLeftStringOrthogonalPosF   = res@gsnCenterStringOrthogonalPosF
     res@gsnRightStringOrthogonalPosF  = res@gsnCenterStringOrthogonalPosF
     res@gsnCenterStringFontHeightF    = FontHeightF * 0.9
     res@gsnLeftStringFontHeightF      = FontHeightF * 0.9
     res@gsnRightStringFontHeightF     = FontHeightF * 0.9

     res@gsnLeftString = ""
     res@gsnCenterString= ""
     res@gsnRightString = ""

     panres = True
     panres@gsnMaximize = True
     panres@gsnPaperOrientation = "portrait"
     panres@gsnPanelLabelBar = True
     panres@gsnPanelYWhiteSpacePercent = 3.0
     panres@pmLabelBarHeightF = 0.04
     panres@pmLabelBarWidthF = 0.55
     panres@pmLabelBarOrthogonalPosF = -0.02
     panres@lbTitleOn = True
     panres@lbBoxLineColor = "gray70"
     if (nEM.le.4) then
        if (nEM.eq.1) then
           panres@txFontHeightF = FontHeightF*0.8
           panres@gsnPanelBottom = 0.50
           panres@lbLabelFontHeightF = FontHeightF*0.8
           panres@lbTitleFontHeightF = FontHeightF*0.8
        else
           panres@txFontHeightF = FontHeightF*0.6
           panres@gsnPanelBottom = 0.50
           panres@lbLabelFontHeightF = FontHeightF*0.6
           panres@lbTitleFontHeightF = FontHeightF*0.6
        end if
    else
        panres@txFontHeightF      = FontHeightF*0.4
        panres@gsnPanelBottom     = 0.05
        panres@lbLabelFontHeightF = FontHeightF*0.4
        panres@lbTitleFontHeightF = FontHeightF*0.4
    end if
    panres@gsnPanelYWhiteSpacePercent = 4
    panres@gsnPanelXWhiteSpacePercent = 4

    res@gsnLeftString   = "Obs(scaled by 0.5)" 
    res@gsnCenterString = ""
    res@gsnRightString  = "ERA5/HadSST/NOAA2C"
    obs0 = obs0 * 0.5
    cmip_plot(0)        = gsn_csm_hov(wks_cmip,obs0,res)

    res0 = res
    submod  = (/"CMIP6","E3SM"/)
    subgrp  = (/"HISTORICAL"/)
    do ii = 0, dimsizes(submod)-1,1
      do jj = 0,dimsizes(subgrp)-1
        tmpstr = submod(ii)+"-"+subgrp(jj)
        imod = ind(finEM_names.eq.tmpstr)
        kk = ii*dimsizes(subgrp) + jj +1
        if(.not.ismissing(imod)) then
          patcor = (pattern_cor(finspec_EM(imod,0,:,:),obs0,1.0,0))
          lxstr  = "PC w/Obs: " +sprintf("%.2f",patcor)
          res0@gsnCenterString = lxstr
          res0@gsnRightString  = finEM_names(imod)
          res0@gsnLeftString   = metrics(0)
          cmip_plot(kk)        = gsn_csm_hov(wks_cmip,finspec_EM(imod,0,:,:),res0)
        end if 
      end do 
    end do 

    res1 = res
    submod  = (/"CMIP6","E3SM"/)
    subgrp  = (/"HISTORICAL"/)
    submec  = metrics(1:)
    do ii = 0,dimsizes(submod)-1
      do jj = 0, dimsizes(subgrp)-1,1
        do hh = 0,dimsizes(submec)-1
          tmpstr = submod(ii)+"-"+subgrp(jj)
          imod = ind(finEM_names.eq.tmpstr)
          kk = ii*dimsizes(submec)+jj*dimsizes(submec) + hh + 3
          if(.not.ismissing(imod)) then
            res1@gsnRightString  = finEM_names(imod)
            if(hh.eq.0) then 
              res1@gsnLeftString   = submec(hh)
              res1@gsnCenterString = ""
              cmip_plot(kk) = gsn_csm_hov(wks_cmip,finspec_EM(imod,1,:,:),res1)
            end if  
            if(hh.eq.1) then
              patcor0 = (pattern_cor(finspec_EM(imod,2,:,:),obs0,1.0,0))
              patcor1 = (pattern_cor(finspec_EM(imod,2,:,:),finspec_EM(imod,0,:,:),1.0,0))
              lxstr  = "PC w/Obs: "  +sprintf("%.2f",patcor0) + "~C~" + \
                       "PC w/Bias: " +sprintf("%.2f",patcor1)
              res1@gsnCenterString  = lxstr
              res1@gsnLeftString  = submec(hh)+"("+finspec_EM@eof1_pcvar(imod)+")" 
              cmip_plot(kk) = gsn_csm_hov(wks_cmip,finspec_EM(imod,2,:,:),res1)
            end if 
            if(hh.eq.2) then
              patcor0 = (pattern_cor(finspec_EM(imod,3,:,:),obs0,1.0,0))
              patcor1 = (pattern_cor(finspec_EM(imod,3,:,:),finspec_EM(imod,0,:,:),1.0,0))
              lxstr  = "PC w/Obs: "  +sprintf("%.2f",patcor0) + "~C~" + \
                       "PC w/Bias: " +sprintf("%.2f",patcor1)
              res1@gsnCenterString  = lxstr
              res1@gsnLeftString  = submec(hh)+"("+finspec_EM@eof2_pcvar(imod)+")"
              cmip_plot(kk) = gsn_csm_hov(wks_cmip,finspec_EM(imod,3,:,:),res1)
            end if 
          end if 
         end do 
       end do 
    end do 
    panres@lbTitleString = ncol_labels(dd)+ " (" + ncol_units(dd)+")"
    gsn_panel(wks_cmip,cmip_plot,(/6,3/),panres)
    ofile = "obs_cmip"+varlist(dd)+".pattern_bias"
    system("convert -density 2400 -trim +repage -border 40 -bordercolor white "+OUTDIR+"cmip.hov.pattern_bias."+wks_type+" "+OUTDIR+ofile+"_ensemble.png")
    system("rm "+OUTDIR+"cmip.hov.pattern_bias.png")
    delete([/submod,subgrp,submec/])

    res2    = res
    submod  = (/"v3","v2.1","v2"/)
    subgrp  = (/"HISTORICAL","piControl"/)
    do ii = 0,dimsizes(subgrp)-1
      do jj = 0, dimsizes(submod)-1,1
        tmpstr = submod(jj)+"-"+subgrp(ii)
        imod = ind(finEM_names.eq.tmpstr)
        kk = ii*dimsizes(submod) + jj 
        if(.not.ismissing(imod)) then 
          indx    = ind(finEM_names.eq."CMIP6-HISTORICAL")
          patcor0 = (pattern_cor(finspec_EM(imod,0,:,:),finspec_EM(0,0,:,:),1.0,0))
          patcor1 = (pattern_cor(finspec_EM(imod,0,:,:),finspec_EM(indx,0,:,:),1.0,0))
          lxstr   = "PC w/Obs: "   + sprintf("%.2f",patcor0) + "~C~" + \
                    "PC w/CMIP6: " + sprintf("%.2f",patcor1)
          res2@gsnCenterString = lxstr 
          res2@gsnRightString  = finEM_names(imod)
          res2@gsnLeftString   = metrics(0)
          esm_plot(kk)         = gsn_csm_hov(wks_esm,finspec_EM(imod,0,:,:),res2)
           
          ;************************************************
          ; add text
          ;************************************************
          patcor1 = (pattern_cor(finspec_EM(imod,0,:,:),finspec_EM(indx,0,:,:),1.0,0))
          patcor2 = (pattern_cor(finspec_EM(imod,0,:,:),finspec_EM(indx,2,:,:),1.0,0))
          patcor3 = (pattern_cor(finspec_EM(imod,0,:,:),finspec_EM(indx,3,:,:),1.0,0))
          lxstr   = "PC w/CMIP6: " +sprintf("%.2f",patcor1)+\
                                 ",  w/EOF1: "   +sprintf("%.2f",patcor2)+\
                                 ",  w/EOF2: "   +sprintf("%.2f",patcor3)
          tres                      = True                ; text mods desired
          tres@txFontHeightF        = FontHeightF*0.9     ; make smaller
          tres@txFontColor          = "Black"
          ;dum(kk) = gsn_add_text(wks_esm,esm_plot(kk),lxstr,\
          ;                  finspec_EM&lon0(80),finspec_EM&time_mon1(26),tres)
          delete(indx)
        end if 
      end do 
    end do 

    panres = True
    panres@gsnPanelYWhiteSpacePercent = 4
    panres@gsnPanelXWhiteSpacePercent = 4
    panres@lbTitleString = ncol_labels(dd)+ " (" + ncol_units(dd)+")"
    gsn_panel(wks_esm,esm_plot,(/6,3/),panres)
    delete(wks_esm)
    ofile = "esm_"+varlist(dd)+".pattern_bias"
    system("convert -density 2400 -trim +repage -border 40 -bordercolor white "+OUTDIR+"esm.hov.pattern_bias."+wks_type+" "+OUTDIR+ofile+"_ensemble.png")
    system("rm "+OUTDIR+"esm.hov.pattern_bias.png")
    delete([/panres/])
    delete([/submod,subgrp/])

   ;scattering plot for bias EOF 
    nexps = dimsizes(finspec_EM@eof1_pctsm)
    eof1_pctsm = new((/3,nexps/),float)
    eof2_pctsm = eof1_pctsm
    do gg = 0,nexps-1,1
      if(.not.ismissing(finspec_EM@eof1_pctsm(gg)))then 
       eofstr1 = str_split(finspec_EM@eof1_pctsm(gg), ";")
       do ff = 0,2
         eof1_pctsm(ff,gg) = tofloat(eofstr1(ff))
       end do
       delete([/eofstr1/])
      end if 
      if(.not.ismissing(finspec_EM@eof1_pctsm(gg)))then
       eofstr2 = str_split(finspec_EM@eof2_pctsm(gg), ";")
       do ff = 0,2
         eof2_pctsm(ff,gg) = tofloat(eofstr2(ff))
       end do 
       delete([/eofstr2/])
      end if 
    end do 
    csubexp          = (/"OBS","CMIP6","E3SMv3dev", "E3SMv2.1", "E3SMv2"/)
    csubexp_color    = (/"Black","Grey50","firebrick2","deepskyblue4","Green4"/)
    csubgroup        = (/"OBS","HISTORICAL", "piControl"/)
    csubgroup_marker = (/7,4,16,3/)
    csubtitle_color  = set_subtitle_colors(max(EM_num))
    csubtitle        = new(max(EM_num),string)
    scolor           = new(nexps,string)
    smarker          = new(nexps,integer)
    sthick           = tofloat(smarker)
    ssize            = tofloat(smarker)
    sthick           = 10.0
    ssize            = 0.020

    do jj = 0,nexps-1,1
     if(finEM_names(jj).eq."Observations") then
       scolor(jj)  = csubexp_color(0)
       csubexp(0)  = "OBS"
     else if (isStrSubset(finEM_names(jj),"CMIP6")) then
       scolor(jj)  = csubexp_color(1)
       csubexp(1)  = "CMIP6"
     else if (isStrSubset(finEM_names(jj),"v3-")) then
       scolor(jj)  = csubexp_color(2) ; "firebrick2"
       csubexp(2)  = "E3SMv3dev"
     else if (isStrSubset(finEM_names(jj),"v2.1-")) then
       scolor(jj)  = csubexp_color(3)
       csubexp(3)  = "E3SMv2.1"
     else if (isStrSubset(finEM_names(jj),"v2-")) then
       scolor(jj)  = csubexp_color(4)
       csubexp(4)  = "E3SMv2"
     else
       scolor(jj)  = csubtitle_color(jj)
     end if
     end if
     end if
     end if
     end if

     if(finEM_names(jj).eq."Observations") then
       smarker(jj) = csubgroup_marker(0)
     else if (isStrSubset(finEM_names(jj),csubgroup(1))) then
       smarker(jj) = csubgroup_marker(1)
     else if (isStrSubset(finEM_names(jj),csubgroup(2))) then
       smarker(jj) = csubgroup_marker(2)
     else if (isStrSubset(finEM_names(jj),csubgroup(3))) then
       smarker(jj) = csubgroup_marker(3)
     else
       smarker(jj) = 14
     end if
     end if
     end if
     end if
    end do

    wks_pcmip  = gsn_open_wks(wks_type,getenv("OUTDIR")+"esm.hov.pcmean_bias" )

    resx = True 
    resx@gsnDraw           = False
    resx@gsnFrame          = False       ; Don't advance frame
    resx@vpXF              = 0.2
    resx@vpYF              = 0.85
    resx@vpWidthF          = 0.5
    resx@vpHeightF         = 0.5

    resx@trYMinF           = -2.0
    resx@trYMaxF           =  2.0
    resx@trXMinF           = -2.0
    resx@trXMaxF           =  2.0

    resx@tiXAxisString     = "PC1"
    resx@tiYAxisString     = "PC2"

    lthick = 5.0
    resx@tmBorderThicknessF  = lthick
    resx@tmXBMajorThicknessF = lthick
    resx@tmXBMinorThicknessF = lthick
    resx@tmYLMajorThicknessF = lthick
    resx@tmYLMinorThicknessF = lthick
    resx@tmYRMajorThicknessF = lthick
    resx@tmYRMinorThicknessF = lthick

    FontHeightF = 0.020
    resx@tmXBLabelFontHeightF= FontHeightF*1.0
    resx@tmYLLabelFontHeightF= FontHeightF*1.0
    resx@tiMainFontHeightF   = FontHeightF*1.0
    resx@tiXAxisFontHeightF  = FontHeightF*1.0
    resx@tiYAxisFontHeightF  = FontHeightF*1.0

    resx@gsnXRefLine       = 0. ; reference line
    resx@gsnYRefLine       = 0. ; reference line
    resx@gsnXRefLineColor  = "Black" ; reference line
    resx@gsnYRefLineColor  = "Black" ; reference line
    resx@gsnXRefLineDashPattern = 5
    resx@gsnYRefLineDashPattern = 5
    resx@gsnXRefLineThicknessF  = 5.0
    resx@gsnYRefLineThicknessF  = 5.0

    resx@tmYLMode          = "Explicit"
    resx@tmYLValues        = fspan(resx@trYMinF,resx@trYMaxF,6)
    resx@tmYLLabels        = fspan(resx@trYMinF,resx@trYMaxF,6)
    resx@tmYLMinorValues   = fspan(resx@trYMinF,resx@trYMaxF,16)

    resx@tmXBMode          = "Explicit"
    resx@tmXBValues        = fspan(resx@trXMinF,resx@trXMaxF,6)
    resx@tmXBLabels        = fspan(resx@trXMinF,resx@trXMaxF,6)
    resx@tmXBMinorValues   = fspan(resx@trXMinF,resx@trXMaxF,16) 
    resx@tmYRBorderOn      = True         ; Habilita a borda do eixo y direito (YR).
    resx@tmXTBorderOn      = True         ; Habilita a borda do eixo x superior (XB).
    resx@tmXTOn            = False
    resx@tmYROn            = False
    resx@tmXBLabelsOn      = True
    resx@tmYLLabelsOn      = True
    resx@tmYLMinorOn       = True
    resx@tmYLOn            = True
    resx@tmXBOn            = True
    resx@tmXBLabelsOn      = True
    resx@tmXBMinorOn       = True

   ;---XY marker resources
    resx@xyMonoMarkerColor   = False          ; Allow different colors for markers
    resx@xyMarkLineMode      = "Markers"
    resx@xyMarkerSizes       = 0.0001
    resx@xyMarkerThicknesses = 1.0
    resx@xyMarkerColors      = "white"
    resx@xyMarkers           = 1
    pcplot = gsn_csm_xy (wks_pcmip,eof1_pctsm(0,:),eof2_pctsm(0,:),resx) 
    gsres = True
    do ff = 0,2
     do gg = 0,nexps-1
      xmarker = eof1_pctsm(ff,gg)
      ymarker = eof2_pctsm(ff,gg)
      gsres@gsMarkerColor = scolor(gg) 
      gsres@gsMarkerIndex = smarker(gg)
      gsres@gsMarkerSizeF = ssize(gg)
      gsres@gsMarkerThicknessF = sthick(gg)
      if((.not.ismissing(xmarker)).and.(.not.ismissing(ymarker))) then 
        pcplot@$unique_string("dum")$ = gsn_add_polymarker(wks_pcmip,pcplot,xmarker,ymarker,gsres)
      end if 
     end do 
    end do
    delete([/resx,eof1_pctsm,eof2_pctsm,gsres/])

    gsres               = True
    txres               = True
    txres@txJust        = "bottomleft"
    txres@txFontHeightF = FontHeightF*0.85
    do i = 0, dimsizes(csubexp)-1
     xtxt = 0.15 + 0.46
     ytxt = 0.28 + i * 0.032
     txres@txFontColor = csubexp_color(i)
     gsn_text_ndc (wks_pcmip,csubexp(i),xtxt,ytxt,txres)
    end do

    do i = 0, dimsizes(csubgroup)-1
     xleg = 0.15 + 0.63
     xtxt = 0.17 + 0.63
     yleg = 0.30 + i * 0.032
     ytxt = 0.30 + i * 0.032
     gsres@gsMarkerIndex      = csubgroup_marker(i)
     gsres@gsMarkerColor      = "Black" ;colors(i)
     gsres@gsMarkerThicknessF = 6.0  ;*(i+1)
     gsres@gsMarkerSizeF      = 15.
     gsn_polymarker_ndc(wks_pcmip,          xleg,yleg,gsres)
     txres@txJust      = "centerleft"
     txres@txFontColor = "Black"
     gsn_text_ndc      (wks_pcmip,csubgroup(i),xtxt,ytxt,txres)
    end do

    panres = True
    panres@gsnPanelYWhiteSpacePercent = 4
    panres@gsnPanelXWhiteSpacePercent = 4
    panres@lbTitleString = ncol_labels(dd)+ " (" + ncol_units(dd)+")"
    gsn_panel(wks_pcmip,pcplot,(/1,1/),panres)
    delete(wks_pcmip)
    ofile = "esm_"+varlist(dd)+".pc_scatter"
    system("convert -density 2400 -trim +repage -border 40 -bordercolor white "+OUTDIR+"esm.hov.pcmean_bias."+wks_type+" "+OUTDIR+ofile+"_ensemble.png")
    system("rm "+OUTDIR+"esm.hov.pcmean_bias.png")
    delete([/panres/])
    delete([/finspec_EM/])

  end do   ; dd loop (each metric)

  print("Finished: ens_metrics_pattern.ncl")
end
