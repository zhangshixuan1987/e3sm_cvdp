; Calculates SST global trends, running global trends and timeseries
;
; Variables used: ts
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: sst.trends_timeseries.ncl")
  
  SCALE_TIMESERIES = getenv("SCALE_TIMESERIES")  
  OUTPUT_DATA      = getenv("OUTPUT_DATA")  
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OPT_CLIMO        = getenv("OPT_CLIMO")
  CLIMO_SYEAR      = toint(getenv("CLIMO_SYEAR"))
  CLIMO_EYEAR      = toint(getenv("CLIMO_EYEAR"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
  COLORMAP         = getenv("COLORMAP")  

  ;;;scale the trend to use the same unit: C 100yr-1
  if( (CLIMO_EYEAR - CLIMO_SYEAR) .ge. 100) then
    TREND_Unit       = "100yr~S~-1~N~"
    TREND_NY         = 100
  else if ( (CLIMO_EYEAR - CLIMO_SYEAR) .gt. 80) then
    TREND_Unit       = "50yr~S~-1~N~"
    TREND_NY         = 50
  else if ( (CLIMO_EYEAR - CLIMO_SYEAR) .gt. 30) then
    TREND_Unit       = "30yr~S~-1~N~"
    TREND_NY         = 30
  else 
    TREND_Unit       = "10yr~S~-1~N~"
    TREND_NY         = 10
  end if
  end if
  end if
   
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
         
  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if
  wks_trends_djf = gsn_open_wks(wks_type,getenv("OUTDIR")+"sst.trends.djf")
  wks_trends_mam = gsn_open_wks(wks_type,getenv("OUTDIR")+"sst.trends.mam")
  wks_trends_jja = gsn_open_wks(wks_type,getenv("OUTDIR")+"sst.trends.jja")
  wks_trends_son = gsn_open_wks(wks_type,getenv("OUTDIR")+"sst.trends.son")
  wks_trends_ann = gsn_open_wks(wks_type,getenv("OUTDIR")+"sst.trends.ann")
  wks_trends_mon = gsn_open_wks(wks_type,getenv("OUTDIR")+"sst.trends.mon")
    
  wks_aa_djf = gsn_open_wks(wks_type,getenv("OUTDIR")+"sst.timeseries.djf")
  wks_aa_mam = gsn_open_wks(wks_type,getenv("OUTDIR")+"sst.timeseries.mam")
  wks_aa_jja = gsn_open_wks(wks_type,getenv("OUTDIR")+"sst.timeseries.jja")
  wks_aa_son = gsn_open_wks(wks_type,getenv("OUTDIR")+"sst.timeseries.son")
  wks_aa_ann = gsn_open_wks(wks_type,getenv("OUTDIR")+"sst.timeseries.ann")
  wks_aa_mon = gsn_open_wks(wks_type,getenv("OUTDIR")+"sst.timeseries.mon")
  
  wks_rt_mon = gsn_open_wks(wks_type,getenv("OUTDIR")+"sst.runtrend.mon")

  if (COLORMAP.eq.0) then
     gsn_define_colormap(wks_trends_djf,"BlueYellowRed")   
     gsn_define_colormap(wks_trends_mam,"BlueYellowRed")  
     gsn_define_colormap(wks_trends_jja,"BlueYellowRed") 
     gsn_define_colormap(wks_trends_son,"BlueYellowRed") 
     gsn_define_colormap(wks_trends_ann,"BlueYellowRed") 
     gsn_define_colormap(wks_trends_mon,"BlueYellowRed") 
     gsn_define_colormap(wks_aa_djf,"ncl_default")   
     gsn_define_colormap(wks_aa_mam,"ncl_default")  
     gsn_define_colormap(wks_aa_jja,"ncl_default") 
     gsn_define_colormap(wks_aa_son,"ncl_default") 
     gsn_define_colormap(wks_aa_ann,"ncl_default") 
     gsn_define_colormap(wks_aa_mon,"ncl_default") 
     gsn_define_colormap(wks_rt_mon,"ncl_default") 
  end if
  if (COLORMAP.eq.1) then
     gsn_define_colormap(wks_trends_djf,"BlueDarkRed18")     
     gsn_define_colormap(wks_trends_mam,"BlueDarkRed18")    
     gsn_define_colormap(wks_trends_jja,"BlueDarkRed18")   
     gsn_define_colormap(wks_trends_son,"BlueDarkRed18")   
     gsn_define_colormap(wks_trends_ann,"BlueDarkRed18")   
     gsn_define_colormap(wks_trends_mon,"BlueDarkRed18")   
     gsn_define_colormap(wks_aa_djf,"ncl_default")   
     gsn_define_colormap(wks_aa_mam,"ncl_default")  
     gsn_define_colormap(wks_aa_jja,"ncl_default") 
     gsn_define_colormap(wks_aa_son,"ncl_default") 
     gsn_define_colormap(wks_aa_ann,"ncl_default") 
     gsn_define_colormap(wks_aa_mon,"ncl_default") 
     gsn_define_colormap(wks_rt_mon,"ncl_default") 
  end if
  map_djf = new(nsim,"graphic")  
  map_mam = new(nsim,"graphic")  
  map_jja = new(nsim,"graphic")  
  map_son = new(nsim,"graphic")  
  map_ann = new(nsim,"graphic")  
  map_mon = new(nsim,"graphic")  
  xy_djf = new(nsim,"graphic")  
  xy_mam = new(nsim,"graphic")  
  xy_jja = new(nsim,"graphic")  
  xy_son = new(nsim,"graphic")  
  xy_ann = new(nsim,"graphic")  
  xy_mon = new(nsim,"graphic")  
  
  xy_rt_mon = new((/5,nsim/),"graphic")  
  
  if (isfilepresent2("obs_ts")) then
     xy_obs_djf = new(nsim,"graphic")  
     xy_obs_mam = new(nsim,"graphic")  
     xy_obs_jja = new(nsim,"graphic")  
     xy_obs_son = new(nsim,"graphic")  
     xy_obs_ann = new(nsim,"graphic")  
     xy_obs_mon = new(nsim,"graphic")  
  end if
  do ee = 0,nsim-1
     sst = data_read_in(paths(ee),"TS",syear(ee),eyear(ee))    ; read in data, orient lats/lons correctly, set time coordinate variable up
     if (isatt(sst,"is_all_missing")) then
        delete(sst)
        continue
     end if 
     sst = where(sst.le.-1.8,-1.8,sst)    ; set all values below -1.8 to -1.8
     d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")   ; mask out land (this is redundant for data that is already masked)
     basemap = d->LSMASK
     lsm = landsea_mask(basemap,sst&lat,sst&lon)
     sst = mask(sst,conform(sst,lsm,(/1,2/)).ge.1,False)
     delete([/lsm,basemap/])
     delete(d)  

     if (OPT_CLIMO.eq."Full") then
        sst = rmMonAnnCycTLL(sst)
     else
        check_custom_climo(names(ee),syear(ee),eyear(ee),CLIMO_SYEAR,CLIMO_EYEAR)
        temp_arr = sst
        delete(temp_arr&time)
        temp_arr&time = cd_calendar(sst&time,-1)
        if (CLIMO_SYEAR.lt.0) then
           climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))       
        else
           climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))                 
        end if
        delete(temp_arr)
        sst   = calcMonAnomTLL(sst,climo) 
        delete(climo)
     end if
  
     coswgt=cos(rad*sst&lat)
     coswgt!0 = "lat"
     coswgt&lat= sst&lat
     
     sst_aa_mon = wgt_areaave_Wrap(sst,coswgt,1.0,0)
     tttt = dtrend_msg_n(ispan(0,dimsizes(sst&time)-1,1),sst,False,True,0)
     sst_trends_mon = sst(0,:,:)
     sst_trends_mon = (/ onedtond(tttt@slope, (/dimsizes(sst&lat),dimsizes(sst&lon)/) ) /)
     sst_trends_mon = sst_trends_mon*TREND_NY*12 ;dimsizes(sst&time)
     sst_trends_mon@units = sst@units+" " + TREND_Unit ;+nyr(ee)+"yr~S~-1~N~"
     delete(tttt)
     
     sst_seas = runave_n_Wrap(sst,3,0,0)
     sst_seas(0,:,:) = (/ dim_avg_n(sst(:1,:,:),0) /)
     sst_seas(dimsizes(sst&time)-1,:,:) = (/ dim_avg_n(sst(dimsizes(sst&time)-2:,:,:),0) /)
     sst_ann = runave_n_Wrap(sst,12,0,0)
     delete(sst)
     
     sst_trends_seas = sst_seas(:3,:,:)
     sst_trends_seas = sst_trends_seas@_FillValue
     sst_trends_ann  = sst_trends_seas(0,:,:)
     sst_aa_seas = new((/4,nyr(ee)/),typeof(sst_seas))
     sst_aa_seas!1 = "time"
     sst_aa_seas&time = ispan(syear(ee),eyear(ee),1)
     sst_aa_seas&time@units = "YYYY"
     sst_aa_seas&time@long_name = "time"
     sst_aa_ann = sst_aa_seas(0,:)
     do ff = 0,4
        if (ff.le.3) then
           tarr = sst_seas(ff*3::12,:,:)     
        end if  
        if (ff.eq.4) then
           tarr = sst_ann(5::12,:,:)
        end if
        tttt = dtrend_msg_n(ispan(0,dimsizes(tarr&time)-1,1),tarr,False,True,0)   
        if (ff.le.3) then
           sst_trends_seas(ff,:,:) = (/ onedtond(tttt@slope, (/dimsizes(tarr&lat),dimsizes(tarr&lon)/) ) /)
           sst_aa_seas(ff,:) = (/ wgt_areaave(tarr,coswgt,1.0,0) /)
        end if
        if (ff.eq.4) then
           sst_trends_ann = (/ onedtond(tttt@slope, (/dimsizes(tarr&lat),dimsizes(tarr&lon)/) ) /)
           sst_aa_ann = (/ wgt_areaave(tarr,coswgt,1.0,0) /)
        end if
        delete([/tarr,tttt/])        
     end do
     sst_trends_seas = sst_trends_seas*TREND_NY            ;*nyr(ee)
     sst_trends_seas@units = sst_seas@units+" "+TREND_Unit ;+nyr(ee)+"yr~S~-1~N~"
     sst_trends_ann = sst_trends_ann*TREND_NY              ;*nyr(ee)
     sst_trends_ann@units = sst_ann@units+" "+TREND_Unit   ;+nyr(ee)+"yr~S~-1~N~"         
     delete([/sst_seas,sst_ann,coswgt/])
     
     if (isfilepresent2("obs_ts").and.ee.eq.0) then
        sst_aa_seas@syear = syear(ee)
        sst_aa_seas@eyear = eyear(ee)
        sst_aa_mon@syear = syear(ee)
        sst_aa_mon@eyear = eyear(ee)
        sst_aa_ann@syear = syear(ee)
        sst_aa_ann@eyear = eyear(ee)
        sst_aa_seas_obs = sst_aa_seas
        sst_aa_mon_obs  = sst_aa_mon
        sst_aa_ann_obs  = sst_aa_ann
     end if

     dimT = dimsizes(sst_aa_mon)      ; calculate running trends from the monthly data
     sst_rt_mon = new((/5,dimT/),typeof(sst_aa_mon))
     sst_rt_mon!1 = "time"
     sst_rt_mon&time = sst_aa_mon&time    
     copy_VarAtts(sst_aa_mon,sst_rt_mon)
     sst_rt_mon@long_name =  sst_rt_mon@long_name+" global average running trend"
     rt_nyr = (/8,10,12,14,16/)
     do ff = 0,dimsizes(rt_nyr)-1
        incr = rt_nyr(ff)*12
        do gg = 0,dimT-incr-1
           tttt = dtrend_msg(ispan(0,incr-1,1),sst_aa_mon(gg:gg+incr-1),False,True)
           sst_rt_mon(ff,gg) = (/ tttt@slope*incr /)
           delete(tttt) 
        end do
     end do
     delete([/dimT,incr/])   

     if (OUTPUT_DATA.eq."True") then
        modname = str_sub_str(names(ee)," ","_")
        bc = (/"/","'","(",")"/)
        do gg = 0,dimsizes(bc)-1
           modname = str_sub_str(modname,bc(gg),"_")
        end do
        fn = getenv("OUTDIR")+modname+".cvdp_data.sst.trends_timeseries."+syear(ee)+"-"+eyear(ee)+".nc"
        if (.not.isfilepresent2(fn)) then
           z = addfile(fn,"c")
           z@source = "NCAR Climate Analysis Section's Climate Variability Diagnostics Package v"+getenv("VERSION")
           z@notes = "Data from "+names(ee)+" from "+syear(ee)+"-"+eyear(ee)
           if (OPT_CLIMO.eq."Full") then
              z@climatology = syear(ee)+"-"+eyear(ee)+" climatology removed prior to all calculations (other than means)"
           else
              if (CLIMO_SYEAR.lt.0) then
                 z@climatology = (eyear(ee)+CLIMO_SYEAR)+"-"+(eyear(ee)+CLIMO_EYEAR)+" climatology removed prior to all calculations (other than means)"
              else
                 z@climatology = CLIMO_SYEAR+"-"+CLIMO_EYEAR+" climatology removed prior to all calculations (other than means)"
              end if
           end if
           z@Conventions = "CF-1.6"
        else
           z = addfile(fn,"w")
        end if
        sst_aa_seas2 = sst_aa_seas
        sst_aa_seas2!1 = "TIME"
        sst_aa_seas2&TIME = ispan(syear(ee),eyear(ee),1)
        sst_aa_seas2&TIME@units = "YYYY"
        sst_aa_seas2&TIME@long_name = "time"
        sst_aa_ann2 = sst_aa_ann
        sst_aa_ann2!0 = "TIME"
        sst_aa_ann2&TIME = ispan(syear(ee),eyear(ee),1)
        sst_aa_ann2&TIME@units = "YYYY"
        sst_aa_ann2&TIME@long_name = "time"
        z->sst_global_avg_mon = set_varAtts(sst_aa_mon,"sst global area-average (monthly)","C","")
        z->sst_global_avg_djf = set_varAtts(sst_aa_seas2(0,:),"sst global area-average (DJF)","C","")
        z->sst_global_avg_mam = set_varAtts(sst_aa_seas2(1,:),"sst global area-average (MAM)","C","")
        z->sst_global_avg_jja = set_varAtts(sst_aa_seas2(2,:),"sst global area-average (JJA)","C","")
        z->sst_global_avg_son = set_varAtts(sst_aa_seas2(3,:),"sst global area-average (SON)","C","")
        z->sst_global_avg_ann = set_varAtts(sst_aa_ann2,"sst global area-average (annual)","C","")
        z->$("sst_global_avg_runtrend_"+rt_nyr(0)+"yr")$ = set_varAtts(sst_rt_mon(0,:),"sst global area-average "+rt_nyr(0)+"yr running trend","","") 
        z->$("sst_global_avg_runtrend_"+rt_nyr(1)+"yr")$ = set_varAtts(sst_rt_mon(1,:),"sst global area-average "+rt_nyr(1)+"yr running trend","","")
        z->$("sst_global_avg_runtrend_"+rt_nyr(2)+"yr")$ = set_varAtts(sst_rt_mon(2,:),"sst global area-average "+rt_nyr(2)+"yr running trend","","")
        z->$("sst_global_avg_runtrend_"+rt_nyr(3)+"yr")$ = set_varAtts(sst_rt_mon(3,:),"sst global area-average "+rt_nyr(3)+"yr running trend","","")
        z->$("sst_global_avg_runtrend_"+rt_nyr(4)+"yr")$ = set_varAtts(sst_rt_mon(4,:),"sst global area-average "+rt_nyr(4)+"yr running trend","","")
        z->sst_trends_djf     = set_varAtts(sst_trends_seas(0,:,:),"sst linear trends (DJF)","","")
        z->sst_trends_mam     = set_varAtts(sst_trends_seas(1,:,:),"sst linear trends (MAM)","","")
        z->sst_trends_jja     = set_varAtts(sst_trends_seas(2,:,:),"sst linear trends (JJA)","","")
        z->sst_trends_son     = set_varAtts(sst_trends_seas(3,:,:),"sst linear trends (SON)","","")
        z->sst_trends_ann     = set_varAtts(sst_trends_ann,"sst linear trends (annual)","","")
        z->sst_trends_mon     = set_varAtts(sst_trends_mon,"sst linear trends (monthly)","","")
        delete(z)
        delete([/sst_aa_seas2,sst_aa_ann2/])
     end if
;========================================================================
     res = True
     res@mpProjection = "WinkelTripel"
     res@mpGeophysicalLineColor = "gray42"
     if (wks_type.eq."png") then
        res@mpGeophysicalLineThicknessF = 2.  
     else
        res@mpGeophysicalLineThicknessF = 1.  
     end if     
     res@mpPerimOn    = False
     res@mpGridLatSpacingF =  90            ; change latitude  line spacing
     res@mpGridLonSpacingF = 180.           ; change longitude line spacing
     res@mpGridLineColor   = "transparent"  ; trick ncl into drawing perimeter
     res@mpGridAndLimbOn   = True           ; turn on lat/lon lines  
     res@mpFillOn = False
     res@mpCenterLonF = 210.
     res@mpOutlineOn = True  
     res@gsnDraw      = False
     res@gsnFrame     = False
  
     res@cnLevelSelectionMode = "ExplicitLevels"
     if (COLORMAP.eq.0) then
        res@cnLevels = (/-4,-3,-2.5,-2,-1.5,-1,-0.5,-0.25,0,0.25,0.5,1,1.5,2,2.5,3,4/)
     end if
     if (COLORMAP.eq.1) then
        res@cnLevels = (/-6,-4,-3,-2,-1,-0.5,-0.25,0,0.25,0.5,1,2,3,4,6/)
     end if
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
     res@gsnLeftString = syear(ee)+"-"+eyear(ee)
 
     res@gsnRightString = sst_trends_seas@units
     res@gsnCenterString = names(ee)
     map_djf(ee) = gsn_csm_contour_map(wks_trends_djf,sst_trends_seas(0,:,:),res)
     map_mam(ee) = gsn_csm_contour_map(wks_trends_mam,sst_trends_seas(1,:,:),res)
     map_jja(ee) = gsn_csm_contour_map(wks_trends_jja,sst_trends_seas(2,:,:),res)
     map_son(ee) = gsn_csm_contour_map(wks_trends_son,sst_trends_seas(3,:,:),res)
     map_ann(ee) = gsn_csm_contour_map(wks_trends_ann,sst_trends_ann,res)
     map_mon(ee) = gsn_csm_contour_map(wks_trends_mon,sst_trends_mon,res)

     xyres = True
     xyres@gsnDraw = False
     xyres@gsnFrame = False
     xyres@gsnYRefLine = 0.0
     xyres@gsnYRefLineColor = "gray42"
     
     if (wks_type.eq."png") then
        xyres@xyLineThicknessF = 4.
     else
        xyres@xyLineThicknessF = 2.
     end if
     if (isfilepresent2("obs_ts").and.ee.eq.0) then
        xyres@xyLineColor = "black"
     else
        xyres@xyLineColor = "royalblue"
     end if
     xyres@tiYAxisString = ""
     if (nsim.le.5) then
        xyres@tmXBLabelFontHeightF = 0.0125
        xyres@tmYLLabelFontHeightF = 0.0125
        xyres@gsnLeftStringFontHeightF = 0.017     
        xyres@gsnRightStringFontHeightF = 0.013     
     else
        xyres@tmXBLabelFontHeightF = 0.018
        xyres@tmYLLabelFontHeightF = 0.018
        xyres@gsnLeftStringFontHeightF = 0.024
        xyres@gsnRightStringFontHeightF = 0.020     
     end if
     xyres@gsnLeftStringOrthogonalPosF = 0.025
     xyres@gsnRightStringOrthogonalPosF = xyres@gsnLeftStringOrthogonalPosF
     xyres@vpXF = 0.05
     xyres@vpHeightF = 0.15
     if (SCALE_TIMESERIES.eq."True") then
        xyres@vpWidthF = 0.9*((nyr(ee)*1.)/nyr_max)
     else
        xyres@vpWidthF = 0.9
     end if
     xyres@gsnLeftString = ""     
     xyres@gsnCenterString = ""
     xyres@gsnRightString = ""
     
     xyres@trXMinF = syear(ee)-.5
     xyres@trXMaxF = eyear(ee)+0.5
     
     xyres2 = xyres
     xyres2@xyLineColor = "gray60"
     xyres2@xyCurveDrawOrder = "PreDraw"
     
     xyres@gsnLeftString = names(ee)
     tttt = dtrend_msg(ispan(0,dimsizes(sst_aa_seas&time)-1,1),sst_aa_seas(0,:),False,True)   
     if (isfilepresent2("obs_ts").and.ee.ge.1) then
        xyres@trYMinF = min((/min(sst_aa_seas(0,:)),min(sst_aa_seas_obs(0,:))/))-.01
        xyres@trYMaxF = max((/max(sst_aa_seas(0,:)),max(sst_aa_seas_obs(0,:))/))+.01
     end if
     xyres@gsnRightString = decimalPlaces(tttt@slope*nyr(ee),2,True)+sst_trends_seas@units
     xy_djf(ee)     = gsn_csm_xy(wks_aa_djf,ispan(syear(ee),eyear(ee),1),sst_aa_seas(0,:),xyres)
     if (isfilepresent2("obs_ts").and.ee.ge.1) then
        xy_obs_djf(ee) = gsn_csm_xy(wks_aa_djf,ispan(sst_aa_seas_obs@syear,sst_aa_seas_obs@eyear,1),sst_aa_seas_obs(0,:),xyres2)
        overlay(xy_djf(ee),xy_obs_djf(ee))
     end if
     
     tttt = dtrend_msg(ispan(0,dimsizes(sst_aa_seas&time)-1,1),sst_aa_seas(1,:),False,True)   
     if (isfilepresent2("obs_ts").and.ee.ge.1) then
        xyres@trYMinF = min((/min(sst_aa_seas(1,:)),min(sst_aa_seas_obs(1,:))/))-.01
        xyres@trYMaxF = max((/max(sst_aa_seas(1,:)),max(sst_aa_seas_obs(1,:))/))+.01
     end if
     xyres@gsnRightString = decimalPlaces(tttt@slope*nyr(ee),2,True)+sst_trends_seas@units
     xy_mam(ee)     = gsn_csm_xy(wks_aa_mam,ispan(syear(ee),eyear(ee),1),sst_aa_seas(1,:),xyres)  
     if (isfilepresent2("obs_ts").and.ee.ge.1) then
        xy_obs_mam(ee) = gsn_csm_xy(wks_aa_mam,ispan(sst_aa_seas_obs@syear,sst_aa_seas_obs@eyear,1),sst_aa_seas_obs(1,:),xyres2)
        overlay(xy_mam(ee),xy_obs_mam(ee))
     end if
     
     tttt = dtrend_msg(ispan(0,dimsizes(sst_aa_seas&time)-1,1),sst_aa_seas(2,:),False,True)   
     if (isfilepresent2("obs_ts").and.ee.ge.1) then
        xyres@trYMinF = min((/min(sst_aa_seas(2,:)),min(sst_aa_seas_obs(2,:))/))-.01
        xyres@trYMaxF = max((/max(sst_aa_seas(2,:)),max(sst_aa_seas_obs(2,:))/))+.01
     end if
     xyres@gsnRightString = decimalPlaces(tttt@slope*nyr(ee),2,True)+sst_trends_seas@units
     xy_jja(ee)     = gsn_csm_xy(wks_aa_jja,ispan(syear(ee),eyear(ee),1),sst_aa_seas(2,:),xyres)  
     if (isfilepresent2("obs_ts").and.ee.ge.1) then
        xy_obs_jja(ee) = gsn_csm_xy(wks_aa_jja,ispan(sst_aa_seas_obs@syear,sst_aa_seas_obs@eyear,1),sst_aa_seas_obs(2,:),xyres2)
        overlay(xy_jja(ee),xy_obs_jja(ee))
     end if
     
     tttt = dtrend_msg(ispan(0,dimsizes(sst_aa_seas&time)-1,1),sst_aa_seas(3,:),False,True)   
     if (isfilepresent2("obs_ts").and.ee.ge.1) then
        xyres@trYMinF = min((/min(sst_aa_seas(3,:)),min(sst_aa_seas_obs(3,:))/))-.01
        xyres@trYMaxF = max((/max(sst_aa_seas(3,:)),max(sst_aa_seas_obs(3,:))/))+.01
     end if
     xyres@gsnRightString = decimalPlaces(tttt@slope*nyr(ee),2,True)+sst_trends_seas@units
     xy_son(ee)     = gsn_csm_xy(wks_aa_son,ispan(syear(ee),eyear(ee),1),sst_aa_seas(3,:),xyres)   
     if (isfilepresent2("obs_ts").and.ee.ge.1) then
        xy_obs_son(ee) = gsn_csm_xy(wks_aa_son,ispan(sst_aa_seas_obs@syear,sst_aa_seas_obs@eyear,1),sst_aa_seas_obs(3,:),xyres2)
        overlay(xy_son(ee),xy_obs_son(ee))
     end if
     delete(tttt)
     
     tttt = dtrend_msg(ispan(0,dimsizes(sst_aa_ann&time)-1,1),sst_aa_ann,False,True)   
     if (isfilepresent2("obs_ts").and.ee.ge.1) then
        xyres@trYMinF = min((/min(sst_aa_ann),min(sst_aa_ann_obs)/))-.01
        xyres@trYMaxF = max((/max(sst_aa_ann),max(sst_aa_ann_obs)/))+.01
     end if  
     xyres@gsnRightString = decimalPlaces(tttt@slope*nyr(ee),2,True)+sst_trends_ann@units
     xy_ann(ee)     = gsn_csm_xy(wks_aa_ann,ispan(syear(ee),eyear(ee),1),sst_aa_ann,xyres)   
     if (isfilepresent2("obs_ts").and.ee.ge.1) then
        xy_obs_ann(ee) = gsn_csm_xy(wks_aa_ann,ispan(sst_aa_seas_obs@syear,sst_aa_seas_obs@eyear,1),sst_aa_ann_obs,xyres2)
        overlay(xy_ann(ee),xy_obs_ann(ee))
        delete(xyres@trYMinF)
        delete(xyres@trYMaxF)
     end if
     delete(tttt)

     xyres@trXMaxF = eyear(ee)+1.5
     xyres2@trXMaxF = eyear(ee)+1.5
     tttt = dtrend_msg(ispan(0,dimsizes(sst_aa_mon&time)-1,1),sst_aa_mon,False,True)
     if (isfilepresent2("obs_ts").and.ee.ge.1) then
        xyres@trYMinF = min((/min(sst_aa_mon),min(sst_aa_mon_obs)/))-.01
        xyres@trYMaxF = max((/max(sst_aa_mon),max(sst_aa_mon_obs)/))+.01
     end if   
     xyres@gsnRightString = decimalPlaces(tttt@slope*dimsizes(sst_aa_mon&time),2,True)+sst_trends_mon@units
     xy_mon(ee)     = gsn_csm_xy(wks_aa_mon,fspan(syear(ee),eyear(ee)+.91667,dimsizes(sst_aa_mon)),sst_aa_mon,xyres)  
     if (isfilepresent2("obs_ts").and.ee.ge.1) then
        xy_obs_mon(ee) = gsn_csm_xy(wks_aa_mon,fspan(sst_aa_seas_obs@syear,sst_aa_seas_obs@eyear+.91667,dimsizes(sst_aa_mon_obs)),sst_aa_mon_obs,xyres2)
        overlay(xy_mon(ee),xy_obs_mon(ee))
     end if
     
     xyres@gsnRightString = ""     
     do ff = 0,4
        if (.not.all(ismissing(sst_rt_mon(ff,:))))    
           xyres@gsnRightString =  sst_rt_mon@units  
           xy_rt_mon(ff,ee)  = gsn_csm_xy(wks_rt_mon,fspan(syear(ee),eyear(ee)+.91667,dimsizes(sst_aa_mon&time)),sst_rt_mon(ff,:),xyres)
        end if
     end do         
     delete([/sst_trends_seas,sst_trends_ann,sst_trends_mon/])  
     delete([/sst_aa_seas,sst_aa_mon,sst_aa_ann,xyres,xyres2,res,tttt,sst_rt_mon/])
  end do
  if (isfilepresent2("obs_ts")) then
     delete([/sst_aa_seas_obs,sst_aa_mon_obs,sst_aa_ann_obs/])
  end if
  
  panres = True
  panres@gsnMaximize = True  
  panres@gsnPaperOrientation = "portrait"
  panres@gsnPanelLabelBar = True
  panres@gsnPanelYWhiteSpacePercent = 3.0
  panres@pmLabelBarHeightF = 0.05
  panres@pmLabelBarWidthF = 0.65
  panres@lbTitleOn = False
  panres@lbBoxLineColor = "gray70"
  panres@lbLabelFontHeightF = 0.013
  if (nsim.le.4) then
     if (nsim.eq.1) then
        panres@txFontHeightF = 0.022
        panres@gsnPanelBottom = 0.50
     else
        panres@txFontHeightF = 0.0145
        panres@gsnPanelBottom = 0.50
     end if
  else
     panres@txFontHeightF = 0.016
     panres@gsnPanelBottom = 0.05
  end if
  panres@lbLabelStride = 1
  
  panres@txString = "TS Trends (DJF)"
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
  gsn_panel2(wks_trends_djf,map_djf,(/nrow,ncol/),panres)
  delete(wks_trends_djf)
  
  panres@txString = "TS Trends (MAM)"
  gsn_panel2(wks_trends_mam,map_mam,(/nrow,ncol/),panres)
  delete(wks_trends_mam)
  
  panres@txString = "TS Trends (JJA)"
  gsn_panel2(wks_trends_jja,map_jja,(/nrow,ncol/),panres)
  delete(wks_trends_jja)
  
  panres@txString = "TS Trends (SON)"
  gsn_panel2(wks_trends_son,map_son,(/nrow,ncol/),panres)
  delete(wks_trends_son)
  
  panres@txString = "TS Trends (Annual)"
  gsn_panel2(wks_trends_ann,map_ann,(/nrow,ncol/),panres)
  delete(wks_trends_ann)
  
  panres@txString = "TS Trends (Monthly)"
  gsn_panel2(wks_trends_mon,map_mon,(/nrow,ncol/),panres)
  delete(wks_trends_mon)
  delete(panres)
  
  panres2 = True
  panres2@gsnMaximize = True
  panres2@gsnPaperOrientation = "portrait"
  panres2@gsnPanelYWhiteSpacePercent = 3.0  
  if (nsim.le.4) then
     panres2@txFontHeightF = 0.024
  else
     panres2@txFontHeightF = 0.016
  end if
  if (SCALE_TIMESERIES.eq."True") then
     tt = ind(nyr.eq.nyr_max)
     panres2@gsnPanelScalePlotIndex = tt(0)
     delete(tt)
  end if
  if (nsim.le.12) then
     lp = (/nsim,1/)
  else
     lp = (/nrow,ncol/)  ;(/nsim/2+1,nsim/8+1/)  
  end if
  panres2@txString = "TS Global Average (DJF)"
  gsn_panel2(wks_aa_djf,xy_djf,lp,panres2)  
  delete(wks_aa_djf)
  
  panres2@txString = "TS Global Average (MAM)"
  gsn_panel2(wks_aa_mam,xy_mam,lp,panres2)  
  delete(wks_aa_mam)
  
  panres2@txString = "TS Global Average (JJA)"
  gsn_panel2(wks_aa_jja,xy_jja,lp,panres2)  
  delete(wks_aa_jja)
  
  panres2@txString = "TS Global Average (SON)"
  gsn_panel2(wks_aa_son,xy_son,lp,panres2)  
  delete(wks_aa_son)
  
  panres2@txString = "TS Global Average (Annual)"
  gsn_panel2(wks_aa_ann,xy_ann,lp,panres2)  
  delete(wks_aa_ann)
  
  panres2@txString = "TS Global Average (Monthly)"
  gsn_panel2(wks_aa_mon,xy_mon,lp,panres2)  
  delete(wks_aa_mon)
  
  panres2@txString = "TS Running 8yr Trend (Monthly)"
  gsn_panel2(wks_rt_mon,xy_rt_mon(0,:),lp,panres2)  
  
  panres2@txString = "TS Running 10yr Trend (Monthly)"
  gsn_panel2(wks_rt_mon,xy_rt_mon(1,:),lp,panres2)  
  
  panres2@txString = "TS Running 12yr Trend (Monthly)"
  gsn_panel2(wks_rt_mon,xy_rt_mon(2,:),lp,panres2)  
  
  panres2@txString = "TS Running 14yr Trend (Monthly)"
  gsn_panel2(wks_rt_mon,xy_rt_mon(3,:),lp,panres2)  
  
  panres2@txString = "TS Running 16yr Trend (Monthly)"
  gsn_panel2(wks_rt_mon,xy_rt_mon(4,:),lp,panres2)  
  delete(wks_rt_mon)
  
  delete([/nrow,ncol,lp,map_djf,map_mam,map_jja,map_son,map_ann,map_mon,xy_djf,xy_mam,xy_jja,xy_son,xy_ann,xy_mon/])
  delete([/xy_rt_mon/])
  delete(panres2)
  if (isfilepresent2("obs_ts")) then
     delete([/xy_obs_djf,xy_obs_mam,xy_obs_jja,xy_obs_son,xy_obs_ann,xy_obs_mon/])
  end if
  OUTDIR = getenv("OUTDIR")
  if (wks_type.eq."png") then  
     do gg = 1,5
        if (isfilepresent2(OUTDIR+"sst.runtrend.mon.00000"+gg+".png")) then
           system("mv "+OUTDIR+"sst.runtrend.mon.00000"+gg+".png "+OUTDIR+"sst."+rt_nyr(gg-1)+"yr_runtrend.mon.png")
        end if
     end do
  else
     if (isfilepresent2(OUTDIR+"sst.runtrend.mon.ps")) then
        system("psplit "+OUTDIR+"sst.runtrend.mon.ps "+OUTDIR+"pict")
        do gg = 1,5
           if (isfilepresent2(OUTDIR+"pict000"+gg+".ps")) then
              system("mv "+OUTDIR+"pict000"+gg+".ps "+OUTDIR+"sst."+rt_nyr(gg-1)+"yr_runtrend.mon.ps")
           end if
        end do
     end if
  end if
  delete(OUTDIR)
  print("Finished: sst.trends_timeseries.ncl")  
end
