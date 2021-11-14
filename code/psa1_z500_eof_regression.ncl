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
  opath                                      = getenv("DIAG_DATA_ROOT")

  tpath                                      = getenv("TPATH")
  cpath                                      = getenv("CPATH")

  tcase                                      = getenv("TEST")
  ccase                                      = getenv("CTRL")

  tname                                      = getenv("TNAME")
  cname                                      = getenv("CNAME")

  tttag                                      = getenv("TTTAG")
  cttag                                      = getenv("CTTAG")

  statistical_test                           = getenv("REGRESSION_TEST")
  statistical_siglev                         = 0.05
  l_regress                                  = "l_regress_z500"

;define regions for eof analysis
  latS                                         = -90.  ;negative for southern hemisphere
  latN                                         = -20.  ;negative for southern hemisphere

;declear the season or annual mean data to be used;;;;;
  seasons                                      = (/"ANN","DJF","JJA","MAM","SON"/)

;define # of desired EOFs
  neof                                         = 1
  eof                                          = (/"PSA1"/)
  eofmodvar                                    = ("Z3")
  eofplev                                      = ("500")

;read in two files

   f                                       = systemfunc("ls "+tpath+"/"+tcase+"_*_"+tttag+".nc")
   f1                                      = addfile(f,"r")
   gw1                                     = f1->gw

   f                                       = systemfunc("ls "+cpath+"/"+ccase+"_*_"+cttag+".nc")
   f2                                      = addfile(f,"r")
   gw2                                     = f2->gw

  ; =================================================================
   ;;;;;;start to do the regression;;;;
   print ("Start to regress mslp eof index on selected variables ")
   load "./share_info_for_regression_map.ncl"

   do jj = 0, dimsizes(modregvars)-1

      mvarnam  = modregvars(jj)
      print("working on variable "+ mvarnam)
      load "./function_read_model_var.ncl"

      if (compare.eq."Model_vs_OBS") then
        ovarnam  = obsregvars(jj)
        load "./function_read_obs_var.ncl"
      end if

      var1@_FillValue                      = -9999.
      var2@_FillValue                      = -9999.

      if(compare.eq."Model_vs_OBS") then
        var1                               = var1*facmod(jj)
        var2                               = var2*facobs(jj)
      else
        var1                               = var1*facmod(jj)
        var2                               = var2*facmod(jj)
      end if

      var1@units                           = varunt(jj)
      var2@units                           = varunt(jj)

      ;;check the two comparing files and see if they are in the same grid,
      ddd1                                  = dimsizes(var1)
      ddd2                                  = dimsizes(var2)
      ;;otherwise, return the error message;;;;
      if ((ddd1(1).ne.ddd2(1)).or.(ddd1(2).ne.ddd2(2)))then
        print("Error: this scripts requires the two files must in the same grid to run!!!")
        return
      end if

  ; ==============================================================
  ; User defined parameters that specify region of globe and
  ; ==============================================================
    regx1  = var1(:,{latS:latN},:)
    regy1  = var2(:,{latS:latN},:)

    latx1  = regx1&lat
    lonx1  = regx1&lon
    latx2  = regy1&lat
    lonx2  = regy1&lon

  ; ==============================================================
  ; compute climatology and Anomalies
  ; ==============================================================
    regxClm1   = clmMonTLL(regx1)                      ; (12,lat,lon)
    regyClm1   = clmMonTLL(regy1)

    regxAnom1  = calcMonAnomTLL (regx1, regxClm1 )
    regyAnom1  = calcMonAnomTLL (regy1, regyClm1 )

  ; =================================================================
  ; Select different season for the eof regression
  ; =================================================================
    ;shift the model time to be consistent with the observations;;;
    regxAnom1&time = regxAnom1&time - 1.0
    if(compare.ne."Model_vs_OBS")then
      regyAnom1&time = regyAnom1&time - 1.0
    end if
    utc_date1 = cd_calendar(regxAnom1&time,0)
    utc_date2 = cd_calendar(regyAnom1&time,0)
    monthx1   = tointeger(utc_date1(:,1))
    monthx2   = tointeger(utc_date2(:,1))
   delete([/utc_date1,utc_date2/])

  do kk = 0,dimsizes(seasons) - 1

    if(seasons(kk).eq."ANN")then

      indx1 = ind ((monthx1.ge.1).and.(monthx1.le.12))
      indx2 = ind ((monthx2.ge.1).and.(monthx2.le.12))

    else if (seasons(kk).eq."DJF")then

      indx1 = ind ((monthx1.eq.12).or.(monthx1.eq.1).or.(monthx1.eq.2))
      indx2 = ind ((monthx2.eq.12).or.(monthx2.eq.1).or.(monthx2.eq.2))

    else if (seasons(kk).eq."JJA") then

      indx1 = ind ((monthx1.eq.6).or.(monthx1.eq.7).or.(monthx1.eq.8))
      indx2 = ind ((monthx2.eq.6).or.(monthx2.eq.7).or.(monthx2.eq.8))

    else if (seasons(kk).eq."MAM") then

      indx1 = ind ((monthx1.eq.ne*3).or.(monthx1.eq.4).or.(monthx1.eq.5))
      indx2 = ind ((monthx2.eq.ne*3).or.(monthx2.eq.4).or.(monthx2.eq.5))

    else if (seasons(kk).eq."SON") then

      indx1 = ind ((monthx1.eq.9).or.(monthx1.eq.10).or.(monthx1.eq.11))
      indx2 = ind ((monthx2.eq.9).or.(monthx2.eq.10).or.(monthx2.eq.11))

    else

      print("User did not specify the season, use all of the monthly data")
      indx1 = ind ((monthx1.ge.1).and.(monthx1.le.12))
      indx2 = ind ((monthx2.ge.1).and.(monthx2.le.12))

    end if
    end if
    end if
    end if 
    end if 

    regxAnom = regxAnom1(indx1,:,:)
    regyAnom = regyAnom1(indx2,:,:)

    delete([/indx1,indx2/])

  ; =================================================================
  ; Regress
  ; =================================================================

    do ne=0,neof-1
   
     ;read PC time series for regression
     eof_file1  = opath +"/"+eof(ne)+"_EOF_PCS_"+tname+"_monthly_mean_"+eofmodvar+"_at_"+eofplev+"hPa_"+seasons(kk)+".nc"
     eof_file2  = opath +"/"+eof(ne)+"_EOF_PCS_"+cname+"_monthly_mean_"+eofmodvar+"_at_"+eofplev+"hPa_"+seasons(kk)+".nc"
     feof1      = addfile(eof_file1,"r")
     feof2      = addfile(eof_file2,"r")
     eof1_ts    = feof1->eof_ts
     eof2_ts    = feof2->eof_ts
     eof1       = feof1->eof
     eof2       = feof2->eof 
     delete([/eof_file1,eof_file2,feof1,feof2/])

     ddeof1      = dimsizes(regxAnom)
     ddeof2      = dimsizes(regyAnom) 

     eof1_regres = new((/ddeof1(1),ddeof1(2)/),typeof(regxAnom))     ; create an array w meta data
     eof2_regres = new((/ddeof2(1),ddeof2(2)/),typeof(regyAnom))     ; create an array w meta data
     eof1_regres@_FillValue = -9999.
     eof2_regres@_FillValue = -9999.

     eof1_regres!0 = "lat"
     eof1_regres!1 = "lon"
     eof1_regres&lat = regxAnom&lat
     eof1_regres&lon = regxAnom&lon

     eof2_regres!0 = "lat"
     eof2_regres!1 = "lon"
     eof2_regres&lat = regyAnom&lat
     eof2_regres&lon = regyAnom&lon

     eof1_rgprob = eof1_regres
     eof2_rgprob = eof2_regres

     rc1   = regCoef_n(eof1_ts, regxAnom, 0, 0)
     rc2   = regCoef_n(eof2_ts, regyAnom, 0, 0)
     rc1@_FillValue = -9999.
     rc2@_FillValue = -9999.

     if (str_lower(statistical_test).eq. "true")then        

      l_plot_test = True 

      drc1  = dimsizes(rc1) 
      df1   = rc1@nptxy-2   ; degrees of freedom
      tval1 = rc1@tval      ; t-statistic
      xb1   = tval1
      xb1   = 0.50
      pb1   = betainc(df1/(df1+tval1^2),df1/2.0,xb1)
      prob1 = reshape(pb1,(/drc1(0),drc1(1)/))
      prob1 = where(prob1.le.statistical_siglev,rc1,rc1@_FillValue)
      eof1_rgprob = (/ tofloat(prob1) /)
      delete([/drc1,df1,tval1,xb1,pb1,prob1/])

      drc2  = dimsizes(rc2)
      df2   = rc2@nptxy-2   ; degrees of freedom
      tval2 = rc2@tval      ; t-statistic
      xb2   = tval2
      xb2   = 0.50
      pb2   = betainc(df2/(df2+tval2^2),df2/2.0,xb2)
      prob2 = reshape(pb2,(/drc2(0),drc2(1)/))
      prob2 = where(prob2.le.statistical_siglev,rc2,rc2@_FillValue)
      eof2_rgprob = (/ tofloat(prob2) /)
      delete([/drc2,df2,tval2,xb2,pb2,prob2/])
     end if 

     eof1_regres = (/ doubletofloat(rc1) /)
     eof2_regres = (/ doubletofloat(rc2) /)

     delete([/rc1,rc2/])

     eof1_rgprob = (1.0 - eof1_rgprob)*100.0
     eof2_rgprob = (1.0 - eof2_rgprob)*100.0

     ;;;calculate the error metrix 
     rad     = 4.*atan(1.)/180.    ;
     cost    = tofloat(cos(eof1_regres&lat*rad))       ; cosine weights
     mean1   = wgt_areaave (eof1_regres,cost,1.0,0)
     mean2   = wgt_areaave (eof2_regres,cost,1.0,0)
     mbias   = wgt_areaave (eof1_regres-eof2_regres,cost,1.0,0)
     mrmsd   = wgt_arearmse(eof1_regres-conform(eof1_regres,mean1,0),eof2_regres-conform(eof2_regres,mean2,0),cost,1.0,0)
     mcorr   = pattern_cor(eof1_regres,eof2_regres,cost, 1) 
  
     eofd_regres = eof1_regres 
     eofd_regres = eof1_regres - eof2_regres
     delete([/rad,cost,mean1,mean2/])

  ; =================================================================
  ; Extract the YYYYMM from the time coordinate 
  ; associated with eof_ts [same as x&time] 
  ; =================================================================
    utc_date1 = cd_calendar(eof1_ts&time,-1)
    utc_date2 = cd_calendar(eof2_ts&time,-1)

    yyyy1     = yyyymm_to_yyyyfrac(utc_date1, 0.0) ;utc_date1(:,0)
    yyyy2     = yyyymm_to_yyyyfrac(utc_date2, 0.0) ;utc_date2(:,0)

    delete([/utc_date1,utc_date2/])

 ;;;;start to plot
  wtype                        = "eps"
  figdir                       = outdir+"/Polar_PSA1_Analysis/"
  fe                           = "PSA1_EOF_Z500_regression_on_"+modregvars(jj)+"_"+seasons(kk)
  wks                          = gsn_open_wks(wtype, figdir + fe)

  plot = new (neof*3,graphic)
  dum  = new (neof*3,graphic)

  smbias    = "Mean diff:   " + sprintf("%5.2f", mbias)
  smrmsd    = "RMS  diff:   " + sprintf("%5.2f", mrmsd)
  smcorr    = "Correlation: " + sprintf("%5.2f", mcorr)

  pstring   = smbias + "~C~" + smrmsd + "~C~" + smcorr

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
    res@gsnStringFontHeightF     = FontHeightF*1.2

    res@cnFillOn                 = True         ; turn on color fill
    res@cnFillPalette            = "BlueDarkRed18"  
    res@cnLinesOn                = False        ; True is default
    res@cnLineLabelsOn           = False        ; True is default

    res@lbLabelBarOn             = True
    res@lbOrientation            = "Vertical"
    res@lbTitleString            = mvarnam +" ("+regxAnom@units+")" ;Geopential height (gpm)";
    res@lbTitlePosition          = "Right"                           ; title location
    res@lbTitleDirection         = "Across"                          ; letter angle
    res@lbTitleAngleF            = 90.                               ; title angle
    res@lbTitleFontHeightF       = FontHeightF                    ; font height
   ;res@pmLabelBarParallelPosF   = 0.61
    res@pmLabelBarOrthogonalPosF = 0.15

    res@tmXTOn                   = False
    res@tmYLLabelFontHeightF     = 0.025
    res@tmBorderThicknessF       = 1.0
    res@tmXBMajorThicknessF      = 1.0
    res@tmXBMinorThicknessF      = 1.0
    res@tmYLMajorThicknessF      = 1.0
    res@tmYLMinorThicknessF      = 1.0
    res@tmYRMajorThicknessF      = 1.0
    res@tmYRMinorThicknessF      = 1.0

   ;set symmetric plot min/ma
   ;tmpdat = (/eof1_regres,eof2_regres/)
   ;symMinMaxPlt(tmpdat, 16, False, res)      ; contributed.ncl
   ;delete(tmpdat)

   res@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following ne*3 resources
   mnmxint = nice_mnmxintvl( -lev_eof1(jj), lev_eof1(jj), maxlev, False)
   res@cnMinLevelValF           = mnmxint(0) ; set the minimum contour level
   res@cnMaxLevelValF           = mnmxint(1) ; set the maximum contour level     
   res@cnLevelSpacingF          = mnmxint(2) ; *special* match CPC

   delete([/mnmxint/])

   res@mpLabelFontHeightF           = FontHeightF*2.0
   res@gsnPolarLabelFontHeightF     = FontHeightF

   left_string   = "Regress on ~C~"+ str_upper(mvarnam)+ " ("+varunt(jj)+")"
   right_string  = eof(ne)
   center_string = ""

   ;*******************************************
   ; first plot
   ;*******************************************
   ;---Draw first plot in upper left corner
     res@gsnLeftString     = left_string
     res@gsnRightString    = right_string
     res@gsnCenterString   = center_string
     res@tiMainString      = "" + panelstr1
     plot(ne*3)   = gsn_csm_contour_map_polar(wks,eof1_regres(:,:),res)

    ;---Draw second plot in upper right corner
     res@gsnLeftString     = left_string
     res@gsnRightString    = right_string
     res@gsnCenterString   = center_string
     res@tiMainString    = ""+panelstr2
     plot(ne*3+1) = gsn_csm_contour_map_polar(wks,eof2_regres(:,:),res)

    ;---Draw third plot in upper right corner
     resd = res
     resd@cnFillPalette     = "BlueDarkOrange18"
     resd@gsnLeftString     = "Difference ("+eof(ne)+")" 
     resd@gsnRightString    = pstring
     resd@gsnCenterString   = "" ;panelstr2
     resd@tiMainString      = ""
     plot(ne*3+2)           = gsn_csm_contour_map_polar(wks,eofd_regres(:,:),resd)

     rescn2 = True
     rescn2@lbLabelBarOn    = False
     rescn2@gsnTickMarksOn  = False	; no tickmarks
     rescn2@gsnDraw         = False	; don't draw
     rescn2@gsnFrame        = False	; don't advance frame
     rescn2@tiMainString    = ""
     rescn2@gsnLeftString   = ""
     rescn2@gsnRightString  = ""
     rescn2@cnMinLevelValF  = (1.0 - statistical_siglev)*100.0
     rescn2@cnMaxLevelValF  = 100.0
    ;rescn2@cnLevelSpacingF = 1.
     rescn2@cnMonoFillPattern = True
     rescn2@cnMonoFillColor = True
     rescn2@cnFillOn        = True	; color fill
     rescn2@cnLinesOn       = False
     rescn2@cnLineLabelsOn  = False        ; True is default
     rescn2@cnInfoLabelOn   = False                ; turn off info label
     rescn2@cnFillMode      = "AreaFill" ; raster fill significance patterns
     rescn2@cnFillPattern   = 17
     rescn2@cnFillDotSizeF  = 0.002
     rescn2@cnFillColor     = "black"
     rescn2@cnFillOpacityF  = 0.5
     dum(ne*3)   = gsn_csm_contour(wks,eof1_rgprob(:,:),rescn2) ; contours are at 95,100
     dum(ne*3+1) = gsn_csm_contour(wks,eof2_rgprob(:,:),rescn2) ; contours are at 95,100

     overlay(plot(ne*3),dum(ne*3))
     overlay(plot(ne*3+1),dum(ne*3+1))

    end do ; end of eof mods

  ; panel plot only resources
     pres                          = True                ; mods desired
    ;pres@gsnPanelBottom           = 0.45    ; space for label bar
    ;pres@gsnPanelTop              = 0.85     ; only panel on lower half of page
     pres@gsnPanelXF               = (/0.07,0.37,0.67/)
     gsn_panel(wks,plot,(/neof,3/),pres)          ; create first panel
   
     delete([/regxAnom,regyAnom/])
     delete([/eof1_regres,eof2_regres,eofd_regres,eof1,eof2,eof1_ts,eof2_ts/])
     delete([/yyyy1,yyyy2,mbias,mrmsd,mcorr/])

   end do        

    delete([/monthx1,monthx2/])
    delete([/regxAnom1,regyAnom1,regx1,regy1,regxClm1,regyClm1/])
     
  end do                                              ; end of looping over variables

end

