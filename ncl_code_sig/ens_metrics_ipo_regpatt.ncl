; This script calculates various metrics scores. 
;
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: ens_metrics_ipo_regpatt.ncl")
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
    print("ens_metrics_ipo_regpatt.ncl: Observations not present.")
    print("Exiting: ens_metrics_ipo_regpatt.ncl")    
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
  varlist = (/"ipo_psl_regression_djf",\
              "ipo_psl_regression_mam",\
              "ipo_psl_regression_jja",\
              "ipo_psl_regression_son"/)
  varlist_obs = varlist
  ncol_labels = (/"IPO regression on PSL (DJF)",\
                  "IPO regression on PSL (JJA)",\
                  "IPO regression on PSL (MAM)",\
                  "IPO regression on PSL (SON)" /)
  ncol_units = (/"hPa",\
                 "hPa",\
                 "hPa",\
                 "hPa"/)
  varlist_fn = (/"sst.ipo.psl",\ 
                 "sst.ipo.psl",\
                 "sst.ipo.psl",\ 
                 "sst.ipo.psl"/)
  domain   = (/"global",\
               "global",\
               "global",\
               "global"/)
  variable = (/"psl",\
               "psl", \
               "psl", \
               "psl"/)
  varfacts = (/1.0,\
               1.0,\
               1.0,\
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
  finEM_names   = new(nEM+1,string)
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
     obs0!0  = "lat0"
     obs0!1  = "lon0"
     lon0 = obs0&lon0
     lat0 = obs0&lat0
     lat0@standard_name = "latitude"
     lon0@standard_name = "longitude"
     obs0&lon0 = lon0
     obs0&lat0 = lat0
     delete([/lat0,lon0/])

     cntr_EM = 0
     cntr    = 1  
     numobs = num(EM_num.eq.0)
     if (.not.isvar("finname_obs")) then
        finname_obs := new((/numobs/),string)
     end if
     finEM_names(cntr_EM) = (/"Observation"/)
     finname_obs(cntr_EM) = (/modnameT/)
     finspec_obs = new((/numobs,dimsizes(obs0&lat0),dimsizes(obs0&lon0)/),typeof(obs0))
     finspec_obs!0 = "ens"
     finspec_obs!1 = "lat0"
     finspec_obs!2 = "lon0"
     finspec_obs&lat0 = obs0&lat0
     finspec_obs&lon0      = obs0&lon0
     finspec_obs(0,:,:)    = (/obs0/)
     if (numobs.ge.2) then     ; plot obs #2-
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
           arr!0  = "lat0"
           arr!1  = "lon0"
           finname_obs(cntr) = (/ modnameT /)
           arr_rg = obs0
           do hh = 0,dimsizes(arr&lat0)-1
              arr_rg(hh,:) = (/ linint1(arr&lon0,arr(hh,:),False,obs0&lon0,0) /)
           end do
           arr_rg@_Fill_Value = -9999.0 
           finspec_obs(cntr,:,:) = (/arr_rg/)
           delete([/arr,arr_rg/])
           cntr = cntr + 1
        end do
     end if

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
     ;read simulation data 
     cntr    = 0
     cntr_EM = 1
     do gg = 1,nEM; operate on each ensemble mean
        nens = num(EM_num.eq.gg) ; determines how many model simulations in each ensemble
        cntr_ens := ind(EM_num.eq.gg)   ; cntr_ens(hh) are the indices where each ensemble member of an ensemble reside
        if (ismissing(finEM_names(cntr_EM))) then
           finEM_names(cntr_EM) = names_EM(cntr_ens(0))
           cntr_EM = cntr_EM + 1
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
          arr!0   = "lat0"
          arr!1   = "lon0"
          arr     = where(ismissing(arr),obs0@_FillValue,arr)
          arr@_FillValue = obs0@_FillValue
          arr_rg  = new((/1,dimsizes(obs0&lat0),dimsizes(obs0&lon0)/),typeof(obs0))
          do ii = 0,dimsizes(arr&lat0)-1
             arr_rg(0,ii,:) = (/ linint1(arr&lon0,arr(ii,:),False,obs0&lon0,0) /)
          end do
          if(.not.isvar("finspec_mod"))then 
            finspec_mod = new((/1,dimsizes(obs0&lat0),dimsizes(obs0&lon0)/),typeof(obs0))
            finspec_mod!0      = "ens"
            finspec_mod!1      = "lat0"
            finspec_mod!2      = "lon0"
            finspec_mod&lat0   = obs0&lat0
            finspec_mod&lon0   = obs0&lon0
            finspec_mod(0,:,:) = (/obs0/)
          end if 
          if (cntr.eq.0) then 
            finname_mod = names_EM(cntr_ens(hh))
            finspec_mod(0,:,:) = (/arr_rg/)
          else
            x1 = finname_mod 
            delete([/finname_mod/])
            finname_mod = array_append_record (x1, names_EM(cntr_ens(hh)), 0)
            delete([/x1/])
            x1 = finspec_mod
            delete([/finspec_mod/])
            finspec_mod = array_append_record (x1, arr_rg, 0)
            delete([/arr,arr_rg,x1/])
          end if 
          cntr =  cntr + 1 
       end do 
     end do 
     if (isvar("obs0")) then 
        delete([/obs0/])
     end if 

    ;process figures;;;;
     wks_mean = gsn_open_wks(wks_type,getenv("OUTDIR")+"mean.hov.pattern" )
     wks_bias = gsn_open_wks(wks_type,getenv("OUTDIR")+"bias.mean.hov.pattern"  )
     wks_stdb = gsn_open_wks(wks_type,getenv("OUTDIR")+"bias.std.hov.pattern"  )
     wks_eofb = gsn_open_wks(wks_type,getenv("OUTDIR")+"bias.eof.hov.pattern_bias"  )
     if (COLORMAP.eq.0) then
       gsn_define_colormap(wks_mean,"testcmap") 
       gsn_define_colormap(wks_bias,"BlueDarkRed18") 
       gsn_define_colormap(wks_stdb,"WhiteYellowOrangeRed")
       gsn_define_colormap(wks_eofb,"BlueDarkRed18")
     end if
     if (COLORMAP.eq.1) then
       gsn_define_colormap(wks_mean,"testcmap")
       gsn_define_colormap(wks_bias,"BlueDarkRed18")
       gsn_define_colormap(wks_stdb,"WhiteYellowOrangeRed")
       gsn_define_colormap(wks_eofb,"BlueDarkRed18")
     end if

     FontHeightF = 0.017

    ;;;;plot the CMIP6 data
     if (COLORMAP.eq.0) then
        cmap = read_colormap_file("MPL_RdBu")
        cmap = cmap(::-1,:)
        nx   = dimsizes(cmap(:,0))
        cmap (nx/2-5:nx/2+5,:) = 0
     end if
     if (COLORMAP.eq.1) then
        cmap = read_colormap_file("NCV_jaisnd")
        nx   = dimsizes(cmap(:,0))
        cmap (nx/2-5:nx/2+5,:) = 0
     end if

     FontHeightF = 0.020

     res = True
     res@vpHeightF = 0.4
     res@vpWidthF  = 0.6
     res@gsnFrame  = False
     res@gsnDraw   = False

     res = True
     res@gsnDraw      = False
     res@gsnFrame     = False
     res@cnFillPalette = cmap

    ;res@mpProjection = "WinkelTripel"
     res@mpGeophysicalLineColor = "Black" ;"gray42"
     res@mpPerimOn              = False
     res@mpGridLineColor        = "transparent"  ; trick ncl into drawing perimeter
     res@mpGridAndLimbOn        = True           ; turn on lat/lon lines
     res@mpFillOn               = False
     res@mpOutlineOn            = True
     if (wks_type.eq."png") then
        res@mpGeophysicalLineThicknessF = 2.
     else
        res@mpGeophysicalLineThicknessF = 1.
     end if

     res@mpGridLatSpacingF      =  90            ; change latitude  line spacing
     res@mpGridLonSpacingF      = 180.           ; change longitude line spacing
     res@gsnMajorLatSpacing     = 30              ; change maj lat tm spacing
     res@gsnMajorLonSpacing     = 60              ; change maj lon tm spacing
     res@gsnMinorLatSpacing     = 15              ; change maj lat tm spacing
     res@gsnMinorLonSpacing     = 30              ; change maj lon tm spacing
     res@mpGridSpacingF         = 30            ; change to match labels
     res@mpCenterLonF           = 180.

     if (domain(dd).eq."global") then
        res@mpCenterLonF           = 180.
        res@gsnMajorLatSpacing     = 30              ; change maj lat tm spacing
        res@gsnMajorLonSpacing     = 60              ; change maj lon tm spacing
        res@gsnMinorLatSpacing     = 15              ; change maj lat tm spacing
        res@gsnMinorLonSpacing     = 30              ; change maj lon tm spacing
        res@mpLimitMode            = "LatLon"
        res@mpMinLatF              = -90.0                ; map area
        res@mpMaxLatF              =  90.0                ; latitudes
        res@mpMinLonF              = 0.0              ; and
        res@mpMaxLonF              = 360.0               ; longitudes
        XWhiteSpacePercent         = 4
        YWhiteSpacePercent         = 4
        FontHeightF                = 0.020
     end if
     if (domain(dd).eq."globalA") then
        res@mpCenterLonF           = 210.
        res@gsnMajorLatSpacing     = 30              ; change maj lat tm spacing
        res@gsnMajorLonSpacing     = 60              ; change maj lon tm spacing
        res@gsnMinorLatSpacing     = 15              ; change maj lat tm spacing
        res@gsnMinorLonSpacing     = 30              ; change maj lon tm spacing
        res@mpLimitMode            = "LatLon"
        res@mpMinLatF              = -70.0                ; map area
        res@mpMaxLatF              =  70.0                ; latitudes
        res@mpMinLonF              = 0.0              ; and
        res@mpMaxLonF              = 360.0               ; longitudes
        XWhiteSpacePercent         = 4
        YWhiteSpacePercent         = 4
        FontHeightF                = 0.020
     end if

     if (domain(dd).eq."NHext") then
        res@mpCenterLonF           = 180.
        res@gsnMajorLatSpacing     = 15              ; change maj lat tm spacing
        res@gsnMajorLonSpacing     = 60              ; change maj lon tm spacing
        res@gsnMinorLatSpacing     = 5               ; change maj lat tm spacing
        res@gsnMinorLonSpacing     = 30              ; change maj lon tm spacing
        res@mpLimitMode            = "LatLon"
        res@mpMinLatF              =  20.0                ; map area
        res@mpMaxLatF              =  90.0                ; latitudes
        res@mpMinLonF              = 0.0              ; and
        res@mpMaxLonF              = 360.0               ; longitudes
        XWhiteSpacePercent         = 4
        YWhiteSpacePercent         = 8
        FontHeightF                = 0.018
        if (isStrSubset(ncol_labels(dd),"NAO")) then
           res@mpCenterLonF        = 330.
        end if
        if (isStrSubset(ncol_labels(dd),"PNA")) then
           res@mpCenterLonF        = 210.
        end if
     end if

     if (domain(dd).eq."SHext") then
        res@mpCenterLonF           = 180.
        res@gsnMajorLatSpacing     = 15              ; change maj lat tm spacing
        res@gsnMajorLonSpacing     = 60              ; change maj lon tm spacing
        res@gsnMinorLatSpacing     = 5               ; change maj lat tm spacing
        res@gsnMinorLonSpacing     = 30              ; change maj lon tm spacing
        res@mpLimitMode            = "LatLon"
        res@mpMinLatF              = -90.0                ; map area
        res@mpMaxLatF              = -20.0                ; latitudes
        res@mpMinLonF              = 0.0              ; and
        res@mpMaxLonF              = 360.0               ; longitudes
        XWhiteSpacePercent         = 4
        YWhiteSpacePercent         = 8
        FontHeightF                = 0.018
     end if

     res@tmXBLabelFontHeightF   = FontHeightF         ; change maj lat tm spacing
     res@tmYLLabelFontHeightF   = FontHeightF         ; change maj lat tm spacing
     res@tmXBMajorLengthF       = 0.02          ; change the tickmark length

    ;res@vpHeightF = 0.4
    ;res@vpWidthF  = 0.6

     res@tmXTOn       = False
     res@tmYROn       = False
     res@tmXTLabelsOn = False
     res@tmXUseBottom = False

     res@cnLineLabelsOn         = False
     res@cnFillOn               = True
     res@cnLinesOn              = False
     res@lbLabelBarOn           = False
     res@tiMainOn = False
     res@cnInfoLabelOn = False
     res@cnLevelSelectionMode = "ExplicitLevels"
     res@cnLevels            := fspan(-1,1,21)
     res@cnLevels             = res@cnLevels * varfacts(dd)

     if (wks_type.eq."png") then
        res@cnLineThicknessF = 2.
     else
        res@cnLineThicknessF = 1.
     end if

     res@gsnLeftString = ""
     res@gsnCenterString= ""
     res@gsnRightString = ""

     res@gsnLeftString = ""
     res@gsnCenterString= ""
     res@gsnRightString = ""

     res@gsnRightStringParallelPosF    = 0.96
     res@gsnCenterStringOrthogonalPosF = 0.015
     res@gsnLeftStringOrthogonalPosF   = res@gsnCenterStringOrthogonalPosF
     res@gsnRightStringOrthogonalPosF  = res@gsnCenterStringOrthogonalPosF
     res@gsnCenterStringFontHeightF    = FontHeightF * 0.9
     res@gsnLeftStringFontHeightF      = FontHeightF * 0.9
     res@gsnRightStringFontHeightF     = FontHeightF * 0.9

     panres = True
     panres@gsnMaximize = True
     panres@gsnPaperOrientation = "portrait"
     panres@gsnPanelLabelBar = True
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

    panres@gsnPanelYWhiteSpacePercent = YWhiteSpacePercent
    panres@gsnPanelXWhiteSpacePercent = XWhiteSpacePercent

    printVarSummary(finspec_obs)

    ;; mean global maps
    res1 = res 
    res1@cnLevelSelectionMode = "ExplicitLevels"
    carr    = new(dimsizes(res1@cnLevels),"string")
    carr    = "transparent"
    carr(8) = "gray50"
    plot    = new(dimsizes(finEM_names),graphic)
    print(finEM_names)
    do kk   = 0,dimsizes(finEM_names)-1,1
      if(finEM_names(kk).eq."Observation") then 
        ;obs0 = dim_avg_n_Wrap(finspec_obs,0)
         obs0 = finspec_obs(0,:,:)
         res1@gsnLeftString   = "Observation"
         res1@gsnRightString  = "" 
         res1@gsnCenterString = ""
         plot(kk) = gsn_csm_contour_map(wks_mean,obs0,res1)
      else
         cntr_ens := ind(finname_mod.eq.finEM_names(kk))
         if(dimsizes(cntr_ens).gt.1) then 
           var0  = dim_avg_n_Wrap(finspec_mod(cntr_ens,:,:),0)  
         else
           var0  = finspec_mod(cntr_ens,:,:)
         end if 
         patcor   = pattern_cor(var0,obs0,1.0,1)
         lxstr    = "PC w/Obs: "  +sprintf("%.2f",patcor)
         res1@gsnCenterString  = "" ;lxstr
         res1@gsnLeftString    = finEM_names(kk) 
         res1@gsnRightString   = lxstr +"; ens #: " + dimsizes(cntr_ens)
         plot(kk) = gsn_csm_contour_map(wks_mean,var0,res1)
         delete([/cntr_ens,patcor,lxstr,var0/])
      end if 
    end do 
    panres@lbTitleString = ncol_labels(dd)+ " (" + ncol_units(dd)+")"
    gsn_panel(wks_mean,plot,(/dimsizes(finEM_names),2/),panres)
    ofile = varlist(dd)+".mean.pattern"
    system("convert -density 2400 -trim +repage -border 40 -bordercolor white "+OUTDIR+"mean.hov.pattern."+wks_type+" "+OUTDIR+ofile+".png")
    system("rm "+OUTDIR+"mean.hov.pattern.png")
    delete([/plot,carr,res1/])

  end do   ; dd loop (each metric)

  print("Finished: ens_metrics_ipo_regpatt.ncl")
end
