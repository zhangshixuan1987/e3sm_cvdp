  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a eof plot for AAO patterns 
;          Data is vertically interpolated to pressure levels
;          1st panel: EOFs for the first three modes
;          2nd panel: time series plot
; Author : Shixuan Zhang
; Date   : Dec 06, 2020

begin

  compare                                    = getenv("COMPARE")
  outdir                                     = getenv("CASEDIR")
  bakpath                                    = getenv("WKROOT")

  tpath                                      = getenv("TPATH")
  cpath                                      = getenv("CPATH")

  tcase                                      = getenv("TEST")
  ccase                                      = getenv("CTRL")

  tname                                      = getenv("TNAME")
  cname                                      = getenv("CNAME")

  nenst                                      = toint(getenv("NENST"))
  nensc                                      = toint(getenv("NENSC"))

  tttag                                      = getenv("TTTAG")
  cttag                                      = getenv("CTTAG")

  statistical_test                           = getenv("DIFFERENCE_TEST")
  statistical_siglev                         = 0.05

;define constants for unit conversion
  pi                                         = 3.14159265
  rearth                                     = 6.37122e6
  grav                                       = 9.80665

;define regions for eof analysis
  latS                                       = -90.  ;negative for southern hemisphere
  latN                                       = -20.  ;negative for southern hemisphere
  lonW                                       = 0.0
  lonE                                       = 360.0

  
  ieof                                       = 3
  seof                                       = "PSA2"
;variable name in the climo file
  modvars                                    = (/"PSL"/)
  facmod                                     = (/1.0/)
  varunt                                     = (/"Pa"/)

;declear the season or annual mean data to be used;;;;;
  seasons                                   = (/"ANN","DJF","JJA","MAM","SON"/)
  pout                                      = (/"Surface"/)

  maxlev                                    = 11 
  minlev_eof                                = (/-1.2/)              
  maxlev_eof                                = (/ 1.2/)
    
;read in two files

  do ll = 0,dimsizes(pout) - 1

    do kk = 0,dimsizes(seasons) - 1

     ;======================================================================
     ;Read the data for the regression analysis
     ;==================================================================
     if (nenst.gt.1) then 
       if(nensc.gt.1) then 
         fn1 = new(nenst*nensc,string) 
         fn2 = new(nenst*nensc,string)
         do ix = 0,nenst-1, 1
           do iy = 0,nensc-1, 1 
             dout_name = tcase+"_en"+sprinti("%0.2i",ix+1) + "_"+tttag+"__vs__"+ccase+"_en"+sprinti("%0.2i",ix+1)+"_"+cttag
             fn1(ix+iy*nenst) = dout_name+"/"+seof+"_EOF_PCS_"+tname+"_en"+sprinti("%.2f",ix+1)+"_monthly_mean_"+modvars+"_at_"+pout(ll)+"_"+seasons(kk)+".nc"
             fn2(ix+iy*nenst) = dout_name+"/"+seof+"_EOF_PCS_"+cname+"_en"+sprinti("%.2f",ix+1)+"_monthly_mean_"+modvars+"_at_"+pout(ll)+"_"+seasons(kk)+".nc"
           end do 
         end do 
        else
         fn1 = new(nenst,string)
         fn2 = new(nenst,string)
         do ix = 0,nenst-1, 1
           dout_name = tcase+"_en"+sprinti("%0.2i",ix+1) + "_"+tttag+"__vs__"+ccase+"_"+cttag
           fn1(ix) = dout_name+"/"+seof+"_EOF_PCS_"+tname+"_en"+sprinti("%0.2i",ix+1)+"_monthly_mean_"+modvars+"_at_"+pout(ll)+"_"+seasons(kk)+".nc"
           fn2(ix) = dout_name+"/"+seof+"_EOF_PCS_"+cname+"_monthly_mean_"+modvars+"_at_"+pout(ll)+"_"+seasons(kk)+".nc"
         end do
       end if
     else
       dout_name = tcase+"_"+tttag+"__vs__"+ccase+"_"+cttag
       fn1 = dout_name+"/"+seof+"_EOF_PCS_"+tname+"_monthly_mean_"+modvars+"_at_"+pout(ll)+"_"+seasons(kk)+".nc" 
       fn2 = dout_name+"/"+seof+"_EOF_PCS_"+cname+"_monthly_mean_"+modvars+"_at_"+pout(ll)+"_"+seasons(kk)+".nc" 
     end if 

     f1    = addfiles(bakpath+"/data/"+fn1,"r")
     f2    = addfiles(bakpath+"/data/"+fn2,"r")

     ListSetType (f1, "join")  
     ListSetType (f2, "join")

     time1 = f1[0]->time
     time2 = f2[0]->time
     ;;Find the overlap of time slices
     utc_date1 = cd_calendar(time1,-1)
     utc_date2 = cd_calendar(time2,-1)
     indtim    = get1Dindex(utc_date1,utc_date2)
     inddx     = ind(.not.ismissing(indtim))
     utc_date  = utc_date1(indtim(inddx))
     ind1      = get1Dindex(utc_date1,utc_date)
     ind2      = get1Dindex(utc_date2,utc_date)
     yyyyfrac  = yyyymm_to_yyyyfrac(utc_date, 0.0)
     ;print(utc_date1(ind1) +  " " +utc_date2(ind2)+" " +yyyyfrac)
     delete([/utc_date1,utc_date2,indtim,inddx,utc_date/])
     utc_date1  = cd_calendar(time1(ind1),0)
     utc_date2  = cd_calendar(time2(ind2),0)
     tttagx     = toint(min(utc_date1(:,0)))+"-"+toint(max(utc_date1(:,0)))
     cttagx     = toint(min(utc_date2(:,0)))+"-"+toint(max(utc_date2(:,0)))
     panelstr1  = tname + " ("+tttagx+")"
     panelstr2  = cname + " ("+cttagx+")"
     delete([/utc_date1,utc_date2,tttagx,cttagx/])

     ;;;read the data and do processing ;;;;
     pcvar1   = f1[:]->eof@pcvar(ieof-1)
     pcvar2   = f2[:]->eof@pcvar(ieof-1)
     eof1     = f1[:]->eof 
     eof2     = f2[:]->eof 
     eof1_tsx = f1[:]->eof_ts
     eof2_tsx = f2[:]->eof_ts 

     ;;check the two comparing files and see if they are in the same grid,
     ddd1    = dimsizes(eof1)
     ddd2    = dimsizes(eof2)
     ;;otherwise, return the error message;;;;
     if ((ddd1(1).ne.ddd2(1)).or.(ddd1(2).ne.ddd2(2)))then
       print("Error: this scripts requires the two files must in the same grid to run!!!")
       return
     end if

     ;;;calculate the error metrix
     rad     = 4.*atan(1.)/180.    ;
     cost    = tofloat(cos(eof1&lat*rad))       ; cosine weights
     mean1   = wgt_areaave (eof1,cost,1.0,0)
     mean2   = wgt_areaave (eof2,cost,1.0,0)
     mbias   = wgt_areaave (eof1-eof2,cost,1.0,0)
     mrmsd   = wgt_arearmse(eof1,eof2,cost,1.0,0)
     mcorr   = pattern_cor(eof1,eof2,cost, 1)

     empcvar1 = sprintf("%.2f", dim_avg_n(pcvar1,0)) +" ~F34~1~N~~F~ "  + sprintf("%.2f", dim_stddev_n(pcvar1,0))
     empcvar2 = sprintf("%.2f", dim_avg_n(pcvar2,0)) +" ~F34~1~N~~F~ "  + sprintf("%.2f", dim_stddev_n(pcvar2,0))
     enmbias = sprintf("%.2f", dim_avg_n(mbias,0)) +" ~F34~1~N~~F~ "  + sprintf("%.2f", dim_stddev_n(mbias,0))
     enmrmsd = sprintf("%.2f", dim_avg_n(mrmsd,0)) +" ~F34~1~N~~F~ "  + sprintf("%.2f", dim_stddev_n(mrmsd,0))
     enmcorr = sprintf("%.2f", dim_avg_n(mcorr,0)) +" ~F34~1~N~~F~ "  + sprintf("%.2f", dim_stddev_n(mcorr,0))

    ;print(enmbias + "" +enmrmsd +"" +enmcorr)
     eof1_regres = dim_avg_n_Wrap(eof1,0)
     eof2_regres = dim_avg_n_Wrap(eof2,0)

     ;;;PCs analysis 
     tcorr         = escorc_n(eof1_tsx,eof2_tsx,1,1)
     enmtcor       = sprintf("%.2f", dim_avg_n(tcorr,0)) +" ~F34~1~N~~F~ "  + sprintf("%.2f", dim_stddev_n(tcorr,0))      
     dddx          = dimsizes(eof1_tsx)
     eof_ts        = new((/6,dddx(1)/),typeof(eof1_tsx))
     eof_ts(0,:) = dim_avg_n_Wrap(eof1_tsx,0)
     eof_ts(2,:) = dim_avg_n_Wrap(eof1_tsx,0) - tofloat(dim_stddev_n_Wrap(eof1_tsx,0))
     eof_ts(3,:) = dim_avg_n_Wrap(eof1_tsx,0) + tofloat(dim_stddev_n_Wrap(eof1_tsx,0))
     eof_ts(1,:) = dim_avg_n_Wrap(eof2_tsx,0)
     eof_ts(4,:) = dim_avg_n_Wrap(eof2_tsx,0) - tofloat(dim_stddev_n_Wrap(eof2_tsx,0))
     eof_ts(5,:) = dim_avg_n_Wrap(eof2_tsx,0) + tofloat(dim_stddev_n_Wrap(eof2_tsx,0))

     ;;;5-year running mean
     nrunave        = 12
     xstring        = "(1-year runave)"
     xyarr1         = runave_n_Wrap(eof1_tsx,nrunave,0,1)
     xyarr2         = runave_n_Wrap(eof2_tsx,nrunave,0,1)
     tcorr1         = escorc_n(xyarr1,xyarr2,1,1)
     enmtcor1       = sprintf("%.2f", dim_avg_n(tcorr1,0)) +" ~F34~1~N~~F~ "  + sprintf("%.2f", dim_stddev_n(tcorr1,0))
     dddx1          = dimsizes(xyarr1)
     eof_ts1        = new((/6,dddx1(1)/),typeof(xyarr1))
     eof_ts1(0,:) = dim_avg_n_Wrap(xyarr1,0)
     eof_ts1(1,:) = dim_avg_n_Wrap(xyarr2,0)
     eof_ts1(2,:) = dim_avg_n_Wrap(xyarr1,0) - dim_stddev_n_Wrap(xyarr1,0)
     eof_ts1(3,:) = dim_avg_n_Wrap(xyarr1,0) + dim_stddev_n_Wrap(xyarr1,0)
     eof_ts1(4,:) = dim_avg_n_Wrap(xyarr2,0) - dim_stddev_n_Wrap(xyarr2,0)
     eof_ts1(5,:) = dim_avg_n_Wrap(xyarr2,0) + dim_stddev_n_Wrap(xyarr2,0)

     delete([/eof1,eof2,eof1_tsx,eof2_tsx,pcvar1,pcvar2,dddx,ddd1,ddd2/])
     delete([/xyarr1,xyarr2,tcorr1,dddx1/])

     ;======================================================================
     ;Save the data for the statistical analysis
     ;==================================================================
     ;setfileoption("nc", "Format",  "NetCDF4")
     ;out_file  = bakpath +"/tables/"+"Stats_"+seof+"_EOF_"+tname+"__vs__"+cname+"monthly_mean_"+modvars+"_at_"+pout(ll)+"_"+seasons(kk)+".txt"
     ;system("rm " + out_file)

      ;=================================================================
      ;do the plot 
      ;=================================================================
      smbias    = "Mean diff:   " + enmbias
      smrmsd    = "RMS  diff:   " + enmrmsd
      smcorr    = "Correlation: " + enmcorr
      pstring1   = smbias + "~C~" + smrmsd + "~C~" + smcorr

      wtype                        = "eps"
      figdir                       = bakpath+"/tables/"
      fe                           = seof+"_EOF_"+tname+"_"+tttag+"__vs__"+cname+"_"+cttag+"_"+seasons(kk)+"_"+pout(ll) 
      wks                          = gsn_open_wks(wtype, figdir + fe)

      plot      = new((/4/),graphic)
      tsmap1    = new((/4/),graphic)
      tsmap2    = new((/4/),graphic)
      
      ;============================================================
      ; PLOTS
      ;============================================================
         res                      = True
         res@gsnDraw              = False        ; don't draw yet
         res@gsnFrame             = False        ; don't advance frame yet
         res@gsnPolar             = "SH"

         res@mpFillOn             = False        ; turn off map fill
         res@mpMaxLatF            = latN
        ;res@mpCenterLonF         = 180

         FontHeightF = 0.018
         res@tiMainFontHeightF        = FontHeightF*1.5
         res@tmYLLabelFontHeightF     = FontHeightF
         res@tmXBLabelFontHeightF     = FontHeightF
         res@lbLabelFontHeightF       = FontHeightF
         res@gsnStringFontHeightF     = FontHeightF

         res@cnFillOn                 = True         ; turn on color fill
         res@cnFillPalette            = "BlueWhiteOrangeRed"
         res@cnLinesOn                = False        ; True is default
         res@cnLineLabelsOn           = False        ; True is default

         res@lbLabelBarOn             = True
         res@lbOrientation            = "Vertical"
         res@lbTitleString            = "" ;mvarnam +" ("+xAnom@units+")" ;Geopential height (gpm)";
         res@lbTitlePosition          = "Right"                           ; title location
         res@lbTitleDirection         = "Across"                          ; letter angle
         res@lbTitleAngleF            = 90.                               ; title angle
         res@lbTitleFontHeightF       = FontHeightF                    ; font height
        ;res@pmLabelBarParallelPosF   = 0.61
         res@pmLabelBarOrthogonalPosF = 0.15

         res@tmXTOn                   = False
         res@tmBorderThicknessF       = 1.0
         res@tmXBMajorThicknessF      = 1.0
         res@tmXBMinorThicknessF      = 1.0
         res@tmYLMajorThicknessF      = 1.0
         res@tmYLMinorThicknessF      = 1.0
         res@tmYRMajorThicknessF      = 1.0
         res@tmYRMinorThicknessF      = 1.0

        res@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following 3 resources
        maxlev        = 11
        minlev_eof    = -200.
        maxlev_eof    =  200.
        mnmxint = nice_mnmxintvl( minlev_eof, maxlev_eof, maxlev, False)
        res@cnMinLevelValF           = mnmxint(0) ; set the minimum contour level
        res@cnMaxLevelValF           = mnmxint(1) ; set the maximum contour level
        res@cnLevelSpacingF          = mnmxint(2) ; *special* match CPC
        delete([/mnmxint/])

       ;*******************************************
       ; first plot
       ;*******************************************
          res@mpLabelFontHeightF           = FontHeightF*2.0
          res@gsnPolarLabelFontHeightF     = FontHeightF

          ;---Draw first plot in upper left corner
          lstr = modvars+ " EOF("+seof+") ~C~ ("+empcvar1+"%)"
          res@gsnLeftString     = lstr
          res@gsnRightString    = pstring1
          res@gsnCenterString   = ""
          res@tiMainOffsetYF    = 0.0
          res@tiMainString      = panelstr1
          plot(0)   = gsn_csm_contour_map_polar(wks,eof1_regres(:,:),res)

          ;---Draw second plot in upper right corner
          lstr = modvars+" EOF ("+seof+") ~C~ ("+empcvar2 +"%)"
          res@gsnLeftString     = lstr
          res@gsnRightString    = ""
          res@gsnCenterString   = "" ;panelstr2
          res@tiMainString      = panelstr2
          res@tiMainOffsetYF    = 0.015
          plot(1) = gsn_csm_contour_map_polar(wks,eof2_regres(:,:),res)

       ;*******************************************
       ; second plot
       ;*******************************************
        ; EOF time series  [bar form]

          rts           = True
          rts@gsnDraw   = False       ; don't draw yet
          rts@gsnFrame  = False       ; don't advance frame yet
          rts@gsnScale  = True        ; force text scaling               

          FontHeightF = 0.018
          rts@tiMainFontHeightF        = FontHeightF*1.5
          rts@tmYLLabelFontHeightF     = FontHeightF
          rts@tmXBLabelFontHeightF     = FontHeightF
          rts@gsnStringFontHeightF     = FontHeightF*1.2
          rts@tiYAxisFontHeightF       = FontHeightF*1.2
          rts@tiXAxisFontHeightF       = FontHeightF*1.2

          rts@tiYAxisString = "" ;"Standardized Index"  
          rts@tiXAxisString = "Time"

          rts@vpHeightF = 0.40        ; Changes the aspect ratio
          rts@vpWidthF  = 0.85
          rts@vpXF      = 0.10        ; change start locations
          rts@vpYF      = 0.75        ; the plot

          rts@tiYAxisString      = ""      ; add an axis title
          rts@tiMainString       = "" ;"Case: "+panelstr1

          rts@tmXTOn                       = False
          rts@tmBorderThicknessF           = 1.0
          rts@tmXBMajorThicknessF          = 1.0
          rts@tmXBMinorThicknessF          = 1.0
          rts@tmYLMajorThicknessF          = 1.0
          rts@tmYLMinorThicknessF          = 1.0
          rts@tmYRMajorThicknessF          = 1.0
          rts@tmYRMinorThicknessF          = 1.0
          rts@txFontHeightF      = 0.0195            ; change title font heights

          rts@gsnYRefLine             = 0.              ; reference line
          rts@gsnYRefLineColor        = "grey25"
          rts@gsnYRefLineDashPattern  = 5
          rts@gsnYRefLineThicknessF   = 0.5
          rts@gsnXYBarChart           = False ;True           ; create bar chart 
          rts@gsnXYFillColors         = "Transparent"

          rts@xyMonoLineColor    = False             ; want colored lines
          rts@xyLineColors       = (/"red","black"/) 
          rts@xyLineThicknesses	 = (/1.,1./)      ; line thicknesses
          rts@xyDashPatterns	 = (/0.,0./)      ; make all lines solid

          rts1 = rts
          rts1@trYMinF                      = -4.0
          rts1@trYMaxF                      =  5.0
         ;rts1@trXMinF                      = miny
         ;rts1@trXMaxF                      = maxy
          rts1@gsnLeftString      = seof + " (corr: "+enmtcor+")"
          rts1@gsnRightString     = "norm. index (original)"
          plot(2) = gsn_csm_xy (wks,yyyyfrac,eof_ts(0:1,:),rts1)       ; create line plot

          ; Create a plot with the area between both curves filled in black.
          delete(rts1@xyLineColors)
          rts1@gsnLeftString       = ""
          rts1@gsnRightString      = ""
          rts1@gsnCenterString     = ""
          rts1@gsnXYFillColors     = "LightPink"
          rts1@xyLineColor         = -1        
          tsmap1(1)                = gsn_csm_xy(wks,yyyyfrac,eof_ts(2:3,:),rts1)
         ; Create a plot with the area between both curves filled in black.
          rts1@gsnLeftString       = ""
          rts1@gsnRightString      = ""
          rts1@gsnCenterString     = ""
          rts1@gsnXYFillColors     = "LightBlue"
          rts1@xyLineColor         = -1
          tsmap1(2)                = gsn_csm_xy(wks,yyyyfrac,eof_ts(4:5,:),rts1)
          overlay(plot(2),tsmap1(2))
          overlay(plot(2),tsmap1(1))

          rts2 = rts
          rts2@trYMinF                      = -3.0
          rts2@trYMaxF                      =  3.0
         ;rts2@trXMinF                      = miny
         ;rts2@trXMaxF                      = maxy
          rts2@gsnLeftString      = seof + " (corr: "+enmtcor1+")"
          rts2@gsnRightString     = "norm. index " + xstring
          plot(3) = gsn_csm_xy (wks,yyyyfrac,eof_ts1(0:1,:),rts2)       ; create line plot
          ; Create a plot with the area between both curves filled in black.
          delete(rts2@xyLineColors)
          rts2@gsnLeftString       = ""
          rts2@gsnRightString      = ""
          rts2@gsnCenterString     = ""
          rts2@gsnXYFillColors     = "LightPink"
          rts2@xyLineColor         = -1
          tsmap2(1)                = gsn_csm_xy(wks,yyyyfrac,eof_ts1(2:3,:),rts2)
         ; Create a plot with the area between both curves filled in black.
          rts2@gsnLeftString       = ""
          rts2@gsnRightString      = ""
          rts2@gsnCenterString     = ""
          rts2@gsnXYFillColors     = "LightBlue"
          rts2@xyLineColor         = -1
          tsmap2(2)               = gsn_csm_xy(wks,yyyyfrac,eof_ts1(4:5,:),rts2)
          overlay(plot(3),tsmap2(2))
          overlay(plot(3),tsmap2(1))

          ;*****************************************************   
          ; Manually create and attach legend
          ;***************************************************** 
          res_text                    = True                  ; text mods desired
          res_text@txFontHeightF      = 0.015                 ; change text size
          res_text@txJust             = "CenterLeft"          ; text justification

          res_lines                   = True                  ; polyline mods desired
          res_lines@gsLineDashPattern = 0.                    ; solid line
          res_lines@gsLineThicknessF  = 1.                    ; line thicker
          res_lines@gsLineColor       = "red"                 ; line color
          xx = (/min(yyyyfrac)+30,min(yyyyfrac)+45/)
          yy = (/3.5,3.5/)
          dum1 = gsn_add_polyline(wks,plot(2),xx,yy,res_lines)              ; add polyline
          dum2 = gsn_add_text(wks,plot(2),tname,min(yyyyfrac)+50,yy(0),res_text); add text
 
          xx = (/min(yyyyfrac)+30,min(yyyyfrac)+45/)
          yy = (/1.5,1.5/)
          dum1x = gsn_add_polyline(wks,plot(3),xx,yy,res_lines)              ; add polyline
          dum2x = gsn_add_text(wks,plot(3),tname,min(yyyyfrac)+50,yy(0),res_text); add text
 
          yy = (/4.5,4.5/)
          res_lines@gsLineColor       = "black"                                 ; change to black
          dum3 = gsn_add_polyline(wks,plot(2),xx,yy,res_lines)                ; add polyline
          dum4 = gsn_add_text(wks,plot(2),cname,min(yyyyfrac)+50,yy(0),res_text)       ; add text

          xx = (/min(yyyyfrac)+30,min(yyyyfrac)+45/)
          yy = (/2.5,2.5/)
          dum3x = gsn_add_polyline(wks,plot(3),xx,yy,res_lines)                ; add polyline
          dum4x = gsn_add_text(wks,plot(3),cname,min(yyyyfrac)+50,yy(0),res_text)       ; add text

       ; panel plot only resources
          pres1                          = True                ; mods desired
          pres1@gsnFrame                 = False               ; save panel until both ready
          pres1@gsnPanelBottom           = 0.45    ; space for label bar
          pres1@gsnPanelTop              = 0.85     ; only panel on lower half of page
          pres1@gsnPanelXF               = (/0.07,0.57/)
          gsn_panel(wks,plot(0:1),(/1,2/),pres1)          ; create first panel

          pres2                           = True                ; mods desired
          pres2@gsnFrame                  = False               ; save panel until both ready
          pres2@gsnPanelBottom            = 0.05                ; draw from center to right edge
          pres2@gsnPanelTop               = 0.5                ; draw from center to right edge
          gsn_panel(wks,plot(2:3),(/1,2/),pres2)       ; create first panel

          frame(wks)                                   ; draw both on same page
          delete(tsmap2)
          delete(tsmap1)
          delete([/eof1_regres,eof2_regres, yyyyfrac, eof_ts, eof_ts1/])
          delete([/f1,f2,time1,time2,ind1,ind2/])

        end do                                              ; end of looping over seasons

  end do                                                    ; end of looping over pressure levels

end

