; Calculates precipitation global patts and timeseries
;
; Variables used: pr
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: spi.pattern_timeseries.ncl")
  
  SCALE_TIMESERIES = getenv("SCALE_TIMESERIES")  
  OUTPUT_DATA      = getenv("OUTPUT_DATA")  
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OPT_CLIMO        = getenv("OPT_CLIMO")
  CLIMO_SYEAR      = toint(getenv("CLIMO_SYEAR"))
  CLIMO_EYEAR      = toint(getenv("CLIMO_EYEAR"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
  COLORMAP         = getenv("COLORMAP")  
  
  nsim = numAsciiRow("namelist_byvar/namelist_prect")
  na = asciiread("namelist_byvar/namelist_prect",(/nsim/),"string")
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
  wks_patts_djf = gsn_open_wks(wks_type,getenv("OUTDIR")+"spi.patts.djf")
  wks_patts_mam = gsn_open_wks(wks_type,getenv("OUTDIR")+"spi.patts.mam")
  wks_patts_jja = gsn_open_wks(wks_type,getenv("OUTDIR")+"spi.patts.jja")
  wks_patts_son = gsn_open_wks(wks_type,getenv("OUTDIR")+"spi.patts.son")
  wks_patts_ann = gsn_open_wks(wks_type,getenv("OUTDIR")+"spi.patts.ann")
    
  wks_aa_djf = gsn_open_wks(wks_type,getenv("OUTDIR")+"spi.timeseries.djf")
  wks_aa_mam = gsn_open_wks(wks_type,getenv("OUTDIR")+"spi.timeseries.mam")
  wks_aa_jja = gsn_open_wks(wks_type,getenv("OUTDIR")+"spi.timeseries.jja")
  wks_aa_son = gsn_open_wks(wks_type,getenv("OUTDIR")+"spi.timeseries.son")
  wks_aa_ann = gsn_open_wks(wks_type,getenv("OUTDIR")+"spi.timeseries.ann")
  
  if (COLORMAP.eq.0) then
     gsn_define_colormap(wks_patts_djf,"precip_diff_12lev")   
     gsn_define_colormap(wks_patts_mam,"precip_diff_12lev")  
     gsn_define_colormap(wks_patts_jja,"precip_diff_12lev") 
     gsn_define_colormap(wks_patts_son,"precip_diff_12lev") 
     gsn_define_colormap(wks_patts_ann,"precip_diff_12lev") 
     gsn_define_colormap(wks_aa_djf,"ncl_default")   
     gsn_define_colormap(wks_aa_mam,"ncl_default")  
     gsn_define_colormap(wks_aa_jja,"ncl_default") 
     gsn_define_colormap(wks_aa_son,"ncl_default") 
     gsn_define_colormap(wks_aa_ann,"ncl_default") 
  end if
  if (COLORMAP.eq.1) then
     gsn_define_colormap(wks_patts_djf,"BrownBlue12")     
     gsn_define_colormap(wks_patts_mam,"BrownBlue12")    
     gsn_define_colormap(wks_patts_jja,"BrownBlue12")   
     gsn_define_colormap(wks_patts_son,"BrownBlue12")   
     gsn_define_colormap(wks_patts_ann,"BrownBlue12")   
     gsn_define_colormap(wks_aa_djf,"ncl_default")   
     gsn_define_colormap(wks_aa_mam,"ncl_default")  
     gsn_define_colormap(wks_aa_jja,"ncl_default") 
     gsn_define_colormap(wks_aa_son,"ncl_default") 
     gsn_define_colormap(wks_aa_ann,"ncl_default") 
  end if
  
  map_djf = new(nsim,"graphic")  
  map_mam = new(nsim,"graphic")  
  map_jja = new(nsim,"graphic")  
  map_son = new(nsim,"graphic")  
  map_ann = new(nsim,"graphic")  
  xy_djf = new(nsim,"graphic")  
  xy_mam = new(nsim,"graphic")  
  xy_jja = new(nsim,"graphic")  
  xy_son = new(nsim,"graphic")  
  xy_ann = new(nsim,"graphic")  
  
  if (isfilepresent2("obs_prect")) then
     xy_obs_djf = new(nsim,"graphic")  
     xy_obs_mam = new(nsim,"graphic")  
     xy_obs_jja = new(nsim,"graphic")  
     xy_obs_son = new(nsim,"graphic")  
     xy_obs_ann = new(nsim,"graphic")  
  end if
  do ee = 0,nsim-1
     ppt = data_read_in(paths(ee),"PRECT",syear(ee),eyear(ee))    ; read in data, orient lats/lons correctly, set time coordinate variable up
     if (isatt(ppt,"is_all_missing")) then
        delete(ppt)
        continue
     end if 

     opt = True 
     opt@spi_type = 3 
     spi = ppt
     spi = dim_spi_n(ppt, 3, opt, 0)

     coswgt=cos(rad*ppt&lat)
     coswgt!0 = "lat"
     coswgt&lat= ppt&lat
     
     ppt_seas = runave_n_Wrap(spi,3,0,0)
     ppt_seas(0,:,:) = (/ dim_avg_n(spi(:1,:,:),0) /)
     ppt_seas(dimsizes(spi&time)-1,:,:) = (/ dim_avg_n(spi(dimsizes(spi&time)-2:,:,:),0) /)
     ppt_ann = runave_n_Wrap(spi,12,0,0)
     delete([/ppt,spi/)
     
     ppt_patts_seas = ppt_seas(:3,:,:)
     ppt_patts_seas = ppt_patts_seas@_FillValue
     ppt_patts_ann  = ppt_patts_seas(0,:,:)
     ppt_aa_seas = new((/4,nyr(ee)/),typeof(ppt_seas))
     ppt_aa_seas!1 = "time"
     ppt_aa_seas&time = ispan(syear(ee),eyear(ee),1)
     ppt_aa_seas&time@units = "YYYY"
     ppt_aa_seas&time@long_name = "time"
     ppt_aa_ann = ppt_aa_seas(0,:)
     do ff = 0,4
        if (ff.le.3) then
           tarr = ppt_seas(ff*3::12,:,:)
        end if
        if (ff.eq.4) then
           tarr = ppt_ann(5::12,:,:)
        end if
        if (ff.le.3) then
           ppt_patts_seas(ff,:,:) = tarr 
           ppt_aa_seas(ff,:) = (/ wgt_areaave(tarr,coswgt,1.0,0) /)
        end if
        if (ff.eq.4) then
           ppt_patts_ann = (/ tarr/)
           ppt_aa_ann = (/ wgt_areaave(tarr,coswgt,1.0,0) /)
        end if
        delete([/tarr/])
     end do

     ppt_patts_seas@units = "1"
     ppt_patts_ann@units = "1"
     ppt_aa_seas@units = ppt_seas@units   
     ppt_aa_ann@units = ppt_ann@units     
     delete([/ppt_seas,ppt_ann,coswgt/])    

     if (isfilepresent2("obs_prect").and.ee.eq.0) then
        ppt_aa_seas@syear = syear(ee)
        ppt_aa_seas@eyear = eyear(ee)
        ppt_aa_ann@syear = syear(ee)
        ppt_aa_ann@eyear = eyear(ee)
        ppt_aa_seas_obs = ppt_aa_seas
        ppt_aa_ann_obs  = ppt_aa_ann
     end if

     if (OUTPUT_DATA.eq."True") then
        modname = str_sub_str(names(ee)," ","_")
        bc = (/"/","'","(",")"/)
        do gg = 0,dimsizes(bc)-1
           modname = str_sub_str(modname,bc(gg),"_")
        end do
        fn = getenv("OUTDIR")+modname+".cvdp_data.spi.pattern_timeseries."+syear(ee)+"-"+eyear(ee)+".nc"
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
        ppt_aa_seas2 = ppt_aa_seas
        ppt_aa_seas2!1 = "TIME"
        ppt_aa_seas2&TIME = ispan(syear(ee),eyear(ee),1)
        ppt_aa_seas2&TIME@units = "YYYY"
        ppt_aa_seas2&TIME@long_name = "time"
        ppt_aa_ann2 = ppt_aa_ann
        ppt_aa_ann2!0 = "TIME"
        ppt_aa_ann2&TIME = ispan(syear(ee),eyear(ee),1)
        ppt_aa_ann2&TIME@units = "YYYY"
        ppt_aa_ann2&TIME@long_name = "time"
        z->spi_global_avg_djf = set_varAtts(ppt_aa_seas2(0,:),"spi global area-average (DJF)","","")
        z->spi_global_avg_mam = set_varAtts(ppt_aa_seas2(1,:),"spi global area-average (MAM)","","")
        z->spi_global_avg_jja = set_varAtts(ppt_aa_seas2(2,:),"spi global area-average (JJA)","","")
        z->spi_global_avg_son = set_varAtts(ppt_aa_seas2(3,:),"spi global area-average (SON)","","")
        z->spi_global_avg_ann = set_varAtts(ppt_aa_ann2,"spi global area-average (annual)","","")
        z->spi_patts_djf     = set_varAtts(ppt_patts_seas(0,:,:),"spi(pr) index patts (DJF)","","")
        z->spi_patts_mam     = set_varAtts(ppt_patts_seas(1,:,:),"spi(pr) index patts (MAM)","","")
        z->spi_patts_jja     = set_varAtts(ppt_patts_seas(2,:,:),"spi(pr) index patts (JJA)","","")
        z->spi_patts_son     = set_varAtts(ppt_patts_seas(3,:,:),"spi(pr) index patts (SON)","","")
        z->spi_patts_ann     = set_varAtts(ppt_patts_ann,"spi(pr) index patts (annual)","","")
        delete(z)
        delete(ppt_aa_seas2)
        delete(ppt_aa_ann2)
        delete([/modname,fn/])
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
        res@cnLevels = (/-4,-3,-2,-1,-0.5,-0.2,0,0.2,0.5,1,2,3,4/)
        res@cnFillColors = (/2,3,4,5,6,7,8,8,9,10,11,12,13,14/)
     end if
     if (COLORMAP.eq.1) then
         res@cnLevels = (/-3,-2,-1,-0.5,-0.2,0,0.2,0.5,1,2,3/)
     end if
     res@cnLineLabelsOn = False
     res@cnFillOn        = True
     res@cnLinesOn       = False
     res@lbLabelBarOn    = False

     res@gsnLeftStringOrthogonalPosF = -0.05
     res@gsnLeftStringParallelPosF = .005
     res@gsnRightStringOrthogonalPosF = -0.05
     res@gsnRightStringParallelPosF = 0.975
     res@gsnRightString = ""
     res@gsnLeftString = ""
     res@gsnLeftStringFontHeightF = 0.014
     res@gsnCenterStringFontHeightF = 0.018
     res@gsnRightStringFontHeightF = 0.014
     res@gsnLeftString = syear(ee)+"-"+eyear(ee)
 
     res@gsnRightString = ppt_patts_seas@units
     res@gsnCenterString = names(ee)
     map_djf(ee) = gsn_csm_contour_map(wks_patts_djf,ppt_patts_seas(0,:,:),res)
     map_mam(ee) = gsn_csm_contour_map(wks_patts_mam,ppt_patts_seas(1,:,:),res)
     map_jja(ee) = gsn_csm_contour_map(wks_patts_jja,ppt_patts_seas(2,:,:),res)
     map_son(ee) = gsn_csm_contour_map(wks_patts_son,ppt_patts_seas(3,:,:),res)
     map_ann(ee) = gsn_csm_contour_map(wks_patts_ann,ppt_patts_ann,res)
     
     
     xyres = True
     xyres@gsnDraw = False
     xyres@gsnFrame = False
     xyres@gsnFrame = False
     xyres@gsnYRefLine = 0.0
     xyres@gsnYRefLineColor = "gray42"
     
     if (wks_type.eq."png") then
        xyres@xyLineThicknessF = 4.
     else
        xyres@xyLineThicknessF = 2.0
     end if
     if (isfilepresent2("obs_prect").and.ee.eq.0) then
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
     if (isfilepresent2("obs_prect").and.ee.ge.1) then
        xyres@trYMinF = min((/min(ppt_aa_seas(0,:)),min(ppt_aa_seas_obs(0,:))/))-.005
        xyres@trYMaxF = max((/max(ppt_aa_seas(0,:)),max(ppt_aa_seas_obs(0,:))/))+.005
     end if
     xyres@gsnRightString = ppt_patts_seas@units
     xy_djf(ee)     = gsn_csm_xy(wks_aa_djf,ispan(syear(ee),eyear(ee),1),ppt_aa_seas(0,:),xyres)
     if (isfilepresent2("obs_prect").and.ee.ge.1) then
        xy_obs_djf(ee) = gsn_csm_xy(wks_aa_djf,ispan(ppt_aa_seas_obs@syear,ppt_aa_seas_obs@eyear,1),ppt_aa_seas_obs(0,:),xyres2)
        overlay(xy_djf(ee),xy_obs_djf(ee))
     end if
     
     if (isfilepresent2("obs_prect").and.ee.ge.1) then
        xyres@trYMinF = min((/min(ppt_aa_seas(1,:)),min(ppt_aa_seas_obs(1,:))/))-.005
        xyres@trYMaxF = max((/max(ppt_aa_seas(1,:)),max(ppt_aa_seas_obs(1,:))/))+.005
     end if 
     xyres@gsnRightString = ppt_patts_seas@units
     xy_mam(ee)     = gsn_csm_xy(wks_aa_mam,ispan(syear(ee),eyear(ee),1),ppt_aa_seas(1,:),xyres)  
     if (isfilepresent2("obs_prect").and.ee.ge.1) then
        xy_obs_mam(ee) = gsn_csm_xy(wks_aa_mam,ispan(ppt_aa_seas_obs@syear,ppt_aa_seas_obs@eyear,1),ppt_aa_seas_obs(1,:),xyres2)
        overlay(xy_mam(ee),xy_obs_mam(ee))
     end if
     
     if (isfilepresent2("obs_prect").and.ee.ge.1) then
        xyres@trYMinF = min((/min(ppt_aa_seas(2,:)),min(ppt_aa_seas_obs(2,:))/))-.005
        xyres@trYMaxF = max((/max(ppt_aa_seas(2,:)),max(ppt_aa_seas_obs(2,:))/))+.005
     end if
     xyres@gsnRightString = ppt_patts_seas@units
     xy_jja(ee)     = gsn_csm_xy(wks_aa_jja,ispan(syear(ee),eyear(ee),1),ppt_aa_seas(2,:),xyres)  
     if (isfilepresent2("obs_prect").and.ee.ge.1) then
        xy_obs_jja(ee) = gsn_csm_xy(wks_aa_jja,ispan(ppt_aa_seas_obs@syear,ppt_aa_seas_obs@eyear,1),ppt_aa_seas_obs(2,:),xyres2)
        overlay(xy_jja(ee),xy_obs_jja(ee))
     end if
     
     if (isfilepresent2("obs_prect").and.ee.ge.1) then
        xyres@trYMinF = min((/min(ppt_aa_seas(3,:)),min(ppt_aa_seas_obs(3,:))/))-.005
        xyres@trYMaxF = max((/max(ppt_aa_seas(3,:)),max(ppt_aa_seas_obs(3,:))/))+.005
     end if  
     xyres@gsnRightString = ppt_patts_seas@units
     xy_son(ee)     = gsn_csm_xy(wks_aa_son,ispan(syear(ee),eyear(ee),1),ppt_aa_seas(3,:),xyres)   
     if (isfilepresent2("obs_prect").and.ee.ge.1) then
        xy_obs_son(ee) = gsn_csm_xy(wks_aa_son,ispan(ppt_aa_seas_obs@syear,ppt_aa_seas_obs@eyear,1),ppt_aa_seas_obs(3,:),xyres2)
        overlay(xy_son(ee),xy_obs_son(ee))
     end if
     
     if (isfilepresent2("obs_prect").and.ee.ge.1) then
        xyres@trYMinF = min((/min(ppt_aa_ann),min(ppt_aa_ann_obs)/))-.005
        xyres@trYMaxF = max((/max(ppt_aa_ann),max(ppt_aa_ann_obs)/))+.005
     end if
     xyres@gsnRightString = ppt_patts_ann@units
     xy_ann(ee)     = gsn_csm_xy(wks_aa_ann,ispan(syear(ee),eyear(ee),1),ppt_aa_ann,xyres)   
     if (isfilepresent2("obs_prect").and.ee.ge.1) then
        xy_obs_ann(ee) = gsn_csm_xy(wks_aa_ann,ispan(ppt_aa_seas_obs@syear,ppt_aa_seas_obs@eyear,1),ppt_aa_ann_obs,xyres2)
        overlay(xy_ann(ee),xy_obs_ann(ee))
        delete(xyres@trYMinF)
        delete(xyres@trYMaxF)
     end if

     delete([/ppt_patts_seas,ppt_patts_ann/])  
     delete([/ppt_aa_seas,ppt_aa_ann,xyres,xyres2,res/])
  end do
  if (isfilepresent2("obs_prect")) then
     delete([/ppt_aa_seas_obs,ppt_aa_ann_obs/])
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
  
  
  panres@txString = "SPI pattern (DJF)"
  ncol = floattointeger(sqrt(nsim))
  nrow = (nsim/ncol)+mod(nsim,ncol)  
  gsn_panel2(wks_patts_djf,map_djf,(/nrow,ncol/),panres)
  delete(wks_patts_djf)
  
  panres@txString = "SPI pattern (MAM)"
  gsn_panel2(wks_patts_mam,map_mam,(/nrow,ncol/),panres)
  delete(wks_patts_mam)

  panres@txString = "SPI pattern (JJA)"
  gsn_panel2(wks_patts_jja,map_jja,(/nrow,ncol/),panres)
  delete(wks_patts_jja)

  panres@txString = "SPI pattern (SON)"
  gsn_panel2(wks_patts_son,map_son,(/nrow,ncol/),panres)
  delete(wks_patts_son)

  panres@txString = "SPI pattern (Annual)"
  gsn_panel2(wks_patts_ann,map_ann,(/nrow,ncol/),panres)
  delete(wks_patts_ann)

  panres2 = True
  panres2@gsnMaximize = True
  panres2@gsnPaperOrientation = "portrait"
  panres2@gsnPanelYWhiteSpacePercent = 3.0  
  if (nsim.le.5) then
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
  panres2@txString = "SPI Global Average (DJF)"
  gsn_panel2(wks_aa_djf,xy_djf,lp,panres2)  
  delete(wks_aa_djf)
  
  panres2@txString = "SPI Global Average (MAM)"
  gsn_panel2(wks_aa_mam,xy_mam,lp,panres2)  
  delete(wks_aa_mam)
  
  panres2@txString = "SPI Global Average (JJA)"
  gsn_panel2(wks_aa_jja,xy_jja,lp,panres2)  
  delete(wks_aa_jja)
  
  panres2@txString = "SPI Global Average (SON)"
  gsn_panel2(wks_aa_son,xy_son,lp,panres2)  
  delete(wks_aa_son)
  
  panres2@txString = "SPI Global Average (Annual)"
  gsn_panel2(wks_aa_ann,xy_ann,lp,panres2)  
  delete(wks_aa_ann)
  
  delete([/nrow,ncol,lp,map_djf,map_mam,map_jja,map_son,map_ann,xy_djf,xy_mam,xy_jja,xy_son,xy_ann/])
  delete(panres2)
  if (isfilepresent2("obs_prect")) then
     delete([/xy_obs_djf,xy_obs_mam,xy_obs_jja,xy_obs_son,xy_obs_ann/])
  end if
  print("Finished: spi.pattern_timeseries.ncl")
end
