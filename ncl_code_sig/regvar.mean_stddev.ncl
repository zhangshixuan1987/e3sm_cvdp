; Calculates PSL global means and standard deviations
;
; Variables used: see regvars
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: regvar.mean_stddev.ncl")
  
  SCALE_TIMESERIES = getenv("SCALE_TIMESERIES")  
  OUTPUT_DATA      = getenv("OUTPUT_DATA")  
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OPT_CLIMO        = getenv("OPT_CLIMO")
  CLIMO_SYEAR      = toint(getenv("CLIMO_SYEAR"))
  CLIMO_EYEAR      = toint(getenv("CLIMO_EYEAR"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
  COLORMAP         = getenv("COLORMAP")

  regvars = (/"psl","sst","trefht","prect","u10","v10", \
              "taux","tauy","shflx","lhflx", "eth", \
              "swcre","olr","cldtot","u850","v850", \
              "th850","z500","u200","v200","aice_nh","aice_sh"/)
  landmsk = (/ 0,    1,   0,   0,    0,    0, \
               0,    0,   0,   0,    1,       \
               0,    0,   0,   0,    0,       \
               0,    0,   0,   0,    1,      1 /)
  varfacs = (/3.0, 1.0,  1.0,  1.0,  1.0,  1.0,   \
              2.0,   2.0, 5.0, 10.0,  5.0, \
              5.0, 5.0,     5.0,  2.0,    2.0,  \
              1.0,   15.0,   5.0,   2.5, 5.0, 5.0/)
  nsvars  = dimsizes(regvars)
 
 do ss = 0, nsvars-1,1
  ;---------Regressions coding-------------------------------------------------
  if(regvars(ss).eq."sst") then
    vnm   = "ts"
  else
    vnm   = regvars(ss)
  end if
  
  lmsk    = landmsk(ss)
  vrfac   = varfacs(ss)

  nsim  = numAsciiRow("namelist_byvar/namelist_"+vnm)
  na    = asciiread("namelist_byvar/namelist_"+vnm,(/nsim/),"string")
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
  wks_stddev_djf = gsn_open_wks(wks_type,getenv("OUTDIR")+vnm+".stddev.djf")
  wks_stddev_mam = gsn_open_wks(wks_type,getenv("OUTDIR")+vnm+".stddev.mam")
  wks_stddev_jja = gsn_open_wks(wks_type,getenv("OUTDIR")+vnm+".stddev.jja")
  wks_stddev_son = gsn_open_wks(wks_type,getenv("OUTDIR")+vnm+".stddev.son")
  wks_stddev_ann = gsn_open_wks(wks_type,getenv("OUTDIR")+vnm+".stddev.ann")
  wks_mean_djf = gsn_open_wks(wks_type,getenv("OUTDIR")+vnm+".mean.djf")
  wks_mean_mam = gsn_open_wks(wks_type,getenv("OUTDIR")+vnm+".mean.mam")
  wks_mean_jja = gsn_open_wks(wks_type,getenv("OUTDIR")+vnm+".mean.jja")
  wks_mean_son = gsn_open_wks(wks_type,getenv("OUTDIR")+vnm+".mean.son")
  wks_mean_ann = gsn_open_wks(wks_type,getenv("OUTDIR")+vnm+".mean.ann")

  
  if (COLORMAP.eq.0) then
     gsn_define_colormap(wks_stddev_djf,"precip3_16lev") 
     gsn_define_colormap(wks_stddev_mam,"precip3_16lev")  
     gsn_define_colormap(wks_stddev_jja,"precip3_16lev") 
     gsn_define_colormap(wks_stddev_son,"precip3_16lev")  
     gsn_define_colormap(wks_stddev_ann,"precip3_16lev")
     gsn_define_colormap(wks_mean_djf,"NCV_jaisnd") 
     gsn_define_colormap(wks_mean_mam,"NCV_jaisnd")  
     gsn_define_colormap(wks_mean_jja,"NCV_jaisnd") 
     gsn_define_colormap(wks_mean_son,"NCV_jaisnd")  
     gsn_define_colormap(wks_mean_ann,"NCV_jaisnd")
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
     ; print("Data to be read in: "+paths(ee)+" from "+syear(ee)+":"+eyear(ee))
     if(vnm.eq."aice_sh".or.vnm.eq."aice_nh") then
       vnmi = vnm
       vreg = data_read_in_ice(paths(ee),vnmi,syear(ee),eyear(ee))
       if (isatt(vreg,"lat2d")) then
         vreg@is_all_missing = True
       else
         vreg!1 = "lat"
         vreg!2 = "lon"
       end if
     else
       vnmi = str_upper(vnm)
       vreg = data_read_in(paths(ee),vnmi,syear(ee),eyear(ee))
     end if

     if (isatt(vreg,"is_all_missing")) then
        delete(vreg)
        continue
     end if 
     do ff = 0,1     
        vregT = vreg
        if (ff.eq.1) then
           if (OPT_CLIMO.eq."Full") then
              vregT = rmMonAnnCycTLL(vregT)
           else
              check_custom_climo(names(ee),syear(ee),eyear(ee),CLIMO_SYEAR,CLIMO_EYEAR)
              temp_arr = vregT
              delete(temp_arr&time)
              temp_arr&time = cd_calendar(vregT&time,-1)
              if (CLIMO_SYEAR.lt.0) then
                 climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))       
              else
                 climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))                 
              end if                  
              delete(temp_arr)
              vregT   = calcMonAnomTLL(vregT,climo) 
              delete(climo)
           end if
        end if        
        vreg_seas = runave_n_Wrap(vregT,3,0,0)
        vreg_seas(0,:,:) = (/ dim_avg_n(vregT(:1,:,:),0) /)
        vreg_seas(dimsizes(vregT&time)-1,:,:) = (/ dim_avg_n(vregT(dimsizes(vregT&time)-2:,:,:),0) /)
        vreg_ann = runave_n_Wrap(vregT,12,0,0)
        delete(vregT)
        
        if (ff.eq.0) then
           vreg_mean_djf = dim_avg_n_Wrap(vreg_seas(0::12,:,:),0)
           vreg_mean_mam = dim_avg_n_Wrap(vreg_seas(3::12,:,:),0)
           vreg_mean_jja = dim_avg_n_Wrap(vreg_seas(6::12,:,:),0)
           vreg_mean_son = dim_avg_n_Wrap(vreg_seas(9::12,:,:),0)
           vreg_mean_ann = dim_avg_n_Wrap(vreg_ann(5::12,:,:),0)
        end if
        if (ff.eq.1) then     
           vreg_sd_djf = dim_stddev_n_Wrap(dtrend_msg_n(ispan(0,nyr(ee)-1,1),vreg_seas(0::12,:,:),False,False,0),0)
           vreg_sd_mam = dim_stddev_n_Wrap(dtrend_msg_n(ispan(0,nyr(ee)-1,1),vreg_seas(3::12,:,:),False,False,0),0)
           vreg_sd_jja = dim_stddev_n_Wrap(dtrend_msg_n(ispan(0,nyr(ee)-1,1),vreg_seas(6::12,:,:),False,False,0),0)
           vreg_sd_son = dim_stddev_n_Wrap(dtrend_msg_n(ispan(0,nyr(ee)-1,1),vreg_seas(9::12,:,:),False,False,0),0)
           vreg_sd_ann = dim_stddev_n_Wrap(dtrend_msg_n(ispan(0,nyr(ee)-1,1),vreg_ann(5::12,:,:),False,False,0),0)
        end if
        delete([/vreg_seas,vreg_ann/])
     end do
     delete(vreg)
     copy_VarMeta(vreg_mean_djf,vreg_sd_djf)
     copy_VarMeta(vreg_mean_mam,vreg_sd_mam)
     copy_VarMeta(vreg_mean_jja,vreg_sd_jja)
     copy_VarMeta(vreg_mean_son,vreg_sd_son)
     copy_VarMeta(vreg_mean_ann,vreg_sd_ann)
         
     if (OUTPUT_DATA.eq."True") then
        modname = str_sub_str(names(ee)," ","_")
        bc = (/"/","'","(",")"/)
        do gg = 0,dimsizes(bc)-1
           modname = str_sub_str(modname,bc(gg),"_")
        end do
        fn = getenv("OUTDIR")+modname+".cvdp_data.clim.mean_stddev.ncl."+syear(ee)+"-"+eyear(ee)+".nc"
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

        z->vreg_spatialmean_djf     = set_varAtts(vreg_mean_djf,vnm+" mean (DJF)","","")
        z->vreg_spatialmean_mam     = set_varAtts(vreg_mean_djf,vnm+" mean (MAM)","","")
        z->vreg_spatialmean_jja     = set_varAtts(vreg_mean_djf,vnm+" mean (JJA)","","")
        z->vreg_spatialmean_son     = set_varAtts(vreg_mean_djf,vnm+" mean (SON)","","")
        z->vreg_spatialmean_ann     = set_varAtts(vreg_mean_djf,vnm+" mean (annual)","","")
        
        z->vreg_spatialstddev_djf     = set_varAtts(vreg_sd_djf,vnm+" standard deviation (DJF)","","")
        z->vreg_spatialstddev_mam     = set_varAtts(vreg_sd_mam,vnm+" standard deviation (MAM)","","")
        z->vreg_spatialstddev_jja     = set_varAtts(vreg_sd_jja,vnm+" standard deviation (JJA)","","")
        z->vreg_spatialstddev_son     = set_varAtts(vreg_sd_son,vnm+" standard deviation (SON)","","")
        z->vreg_spatialstddev_ann     = set_varAtts(vreg_sd_ann,vnm+" standard deviation (annual)","","")
        delete(z)
        delete([/modname,fn/])
     end if
;==========================================================================================
     res = True
     res@mpProjection = "WinkelTripel"
     res@mpGeophysicalLineColor = "gray42"
     res@mpPerimOn    = False
     res@mpGridLatSpacingF =  90            ; change latitude  line spacing
     res@mpGridLonSpacingF = 180.           ; change longitude line spacing
     res@mpGridLineColor   = "transparent"  ; trick ncl into drawing perimeter
     res@mpGridAndLimbOn   = True           ; turn on lat/lon lines  
     res@mpFillOn = False
     res@mpCenterLonF = 210.
     res@mpOutlineOn = True  
     if (wks_type.eq."png") then
        res@mpGeophysicalLineThicknessF = 2.  
     else
        res@mpGeophysicalLineThicknessF = 1.  
     end if
     res@gsnDraw      = False
     res@gsnFrame     = False
  
     res@cnLineLabelsOn = False
     res@cnFillOn        = True
     res@cnLinesOn       = False
     res@lbLabelBarOn    = False

     res@cnLevelSelectionMode = "ExplicitLevels"
     

     res@gsnLeftStringOrthogonalPosF = -0.05
     res@gsnLeftStringParallelPosF = .005
     res@gsnRightStringOrthogonalPosF = -0.05
     res@gsnRightStringParallelPosF = 0.96
     res@gsnRightString = ""
     res@gsnLeftString = ""
     res@gsnLeftStringFontHeightF = 0.014
     res@gsnCenterStringFontHeightF = 0.018
     res@gsnRightStringFontHeightF = 0.014

     sres = res
     
     res@cnLevels = fspan(.4,6.0,8)
     if (COLORMAP.eq.0) then
        res@cnFillColors = (/2,4,6,8,10,12,14,16,18/)
        sres@cnLevels  = ispan(972,1044,4)
     end if
     if (COLORMAP.eq.1) then
        res@cnFillColors = (/35,47,63,79,95,111,124,155,175/)
        sres@cnLevels  = ispan(980,1036,4)
     end if

     if (isfilepresent2("obs_"+vnm).and.ee.eq.0) then    ; for pattern correlation table
        patcor = new((/nsim,dimsizes(vreg_sd_ann&lat),dimsizes(vreg_sd_ann&lon)/),typeof(vreg_sd_ann))
        patcor!1 = "lat"
        patcor&lat = vreg_sd_ann&lat
        patcor!2 = "lon"
        patcor&lon = vreg_sd_ann&lon
        patcor(ee,:,:) = (/ vreg_sd_ann /)
     end if
     if (isfilepresent2("obs_"+vnm).and.ee.ge.1.and.isvar("patcor")) then
        patcor(ee,:,:) = (/ totype(linint2(vreg_sd_ann&lon,vreg_sd_ann&lat,vreg_sd_ann,True,patcor&lon,patcor&lat,0),typeof(patcor)) /)
     end if

     res@gsnLeftString = syear(ee)+"-"+eyear(ee) 
     res@gsnRightString = vreg_mean_djf@units
     res@gsnCenterString = names(ee)     
     plot_stddev_djf(ee) = gsn_csm_contour_map(wks_stddev_djf,vreg_sd_djf,res)
     plot_stddev_mam(ee) = gsn_csm_contour_map(wks_stddev_mam,vreg_sd_mam,res)
     plot_stddev_jja(ee) = gsn_csm_contour_map(wks_stddev_jja,vreg_sd_jja,res)
     plot_stddev_son(ee) = gsn_csm_contour_map(wks_stddev_son,vreg_sd_son,res)
     plot_stddev_ann(ee) = gsn_csm_contour_map(wks_stddev_ann,vreg_sd_ann,res)
     
     sres@gsnLeftString = syear(ee)+"-"+eyear(ee) 
     sres@gsnRightString = vreg_mean_djf@units
     sres@gsnCenterString = names(ee)
     plot_mean_djf(ee) = gsn_csm_contour_map(wks_mean_djf,vreg_mean_djf,sres)
     plot_mean_mam(ee) = gsn_csm_contour_map(wks_mean_mam,vreg_mean_mam,sres)
     plot_mean_jja(ee) = gsn_csm_contour_map(wks_mean_jja,vreg_mean_jja,sres)
     plot_mean_son(ee) = gsn_csm_contour_map(wks_mean_son,vreg_mean_son,sres)
     plot_mean_ann(ee) = gsn_csm_contour_map(wks_mean_ann,vreg_mean_ann,sres)
     delete([/vreg_sd_djf,vreg_sd_mam,vreg_sd_jja,vreg_sd_son,vreg_sd_ann,vreg_mean_djf,vreg_mean_mam,vreg_mean_jja,vreg_mean_son,vreg_mean_ann,res,sres/])
  end do     
  
  if (isvar("patcor")) then    ; for pattern correlation table  
     clat = cos(0.01745329*patcor&lat)
     finpr   = vnm+" Std Dev (Ann) "    ; Must be 18 characters long
     line3   = "                  "    ; Must be 18 characters long
     line4   = line3
     header = (/"","Pattern Correlations/RMS Differences   Observations vs. Model(s)",""/)
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
        if (all(ismissing(patcor(hh,:,:)))) then
           finpr = finpr+sprintf(format2,9.99)+"/"+sprintf(format3,9.99)
        else
           finpr = finpr+sprintf(format2,(pattern_cor(patcor(0,:,:),patcor(hh,:,:),clat,0)))+"/"+sprintf(format3,(wgt_arearmse(patcor(0,:,:),patcor(hh,:,:),clat,1.0,0)))
        end if
     end do
     if (dimsizes(tochar(line4)).ge.8190) then   ; system or fortran compiler limit
        print("Metrics table warning: Not creating metrics table as size of comparison results in a invalid ascii row size.")   
     else
        write_table(getenv("OUTDIR")+"metrics.clim.mean_stddev.ncl.txt","w",[/header/],"%s")
        write_table(getenv("OUTDIR")+"metrics.clim.mean_stddev.ncl.txt","a",[/line3/],"%s")
        write_table(getenv("OUTDIR")+"metrics.clim.mean_stddev.ncl.txt","a",[/line4/],"%s")
        write_table(getenv("OUTDIR")+"metrics.clim.mean_stddev.ncl.txt","a",[/finpr/],"%s")
     end if     
     delete([/finpr,line3,line4,format2,format3,nchar,ntc,clat,patcor,dimY,ntb,header/])
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
  panres@lbLabelFontHeightF = 0.013
  panres@lbLabelStride = 1
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
  
  panres@txString = "PSL Standard Deviations (DJF)"
  gsn_panel2(wks_stddev_djf,plot_stddev_djf,(/nrow,ncol/),panres)
  delete(wks_stddev_djf)
  
  panres@txString = "PSL Standard Deviations (MAM)"
  gsn_panel2(wks_stddev_mam,plot_stddev_mam,(/nrow,ncol/),panres)
  delete(wks_stddev_mam)
  
  panres@txString = "PSL Standard Deviations (JJA)"
  gsn_panel2(wks_stddev_jja,plot_stddev_jja,(/nrow,ncol/),panres)
  delete(wks_stddev_jja)
  
  panres@txString = "PSL Standard Deviations (SON)"
  gsn_panel2(wks_stddev_son,plot_stddev_son,(/nrow,ncol/),panres)
  delete(wks_stddev_son)
  
  panres@txString = "PSL Standard Deviations (Annual)"
  gsn_panel2(wks_stddev_ann,plot_stddev_ann,(/nrow,ncol/),panres)
  delete(wks_stddev_ann)
  
  panres@txString = "PSL Means (DJF)"
  gsn_panel2(wks_mean_djf,plot_mean_djf,(/nrow,ncol/),panres)
  delete(wks_mean_djf)
  
  panres@txString = "PSL Means (MAM)"
  gsn_panel2(wks_mean_mam,plot_mean_mam,(/nrow,ncol/),panres)
  delete(wks_mean_mam)
  
  panres@txString = "PSL Means (JJA)"
  gsn_panel2(wks_mean_jja,plot_mean_jja,(/nrow,ncol/),panres)
  delete(wks_mean_jja)
  
  panres@txString = "PSL Means (SON)"
  gsn_panel2(wks_mean_son,plot_mean_son,(/nrow,ncol/),panres)
  delete(wks_mean_son)
  
  panres@txString = "PSL Means (Annual)"
  gsn_panel2(wks_mean_ann,plot_mean_ann,(/nrow,ncol/),panres)
  delete(wks_mean_ann)
  delete(panres)
  pint("Finished: regvar.mean_stddev.ncl")

end do ; end of loop var 
end
