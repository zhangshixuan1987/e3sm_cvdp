  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a jet plot for AAO patterns 
;          Data is vertically interpolated to pressure levels
;          1st panel: EOFs for the first three modes
;          2nd panel: time series plot
; Author : Shixuan Zhang
; Date   : Dec 06, 2020

begin

  compare                                    = getenv("COMPARE")
  tpath                                      = getenv("TPATH")
  cpath                                      = getenv("CPATH")
  case1name                                  = getenv("TEST_NAME")
  case2name                                  = getenv("CTRL_NAME")
  casedir                                    = getenv("CASEDIR")
  obstimtag                                  = getenv("OBS_TIME_TAG")
  opath                                      = getenv("DIAG_DATA_ROOT")
  statistical_test                           = getenv("REGRESSION_TEST")
  statistical_siglev                         = 0.1
  l_regress                                  = "l_regress_jet_pos"

;define regions for jet analysis
  latS                                       = -90.  ;negative for southern hemisphere
  latN                                       = -20.  ;negative for southern hemisphere

;declear the season or annual mean data to be used;;;;;
  seasons                                      = (/"ANN","DJF","JJA"/)

;define the jet index information
  jet                                        = (/"Jet position"/)
  jetmodvar                                  = ("U")
  jetplev                                    = ("850")

;define color for the plot of signiticant test 
  FillColor           = "Black";"Grey75" ;"Grey65";"Grey28";"Grey";"Black"
  FillPattern         = 0 ;17 ;6 ;17;11
  FillScaleF          = 5.0
  FillDotSizeF        = 0.00002    ; increase dot size of contours
  FillOpacityF        = 0.5 ;0.15

;read in two files

  f                                      = systemfunc("ls $TPATH/*_monthly_means.nc")
  f1                                     = addfile(f,"r")

  if(compare.eq."Model_vs_OBS") then
    f                                    = systemfunc("ls $CPATH/*_siglev_analysis*monthly*.nc")
    f2                                   = addfile(f,"r")
  else
    f                                    = systemfunc("ls $CPATH/*_monthly_means.nc")
    f2                                   = addfile(f,"r")
  end if

 ; =================================================================
  ;;;;;;start to do the regression;;;;
  print ("Start to regress enso index on selected variables ")
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

     var1@_FillValue                      = -9999.
     var2@_FillValue                      = -9999.

     ddd1                                = dimsizes(var1)
     ddd2                                = dimsizes(var2)

     ;printVarSummary(var1)
     ;printVarSummary(var2)

     ;;check the two comparing files and see if they are in the same grid, 
     ;;otherwise, return the error message;;;;
     if ((ddd1(1).ne.ddd2(1)).or.(ddd1(2).ne.ddd2(2))) then 
      print("Error: this scripts requires the two files must in the same grid to run!!!")
      return
     end if

 ; ==============================================================
 ; User defined parameters that specify region of globe and
 ; ==============================================================
   regx1  = var1(:,{latS:latN},:)
   regy1  = var2(:,{latS:latN},:)
   delete([/var1,var2/])

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

 do kk = 0,dimsizes(seasons) - 1

 ; =================================================================
 ; Select different season for the jet regression
 ; =================================================================
   utc_date1 = cd_calendar(regxAnom1&time,0)
   utc_date2 = cd_calendar(regyAnom1&time,0)
   monthx1   = tointeger(utc_date1(:,1))
   monthx2   = tointeger(utc_date2(:,1))

   if(seasons(kk).eq."ANN")then

     indx1 = ind ((monthx1.ge.1).and.(monthx1.le.12))
     indx2 = ind ((monthx2.ge.1).and.(monthx2.le.12))

   else if (seasons(kk).eq."DJF")then

     indx1 = ind ((monthx1.eq.12).or.(monthx1.eq.1).or.(monthx1.eq.2))
     indx2 = ind ((monthx2.eq.12).or.(monthx2.eq.1).or.(monthx2.eq.2))

   else if (seasons(kk).eq."JJA") then

     indx1 = ind ((monthx1.eq.6).or.(monthx1.eq.7).or.(monthx1.eq.8))
     indx2 = ind ((monthx2.eq.6).or.(monthx2.eq.7).or.(monthx2.eq.8))

   else

     print("User did not specify the season, use all of the monthly data")
     indx1 = ind ((monthx1.ge.1).and.(monthx1.le.12))
     indx2 = ind ((monthx2.ge.1).and.(monthx2.le.12))

   end if
   end if
   end if

   regxAnom = regxAnom1(indx1,:,:)
   regyAnom = regyAnom1(indx2,:,:)

   delete([/indx1,indx2,utc_date1,utc_date2,monthx1,monthx2/])

 ; =================================================================
 ; Regress
 ; =================================================================
  
 ; read PC time series for regression
   jet_file1  = opath +"/"+"Jet_index_"+case1name+"_monthly_mean_"+jetmodvar+"_at_"+toint(jetplev)+"hPa_"+seasons(kk)+".nc"
   jet_file2  = opath +"/"+"Jet_index_"+case2name+"_monthly_mean_"+jetmodvar+"_at_"+toint(jetplev)+"hPa_"+seasons(kk)+".nc"
   fjet1      = addfile(jet_file1,"r")
   fjet2      = addfile(jet_file2,"r")
   jet1_ts    = fjet1->jetd_pos
   jet2_ts    = fjet2->jetd_pos
   jet1       = fjet1->jetd_ins
   jet2       = fjet2->jetd_ins

   delete([/jet_file1,jet_file2,fjet1,fjet2/])

   ddjet1      = dimsizes(regxAnom)
   ddjet2      = dimsizes(regyAnom) 
   jet1_lat    = new((/ddjet1(1)*ddjet1(2)/),typeof(latx1))
   jet1_lon    = new((/ddjet1(1)*ddjet1(2)/),typeof(lonx1))
   jet2_lat    = new((/ddjet2(1)*ddjet2(2)/),typeof(latx2))
   jet2_lon    = new((/ddjet2(1)*ddjet2(2)/),typeof(lonx2))
   jet1_lat@_FillValue = -9999.
   jet1_lon@_FillValue = -9999.
   jet2_lat@_FillValue = -9999.
   jet2_lon@_FillValue = -9999.


   jet1_regres = new((/ddjet1(1),ddjet1(2)/),typeof(regxAnom))     ; create an array w meta data
   jet2_regres = new((/ddjet2(1),ddjet2(2)/),typeof(regyAnom))     ; create an array w meta data
   jet1_regres@_FillValue = -9999.
   jet2_regres@_FillValue = -9999.
   jet1_regres!0 = "lat"
   jet1_regres!1 = "lon"
   jet1_regres&lat = regxAnom&lat
   jet1_regres&lon = regxAnom&lon
   jet2_regres!0 = "lat"
   jet2_regres!1 = "lon"
   jet2_regres&lat = regyAnom&lat
   jet2_regres&lon = regyAnom&lon

   rc1   = regCoef_n(jet1_ts, regxAnom, 0, 0)
   rc2   = regCoef_n(jet2_ts, regyAnom, 0, 0)
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
     lat11 = ndtooned(conform(rc1,latx1,0)) 
     lon11 = ndtooned(conform(rc1,lonx1,1))
     lat11 = where(pb1.le.statistical_siglev,lat11,rc1@_FillValue)
     lon11 = where(pb1.le.statistical_siglev,lon11,rc1@_FillValue)
     jet1_lat(:) = (/lat11/)
     jet1_lon(:) = (/lon11/) 
    ;prob1 = reshape(pb1,(/drc1(0),drc1(1)/))
    ;prob1 = where(prob1.le.statistical_siglev,rc1,rc1@_FillValue)
    ;jet1_prob(:,:) = (/ prob1 /)
     delete([/drc1,df1,tval1,xb1,pb1,lat11,lon11/])

     drc2  = dimsizes(rc2)
     df2   = rc2@nptxy-2  ; degrees of freedom
     tval2 = rc2@tval     ; t-statistic
     xb2   = tval2
     xb2   = 0.50
     pb2   = betainc(df2/(df2+tval2^2),df2/2.0,xb2)
     lat12 = ndtooned(conform(rc2,latx2,0))
     lon12 = ndtooned(conform(rc2,lonx2,1))
     lat12 = where(pb2.le.statistical_siglev,lat12,rc2@_FillValue)
     lon12 = where(pb2.le.statistical_siglev,lon12,rc2@_FillValue)
     jet2_lat(:) = (/lat12/)
     jet2_lon(:) = (/lon12/)
    ;prob2 = reshape(pb2,(/drc2(0),drc2(1)/))
    ;prob2 = where(prob2.le.statistical_siglev,rc2,rc2@_FillValue)
    ;jet2_prob(:,:) = (/ prob2 /)
     delete([/drc2,df2,tval2,xb2,pb2,lat12,lon12/])
   end if 

   jet1_regres = (/ rc1 /)
   jet2_regres = (/ rc2 /)
   delete([/rc1,rc2/])

 ; =================================================================
 ; Extract the YYYYMM from the time coordinate 
 ; associated with jet_ts [same as x&time] 
 ; =================================================================
   utc_date1 = cd_calendar(jet1_ts&time,-1)
   utc_date2 = cd_calendar(jet2_ts&time,-1)
   yyyy1     = yyyymm_to_yyyyfrac(utc_date1, 0.0) ;utc_date1(:,0)
   yyyy2     = yyyymm_to_yyyyfrac(utc_date2, 0.0) ;utc_date2(:,0)

   delete([/utc_date1,utc_date2/])

   wtype                        = "eps"
  ;wtype@wkWidth                = 2500
  ;wtype@wkHeight               = 2500
   figdir                       = casedir+"/Jet_Index_Analysis/"
   fe                           = "Jet_position_from_monthly_mean_regression_on_"+modregvars(jj)+"_"+seasons(kk)
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
  ;tmpdat = (/jet1_regres,jet2_regres/)
  ;symMinMaxPlt(tmpdat, 16, False, res)      ; contributed.ncl
  ;delete(tmpdat)

  res@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following 3 resources
  mnmxint = nice_mnmxintvl( -lev_jet(jj), lev_jet(jj), maxlev, False)
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
    res@gsnLeftString     = "Regression (jet position)"
    res@gsnRightString    = ""
    res@gsnCenterString   = "" ;panelstr1
    res@tiMainString      = "Case: "+panelstr1
    plot(0)   = gsn_csm_contour_map_polar(wks,jet1_regres(:,:),res)

    ;---Draw second plot in upper right corner
    res@gsnLeftString     = "Regression (jet position)";(EOF "+(n+1)+")"
    res@gsnRightString    = ""
    res@gsnCenterString   = "" ;panelstr2
    res@tiMainString      = "Case: "+panelstr2
    plot(1) = gsn_csm_contour_map_polar(wks,jet2_regres(:,:),res)

   ;res1=res
   ;res1@cnFillOn              = True     ; color plot desired
   ;res1@lbLabelBarOn          = False    ; turn off contour labels
   ;res1@cnLinesOn             = False    ; turn off contour lines
   ;res1@cnLineLabelsOn        = False    ; turn off contour labels
   ;res1@cnMissingValFillColor = -1
   ;res1@cnMonoFillColor       = True     ; default color is fground [black]
   ;res1@cnMonoFillPattern     = True     ; want multiple patterns
   ;res1@cnMonoFillScale       = True     ; want patterns w/ diff densities
   ;res1@cnFillColor           = FillColor
   ;res1@cnFillPattern         = FillPattern
   ;res1@cnFillScaleF          = FillScaleF
   ;res1@cnFillDotSizeF        = FillDotSizeF
   ;res1@cnFillOpacityF        = FillOpacityF
   ;res1@tiMainString          = "" ;label
   ;res1@cnInfoLabelOn         = False
   ;str1=unique_string("tmp1")
   ;str2=unique_string("tmp2")
   ;;wrf_smooth_2d(jet1_regres(:,:),3)
   ;;wrf_smooth_2d(jet2_regres(:,:),3)
   ;plot@str1                = gsn_csm_contour_map_polar(wks,jet1_prob(:,:),res1)
   ;plot@str2                = gsn_csm_contour_map_polar(wks,jet2_prob(:,:),res1)
   ;overlay(plot(0),plot@str1)
   ;overlay(plot(1),plot@str2)
   ;delete([/res1/])

    mkres = True
    mkres@gsMarkerIndex        = 16          ; Filled dots
    mkres@gsMarkerSizeF        = FillDotSizeF 
    mkres@gsMarkerColor        = FillColor
    mkres@gsMarkerOpacityF     = FillOpacityF
   ;mkres@gsMarkerThicknessF   = FillScaleF
    mkres@cnFillOpacityF       = FillOpacityF

    str1=unique_string("tmp1")
    str2=unique_string("tmp2")
   ;wrf_smooth_2d(jet1_regres(:,:),3)
   ;wrf_smooth_2d(jet2_regres(:,:),3)
    plot@str1                = gsn_add_polymarker(wks,plot(0),jet2_lon(:),jet2_lat(:),mkres)
    plot@str2                = gsn_add_polymarker(wks,plot(1),jet2_lon(:),jet2_lat(:),mkres)

 ;*******************************************
 ; second plot
 ;*******************************************
  ; EOF time series  [bar form]

    rts           = True
    rts@gsnDraw   = False       ; don't draw yet
    rts@gsnFrame  = False       ; don't advance frame yet
    rts@gsnScale  = True        ; force text scaling               

    rts@tiYAxisString = "Standardized"          ; y-axis label      

    rts@vpHeightF = 0.40        ; Changes the aspect ratio
    rts@vpWidthF  = 0.85
    rts@vpXF      = 0.10        ; change start locations
    rts@vpYF      = 0.75        ; the plot

    rts@gsnYRefLine           = 0.              ; reference line   
    rts@gsnXYBarChart         = True            ; create bar chart 
    rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
    rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

    rts@tmXTOn                       = False
    rts@tmYLLabelFontHeightF         = 0.025
    rts@tmBorderThicknessF           = 1.0
    rts@tmXBMajorThicknessF          = 1.0
    rts@tmXBMinorThicknessF          = 1.0
    rts@tmYLMajorThicknessF          = 1.0
    rts@tmYLMinorThicknessF          = 1.0
    rts@tmYRMajorThicknessF          = 1.0
    rts@tmYRMinorThicknessF          = 1.0

    rts@trYMinF                      = -3.0
    rts@trYMaxF                      =  3.0

   ;create individual plots
   ;---Draw third plot in lower left corner
    rts@gsnLeftString     = "Jet position" ;(EOF "+(n+1)+")"
    rts@gsnRightString    = ""
    rts@tiMainString      = "" ;"Case: "+panelstr1
    plot(2) = gsn_csm_xy (wks,yyyy1,jet1_ts(:),rts)
     
    rts1 = rts
    rts1@gsnXYBarChart       = False
    rts1@gsnLeftString       = ""
    rts1@gsnRightString      = ""
    rts1@gsnCenterString     = ""
    rts1@xyLineThicknesses   = 3            
    rts1@xyLineColors        = "Black"
    xyarr1                   = wgt_runave_Wrap(jet1_ts(:),(/1.,3,5,6,5,3,1/), 0)   
    tsmap1(2)            = gsn_csm_xy(wks,yyyy1,xyarr1,rts1) 
    overlay(plot(2),tsmap1(2))
    delete([/xyarr1/])


    ;---Draw fourth plot in upper right corner
    rts@gsnLeftString        = "Jet position"
    rts@gsnRightString       = ""
    rts@tiMainString         = "" ;"Case: "+panelstr2
    plot(3) = gsn_csm_xy (wks,yyyy2,jet2_ts(:),rts)

    rts2 = rts
    rts2@gsnXYBarChart       = False
    rts2@gsnLeftString       = ""
    rts2@gsnRightString      = ""
    rts2@gsnCenterString     = ""
    rts2@xyLineThicknesses   = 3 
    rts2@xyLineColors        = "Black"
    xyarr2                   = wgt_runave_Wrap(jet2_ts(:),(/1.,3,5,6,5,3,1/), 0) 
    tsmap2(3)            = gsn_csm_xy(wks,yyyy2,xyarr2,rts2)
    overlay(plot(3),tsmap2(3))
    delete([/xyarr2/])

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
    pres2@gsnPanelTop               = 0.5		       ; draw from center to right edge 
   ;gsn_panel(wks,plot(2:3),(/1,2/),pres2)       ; create first panel

   ;if (wtype .eq. "png") then
   ;  tmpa = systemfunc("convert "+fe+".png -trim del.png")
   ;  tmpb = systemfunc("mv del.png "+fe+".png")
   ;end if

   frame(wks)                                   ; draw both on same page

   ;delete([/xyarr1,xyarr2,tsmap1,tsmap2/])

   delete([/regxAnom,regyAnom,jet1_regres,jet2_regres,jet1,jet2,jet1_ts,jet2_ts/])
   delete([/yyyy1,yyyy2/])

  end do

  delete([/regxAnom1,regyAnom1,regx1,regy1/])

 end do                                              ; end of looping over variables

end

