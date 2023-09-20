; Calculates tforce indices as well as tforce index 
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
  print("Starting: Amundsen_thermal_forcing_regpatt.ncl")
  
  SCALE_TIMESERIES = getenv("SCALE_TIMESERIES")  
  OUTPUT_DATA      = getenv("OUTPUT_DATA")  
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OPT_CLIMO        = getenv("OPT_CLIMO")
  CLIMO_SYEAR      = toint(getenv("CLIMO_SYEAR"))
  CLIMO_EYEAR      = toint(getenv("CLIMO_EYEAR"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
  COMPUTE_MODES_MON = getenv("COMPUTE_MODES_MON")
  COLORMAP         = getenv("COLORMAP")  
 
  region      = "Amundsen_Sea"
  regind      = 0
  llats       = -80.    ; Amundsen Sea
  llatn       = -60.
  llonw       = 170.
  llone       = 298.
 
  nsim = numAsciiRow("namelist_byvar/namelist_tforce")
  na = asciiread("namelist_byvar/namelist_tforce",(/nsim/),"string")
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
 varfacs = (/1.0,  0.5,     0.5,    0.5,  1.0,  1.0,   1.0,   1.0,   1.0, 1.0,  1.0, \
             1.0,  1.0,     1.0,  1.0,    1.0,  0.5,   1.0,   1.0,   1.0, 1.0, 1.0/)
  
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
  
  wks_tforce  = gsn_open_wks(wks_type,getenv("OUTDIR")+"tforce1.vxreg")
  
  if (COLORMAP.eq.0) then
     gsn_define_colormap(wks_tforce,"MPL_RdBu")  
     gsn_reverse_colormap(wks_tforce)           ; Reverse the color map.
  end if
  if (COLORMAP.eq.1) then
     gsn_define_colormap(wks_tforce,"NCV_jaisnd")  
  end if
  
  reg_tforce_djf = new(nsim,"graphic")  
  reg_tforce_mam = new(nsim,"graphic")  
  reg_tforce_jja = new(nsim,"graphic")  
  reg_tforce_son = new(nsim,"graphic")  
  reg_tforce_ann = new(nsim,"graphic")  
  reg_tforce_mon = new(nsim,"graphic")  
  
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
      zpath = paths(ee)
      c = addfile(zpath,"r")
      if (isfilevar(c,"TFORCE")) then
        farr   = tofloat(c->TFORCE(regind,:))
        farr!0 = "time"
        cpath  = stringtochar(zpath)
        nchar  = dimsizes(cpath)
        sydata = stringtointeger(charactertostring(cpath(nchar-17:nchar-14)))
        smdata = stringtointeger(charactertostring(cpath(nchar-13:nchar-12)))
        eydata = stringtointeger(charactertostring(cpath(nchar-10:nchar-7)))
        emdata = stringtointeger(charactertostring(cpath(nchar-6:nchar-5)))
        delete([/cpath,nchar/])
        timeT  = yyyymm_time(sydata, eydata, "integer")
        time   = timeT({sydata*100+smdata:eydata*100+emdata})
        farr&time = time 
        delete([/timeT,time,sydata,eydata,emdata,smdata/])
        arr = farr({time|syear(ee)*100+1:eyear(ee)*100+12})
      else
        arr@is_all_missing = True 
      end if
      if (isatt(arr,"is_all_missing")) then
        delete(arr)
        continue
      end if 

      arrT =  runave_n_Wrap(arr,3,0,0)               ; form DJF averages
      arrT(0) = (/ dim_avg_n(arr(:1),0) /)   
      arr_djf = arrT(0::12)
      arr_mam = arrT(3::12)
      arr_jja = arrT(6::12)                       ; form JJA averages
      arr_son = arrT(9::12)
      delete(arrT)
     
      arrV = runave_n_Wrap(arr,12,0,0)
      arr_ann = arrV(5::12)
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
     ; print("Data to be read in: "+paths_reg(ee)+" from "+syear_reg(ee)+":"+eyear_reg(ee))
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
       if(vnm.eq."trefht".and.lmsk.eq.1) then
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
   
;----------tforce definition----------------------------------------------------------------------
     coswgt      = cos(rad*vreg&lat)
     coswgt!0    = "lat"
     coswgt&lat  = vreg&lat

;----------tforce calculations----------------------------------------------------------------------
     tforce_pc_djf = dim_standardize(arr_djf,0)
     tforce_djf    = arr_djf
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(tforce_pc_djf, vreg_djf, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval    
        b         = 0.5
        tforce_vreg_djf  = vreg_djf(0,:,:)
        tforce_prob_djf  = vreg_djf(0,:,:)
        tforce_vreg_djf  = (/ rc /) 
        tforce_prob_djf  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/)
        tforce_prob_djf  = where(ismissing(tforce_vreg_djf),tforce_vreg_djf@_FillValue,tforce_prob_djf)
        tforce_vreg_djf@units = vreg_djf@units +" (per std dev)"
        delete(rc)
        rc    = tforce_vreg_djf
        rc    = (/escorc_n(tforce_pc_djf,vreg_djf,0,0)/)
        rc    = rc*rc*100.0
        pcvar = wgt_areaave_Wrap(rc({llats:llatn},{llonw:llone}),coswgt({llats:llatn}),1.0,0)
        tforce_djf@pcvar = tofloat(sprintf("%4.1f", pcvar))+"%"
        delete([/rc,tval,df,b,vreg_djf,pcvar/]) 
     end if     
     tforce_pc_djf!0 = "TIME"
     tforce_pc_djf&TIME = ispan(syear_reg(ee),eyear_reg(ee),1)
     tforce_pc_djf&TIME@units = "YYYY"
     tforce_pc_djf&TIME@long_name = "time"     
 
     tforce_pc_mam = dim_standardize(arr_mam,0)
     tforce_mam    = arr_mam
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(tforce_pc_mam, vreg_mam, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        tforce_vreg_mam  = vreg_mam(0,:,:)
        tforce_prob_mam  = vreg_mam(0,:,:)
        tforce_vreg_mam  = (/ rc /)
        tforce_prob_mam  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        tforce_prob_mam  = where(ismissing(tforce_vreg_mam),tforce_vreg_mam@_FillValue,tforce_prob_mam)
        tforce_vreg_mam@units = vreg_mam@units +"(per std dev)"
        delete(rc)
        rc    = tforce_vreg_mam
        rc    = (/escorc_n(tforce_pc_mam,vreg_mam,0,0)/)
        rc    = rc*rc*100.0
        pcvar = wgt_areaave_Wrap(rc({llats:llatn},{llonw:llone}),coswgt({llats:llatn}),1.0,0)
        tforce_mam@pcvar = tofloat(sprintf("%4.1f", pcvar))+"%"
        delete([/rc,tval,df,b,vreg_mam,pcvar/])
     end if
     copy_VarCoords(tforce_pc_djf,tforce_pc_mam) 
     
     tforce_pc_jja = dim_standardize(arr_jja,0)
     tforce_jja = arr_jja
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(tforce_pc_jja, vreg_jja, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        tforce_vreg_jja  = vreg_jja(0,:,:)
        tforce_prob_jja  = vreg_jja(0,:,:)
        tforce_vreg_jja  = (/ rc /)
        tforce_prob_jja  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        tforce_prob_jja  = where(ismissing(tforce_vreg_jja),tforce_vreg_jja@_FillValue,tforce_prob_jja)
        tforce_vreg_jja@units = vreg_jja@units +"(per std dev)"
        delete(rc)
        rc    = tforce_vreg_jja
        rc    = (/escorc_n(tforce_pc_jja,vreg_jja,0,0)/)
        rc    = rc*rc*100.0
        pcvar = wgt_areaave_Wrap(rc({llats:llatn},{llonw:llone}),coswgt({llats:llatn}),1.0,0)
        tforce_jja@pcvar = tofloat(sprintf("%4.1f", pcvar))+"%"
        delete([/rc,tval,df,b,vreg_jja,pcvar/])
     end if
     copy_VarCoords(tforce_pc_djf,tforce_pc_jja) 
 
     tforce_pc_son = dim_standardize(arr_son,0)
     tforce_son = arr_son
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(tforce_pc_son, vreg_son, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        tforce_vreg_son  = vreg_son(0,:,:)
        tforce_prob_son  = vreg_son(0,:,:)
        tforce_vreg_son  = (/ rc /)
        tforce_prob_son  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        tforce_prob_son  = where(ismissing(tforce_vreg_son),tforce_vreg_son@_FillValue,tforce_prob_son)
        tforce_vreg_son@units = vreg_son@units +"(per std dev)"
        delete(rc)
        rc    = tforce_vreg_son
        rc    = (/escorc_n(tforce_pc_son,vreg_son,0,0)/)
        rc    = rc*rc*100.0
        pcvar = wgt_areaave_Wrap(rc({llats:llatn},{llonw:llone}),coswgt({llats:llatn}),1.0,0)
        tforce_son@pcvar = tofloat(sprintf("%4.1f", pcvar))+"%"
        delete([/rc,tval,df,b,vreg_son,pcvar/])
     end if
     copy_VarCoords(tforce_pc_djf,tforce_pc_son) 

     tforce_pc_ann = dim_standardize(arr_ann,0)
     tforce_ann = arr_ann
     if (vxreg_plot_flag.eq.0) then
        rc        = regCoef_n(tforce_pc_ann, vreg_ann, 0, 0) ; rc(nlat,mlon)
        tval      = onedtond(rc@tval , dimsizes(rc))
        df        = onedtond(rc@nptxy, dimsizes(rc)) - 2
        b         = tval
        b         = 0.5
        tforce_vreg_ann  = vreg_ann(0,:,:)
        tforce_prob_ann  = vreg_ann(0,:,:)
        tforce_vreg_ann  = (/ rc /)
        tforce_prob_ann  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
        tforce_prob_ann  = where(ismissing(tforce_vreg_ann),tforce_vreg_ann@_FillValue,tforce_prob_ann)
        tforce_vreg_ann@units = vreg_ann@units +"(per std dev)"
        delete(rc)
        rc    = tforce_vreg_ann
        rc    = (/escorc_n(tforce_pc_ann,vreg_ann,0,0)/)
        rc    = rc*rc*100.0
        pcvar = wgt_areaave_Wrap(rc({llats:llatn},{llonw:llone}),coswgt({llats:llatn}),1.0,0)
        tforce_ann@pcvar = tofloat(sprintf("%4.1f", pcvar))+"%"
        delete([/rc,tval,df,b,vreg_ann,pcvar/])
     end if
     copy_VarCoords(tforce_pc_djf,tforce_pc_ann) 
     
     if (COMPUTE_MODES_MON.eq."True") then     
        tforce_pc_mon = dim_standardize(arr,0)
        tforce_mon = arr
        if (vxreg_plot_flag.eq.0) then
           rc           = regCoef_n(tforce_pc_mon, vreg, 0, 0) ; rc(nlat,mlon)
           tval         = onedtond(rc@tval , dimsizes(rc))
           df           = onedtond(rc@nptxy, dimsizes(rc)) - 2
           b            = tval
           b            = 0.5
           tforce_vreg_mon  = vreg(0,:,:)
           tforce_prob_mon  = vreg(0,:,:)
           tforce_vreg_mon  = (/ rc /)
           tforce_prob_mon  = (/(1-betainc(df/(df+tval^2),df/2.0,b))*100.0/) 
           tforce_prob_mon  = where(ismissing(tforce_vreg_mon),tforce_vreg_mon@_FillValue,tforce_prob_mon)
           tforce_vreg_mon@units = vreg@units +"(per std dev)"
           delete(rc)
           rc    = tforce_vreg_mon
           rc    = (/escorc_n(tforce_pc_mon,vreg,0,0)/)
           rc    = rc*rc*100.0
           pcvar = wgt_areaave_Wrap(rc({llats:llatn},{llonw:llone}),coswgt({llats:llatn}),1.0,0)
           tforce_mon@pcvar = tofloat(sprintf("%4.1f", pcvar))+"%"
           delete([/rc,tval,df,b,vreg,pcvar/])
        end if
        tforce_pc_mon!0 = "time"
        tforce_pc_mon&time = arr&time   
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
           fn = getenv("OUTDIR")+modname+".cvdp_data.thermal_forcing."+vnm+"."+syear_reg(ee)+"-"+eyear_reg(ee)+".nc"
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

           z->tforce_timeseries_djf = set_varAtts(tforce_pc_djf,"ENSO (Nino34) normalized mean timeseries (DJF)","1","")
           z->tforce_timeseries_mam = set_varAtts(tforce_pc_mam,"ENSO (Nino34) normalized mean timeseries (MAM)","1","")
           z->tforce_timeseries_jja = set_varAtts(tforce_pc_jja,"ENSO (Nino34) normalized mean timeseries (JJA)","1","")
           z->tforce_timeseries_son = set_varAtts(tforce_pc_son,"ENSO (Nino34) normalized mean timeseries (SON)","1","")
           z->tforce_timeseries_ann = set_varAtts(tforce_pc_ann,"ENSO (Nino34) normalized mean timeseries (annual)","1","")
           vout = "tforce_"+vnm+"_regression_djf"
           vosr = vnm+" regression onto thermal forcing mean timeseries (DJF)"
           z->$vout$ = set_varAtts(tforce_vreg_djf,vosr,"","") 
           vout = "tforce_"+vnm+"_regression_mam"
           vosr = vnm+" regression onto thermal forcing mean timeseries (MAM)"
           z->$vout$ = set_varAtts(tforce_vreg_mam,vosr,"","")  
           vout = "tforce_"+vnm+"_regression_jja"
           vosr = vnm+" regression onto thermal forcing mean timeseries (JJA)"
           z->$vout$ = set_varAtts(tforce_vreg_jja,vosr,"","")  
           vout = "tforce_"+vnm+"_regression_son"
           vosr = vnm+" regression onto thermal forcing mean timeseries (SON)"
           z->$vout$ = set_varAtts(tforce_vreg_son,vosr,"","")  
           vout = "tforce_"+vnm+"_regression_ann"
           vosr = vnm+" regression onto thermal forcing mean timeseries (annual)"
           z->$vout$ = set_varAtts(tforce_vreg_ann,vosr,"","")  

           vout = "tforce_"+vnm+"_regprob_djf"
           vosr = vnm+" ENSO (Nino34) regression t-test probility(DJF)"
           z->$vout$ = set_varAtts(tforce_prob_djf,vosr,"","")
           vout = "tforce_"+vnm+"_regprob_mam"
           vosr = vnm+" ENSO (Nino34) regression t-test probility(MAM)"
           z->$vout$ = set_varAtts(tforce_prob_mam,vosr,"","")
           vout = "tforce_"+vnm+"_regprob_jja"
           vosr = vnm+" ENSO (Nino34) regression t-test probility(JJA)"
           z->$vout$ = set_varAtts(tforce_prob_jja,vosr,"","")
           vout = "tforce_"+vnm+"_regprob_son"
           vosr = vnm+" ENSO (Nino34) regression t-test probility(SON)"
           z->$vout$ = set_varAtts(tforce_prob_son,vosr,"","")
           vout = "tforce_"+vnm+"_regprob_ann"
           vosr = vnm+" ENSO (Nino34) regression t-test probility(annual)"
           z->$vout$ = set_varAtts(tforce_prob_ann,vosr,"","")

           if (COMPUTE_MODES_MON.eq."True") then   

              z->tforce_timeseries_mon  = set_varAtts(tforce_pc_mon,"ENSO (Nino34) mean timeseries (monthly)","","")

              vout = "tforce_"+vnm+"_regression_mon"
              vosr = vnm+" regression onto thermal forcing mean timeseries (monthly)"
              z->$vout$ = set_varAtts(tforce_vreg_mon,vosr,"","")

              vout = "tforce_"+vnm+"_regprob_mon"
              vosr = vnm+" ENSO (Nino34) regression t-test probility(monthly)"
              z->$vout$ = set_varAtts(tforce_prob_mon,vosr,"","")

           end if
           delete(z)
           delete([/modname,fn/])
        end if
     end if     
     delete([/tforce_pc_djf,tforce_pc_jja,tforce_pc_mam,tforce_pc_son,tforce_pc_ann,tforce_pc_mon/])

;========================================================================
     res = True
     res@mpProjection = "WinkelTripel"
     res@mpGeophysicalLineColor = "gray42"
     res@mpPerimOn    = False
     res@mpGridLatSpacingF =  90            ; change latitude  line spacing
     res@mpGridLonSpacingF = 180.           ; change longitude line spacing
     res@mpGridLineColor   = "transparent"  ; trick ncl into drawing perimeter
     res@mpGridAndLimbOn   = True           ; turn on lat/lon lines

     res@mpCenterLonF = 270.
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

    ;res@cnLevels := (/-0.8,-0.6,-0.4,-0.2,-0.1,0,0.1,0.2,0.4,0.6,0.8/)
     res@cnLevels := fspan(-0.4,0.4,21)
     res@cnLevels  = res@cnLevels * vrfac
     res@gsnLeftString = syear_reg(ee)+"-"+eyear_reg(ee)
     res@gsnCenterString = names(ee)
     res@lbBoxLinesOn    = True 
     res@lbBoxLineThicknessF   = 2.0
     if(dimsizes(res@cnLevels).ge.10) then
       res@lbBoxSeparatorLinesOn = False
     else
       res@lbBoxSeparatorLinesOn = True
     end if

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
     opt@gsnShadeFillScaleF    = 0.5 ;-- density of fill pattern (the lower the denser); default=1.0
     opt@gsnShadeFillDotSizeF  = 0.0015
    
     if (isfilepresent2("obs_ts").and.ee.eq.0) then    ; for pattern correlation table. Save entire lat/lon array
        patcor_vreg_tforce_djf = new((/nsim,dimsizes(tforce_vreg_djf&lat),dimsizes(tforce_vreg_djf&lon)/),typeof(tforce_vreg_djf))
        patcor_vreg_tforce_djf!1 = "lat"
        patcor_vreg_tforce_djf&lat = tforce_vreg_djf&lat
        patcor_vreg_tforce_djf!2 = "lon"
        patcor_vreg_tforce_djf&lon = tforce_vreg_djf&lon
        patcor_vreg_tforce_mam = patcor_vreg_tforce_djf
        patcor_vreg_tforce_jja = patcor_vreg_tforce_djf
        patcor_vreg_tforce_son = patcor_vreg_tforce_djf
        patcor_vreg_tforce_ann = patcor_vreg_tforce_djf
        patcor_vreg_tforce_djf(ee,:,:) = (/ tforce_vreg_djf /)
        patcor_vreg_tforce_mam(ee,:,:) = (/ tforce_vreg_mam /)
        patcor_vreg_tforce_jja(ee,:,:) = (/ tforce_vreg_jja /)
        patcor_vreg_tforce_son(ee,:,:) = (/ tforce_vreg_son /)
        patcor_vreg_tforce_ann(ee,:,:) = (/ tforce_vreg_ann /)
        if (COMPUTE_MODES_MON.eq."True") then
          patcor_vreg_tforce_mon = patcor_vreg_tforce_djf
          patcor_vreg_tforce_mon(ee,:,:) = (/ tforce_vreg_mon /)
        end if 
     end if
     if (isfilepresent2("obs_ts").and.ee.ge.1.and.isvar("patcor_vreg_tforce_djf")) then       
        patcor_vreg_tforce_djf(ee,:,:) = (/ totype(linint2(tforce_vreg_djf&lon,tforce_vreg_djf&lat,tforce_vreg_djf,True,patcor_vreg_tforce_djf&lon,patcor_vreg_tforce_djf&lat,0),typeof(patcor_vreg_tforce_djf)) /)
        patcor_vreg_tforce_mam(ee,:,:) = (/ totype(linint2(tforce_vreg_mam&lon,tforce_vreg_mam&lat,tforce_vreg_mam,True,patcor_vreg_tforce_mam&lon,patcor_vreg_tforce_mam&lat,0),typeof(patcor_vreg_tforce_mam)) /)
        patcor_vreg_tforce_jja(ee,:,:) = (/ totype(linint2(tforce_vreg_jja&lon,tforce_vreg_jja&lat,tforce_vreg_jja,True,patcor_vreg_tforce_jja&lon,patcor_vreg_tforce_jja&lat,0),typeof(patcor_vreg_tforce_jja)) /)
        patcor_vreg_tforce_son(ee,:,:) = (/ totype(linint2(tforce_vreg_son&lon,tforce_vreg_son&lat,tforce_vreg_son,True,patcor_vreg_tforce_son&lon,patcor_vreg_tforce_son&lat,0),typeof(patcor_vreg_tforce_son)) /)
        patcor_vreg_tforce_ann(ee,:,:) = (/ totype(linint2(tforce_vreg_ann&lon,tforce_vreg_ann&lat,tforce_vreg_ann,True,patcor_vreg_tforce_ann&lon,patcor_vreg_tforce_ann&lat,0),typeof(patcor_vreg_tforce_ann)) /)
        if (COMPUTE_MODES_MON.eq."True") then
          patcor_vreg_tforce_mon(ee,:,:) = (/ totype(linint2(tforce_vreg_mon&lon,tforce_vreg_mon&lat,tforce_vreg_mon,True,patcor_vreg_tforce_mon&lon,patcor_vreg_tforce_mon&lat,0),typeof(patcor_vreg_tforce_mon)) /)
        end if 
     end if
      
     if (vxreg_plot_flag.eq.0) then
        res@gsnCenterString = names_reg(ee)
        res@gsnRightString = ""
        lbunitstr = tforce_vreg_djf@units
        res@gsnRightString = tforce_djf@pcvar
        reg_tforce_djf(ee) = gsn_csm_contour_map(wks_tforce,tforce_vreg_djf,res)
        res@gsnRightString = tforce_mam@pcvar
        reg_tforce_mam(ee) = gsn_csm_contour_map(wks_tforce,tforce_vreg_mam,res)
        res@gsnRightString = tforce_jja@pcvar
        reg_tforce_jja(ee) = gsn_csm_contour_map(wks_tforce,tforce_vreg_jja,res)
        res@gsnRightString = tforce_son@pcvar
        reg_tforce_son(ee) = gsn_csm_contour_map(wks_tforce,tforce_vreg_son,res)
        res@gsnRightString = tforce_ann@pcvar
        reg_tforce_ann(ee) = gsn_csm_contour_map(wks_tforce,tforce_vreg_ann,res)     
        delete([/tforce_vreg_djf,tforce_vreg_mam,tforce_vreg_jja,tforce_vreg_son,tforce_vreg_ann/])
        o_djf = gsn_csm_contour(wks_tforce,tforce_prob_djf,res2)
        o_djf = gsn_contour_shade(o_djf,-999,95,opt) 
        o_mam = gsn_csm_contour(wks_tforce,tforce_prob_mam,res2)
        o_mam = gsn_contour_shade(o_mam,-999,95,opt) 
        o_jja = gsn_csm_contour(wks_tforce,tforce_prob_jja,res2)
        o_jja = gsn_contour_shade(o_jja,-999,95,opt)
        o_son = gsn_csm_contour(wks_tforce,tforce_prob_son,res2)
        o_son = gsn_contour_shade(o_son,-999,95,opt)
        o_ann = gsn_csm_contour(wks_tforce,tforce_prob_ann,res2)
        o_ann = gsn_contour_shade(o_ann,-999,95,opt)
        delete([/tforce_prob_djf,tforce_prob_mam,tforce_prob_jja,tforce_prob_son,tforce_prob_ann/])
        overlay(reg_tforce_djf(ee),o_djf)
        overlay(reg_tforce_mam(ee),o_mam)
        overlay(reg_tforce_jja(ee),o_jja)
        overlay(reg_tforce_son(ee),o_son)
        overlay(reg_tforce_ann(ee),o_ann)
        delete([/o_djf,o_mam,o_jja,o_son,o_ann/])
        if (COMPUTE_MODES_MON.eq."True") then 
           res@gsnRightString = tforce_mon@pcvar                   
           reg_tforce_mon(ee) = gsn_csm_contour_map(wks_tforce,tforce_vreg_mon,res)
           delete([/tforce_vreg_mon/])
           o_mon = gsn_csm_contour(wks_tforce,tforce_prob_mon,res2)
           o_mon = gsn_contour_shade(o_mon,-999,95,opt)
           overlay(reg_tforce_mon(ee),o_mon)
           delete([/o_mon,tforce_prob_mon/])
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

  if (isvar("patcor_vreg_tforce_djf")) then    ; for pattern correlation table
    mods = (/"tforce"/)
    if (COMPUTE_MODES_MON.eq."True") then
      seas = (/"djf","mam","jja","son","ann","mon"/)
    else
      seas = (/"djf","mam","jja","son","ann"/)
    end if
    do kk = 0,dimsizes(seas)-1
     do ll = 0,dimsizes(mods)-1
      vreg_nam  = "patcor_vreg_"+mods(ll)+"_"+seas(kk)
      if(vreg_nam.eq."patcor_vreg_tforce_djf") then
        patcor_vreg = patcor_vreg_tforce_djf
      end if
      if(vreg_nam.eq."patcor_vreg_tforce_mam") then
        patcor_vreg = patcor_vreg_tforce_mam
      end if
      if(vreg_nam.eq."patcor_vreg_tforce_jja") then
        patcor_vreg = patcor_vreg_tforce_jja
      end if
      if(vreg_nam.eq."patcor_vreg_tforce_son") then
        patcor_vreg = patcor_vreg_tforce_son
      end if
      if(vreg_nam.eq."patcor_vreg_tforce_ann") then
        patcor_vreg = patcor_vreg_tforce_ann
      end if
      if(vreg_nam.eq."patcor_vreg_tforce_mon") then
        patcor_vreg = patcor_vreg_tforce_mon
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
         if (all(ismissing(patcor_vreg_tforce_djf(hh,:,:)))) then
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
          write_table(getenv("OUTDIR")+"regpatt_metrics.thermal_forcing_"+region+"."+vnm+".txt","w",[/header/],"%s")
          write_table(getenv("OUTDIR")+"regpatt_metrics.thermal_forcing_"+region+"."+vnm+".txt","a",[/line3/],"%s")
          write_table(getenv("OUTDIR")+"regpatt_metrics.thermal_forcing_"+region+"."+vnm+".txt","a",[/line4/],"%s")
          write_table(getenv("OUTDIR")+"regpatt_metrics.thermal_forcing_"+region+"."+vnm+".txt","a",[/finpr/],"%s")
        else
          write_table(getenv("OUTDIR")+"regpatt_metrics.thermal_forcing_"+region+"."+vnm+".txt","a",[/finpr/],"%s")
        end if
     end if
     delete([/line3,line4,format2,format3,nchar,ntc,clat,dimY,ntb,header/])
     end do
    end do
    delete([/mods,seas/])
    delete([/patcor_vreg_tforce_djf,patcor_vreg_tforce_mam,patcor_vreg_tforce_jja,patcor_vreg_tforce_son,patcor_vreg_tforce_ann/])
    if (COMPUTE_MODES_MON.eq."True") then
      delete([/patcor_vreg_tforce_mon/])
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
     panres@txString = "Amundsen Sea Thermal Forcing Regressions (DJF)" 
     gsn_panel2(wks_tforce,reg_tforce_djf,(/nrow,ncol/),panres)
     delete(reg_tforce_djf)
     panres@txString = "Amundsen Sea Thermal Forcing Regressions (MAM)"
     gsn_panel2(wks_tforce,reg_tforce_mam,(/nrow,ncol/),panres)
     delete(reg_tforce_mam)
     panres@txString = "Amundsen Sea Thermal Forcing Regressions (JJA)"
     gsn_panel2(wks_tforce,reg_tforce_jja,(/nrow,ncol/),panres)
     delete(reg_tforce_jja)
     panres@txString = "Amundsen Sea Thermal Forcing Regressions (SON)"
     gsn_panel2(wks_tforce,reg_tforce_son,(/nrow,ncol/),panres)
     delete(reg_tforce_son)
     panres@txString = "Amundsen Sea Thermal Forcing Regressions (Annual)"
     gsn_panel2(wks_tforce,reg_tforce_ann,(/nrow,ncol/),panres)
     delete(reg_tforce_ann)
     if (COMPUTE_MODES_MON.eq."True") then    
        panres@txString = "Amundsen Sea Thermal Forcing Regressions (Monthly)"
        gsn_panel2(wks_tforce,reg_tforce_mon,(/nrow,ncol/),panres)
        delete(reg_tforce_mon)
     end if
     delete(wks_tforce)
  end if
  
;--------------------------------------------------------------------------------------------------
  OUTDIR = getenv("OUTDIR") 
  if (wks_type.eq."png") then       
     if (vxreg_frame.eq.0) then
        system("mv "+OUTDIR+"tforce1.vxreg.000001.png "+OUTDIR+"tforce."+region+"."+vnm+"reg.djf.png")
        system("mv "+OUTDIR+"tforce1.vxreg.000002.png "+OUTDIR+"tforce."+region+"."+vnm+"reg.mam.png")
        system("mv "+OUTDIR+"tforce1.vxreg.000003.png "+OUTDIR+"tforce."+region+"."+vnm+"reg.jja.png")
        system("mv "+OUTDIR+"tforce1.vxreg.000004.png "+OUTDIR+"tforce."+region+"."+vnm+"reg.son.png")
        system("mv "+OUTDIR+"tforce1.vxreg.000005.png "+OUTDIR+"tforce."+region+"."+vnm+"reg.ann.png")
        if (COMPUTE_MODES_MON.eq."True") then
          system("mv "+OUTDIR+"tforce1.vxreg.000006.png "+OUTDIR+"tforce."+region+"."+vnm+"reg.mon.png")   
        end if 
     end if

  else     
     system("psplit "+OUTDIR+"tforce1.vxreg.ps "+OUTDIR+"vx1_sp")
     if (vxreg_frame.eq.0) then
        system("mv "+OUTDIR+"vx1_sp0001.ps "+OUTDIR+"tforce."+region+"."+vnm+"reg.djf.ps") 
        system("mv "+OUTDIR+"vx1_sp0002.ps "+OUTDIR+"tforce."+region+"."+vnm+"reg.mam.ps") 
        system("mv "+OUTDIR+"vx1_sp0003.ps "+OUTDIR+"tforce."+region+"."+vnm+"reg.jja.ps") 
        system("mv "+OUTDIR+"vx1_sp0004.ps "+OUTDIR+"tforce."+region+"."+vnm+"reg.son.ps") 
        system("mv "+OUTDIR+"vx1_sp0005.ps "+OUTDIR+"tforce."+region+"."+vnm+"reg.ann.ps")
        if (COMPUTE_MODES_MON.eq."True") then
           system("mv "+OUTDIR+"vx1_sp0006.ps "+OUTDIR+"tforce."+region+"."+vnm+"reg.mon.ps") 
        end if
     end if

  end if

  delete([/vnm,lmsk,nsim_reg,names_reg,paths_reg,syear_reg,syear_reg,eyear_reg,nyr_reg,vrfac/])
 end do 
    
 print("Finished: Amundsen_thermal_forcing_regpatt.ncl")

end  
