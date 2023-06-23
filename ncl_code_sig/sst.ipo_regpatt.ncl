; Calculates ipo indices as well as ipo index 
; timeseries onto selected quantities (see reg_var)
;
; Variables used: sst and selected quantities 
; 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: sst.ipo_regpatt.ncl")
  
  SCALE_TIMESERIES = getenv("SCALE_TIMESERIES")  
  OUTPUT_DATA      = getenv("OUTPUT_DATA")  
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OPT_CLIMO        = getenv("OPT_CLIMO")
  CLIMO_SYEAR      = toint(getenv("CLIMO_SYEAR"))
  CLIMO_EYEAR      = toint(getenv("CLIMO_EYEAR"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
  COMPUTE_MODES_MON = getenv("COMPUTE_MODES_MON")
  COLORMAP         = getenv("COLORMAP")  
  
  nsim = numAsciiRow("namelist_byvar/namelist_ts")
  na = asciiread("namelist_byvar/namelist_ts",(/nsim/),"string")
  names = new(nsim,"string")
  paths = new(nsim,"string")
  syear = new(nsim,"integer",-999)
  eyear = new(nsim,"integer",-999)
  delim = "|"

  do gg = 0,nsim-1
     names(gg) = str_strip(str_get_field(na(gg),1,delim))
     paths(gg) = str_strip(str_get_field(na(gg),2,delim))
     syear(gg) = stringtointeger(str_strip(str_get_field(na(gg),3,delim)))
     eyear(gg) = stringtointeger(str_strip(str_get_field(na(gg),4,delim)))
  end do
  nyr = eyear-syear+1
  nyr_max = max(nyr)

  pi=4.*atan(1.0)
  rad=(pi/180.)
 
 regvars = (/"psl","sst","trefht","prect","u10","v10","taux","tauy","shflx","lhflx", "eth", \
             "swcre","olr","cldtot","u850","v850","th850","z500","u200","v200","aice_nh","aice_sh"/)
 landmsk = (/    0,    1,       0,      0,    0,    0,     0,     0,   0,   0,     1, \
                 0,      0,       0,     0,     0,      0,     0,     0,   0,      1, 1/)
 varfacs = (/3.0,   1.0,     1.0,    1.0,  1.0,  1.0,   2.0,   2.0, 5.0, 10.0,  5.0, \
                 5.0, 5.0,     5.0,  2.0,    2.0,  1.0,   15.0,   5.0,   2.5, 5.0, 5.0/)
 nsvars  = dimsizes(regvars)

 do ss = 0, nsvars-1,1
  ;---------Regressions coding-------------------------------------------------
  if(regvars(ss).eq."sst") then
    vnm   = "ts"
  else 
    vnm   = regvars(ss)
  end if

  lmsk  = landmsk(ss)
  vrfac = varfacs(ss)
  nsim_reg = numAsciiRow("namelist_byvar/namelist_"+vnm)
  na_reg   = asciiread("namelist_byvar/namelist_"+vnm,(/nsim_reg/),"string")

  names_reg = new(nsim_reg,"string")
  paths_reg = new(nsim_reg,"string")
  syear_reg = new(nsim_reg,"integer",-999)
  eyear_reg = new(nsim_reg,"integer",-999)

  do gg = 0,nsim_reg-1
     names_reg(gg) = str_strip(str_get_field(na_reg(gg),1,delim))
     paths_reg(gg) = str_strip(str_get_field(na_reg(gg),2,delim))
     syear_reg(gg) = stringtointeger(str_strip(str_get_field(na_reg(gg),3,delim)))
     eyear_reg(gg) = stringtointeger(str_strip(str_get_field(na_reg(gg),4,delim)))
  end do
  delete(na_reg)
  nyr_reg = eyear_reg-syear_reg+1 
 
;-------------------------------------------------------------------------------------------------
  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if
  
  wks_ipo  = gsn_open_wks(wks_type,getenv("OUTDIR")+"ipo.vxreg")
  
  if (COLORMAP.eq.0) then
     gsn_define_colormap(wks_ipo,"MPL_RdBu")  
     gsn_reverse_colormap(wks_ipo)           ; Reverse the color map.
  end if
  if (COLORMAP.eq.1) then
     gsn_define_colormap(wks_ipo,"NCV_jaisnd")  
  end if
  
  reg_ipo_djf = new(nsim,"graphic")  
  reg_ipo_mam = new(nsim,"graphic")  
  reg_ipo_jja = new(nsim,"graphic")  
  reg_ipo_son = new(nsim,"graphic")  
  reg_ipo_ann = new(nsim,"graphic")  
  reg_ipo_mon = new(nsim,"graphic")  
  
  vxreg_frame    = 1 

  do ee = 0,nsim-1

     ;check that regression var and index var contains shared range
     ;suppose that regression var period <= index var time period 
     if (any(ismissing((/syear(ee),syear_reg(ee),eyear(ee),eyear_reg(ee)/)))) then
       vxreg_plot_flag = 1
     else
       if (syear_reg(ee).ge.syear(ee).and.eyear_reg(ee).le.eyear(ee)) then
         vxreg_plot_flag = 0
       else
         vxreg_plot_flag = 1
       end if
     end if

     if (vxreg_plot_flag.eq.0) then 

      arr = data_read_in(paths(ee),"TS",syear_reg(ee),eyear_reg(ee)) ; read in data, orient lats/lons correctly, set time coordinate variable up
      if (isatt(arr,"is_all_missing")) then
        delete(arr)
        continue
      end if 
 
      arr = where(arr.le.-1.8,-1.8,arr)    ; set all values below -1.8 to -1.8
      d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")   ; mask out land (this is redundant for data that is already masked)
      basemap = d->LSMASK
      lsm = landsea_mask(basemap,arr&lat,arr&lon)
      arr = mask(arr,conform(arr,lsm,(/1,2/)).ge.1,False)
      delete([/lsm,basemap/])
      delete(d)
    
      if (OPT_CLIMO.eq."Full") then
        arr = rmMonAnnCycTLL(arr)
      else
        check_custom_climo(names(ee),syear_reg(ee),eyear_reg(ee),CLIMO_SYEAR,CLIMO_EYEAR)
        temp_arr = arr
        delete(temp_arr&time)
        temp_arr&time = cd_calendar(arr&time,-1)
        if (CLIMO_SYEAR.lt.0) then
           climo = clmMonTLL(temp_arr({(eyear_reg(ee)+CLIMO_SYEAR)*100+1:(eyear_reg(ee)+CLIMO_EYEAR)*100+12},:,:))       
        else
           climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))                 
        end if   
        delete(temp_arr)
        arr   = calcMonAnomTLL(arr,climo) 
        delete(climo)
      end if

      ;apply low pass filtering 
      fca    = 1./157.
      fcb    = 0.
      ihp    = 0
      nsigma = 1
      nwgt   = 217
      wgt    = new(nwgt,float)
      wgt    = filwgts_lancos(nwgt,ihp,fca,fcb,nsigma)   ; create low pass filter
      arr    = wgt_runave_n_Wrap(arr,wgt,1,0)   ; apply low pass filter
      delete([/fca,fcb,ihp,nsigma,nwgt,wgt/])

      coswgt=cos(rad*arr&lat)
      coswgt!0 = "lat"
      coswgt&lat= arr&lat
      do ff = 0,dimsizes(arr&time)-1
         arr(ff,:,:) = (/ arr(ff,:,:) - wgt_areaave(arr(ff,{-60:70},:),coswgt({-60.:70.}),1.0,0) /)
      end do
      delete(coswgt)

      arrT =  runave_n_Wrap(arr,3,0,0)               ; form DJF averages
      arrT(0,:,:) = (/ dim_avg_n(arr(:1,:,:),0) /)   
      arr_djf = arrT(0::12,:,:)
      arr_mam = arrT(3::12,:,:)
      arr_jja = arrT(6::12,:,:)                       ; form JJA averages
      arr_son = arrT(9::12,:,:)
      delete(arrT)
     
      arrV = runave_n_Wrap(arr,12,0,0)
      arr_ann = arrV(5::12,:,:)
      delete(arrV)
;          
;     arr_djf = (/ dtrend_msg_n(ispan(0,dimsizes(arr_djf&time)-1,1),arr_djf,True,False,0) /)
;     arr_mam = (/ dtrend_msg_n(ispan(0,dimsizes(arr_mam&time)-1,1),arr_mam,True,False,0) /)
;     arr_jja = (/ dtrend_msg_n(ispan(0,dimsizes(arr_jja&time)-1,1),arr_jja,True,False,0) /)
;     arr_son = (/ dtrend_msg_n(ispan(0,dimsizes(arr_son&time)-1,1),arr_son,True,False,0) /)
;     
;     arr_ann = (/ dtrend_msg_n(ispan(0,dimsizes(arr_ann&time)-1,1),arr_ann,True,False,0) /)
;     
;     arr_ndjfm = (/ dtrend_msg_n(ispan(0,dimsizes(arr_ndjfm&time)-1,1),arr_ndjfm,True,False,0) /)
;     
;     arr = (/ dtrend_msg_n(ispan(0,dimsizes(arr&time)-1,1),arr,True,False,0) /)
     end if 

;---------Regressions coding-------------------------------------------------
    ;print("Data to be read in: "+paths_reg(ee)+" from "+syear_reg(ee)+":"+eyear_reg(ee))
     if(vnm.eq."aice_sh".or.vnm.eq."aice_nh") then
       vnmi = vnm
       vreg = data_read_in_ice(paths_reg(ee),vnmi,syear_reg(ee),eyear_reg(ee))
       if (isatt(vreg,"lat2d")) then
         vreg@is_all_missing = True
       else
         vreg!1 = "lat"
         vreg!2 = "lon"
       end if
     else
       vnmi = str_upper(vnm)
       vreg = data_read_in(paths_reg(ee),vnmi,syear_reg(ee),eyear_reg(ee))
     end if

     if (isatt(vreg,"is_all_missing")) then
       vxreg_plot_flag = 1
       delete(vreg)
     end if

     if (vxreg_plot_flag.eq.0) then    ; only continue if both PSL/TS fields are present
       if(vnm.eq."ts") then 
         vreg = where(vreg.le.-1.8,-1.8,vreg)
       end if 
       if(vnm.eq."trefht") then
         d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")    
         basemap = d->LSMASK
         lsm = landsea_mask(basemap,vreg&lat,vreg&lon)
         vreg = mask(vreg,conform(vreg,lsm,(/1,2/)).eq.0,False)
         delete(lsm)
       end if 
       if(lmsk.eq.1) then 
         d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")   
         basemap = d->LSMASK
         lsm = landsea_mask(basemap,vreg&lat,vreg&lon)
         vreg = mask(vreg,conform(vreg,lsm,(/1,2/)).ge.1,False)
         delete(lsm)
       end if   
       if (OPT_CLIMO.eq."Full") then
          vreg = rmMonAnnCycTLL(vreg)
       else
          check_custom_climo(names_reg(ee),syear_reg(ee),eyear_reg(ee),CLIMO_SYEAR,CLIMO_EYEAR)
          temp_arr = vreg
          delete(temp_arr&time)
          temp_arr&time = cd_calendar(vreg&time,1)
          if (CLIMO_SYEAR.lt.0) then
             climo = clmMonTLL(temp_arr({(eyear_reg(ee)+CLIMO_SYEAR)*100+1:(eyear_reg(ee)+CLIMO_EYEAR)*100+12},:,:))       
          else
             climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))                 
          end if   
          delete(temp_arr)
          vreg   = calcMonAnomTLL(vreg,climo) 
          delete(climo)
       end if
;      vreg = (/ dtrend_msg_n(ispan(0,dimsizes(vreg&time)-1,1),vreg,False,False,0) /)  
    
       vregT =  runave_n_Wrap(vreg,3,0,0)               ; form DJF averages
       vregT(0,:,:) = (/ dim_avg_n(vreg(:1,:,:),0) /)   
       vreg_djf = vregT(0::12,:,:)
       vreg_mam = vregT(3::12,:,:)
       vreg_jja = vregT(6::12,:,:)                       ; form JJA averages
       vreg_son = vregT(9::12,:,:)
       delete(vregT)
    
       vregV = runave_n_Wrap(vreg,12,0,0)
       vreg_ann = vregV(5::12,:,:)
       delete(vregV)
     end if 
   
;----------ipo definition----------------------------------------------------------------------
     coswgt     =cos(rad*arr_djf&lat)
     coswgt!0   = "lat"
     coswgt&lat = arr_djf&lat
     llats = -40.     ; nino3.4
     llatn =  60.
     llonw = 110.
     llone = 290.

     ;use a regional mean SSTA to make sign consistent for all simulation if possible
     llats1 =  30.0
     llatn1 =  35.0
     llonw1 =  150.0
     llone1 =  160.0

    ;sst_CW = arr
    ;sst_CW = SqrtCosWeight(arr)
    ;evecv = eofunc(sst_CW({lat|-40:60},{lon|110:290},time|:),2,75)
    ;delete(sst_CW)
    ;pcts = eofunc_ts(sst({lat|-40:60},{lon|110:290},time|:),evecv,False)
    ;pctsS = dim_standardize(pcts(0,:),0)
    ;delete([/pcts/])

    ;pc1 = pctsS
    ;pc1!0 = "time"
    ;pc1&time = sst&time
    ;pc1@units = "1"
    ;sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(pc1),False)
    ;if (sig_pcv(0)) then    ; if True then significant
    ;   ipo@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
    ;else
    ;   ipo@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
    ;end if
    ;delete([/sig_pcv,evecv/])

;----------ipo calculations----------------------------------------------------------------------
     sst_CW = arr_djf
     sst_CW = SqrtCosWeight(arr_djf)
     evecv  = eofunc(sst_CW({lat|llats:llatn},{lon|llonw:llone},time|:),2,75)
     pcts   = eofunc_ts(sst_CW({lat|llats:llatn},{lon|llonw:llone},time|:),evecv,False)
     ipo_pc_djf  = dim_standardize(pcts(0,:),0)
     ipo_djf     = arr_djf(0,:,:)
     ipo_djf     = (/ regCoef(ipo_pc_djf,arr_djf(lat|:,lon|:,time|:)) /)
     delete([/pcts,sst_CW,evecv/])
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(ipo_pc_djf, vreg_djf, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval    
        b         = 0.5
        ipo_vreg_djf  = vreg_djf(0,:,:)
        ipo_prob_djf  = vreg_djf(0,:,:)
        ipo_vreg_djf  = (/ rc /) 
        ipo_prob_djf  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/)
        ipo_prob_djf  = where(ismissing(ipo_vreg_djf),ipo_vreg_djf@_FillValue,ipo_prob_djf)
        ipo_vreg_djf@units = vreg_djf@units +" (per std dev)"
        delete([/rc,tval,df,b,vreg_djf/]) 
     end if     
     if (.not.all(ismissing(ipo_djf({llats1:llatn1},{llonw1:llone1})))) then
       if (avg(ipo_djf({llats1:llatn1},{llonw1:llone1})).ge.0) then
           ipo_djf = ipo_djf*-1.
           ipo_pc_djf = ipo_pc_djf*-1.
           if (vxreg_plot_flag.eq.0) then
              ipo_vreg_djf = ipo_vreg_djf*-1.
           end if 
       end if 
     end if
     rc    = arr_djf(0,:,:) 
     rc    = (/escorc_n(ipo_pc_djf,arr_djf,0,0)/)
     rc    = rc*rc*100.0
     pcvar = wgt_areaave_Wrap(rc({llats:llatn},{llonw:llone}),coswgt({llats:llatn}),1.0,0)
     ipo_djf@pcvar = tofloat(sprintf("%4.1f", pcvar))+"%"
     delete([/pcvar,rc/])    
     ipo_pc_djf!0 = "TIME"
     ipo_pc_djf&TIME = ispan(syear_reg(ee),eyear_reg(ee),1)
     ipo_pc_djf&TIME@units = "YYYY"
     ipo_pc_djf&TIME@long_name = "time"     
 
     sst_CW = arr_mam
     sst_CW = SqrtCosWeight(arr_mam)
     evecv  = eofunc(sst_CW({lat|llats:llatn},{lon|llonw:llone},time|:),2,75)
     pcts   = eofunc_ts(sst_CW({lat|llats:llatn},{lon|llonw:llone},time|:),evecv,False)
     ipo_pc_mam  = dim_standardize(pcts(0,:),0)
     ipo_mam     = arr_mam(0,:,:)
     ipo_mam     = (/ regCoef(ipo_pc_mam,arr_mam(lat|:,lon|:,time|:)) /)
     delete([/pcts,sst_CW,evecv/])
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(ipo_pc_mam, vreg_mam, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        ipo_vreg_mam  = vreg_mam(0,:,:)
        ipo_prob_mam  = vreg_mam(0,:,:)
        ipo_vreg_mam  = (/ rc /)
        ipo_prob_mam  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        ipo_prob_mam  = where(ismissing(ipo_vreg_mam),ipo_vreg_mam@_FillValue,ipo_prob_mam)
        ipo_vreg_mam@units = vreg_mam@units +"(per std dev)"
        delete([/rc,tval,df,b,vreg_mam/])
     end if
     if (.not.all(ismissing(ipo_mam({llats1:llatn1},{llonw1:llone1})))) then
       if (avg(ipo_mam({llats1:llatn1},{llonw1:llone1})).ge.0) then
           ipo_mam = ipo_mam*-1.
           ipo_pc_mam = ipo_pc_mam*-1.
           if (vxreg_plot_flag.eq.0) then
              ipo_vreg_mam = ipo_vreg_mam*-1.
           end if 
       end if 
     end if
     rc    = arr_djf(0,:,:)
     rc    = (/escorc_n(ipo_pc_mam,arr_mam,0,0)/)
     rc    = rc*rc*100.0
     pcvar = wgt_areaave_Wrap(rc({llats:llatn},{llonw:llone}),coswgt({llats:llatn}),1.0,0)
     ipo_mam@pcvar = tofloat(sprintf("%4.1f", pcvar))+"%"
     delete([/pcvar,rc/])
     copy_VarCoords(ipo_pc_djf,ipo_pc_mam) 
     
     sst_CW = arr_jja
     sst_CW = SqrtCosWeight(arr_jja)
     evecv  = eofunc(sst_CW({lat|llats:llatn},{lon|llonw:llone},time|:),2,75)
     pcts   = eofunc_ts(sst_CW({lat|llats:llatn},{lon|llonw:llone},time|:),evecv,False)
     ipo_pc_jja  = dim_standardize(pcts(0,:),0)
     ipo_jja     = arr_jja(0,:,:)
     ipo_jja     = (/ regCoef(ipo_pc_jja,arr_jja(lat|:,lon|:,time|:)) /)
     delete([/pcts,sst_CW,evecv/])
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(ipo_pc_jja, vreg_jja, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        ipo_vreg_jja  = vreg_jja(0,:,:)
        ipo_prob_jja  = vreg_jja(0,:,:)
        ipo_vreg_jja  = (/ rc /)
        ipo_prob_jja  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        ipo_prob_jja  = where(ismissing(ipo_vreg_jja),ipo_vreg_jja@_FillValue,ipo_prob_jja)
        ipo_vreg_jja@units = vreg_jja@units +"(per std dev)"
        delete([/rc,tval,df,b,vreg_jja/])
     end if
     if (.not.all(ismissing(ipo_jja({llats1:llatn1},{llonw1:llone1})))) then
       if (avg(ipo_jja({llats1:llatn1},{llonw1:llone1})).ge.0) then
           ipo_jja = ipo_jja*-1.
           ipo_pc_jja = ipo_pc_jja*-1.
           if (vxreg_plot_flag.eq.0) then
              ipo_vreg_jja = ipo_vreg_jja*-1.
           end if 
       end if 
     end if
     rc    = arr_jja(0,:,:)
     rc    = (/escorc_n(ipo_pc_jja,arr_jja,0,0)/)
     rc    = rc*rc*100.0
     pcvar = wgt_areaave_Wrap(rc({llats:llatn},{llonw:llone}),coswgt({llats:llatn}),1.0,0)
     ipo_jja@pcvar = tofloat(sprintf("%4.1f", pcvar))+"%"
     delete([/pcvar,rc/])
     copy_VarCoords(ipo_pc_djf,ipo_pc_jja) 
 
     sst_CW = arr_son
     sst_CW = SqrtCosWeight(arr_son)
     evecv  = eofunc(sst_CW({lat|llats:llatn},{lon|llonw:llone},time|:),2,75)
     pcts   = eofunc_ts(sst_CW({lat|llats:llatn},{lon|llonw:llone},time|:),evecv,False)
     ipo_pc_son  = dim_standardize(pcts(0,:),0)
     ipo_son     = arr_son(0,:,:)
     ipo_son     = (/ regCoef(ipo_pc_son,arr_son(lat|:,lon|:,time|:)) /)
     delete([/pcts,sst_CW,evecv/])
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(ipo_pc_son, vreg_son, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        ipo_vreg_son  = vreg_son(0,:,:)
        ipo_prob_son  = vreg_son(0,:,:)
        ipo_vreg_son  = (/ rc /)
        ipo_prob_son  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        ipo_prob_son  = where(ismissing(ipo_vreg_son),ipo_vreg_son@_FillValue,ipo_prob_son)
        ipo_vreg_son@units = vreg_son@units +"(per std dev)"
        delete([/rc,tval,df,b,vreg_son/])
     end if
     if (.not.all(ismissing(ipo_son({llats1:llatn1},{llonw1:llone1})))) then
       if (avg(ipo_son({llats1:llatn1},{llonw1:llone1})).ge.0) then
           ipo_son = ipo_son*-1.
           ipo_pc_son = ipo_pc_son*-1.
           if (vxreg_plot_flag.eq.0) then
              ipo_vreg_son = ipo_vreg_son*-1.
           end if 
       end if 
     end if
     rc    = arr_son(0,:,:)
     rc    = (/escorc_n(ipo_pc_son,arr_son,0,0)/)
     rc    = rc*rc*100.0
     pcvar = wgt_areaave_Wrap(rc({llats:llatn},{llonw:llone}),coswgt({llats:llatn}),1.0,0)
     ipo_son@pcvar = tofloat(sprintf("%4.1f", pcvar))+"%"
     delete([/pcvar,rc/])
     copy_VarCoords(ipo_pc_djf,ipo_pc_son) 

     sst_CW = arr_ann
     sst_CW = SqrtCosWeight(arr_ann)
     evecv  = eofunc(sst_CW({lat|llats:llatn},{lon|llonw:llone},time|:),2,75)
     pcts   = eofunc_ts(sst_CW({lat|llats:llatn},{lon|llonw:llone},time|:),evecv,False)
     ipo_pc_ann  = dim_standardize(pcts(0,:),0)
     ipo_ann     = arr_ann(0,:,:)
     ipo_ann     = (/ regCoef(ipo_pc_ann,arr_ann(lat|:,lon|:,time|:)) /)
     delete([/pcts,sst_CW,evecv/])
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(ipo_pc_ann, vreg_ann, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        ipo_vreg_ann  = vreg_ann(0,:,:)
        ipo_prob_ann  = vreg_ann(0,:,:)
        ipo_vreg_ann  = (/ rc /)
        ipo_prob_ann  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        ipo_prob_ann  = where(ismissing(ipo_vreg_ann),ipo_vreg_ann@_FillValue,ipo_prob_ann)
        ipo_vreg_ann@units = vreg_ann@units +"(per std dev)"
        delete([/rc,tval,df,b,vreg_ann/])
     end if
     if (.not.all(ismissing(ipo_ann({llats1:llatn1},{llonw1:llone1})))) then
       if (avg(ipo_ann({llats1:llatn1},{llonw1:llone1})).ge.0) then
           ipo_ann = ipo_ann*-1.
           ipo_pc_ann = ipo_pc_ann*-1.
           if (vxreg_plot_flag.eq.0) then
              ipo_vreg_ann = ipo_vreg_ann*-1.
           end if 
       end if 
     end if
     rc    = arr_ann(0,:,:)
     rc    = (/escorc_n(ipo_pc_ann,arr_ann,0,0)/)
     rc    = rc*rc*100.0
     pcvar = wgt_areaave_Wrap(rc({llats:llatn},{llonw:llone}),coswgt({llats:llatn}),1.0,0)
     ipo_ann@pcvar = tofloat(sprintf("%4.1f", pcvar))+"%"
     delete([/pcvar,rc/])
     copy_VarCoords(ipo_pc_djf,ipo_pc_ann) 
     
     if (COMPUTE_MODES_MON.eq."True") then     
        sst_CW = arr
        sst_CW = SqrtCosWeight(arr)
        evecv  = eofunc(sst_CW({lat|llats:llatn},{lon|llonw:llone},time|:),2,75)
        pcts   = eofunc_ts(sst_CW({lat|llats:llatn},{lon|llonw:llone},time|:),evecv,False)
        ipo_pc_mon  = dim_standardize(pcts(0,:),0)
        ipo_mon     = arr(0,:,:)
        ipo_mon     = (/ regCoef(ipo_pc_mon,arr(lat|:,lon|:,time|:)) /)
        delete([/pcts,sst_CW,evecv/])
        if (vxreg_plot_flag.eq.0) then
           rc           = regCoef_n(ipo_pc_mon, vreg, 0, 0) ; rc(nlat,mlon)
           tval         = onedtond(rc@tval , dimsizes(rc))
           df           = onedtond(rc@nptxy, dimsizes(rc)) - 2
           b            = tval
           b            = 0.5
           ipo_vreg_mon  = vreg(0,:,:)
           ipo_prob_mon  = vreg(0,:,:)
           ipo_vreg_mon  = (/ rc /)
           ipo_prob_mon  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
           ipo_prob_mon  = where(ismissing(ipo_vreg_mon),ipo_vreg_mon@_FillValue,ipo_prob_mon)
           ipo_vreg_mon@units = vreg@units +"(per std dev)"
           delete([/rc,tval,df,b,vreg/])
        end if
        if (.not.all(ismissing(ipo_mon({llats1:llatn1},{llonw1:llone1})))) then
          if (avg(ipo_mon({llats1:llatn1},{llonw1:llone1})).ge.0) then
              ipo_mon = ipo_mon*-1.
              ipo_pc_mon = ipo_pc_mon*-1.
              if (vxreg_plot_flag.eq.0) then
                 ipo_vreg_mon = ipo_vreg_mon*-1.
              end if
          end if
        end if
        rc    = arr(0,:,:)
        rc    = (/escorc_n(ipo_pc_mon,arr,0,0)/)
        rc    = rc*rc*100.0
        pcvar = wgt_areaave_Wrap(rc({llats:llatn},{llonw:llone}),coswgt({llats:llatn}),1.0,0)
        ipo_mon@pcvar = tofloat(sprintf("%4.1f", pcvar))+"%"
        delete([/pcvar,rc/])
        ipo_pc_mon!0 = "time"
        ipo_pc_mon&time = arr&time   
        delete([/arr/])
     end if
     delete([/arr_djf,arr_mam,arr_jja,arr_son,arr_ann/])

     if (isvar("arr")) then
        delete(arr)
     end if
     if (isvar("vreg")) then
        delete(vreg)
     end if
;------------------------------------------------------------------------------------------------------
     if (vxreg_frame.eq.1.and.vxreg_plot_flag.eq.0) then      ; vxreg_frame = flag to create regressions .ps/.png files 
        vxreg_frame = 0
     end if            
;------------------------------------------------------------------------------------------------------
     if (OUTPUT_DATA.eq."True") then
        if (vxreg_plot_flag.eq.0) then
           modname = str_sub_str(names_reg(ee)," ","_")
           bc = (/"/","'","(",")"/)
           do gg = 0,dimsizes(bc)-1
              modname = str_sub_str(modname,bc(gg),"_")
           end do
           fn = getenv("OUTDIR")+modname+".cvdp_data.sst.ipo."+vnm+"."+syear_reg(ee)+"-"+eyear_reg(ee)+".nc"
           if (.not.isfilepresent2(fn)) then
              z = addfile(fn,"c")
              z@source = "NCAR Climate Analysis Section's Climate Variability Diagnostics Package v"+getenv("VERSION")
              z@notes = "Data from "+names_reg(ee)+" from "+syear_reg(ee)+"-"+eyear_reg(ee)
              if (OPT_CLIMO.eq."Full") then
                 z@climatology = syear_reg(ee)+"-"+eyear_reg(ee)+" climatology removed prior to all calculations (other than means)"
              else
                 if (CLIMO_SYEAR.lt.0) then
                    z@climatology = (eyear_reg(ee)+CLIMO_SYEAR)+"-"+(eyear_reg(ee)+CLIMO_EYEAR)+" climatology removed prior to all calculations (other than means)"
                 else
                    z@climatology = CLIMO_SYEAR+"-"+CLIMO_EYEAR+" climatology removed prior to all calculations (other than means)"
                 end if
              end if
              z@Conventions = "CF-1.6"
           else
              z = addfile(fn,"w")
           end if

           z->ipo_timeseries_djf = set_varAtts(ipo_pc_djf,"IPO normalized principal component timeseries (DJF)","1","")
           z->ipo_timeseries_mam = set_varAtts(ipo_pc_mam,"IPO normalized principal component timeseries (MAM)","1","")
           z->ipo_timeseries_jja = set_varAtts(ipo_pc_jja,"IPO normalized principal component timeseries (JJA)","1","")
           z->ipo_timeseries_son = set_varAtts(ipo_pc_son,"IPO normalized principal component timeseries (SON)","1","")
           z->ipo_timeseries_ann = set_varAtts(ipo_pc_ann,"IPO normalized principal component timeseries (annual)","1","")
           vout = "ipo_"+vnm+"_regression_djf"
           vosr = vnm+" regression onto IPO principal component timeseries (DJF)"
           z->$vout$ = set_varAtts(ipo_vreg_djf,vosr,"","") 
           vout = "ipo_"+vnm+"_regression_mam"
           vosr = vnm+" regression onto IPO principal component timeseries (MAM)"
           z->$vout$ = set_varAtts(ipo_vreg_mam,vosr,"","")  
           vout = "ipo_"+vnm+"_regression_jja"
           vosr = vnm+" regression onto IPO principal component timeseries (JJA)"
           z->$vout$ = set_varAtts(ipo_vreg_jja,vosr,"","")  
           vout = "ipo_"+vnm+"_regression_son"
           vosr = vnm+" regression onto IPO principal component timeseries (SON)"
           z->$vout$ = set_varAtts(ipo_vreg_son,vosr,"","")  
           vout = "ipo_"+vnm+"_regression_ann"
           vosr = vnm+" regression onto IPO principal component timeseries (annual)"
           z->$vout$ = set_varAtts(ipo_vreg_ann,vosr,"","")  

           vout = "ipo_"+vnm+"_regprob_djf"
           vosr = vnm+" IPO regression t-test probility(DJF)"
           z->$vout$ = set_varAtts(ipo_prob_djf,vosr,"","")
           vout = "ipo_"+vnm+"_regprob_mam"
           vosr = vnm+" IPO regression t-test probility(MAM)"
           z->$vout$ = set_varAtts(ipo_prob_mam,vosr,"","")
           vout = "ipo_"+vnm+"_regprob_jja"
           vosr = vnm+" IPO regression t-test probility(JJA)"
           z->$vout$ = set_varAtts(ipo_prob_jja,vosr,"","")
           vout = "ipo_"+vnm+"_regprob_son"
           vosr = vnm+" IPO regression t-test probility(SON)"
           z->$vout$ = set_varAtts(ipo_prob_son,vosr,"","")
           vout = "ipo_"+vnm+"_regprob_ann"
           vosr = vnm+" IPO regression t-test probility(annual)"
           z->$vout$ = set_varAtts(ipo_prob_ann,vosr,"","")

           if (COMPUTE_MODES_MON.eq."True") then   

              z->ipo_timeseries_mon  = set_varAtts(ipo_pc_mon,"IPO principal component timeseries (monthly)","","")

              vout = "ipo_"+vnm+"_regression_mon"
              vosr = vnm+" regression onto IPO principal component timeseries (monthly)"
              z->$vout$ = set_varAtts(ipo_vreg_mon,vosr,"","")

              vout = "ipo_"+vnm+"_regprob_mon"
              vosr = vnm+" IPO regression t-test probility(monthly)"
              z->$vout$ = set_varAtts(ipo_prob_mon,vosr,"","")

           end if
           delete(z)
           delete([/modname,fn/])
        end if
     end if     
     delete([/ipo_pc_djf,ipo_pc_jja,ipo_pc_mam,ipo_pc_son,ipo_pc_ann,ipo_pc_mon/])

;========================================================================
     res = True
     res@mpProjection = "WinkelTripel"
     res@mpGeophysicalLineColor = "gray42"
     res@mpPerimOn    = False
     res@mpGridLatSpacingF =  90            ; change latitude  line spacing
     res@mpGridLonSpacingF = 180.           ; change longitude line spacing
     res@mpGridLineColor   = "transparent"  ; trick ncl into drawing perimeter
     res@mpGridAndLimbOn   = True           ; turn on lat/lon lines

     res@mpCenterLonF = 210.
     res@mpOutlineOn = True
     if (wks_type.eq."png") then
        res@mpGeophysicalLineThicknessF = 2.
     else
        res@mpGeophysicalLineThicknessF = 1.
     end if
     res@gsnDraw      = False
     res@gsnFrame     = False

     res@cnLevelSelectionMode = "ExplicitLevels"
     res@cnLineLabelsOn = False
     res@cnFillOn        = True
     res@cnLinesOn       = False
     res@lbLabelBarOn    = False

     res@gsnLeftStringOrthogonalPosF = -0.05
     res@gsnLeftStringParallelPosF = .005
     res@gsnRightStringOrthogonalPosF = -0.05
     res@gsnRightStringParallelPosF = 0.96
     res@gsnRightString = ""
     res@gsnLeftString = ""
     res@gsnLeftStringFontHeightF = 0.014
     res@gsnCenterStringFontHeightF = 0.018
     res@gsnRightStringFontHeightF = 0.014

     res@cnLevels := (/-0.8,-0.6,-0.4,-0.2,-0.1,0,0.1,0.2,0.4,0.6,0.8/)
     res@cnLevels = res@cnLevels * vrfac
     res@gsnLeftString = syear_reg(ee)+"-"+eyear_reg(ee)
     res@gsnCenterString = names(ee)
 
     res2 = True
     res2@gsnDraw         = False
     res2@gsnFrame        = False
     res2@lbLabelBarOn    = False
     res2@gsnTickMarksOn  = False     ; no tickmarks
     res2@tiMainString    = ""
     res2@gsnLeftString   = ""
     res2@gsnRightString  = ""
     res2@cnLevelSelectionMode = "ExplicitLevels"
     res2@cnLevels          = (/95/) ;-- draw only the 5% contour line
     res2@cnMonoFillPattern = True
     res2@cnMonoFillColor   = True
     res2@cnFillOn          = False      ; color fill
     res2@cnLinesOn         = True
     res2@cnLineThicknessF  = 0.5
     res2@cnLineLabelsOn    = False        ; True is default
     res2@cnInfoLabelOn     = False                ; turn off info label
     res2@gsnAddCyclic      = False

     opt = True
     opt@gsnShadeFillType      = "pattern" ;-- shading is a pattern fill
     opt@gsnShadeHigh          = 17 ;-- pattern type is dots (#17) for all values <= 0.05
     opt@gsnShadeFillScaleF    = 0.75 ;-- density of fill pattern (the lower the denser); default=1.0
     opt@gsnShadeFillDotSizeF  = 0.002
    
     if (isfilepresent2("obs_ts").and.ee.eq.0) then    ; for pattern correlation table. Save entire lat/lon array
        patcor_vreg_ipo_djf = new((/nsim,dimsizes(ipo_vreg_djf&lat),dimsizes(ipo_vreg_djf&lon)/),typeof(ipo_vreg_djf))
        patcor_vreg_ipo_djf!1 = "lat"
        patcor_vreg_ipo_djf&lat = ipo_vreg_djf&lat
        patcor_vreg_ipo_djf!2 = "lon"
        patcor_vreg_ipo_djf&lon = ipo_vreg_djf&lon
        patcor_vreg_ipo_mam = patcor_vreg_ipo_djf
        patcor_vreg_ipo_jja = patcor_vreg_ipo_djf
        patcor_vreg_ipo_son = patcor_vreg_ipo_djf
        patcor_vreg_ipo_ann = patcor_vreg_ipo_djf
        patcor_vreg_ipo_djf(ee,:,:) = (/ ipo_vreg_djf /)
        patcor_vreg_ipo_mam(ee,:,:) = (/ ipo_vreg_mam /)
        patcor_vreg_ipo_jja(ee,:,:) = (/ ipo_vreg_jja /)
        patcor_vreg_ipo_son(ee,:,:) = (/ ipo_vreg_son /)
        patcor_vreg_ipo_ann(ee,:,:) = (/ ipo_vreg_ann /)
        if (COMPUTE_MODES_MON.eq."True") then
          patcor_vreg_ipo_mon = patcor_vreg_ipo_djf
          patcor_vreg_ipo_mon(ee,:,:) = (/ ipo_vreg_mon /)
        end if 
     end if
     if (isfilepresent2("obs_ts").and.ee.ge.1.and.isvar("patcor_vreg_ipo_djf")) then       
        patcor_vreg_ipo_djf(ee,:,:) = (/ totype(linint2(ipo_vreg_djf&lon,ipo_vreg_djf&lat,ipo_vreg_djf,True,patcor_vreg_ipo_djf&lon,patcor_vreg_ipo_djf&lat,0),typeof(patcor_vreg_ipo_djf)) /)
        patcor_vreg_ipo_mam(ee,:,:) = (/ totype(linint2(ipo_vreg_mam&lon,ipo_vreg_mam&lat,ipo_vreg_mam,True,patcor_vreg_ipo_mam&lon,patcor_vreg_ipo_mam&lat,0),typeof(patcor_vreg_ipo_mam)) /)
        patcor_vreg_ipo_jja(ee,:,:) = (/ totype(linint2(ipo_vreg_jja&lon,ipo_vreg_jja&lat,ipo_vreg_jja,True,patcor_vreg_ipo_jja&lon,patcor_vreg_ipo_jja&lat,0),typeof(patcor_vreg_ipo_jja)) /)
        patcor_vreg_ipo_son(ee,:,:) = (/ totype(linint2(ipo_vreg_son&lon,ipo_vreg_son&lat,ipo_vreg_son,True,patcor_vreg_ipo_son&lon,patcor_vreg_ipo_son&lat,0),typeof(patcor_vreg_ipo_son)) /)
        patcor_vreg_ipo_ann(ee,:,:) = (/ totype(linint2(ipo_vreg_ann&lon,ipo_vreg_ann&lat,ipo_vreg_ann,True,patcor_vreg_ipo_ann&lon,patcor_vreg_ipo_ann&lat,0),typeof(patcor_vreg_ipo_ann)) /)
        if (COMPUTE_MODES_MON.eq."True") then
          patcor_vreg_ipo_mon(ee,:,:) = (/ totype(linint2(ipo_vreg_mon&lon,ipo_vreg_mon&lat,ipo_vreg_mon,True,patcor_vreg_ipo_mon&lon,patcor_vreg_ipo_mon&lat,0),typeof(patcor_vreg_ipo_mon)) /)
        end if 
     end if
      
     if (vxreg_plot_flag.eq.0) then
        res@gsnCenterString = names_reg(ee)
        res@gsnRightString = ""
        lbunitstr = ipo_vreg_djf@units
        res@gsnRightString = ipo_djf@pcvar
        reg_ipo_djf(ee) = gsn_csm_contour_map(wks_ipo,ipo_vreg_djf,res)
        res@gsnRightString = ipo_mam@pcvar
        reg_ipo_mam(ee) = gsn_csm_contour_map(wks_ipo,ipo_vreg_mam,res)
        res@gsnRightString = ipo_jja@pcvar
        reg_ipo_jja(ee) = gsn_csm_contour_map(wks_ipo,ipo_vreg_jja,res)
        res@gsnRightString = ipo_son@pcvar
        reg_ipo_son(ee) = gsn_csm_contour_map(wks_ipo,ipo_vreg_son,res)
        res@gsnRightString = ipo_ann@pcvar
        reg_ipo_ann(ee) = gsn_csm_contour_map(wks_ipo,ipo_vreg_ann,res)     
        delete([/ipo_vreg_djf,ipo_vreg_mam,ipo_vreg_jja,ipo_vreg_son,ipo_vreg_ann/])
        o_djf = gsn_csm_contour(wks_ipo,ipo_prob_djf,res2)
        o_djf = gsn_contour_shade(o_djf,-999,95,opt) 
        o_mam = gsn_csm_contour(wks_ipo,ipo_prob_mam,res2)
        o_mam = gsn_contour_shade(o_mam,-999,95,opt) 
        o_jja = gsn_csm_contour(wks_ipo,ipo_prob_jja,res2)
        o_jja = gsn_contour_shade(o_jja,-999,95,opt)
        o_son = gsn_csm_contour(wks_ipo,ipo_prob_son,res2)
        o_son = gsn_contour_shade(o_son,-999,95,opt)
        o_ann = gsn_csm_contour(wks_ipo,ipo_prob_ann,res2)
        o_ann = gsn_contour_shade(o_ann,-999,95,opt)
        delete([/ipo_prob_djf,ipo_prob_mam,ipo_prob_jja,ipo_prob_son,ipo_prob_ann/])
        overlay(reg_ipo_djf(ee),o_djf)
        overlay(reg_ipo_mam(ee),o_mam)
        overlay(reg_ipo_jja(ee),o_jja)
        overlay(reg_ipo_son(ee),o_son)
        overlay(reg_ipo_ann(ee),o_ann)
        delete([/o_djf,o_mam,o_jja,o_son,o_ann/])
        if (COMPUTE_MODES_MON.eq."True") then 
           res@gsnRightString = ipo_mon@pcvar                   
           reg_ipo_mon(ee) = gsn_csm_contour_map(wks_ipo,ipo_vreg_mon,res)
           delete([/ipo_vreg_mon/])
           o_mon = gsn_csm_contour(wks_ipo,ipo_prob_mon,res2)
           o_mon = gsn_contour_shade(o_mon,-999,95,opt)
           overlay(reg_ipo_mon(ee),o_mon)
           delete([/o_mon,ipo_prob_mon/])
        end if
     
     end if

     delete(vxreg_plot_flag)  
  end do
  
  if (isvar("clim_syear")) then
     delete(clim_syear)
  end if
  if (isvar("clim_eyear")) then
     delete(clim_eyear)
  end if

  if (isvar("patcor_vreg_ipo_djf")) then    ; for pattern correlation table
    mods = (/"ipo"/)
    if (COMPUTE_MODES_MON.eq."True") then
      seas = (/"djf","mam","jja","son","ann","mon"/)
    else
      seas = (/"djf","mam","jja","son","ann"/)
    end if
    do kk = 0,dimsizes(seas)-1
     do ll = 0,dimsizes(mods)-1
      vreg_nam  = "patcor_vreg_"+mods(ll)+"_"+seas(kk)
      if(vreg_nam.eq."patcor_vreg_ipo_djf") then
        patcor_vreg = patcor_vreg_ipo_djf
      end if
      if(vreg_nam.eq."patcor_vreg_ipo_mam") then
        patcor_vreg = patcor_vreg_ipo_mam
      end if
      if(vreg_nam.eq."patcor_vreg_ipo_jja") then
        patcor_vreg = patcor_vreg_ipo_jja
      end if
      if(vreg_nam.eq."patcor_vreg_ipo_son") then
        patcor_vreg = patcor_vreg_ipo_son
      end if
      if(vreg_nam.eq."patcor_vreg_ipo_ann") then
        patcor_vreg = patcor_vreg_ipo_ann
      end if
      if(vreg_nam.eq."patcor_vreg_ipo_mon") then
        patcor_vreg = patcor_vreg_ipo_mon
      end if
      clat = cos(0.01745329*patcor_vreg&lat)
      clat!0 = "lat"
      clat&lat = patcor_vreg&lat
      line3  = "                  "    ; Must be 18 characters long
      line4  = line3
      header = (/"","Pattern Correlations   Observations vs. Model(s)",""/)
      finpr  = str_upper(mods(ll))+" ("+str_upper(seas(kk))+")         "
      do hh = 1,nsim-1
         dimY = dimsizes(tochar(names(hh)))
         nchar = dimY
         nchar = where(nchar.le.10,10,nchar)
         if (dimY.lt.10) then
            ntb = ""
            do ii = 0,10-dimY-1
               ntb = ntb+" "
            end do
            ntb = ntb+names(hh)
         else
            ntb = names(hh)
         end if

         ntc = ""
         do ii = 0,nchar-1
            ntc = ntc+"-"
         end do
         format2 = "%"+(nchar-5+1)+".2f"
         format3 = "%4.2f"
         line3 = line3+" "+ntb
         line4 = line4+" "+ntc
         if (all(ismissing(patcor_vreg_ipo_djf(hh,:,:)))) then
            finpr = finpr+sprintf(format2,9.99)+"/"+sprintf(format3,9.99)
         else
            finpr = finpr+sprintf(format2,(pattern_cor(patcor_vreg(0,:,:),patcor_vreg(hh,:,:),clat(:),0)))+"/"+sprintf(format3,(wgt_arearmse(patcor_vreg(0,:,:),patcor_vreg(hh,:,:),clat(:),1.0,0)))
         end if
      end do
;
     if (dimsizes(tochar(line4)).ge.8190) then   ; system or fortran compiler limit
        print("Metrics table warning: Not creating regpatt_metrics.table as size of comparison results in a invalid ascii row size.")
     else
        if(kk.eq.0.and.ll.eq.0) then
          write_table(getenv("OUTDIR")+"regpatt_metrics.sst.ipo_"+vnm+".txt","w",[/header/],"%s")
          write_table(getenv("OUTDIR")+"regpatt_metrics.sst.ipo_"+vnm+".txt","a",[/line3/],"%s")
          write_table(getenv("OUTDIR")+"regpatt_metrics.sst.ipo_"+vnm+".txt","a",[/line4/],"%s")
          write_table(getenv("OUTDIR")+"regpatt_metrics.sst.ipo_"+vnm+".txt","a",[/finpr/],"%s")
        else
          write_table(getenv("OUTDIR")+"regpatt_metrics.sst.ipo_"+vnm+".txt","a",[/finpr/],"%s")
        end if
     end if
     delete([/line3,line4,format2,format3,nchar,ntc,clat,dimY,ntb,header/])
     end do
    end do
    delete([/mods,seas/])
    delete([/patcor_vreg_ipo_djf,patcor_vreg_ipo_mam,patcor_vreg_ipo_jja,patcor_vreg_ipo_son,patcor_vreg_ipo_ann/])
    if (COMPUTE_MODES_MON.eq."True") then
      delete([/patcor_vreg_ipo_mon/])
    end if
  end if 
 
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
  if (nsim.le.4) then
     if (nsim.eq.1) then
        panres@txFontHeightF = 0.022
        panres@gsnPanelBottom = 0.50
        panres@lbLabelFontHeightF = 0.018
        panres@lbTitleFontHeightF = 0.018
     else
        panres@txFontHeightF = 0.0145
        panres@gsnPanelBottom = 0.50
        panres@lbLabelFontHeightF = 0.012
        panres@lbTitleFontHeightF = 0.012
     end if
  else
     panres@txFontHeightF = 0.016
     panres@gsnPanelBottom = 0.05
     panres@lbLabelFontHeightF = 0.012
     panres@lbTitleFontHeightF = 0.012
  end if
  if (nsim.le.3) then
    ncol = nsim
    nrow = 1
  else if (nsim.le.6) then
    nrow = 2
    ncol = 3
  else
    ncol = floattointeger(sqrt(nsim))
    nrow = (nsim/ncol)+mod(nsim,ncol)
  end if
  end if
  
  if (vxreg_frame.eq.0) then
     txt0 = str_upper(vnm)
     panres@lbTitleString = txt0 + " [" + lbunitstr +"]"  
     panres@txString = "IPO Regressions (DJF)" 
     gsn_panel2(wks_ipo,reg_ipo_djf,(/nrow,ncol/),panres)
     delete(reg_ipo_djf)
     panres@txString = "IPO Regressions (MAM)"
     gsn_panel2(wks_ipo,reg_ipo_mam,(/nrow,ncol/),panres)
     delete(reg_ipo_mam)
     panres@txString = "IPO Regressions (JJA)"
     gsn_panel2(wks_ipo,reg_ipo_jja,(/nrow,ncol/),panres)
     delete(reg_ipo_jja)
     panres@txString = "IPO Regressions (SON)"
     gsn_panel2(wks_ipo,reg_ipo_son,(/nrow,ncol/),panres)
     delete(reg_ipo_son)
     panres@txString = "IPO Regressions (Annual)"
     gsn_panel2(wks_ipo,reg_ipo_ann,(/nrow,ncol/),panres)
     delete(reg_ipo_ann)
     if (COMPUTE_MODES_MON.eq."True") then    
        panres@txString = "IPO Regressions (Monthly)"
        gsn_panel2(wks_ipo,reg_ipo_mon,(/nrow,ncol/),panres)
        delete(reg_ipo_mon)
     end if
     delete(wks_ipo)
  end if
  
;--------------------------------------------------------------------------------------------------
  OUTDIR = getenv("OUTDIR") 
  if (wks_type.eq."png") then       
     if (vxreg_frame.eq.0) then
        system("mv "+OUTDIR+"ipo.vxreg.000001.png "+OUTDIR+"ipo."+vnm+"reg.djf.png")
        system("mv "+OUTDIR+"ipo.vxreg.000002.png "+OUTDIR+"ipo."+vnm+"reg.mam.png")
        system("mv "+OUTDIR+"ipo.vxreg.000003.png "+OUTDIR+"ipo."+vnm+"reg.jja.png")
        system("mv "+OUTDIR+"ipo.vxreg.000004.png "+OUTDIR+"ipo."+vnm+"reg.son.png")
        system("mv "+OUTDIR+"ipo.vxreg.000005.png "+OUTDIR+"ipo."+vnm+"reg.ann.png")
        if (COMPUTE_MODES_MON.eq."True") then
          system("mv "+OUTDIR+"ipo.vxreg.000006.png "+OUTDIR+"ipo."+vnm+"reg.mon.png")   
        end if 
     end if

  else     
     system("psplit "+OUTDIR+"ipo.vxreg.ps "+OUTDIR+"vx_sp")
     if (vxreg_frame.eq.0) then
        system("mv "+OUTDIR+"vx_sp0001.ps "+OUTDIR+"ipo."+vnm+"reg.djf.ps") 
        system("mv "+OUTDIR+"vx_sp0002.ps "+OUTDIR+"ipo."+vnm+"reg.mam.ps") 
        system("mv "+OUTDIR+"vx_sp0003.ps "+OUTDIR+"ipo."+vnm+"reg.jja.ps") 
        system("mv "+OUTDIR+"vx_sp0004.ps "+OUTDIR+"ipo."+vnm+"reg.son.ps") 
        system("mv "+OUTDIR+"vx_sp0005.ps "+OUTDIR+"ipo."+vnm+"reg.ann.ps")
        if (COMPUTE_MODES_MON.eq."True") then
           system("mv "+OUTDIR+"vx_sp0006.ps "+OUTDIR+"ipo."+vnm+"reg.mon.ps") 
        end if
     end if

  end if

  delete([/vnm,lmsk,nsim_reg,names_reg,paths_reg,syear_reg,syear_reg,eyear_reg,nyr_reg,vrfac/])
 end do 
    
 print("Finished: sst.ipo_regpatt.ncl")

end  
