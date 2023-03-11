; Calculates 2m air temperature global means and standard deviations
;
; Variables used: zmsf
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: zmsf.trends.ncl")
  
  SCALE_TIMESERIES = getenv("SCALE_TIMESERIES")  
  OUTPUT_DATA      = getenv("OUTPUT_DATA")  
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OPT_CLIMO        = getenv("OPT_CLIMO")
  CLIMO_SYEAR      = toint(getenv("CLIMO_SYEAR"))
  CLIMO_EYEAR      = toint(getenv("CLIMO_EYEAR"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
  COLORMAP         = getenv("COLORMAP")
  
  nsim = numAsciiRow("namelist_byvar/namelist_zmsf")
  na = asciiread("namelist_byvar/namelist_zmsf",(/nsim/),"string")
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
  
  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if
  wks_trends_djf = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.trends.djf")
  wks_trends_mam = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.trends.mam")
  wks_trends_jja = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.trends.jja")
  wks_trends_son = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.trends.son")
  wks_trends_ann = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.trends.ann")
  wks_trends_mon = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.trends.mon")
 
  if (COLORMAP.eq.0) then
     gsn_define_colormap(wks_trends_djf,"temp_19lev") 
     gsn_define_colormap(wks_trends_mam,"temp_19lev")  
     gsn_define_colormap(wks_trends_jja,"temp_19lev") 
     gsn_define_colormap(wks_trends_son,"temp_19lev")  
     gsn_define_colormap(wks_trends_ann,"temp_19lev")
     gsn_define_colormap(wks_trends_mon,"temp_19lev")
  end if
  if (COLORMAP.eq.1) then
     gsn_define_colormap(wks_trends_djf,"BlueDarkRed18") 
     gsn_define_colormap(wks_trends_mam,"BlueDarkRed18")  
     gsn_define_colormap(wks_trends_jja,"BlueDarkRed18") 
     gsn_define_colormap(wks_trends_son,"BlueDarkRed18")  
     gsn_define_colormap(wks_trends_ann,"BlueDarkRed18")     
     gsn_define_colormap(wks_trends_mon,"BlueDarkRed18")
  end if

  map_djf = new(nsim,"graphic")  
  map_mam = new(nsim,"graphic")  
  map_jja = new(nsim,"graphic")  
  map_son = new(nsim,"graphic")   
  map_ann = new(nsim,"graphic")  
  map_mon = new(nsim,"graphic")

  do ee = 0,nsim-1
     zmsf = data_read_in(paths(ee),"SF",syear(ee),eyear(ee))    ; read in data, orient lats/lons correctly, set time coordinate variable up   
     if (isatt(zmsf,"is_all_missing")) then
        delete(zmsf)
        continue
     end if 

     scale_factor = 1.e9
     zmsf         = zmsf / scale_factor 
     zmsf@units   = "10~S~9~N~ " + zmsf@units
     lbunit       = zmsf@units

     if (OPT_CLIMO.eq."Full") then
        zmsf = rmMonAnnCycTLL(zmsf)
     else
        check_custom_climo(names(ee),syear(ee),eyear(ee),CLIMO_SYEAR,CLIMO_EYEAR)
        temp_arr = zmsf
        delete(temp_arr&time)
        temp_arr&time = cd_calendar(zmsf&time,-1)
        if (CLIMO_SYEAR.lt.0) then
           climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))       
        else
           climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))                 
        end if
        delete(temp_arr)
        zmsf   = calcMonAnomTLL(zmsf,climo) 
        delete(climo)
     end if

     tttt = dtrend_msg_n(ispan(0,dimsizes(zmsf&time)-1,1),zmsf,False,True,0)
     zmsf_trends_mon = zmsf(0,:,:)
     zmsf_trends_mon = (/ onedtond(tttt@slope, (/dimsizes(zmsf&lev),dimsizes(zmsf&lat)/) ) /)
     zmsf_trends_mon = zmsf_trends_mon*dimsizes(zmsf&time)
     zmsf_trends_mon@units = zmsf@units+" "+nyr(ee)+"yr~S~-1~N~"
     delete(tttt)
     
     zmsf_seas = runave_n_Wrap(zmsf,3,0,0)
     zmsf_seas(0,:,:) = (/ dim_avg_n(zmsf(:1,:,:),0) /)
     zmsf_seas(dimsizes(zmsf&time)-1,:,:) = (/ dim_avg_n(zmsf(dimsizes(zmsf&time)-2:,:,:),0) /)
     zmsf_ann = runave_n_Wrap(zmsf,12,0,0)
     
     zmsf_trends_seas = zmsf_seas(:3,:,:)
     zmsf_trends_seas = zmsf_trends_seas@_FillValue
     zmsf_trends_ann  = zmsf_trends_seas(0,:,:)
     do ff = 0,4
        if (ff.le.3) then
           tarr = zmsf_seas(ff*3::12,:,:)
        end if
        if (ff.eq.4) then
           tarr = zmsf_ann(5::12,:,:)
        end if
        tttt = dtrend_msg_n(ispan(0,dimsizes(tarr&time)-1,1),tarr,False,True,0)
        if (ff.le.3) then
           zmsf_trends_seas(ff,:,:) = (/ onedtond(tttt@slope, (/dimsizes(tarr&lev),dimsizes(tarr&lat)/) ) /)
        end if
        if (ff.eq.4) then
           zmsf_trends_ann = (/ onedtond(tttt@slope, (/dimsizes(tarr&lev),dimsizes(tarr&lat)/) ) /)
        end if
        delete([/tarr,tttt/])
     end do
     zmsf_trends_seas = zmsf_trends_seas*nyr(ee)
     zmsf_trends_seas@units = zmsf_seas@units+" "+nyr(ee)+"yr~S~-1~N~"
     zmsf_trends_ann = zmsf_trends_ann*nyr(ee)
     zmsf_trends_ann@units = zmsf_ann@units+" "+nyr(ee)+"yr~S~-1~N~"
     lbunit = lbunit + " "+nyr(ee)+"yr~S~-1~N~" 

     if (OUTPUT_DATA.eq."True") then
        modname = str_sub_str(names(ee)," ","_")
        bc = (/"/","'","(",")"/)
        do gg = 0,dimsizes(bc)-1
           modname = str_sub_str(modname,bc(gg),"_")
        end do
        fn = getenv("OUTDIR")+modname+".cvdp_data.zmsf.trends."+syear(ee)+"-"+eyear(ee)+".nc"
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

        z->zmsf_trends_seas     = set_varAtts(zmsf_trends_seas(0,:,:),"zmsf linear trends (DJF)","","")
        z->zmsf_trends_mam     = set_varAtts(zmsf_trends_seas(1,:,:),"zmsf linear trends (MAM)","","")
        z->zmsf_trends_jja     = set_varAtts(zmsf_trends_seas(2,:,:),"zmsf linear trends (JJA)","","")
        z->zmsf_trends_son     = set_varAtts(zmsf_trends_seas(3,:,:),"zmsf linear trends (SON)","","")
        z->zmsf_trends_ann     = set_varAtts(zmsf_trends_ann,"zmsf linear trends (annual)","","")
        z->zmsf_trends_mon     = set_varAtts(zmsf_trends_mon,"zmsf linear trends (monthly)","","")
        delete(z)
        delete([/modname,fn/])
     end if
     if(isvar("zmsf_seas")) then 
       delete([/zmsf_seas/])
     end if 
     if(isvar("zmsf_ann")) then
       delete([/zmsf_ann/])
     end if
      if(isvar("zmsf")) then
       delete([/zmsf/])
     end if
;==========================================================================================
     res = True
     res@vpWidthF   = 0.8
     res@vpHeightF  = 0.6

     if (wks_type.eq."png") then
       res@tmBorderThicknessF           = 2.0
       res@tmXBMajorThicknessF          = 2.0
       res@tmXBMinorThicknessF          = 2.0
       res@tmYLMajorThicknessF          = 2.0
       res@tmYLMinorThicknessF          = 2.0
       res@tmYRMajorThicknessF          = 2.0
       res@tmYRMinorThicknessF          = 2.0
       res@cnLineThicknessF             = 2.0
     else
       res@tmBorderThicknessF           = 1.0 
       res@tmXBMajorThicknessF          = 1.0 
       res@tmXBMinorThicknessF          = 1.0 
       res@tmYLMajorThicknessF          = 1.0 
       res@tmYLMinorThicknessF          = 1.0 
       res@tmYRMajorThicknessF          = 1.0 
       res@tmYRMinorThicknessF          = 1.0 
       res@cnLineThicknessF             = 1.0
     end if
    ;res@tmYRMode     = "Automatic"          ; turn off special labels on right axis

     res@gsnDraw      = False
     res@gsnFrame     = False
  
     res@trYReverse                   = True
     res@tiYAxisString                = "Pressure (hPa)"

     res@gsnLeftStringFontHeightF     = 0.025
     res@gsnLeftStringOrthogonalPosF  = 0.015

     res@cnLineLabelsOn = False
     res@cnFillOn        = True
     res@cnLinesOn       = True
     res@cnLineLabelsOn  = False        ; True is default
     res@cnInfoLabelOn   = False                ; turn off info label
     res@lbLabelBarOn    = False
     res@cnMissingValFillColor  = "White" ;"gray76"               ; black = 1

     res@trXMinF         = -50.0
     res@trXMaxF         =  50.0
     res@tmXBMode        = "Explicit"
     res@tmXBValues      = ispan(toint(min(zmsf_trends_seas&lat)),toint(max(zmsf_trends_seas&lat)),15)
     res@tmXBLabels      = (/"90S","75S", "60S","45S", "30S","15S", "0", \
                             "15N","30N","45N","60N","75","90N"/)
     res@tmXBMinorValues = ispan(toint(min(zmsf_trends_seas&lat)),toint(max(zmsf_trends_seas&lat)),5)

     res@tmYLMode        = "Explicit"                ; explicit labels
     res@tmYLValues      = (/ 1000, 850, 700, 500, 300, 200, 100, 10, 1/)
     res@tmYLLabels      = ""+res@tmYLValues         ; make strings

     res@cnLevelSelectionMode = "ExplicitLevels"

     res@gsnLeftStringOrthogonalPosF  = 0.01
     res@gsnLeftStringParallelPosF    = .005
     res@gsnRightStringOrthogonalPosF = 0.01
     res@gsnRightStringParallelPosF   = 0.96
     res@gsnRightString  = ""
     res@gsnLeftString   = ""
     res@gsnLeftStringFontHeightF   = 0.014 * 2.0
     res@gsnCenterStringFontHeightF = 0.018 * 2.0
     res@gsnRightStringFontHeightF  = 0.014 * 2.0    

     res@cnLevelSelectionMode = "ExplicitLevels"
     res@cnLevels = ispan(-20,20,2)    

     res@gsnLeftString   = names(ee) 
     res@gsnRightString  = syear(ee)+"-"+eyear(ee) 
     res@gsnCenterString = "" 

     map_djf(ee) = gsn_csm_contour(wks_trends_djf,zmsf_trends_seas(0,:,:),res)
     map_mam(ee) = gsn_csm_contour(wks_trends_mam,zmsf_trends_seas(1,:,:),res)
     map_jja(ee) = gsn_csm_contour(wks_trends_jja,zmsf_trends_seas(2,:,:),res)
     map_son(ee) = gsn_csm_contour(wks_trends_son,zmsf_trends_seas(3,:,:),res)
     map_ann(ee) = gsn_csm_contour(wks_trends_ann,zmsf_trends_ann(:,:),res)
     map_mon(ee) = gsn_csm_contour(wks_trends_mon,zmsf_trends_mon(:,:),res)

     delete([/zmsf_trends_seas,zmsf_trends_ann,zmsf_trends_mon,res/])
  end do     
     
  panres = True
  panres@gsnMaximize = True  
  panres@gsnPaperOrientation = "portrait"
  panres@gsnPanelLabelBar = True
  panres@gsnPanelYWhiteSpacePercent = 3.0
  panres@lbTitleOn = True
  panres@lbBoxLineColor = "gray70"
  if (nsim.le.4) then
     if (nsim.eq.1) then
        panres@txFontHeightF = 0.020
        panres@gsnPanelBottom = 0.50
        panres@lbLabelFontHeightF = 0.016
        panres@lbTitleFontHeightF = 0.016
     else
        panres@txFontHeightF = 0.0125
        panres@gsnPanelBottom = 0.50
        panres@lbLabelFontHeightF = 0.010
        panres@lbTitleFontHeightF = 0.010
     end if
  else
     panres@txFontHeightF      = 0.014
     panres@gsnPanelBottom     = 0.05
     panres@lbLabelFontHeightF = 0.010
     panres@lbTitleFontHeightF = 0.010
  end if
  panres@lbLabelStride = 1
  panres@pmLabelBarWidthF  = 0.65
  panres@pmLabelBarHeightF = 0.04
  panres@pmLabelBarOrthogonalPosF = -0.02
  panres@pmLabelBarParallelPosF = 0.02

  panres@lbTitleString = "Meridional Stream function (SF) Trend ("+lbunit+") "

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
  
  panres@txString = "Meridional Stream Function Trends (DJF)"
  gsn_panel2(wks_trends_djf,map_djf,(/nrow,ncol/),panres)
  delete(wks_trends_djf)
  
  panres@txString = "Meridional Stream Function Trends (MAM)"
  gsn_panel2(wks_trends_mam,map_mam,(/nrow,ncol/),panres)
  delete(wks_trends_mam)
  
  panres@txString = "Meridional Stream Function Trends (JJA)"
  gsn_panel2(wks_trends_jja,map_jja,(/nrow,ncol/),panres)
  delete(wks_trends_jja)
  
  panres@txString = "Meridional Stream Function Trends (SON)"
  gsn_panel2(wks_trends_son,map_son,(/nrow,ncol/),panres)
  delete(wks_trends_son)
  
  panres@txString = "Meridional Stream Function Trends (Annual)"
  gsn_panel2(wks_trends_ann,map_ann,(/nrow,ncol/),panres)
  delete(wks_trends_ann)

  panres@txString = "Meridional Stream Function Trends (Monthly)"
  gsn_panel2(wks_trends_mon,map_mon,(/nrow,ncol/),panres)
  delete(wks_trends_mon)

  delete([/nrow,ncol,map_djf,map_mam,map_jja,map_son,map_ann,map_mon,panres/])
  print("Finished: zmsf.trends.ncl")
end
