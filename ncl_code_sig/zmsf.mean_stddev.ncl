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
  print("Starting: zmsf.mean_stddev.ncl")
  
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
  wks_stddev_djf = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.stddev.djf")
  wks_stddev_mam = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.stddev.mam")
  wks_stddev_jja = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.stddev.jja")
  wks_stddev_son = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.stddev.son")
  wks_stddev_ann = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.stddev.ann")
  wks_mean_djf = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.mean.djf")
  wks_mean_mam = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.mean.mam")
  wks_mean_jja = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.mean.jja")
  wks_mean_son = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.mean.son")
  wks_mean_ann = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.mean.ann")
  
  if (COLORMAP.eq.0) then
     gsn_define_colormap(wks_stddev_djf,"precip3_16lev") 
     gsn_define_colormap(wks_stddev_mam,"precip3_16lev")  
     gsn_define_colormap(wks_stddev_jja,"precip3_16lev") 
     gsn_define_colormap(wks_stddev_son,"precip3_16lev")  
     gsn_define_colormap(wks_stddev_ann,"precip3_16lev")
     gsn_define_colormap(wks_mean_djf,"temp_19lev") 
     gsn_define_colormap(wks_mean_mam,"temp_19lev")  
     gsn_define_colormap(wks_mean_jja,"temp_19lev") 
     gsn_define_colormap(wks_mean_son,"temp_19lev")  
     gsn_define_colormap(wks_mean_ann,"temp_19lev")
  end if
  if (COLORMAP.eq.1) then
     gsn_define_colormap(wks_stddev_djf,"cb_rainbow") 
     gsn_define_colormap(wks_stddev_mam,"cb_rainbow")  
     gsn_define_colormap(wks_stddev_jja,"cb_rainbow") 
     gsn_define_colormap(wks_stddev_son,"cb_rainbow")  
     gsn_define_colormap(wks_stddev_ann,"cb_rainbow")
     gsn_define_colormap(wks_mean_djf,"BlueDarkRed18") 
     gsn_define_colormap(wks_mean_mam,"BlueDarkRed18")  
     gsn_define_colormap(wks_mean_jja,"BlueDarkRed18") 
     gsn_define_colormap(wks_mean_son,"BlueDarkRed18")  
     gsn_define_colormap(wks_mean_ann,"BlueDarkRed18")     
  end if

  plot_mean_djf = new(nsim,"graphic")  
  plot_mean_mam = new(nsim,"graphic")  
  plot_mean_jja = new(nsim,"graphic")  
  plot_mean_son = new(nsim,"graphic")   
  plot_mean_ann = new(nsim,"graphic")  
  plot_stddev_djf = new(nsim,"graphic")  
  plot_stddev_mam = new(nsim,"graphic")  
  plot_stddev_jja = new(nsim,"graphic")  
  plot_stddev_son = new(nsim,"graphic")   
  plot_stddev_ann = new(nsim,"graphic")  
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

     do ff = 0,1     
        zmsfT = zmsf
        if (ff.eq.1) then
           if (OPT_CLIMO.eq."Full") then
              zmsfT = rmMonAnnCycTLL(zmsfT)
           else
              check_custom_climo(names(ee),syear(ee),eyear(ee),CLIMO_SYEAR,CLIMO_EYEAR)
              temp_arr = zmsfT
              delete(temp_arr&time)
              temp_arr&time = cd_calendar(zmsfT&time,-1)
              if (CLIMO_SYEAR.lt.0) then
                 climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))       
              else
                 climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))                 
              end if
              delete(temp_arr)
              zmsfT   = calcMonAnomTLL(zmsfT,climo) 
              delete(climo)
           end if
        end if   
     
        zmsf_seas = runave_n_Wrap(zmsfT,3,0,0)
        zmsf_seas(0,:,:) = (/ dim_avg_n(zmsfT(:1,:,:),0) /)
        zmsf_seas(dimsizes(zmsfT&time)-1,:,:) = (/ dim_avg_n(zmsfT(dimsizes(zmsfT&time)-2:,:,:),0) /)
        zmsf_ann = runave_n_Wrap(zmsfT,12,0,0)
        delete(zmsfT)
        
        if (ff.eq.0) then
           zmsf_mean_djf = dim_avg_n_Wrap(zmsf_seas(0::12,:,:),0)
           zmsf_mean_mam = dim_avg_n_Wrap(zmsf_seas(3::12,:,:),0)
           zmsf_mean_jja = dim_avg_n_Wrap(zmsf_seas(6::12,:,:),0)
           zmsf_mean_son = dim_avg_n_Wrap(zmsf_seas(9::12,:,:),0)
           zmsf_mean_ann = dim_avg_n_Wrap(zmsf_ann(5::12,:,:),0)
        end if
        if (ff.eq.1) then     
           zmsf_sd_djf = dim_stddev_n_Wrap(dtrend_msg_n(ispan(0,nyr(ee)-1,1),zmsf_seas(0::12,:,:),False,False,0),0)
           zmsf_sd_mam = dim_stddev_n_Wrap(dtrend_msg_n(ispan(0,nyr(ee)-1,1),zmsf_seas(3::12,:,:),False,False,0),0)
           zmsf_sd_jja = dim_stddev_n_Wrap(dtrend_msg_n(ispan(0,nyr(ee)-1,1),zmsf_seas(6::12,:,:),False,False,0),0)
           zmsf_sd_son = dim_stddev_n_Wrap(dtrend_msg_n(ispan(0,nyr(ee)-1,1),zmsf_seas(9::12,:,:),False,False,0),0)
           zmsf_sd_ann = dim_stddev_n_Wrap(dtrend_msg_n(ispan(0,nyr(ee)-1,1),zmsf_ann(5::12,:,:),False,False,0),0)
        end if
        delete([/zmsf_seas,zmsf_ann/])
     end do
     delete(zmsf)
     copy_VarMeta(zmsf_mean_djf,zmsf_sd_djf)
     copy_VarMeta(zmsf_mean_mam,zmsf_sd_mam)
     copy_VarMeta(zmsf_mean_jja,zmsf_sd_jja)
     copy_VarMeta(zmsf_mean_son,zmsf_sd_son)
     copy_VarMeta(zmsf_mean_ann,zmsf_sd_ann)
     
     if (OUTPUT_DATA.eq."True") then
        modname = str_sub_str(names(ee)," ","_")
        bc = (/"/","'","(",")"/)
        do gg = 0,dimsizes(bc)-1
           modname = str_sub_str(modname,bc(gg),"_")
        end do
        fn = getenv("OUTDIR")+modname+".cvdp_data.zmsf.mean_stddev."+syear(ee)+"-"+eyear(ee)+".nc"
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

        z->zmsf_spatialmean_djf     = set_varAtts(zmsf_mean_djf,"zmsf mean (DJF)","","")
        z->zmsf_spatialmean_mam     = set_varAtts(zmsf_mean_mam,"zmsf mean (MAM)","","")
        z->zmsf_spatialmean_jja     = set_varAtts(zmsf_mean_jja,"zmsf mean (JJA)","","")
        z->zmsf_spatialmean_son     = set_varAtts(zmsf_mean_son,"zmsf mean (SON)","","")
        z->zmsf_spatialmean_ann     = set_varAtts(zmsf_mean_ann,"zmsf mean (annual)","","")
        
        z->zmsf_spatialstddev_djf     = set_varAtts(zmsf_sd_djf,"zmsf standard deviation (DJF)","","")
        z->zmsf_spatialstddev_mam     = set_varAtts(zmsf_sd_mam,"zmsf standard deviation (MAM)","","")
        z->zmsf_spatialstddev_jja     = set_varAtts(zmsf_sd_jja,"zmsf standard deviation (JJA)","","")
        z->zmsf_spatialstddev_son     = set_varAtts(zmsf_sd_son,"zmsf standard deviation (SON)","","")
        z->zmsf_spatialstddev_ann     = set_varAtts(zmsf_sd_ann,"zmsf standard deviation (annual)","","")
        delete(z)
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
     res@tmXBValues      = ispan(toint(min(zmsf_mean_djf&lat)),toint(max(zmsf_mean_djf&lat)),15)
     res@tmXBLabels      = (/"90S","75S", "60S","45S", "30S","15S", "0", \
                             "15N","30N","45N","60N","75","90N"/)
     res@tmXBMinorValues = ispan(toint(min(zmsf_mean_djf&lat)),toint(max(zmsf_mean_djf&lat)),5)

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

     sres = res
     
     res@cnLevels = fspan(.5,20.5,11)    
     if (COLORMAP.eq.0) then
        res@cnFillColors = (/2,3,4,6,8,9,10,11,12,14,16,18/)
        sres@cnLevels = ispan(-200,200,20)
     end if
     if (COLORMAP.eq.1) then
        res@cnFillColors = (/35,47,63,79,95,100,112,124,136,155,175,196/)
        sres@cnLevels = ispan(-200,200,20)
     end if
     
     res@gsnLeftString   = names(ee) 
     res@gsnRightString  = syear(ee)+"-"+eyear(ee) 
     res@gsnCenterString = "" 
     plot_stddev_djf(ee) = gsn_csm_contour(wks_stddev_djf,zmsf_sd_djf,res)
     plot_stddev_mam(ee) = gsn_csm_contour(wks_stddev_mam,zmsf_sd_mam,res)
     plot_stddev_jja(ee) = gsn_csm_contour(wks_stddev_jja,zmsf_sd_jja,res)
     plot_stddev_son(ee) = gsn_csm_contour(wks_stddev_son,zmsf_sd_son,res)
     plot_stddev_ann(ee) = gsn_csm_contour(wks_stddev_ann,zmsf_sd_ann,res)
     
     sres@gsnLeftString   = names(ee) 
     sres@gsnRightString  = syear(ee)+"-"+eyear(ee) 
     sres@gsnCenterString = "" 
     plot_mean_djf(ee) = gsn_csm_contour(wks_mean_djf,zmsf_mean_djf,sres)
     plot_mean_mam(ee) = gsn_csm_contour(wks_mean_mam,zmsf_mean_mam,sres)
     plot_mean_jja(ee) = gsn_csm_contour(wks_mean_jja,zmsf_mean_jja,sres)
     plot_mean_son(ee) = gsn_csm_contour(wks_mean_son,zmsf_mean_son,sres)
     plot_mean_ann(ee) = gsn_csm_contour(wks_mean_ann,zmsf_mean_ann,sres)
     delete([/zmsf_sd_djf,zmsf_sd_mam,zmsf_sd_jja,zmsf_sd_son,zmsf_sd_ann,zmsf_mean_djf,zmsf_mean_mam,zmsf_mean_jja,zmsf_mean_son,zmsf_mean_ann,res,sres/])
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

  panres@lbTitleString = "Mean Meridional Stream function (SF) ("+lbunit+") "

  ncol = floattointeger(sqrt(nsim))
  nrow = (nsim/ncol)+mod(nsim,ncol)  

  panres@txString = "Meridional Stream Function Standard Deviations (DJF)"
  gsn_panel2(wks_stddev_djf,plot_stddev_djf,(/nrow,ncol/),panres)
  delete(wks_stddev_djf)
  
  panres@txString = "Meridional Stream Function Standard Deviations (MAM)"
  gsn_panel2(wks_stddev_mam,plot_stddev_mam,(/nrow,ncol/),panres)
  delete(wks_stddev_mam)
  
  panres@txString = "Meridional Stream Function Standard Deviations (JJA)"
  gsn_panel2(wks_stddev_jja,plot_stddev_jja,(/nrow,ncol/),panres)
  delete(wks_stddev_jja)
  
  panres@txString = "Meridional Stream Function Standard Deviations (SON)"
  gsn_panel2(wks_stddev_son,plot_stddev_son,(/nrow,ncol/),panres)
  delete(wks_stddev_son)
  
  panres@txString = "Meridional Stream Function Standard Deviations (Annual)"
  gsn_panel2(wks_stddev_ann,plot_stddev_ann,(/nrow,ncol/),panres)
  delete(wks_stddev_ann)
  
  panres@txString = "Meridional Stream Function Means (DJF)"
  gsn_panel2(wks_mean_djf,plot_mean_djf,(/nrow,ncol/),panres)
  delete(wks_mean_djf)
  
  panres@txString = "Meridional Stream Function Means (MAM)"
  gsn_panel2(wks_mean_mam,plot_mean_mam,(/nrow,ncol/),panres)
  delete(wks_mean_mam)
  
  panres@txString = "Meridional Stream Function Means (JJA)"
  gsn_panel2(wks_mean_jja,plot_mean_jja,(/nrow,ncol/),panres)
  delete(wks_mean_jja)
  
  panres@txString = "Meridional Stream Function Means (SON)"
  gsn_panel2(wks_mean_son,plot_mean_son,(/nrow,ncol/),panres)
  delete(wks_mean_son)
  
  panres@txString = "Meridional Stream Function Means (Annual)"
  gsn_panel2(wks_mean_ann,plot_mean_ann,(/nrow,ncol/),panres)
  delete(wks_mean_ann)
  delete(panres)
  print("Finished: zmsf.mean_stddev.ncl")
end
