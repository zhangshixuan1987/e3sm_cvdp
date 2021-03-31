  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a enso plot for AAO patterns 
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
  statistical_test                           = getenv("REGRESSION_TEST")
  statistical_siglev                         = 0.1
  l_regress                                  = "l_regress_enso"

;define regions for enso analysis
  latS                                       = -90.  ;negative for southern hemisphere
  latN                                       = -20.  ;negative for southern hemisphere

;declear the season or annual mean data to be used;;;;;
  seasons                                      = (/"ANN","DJF","JJA"/)

;define color for the plot of signiticant test 
  FillColor           = "Black";"Grey75" ;"Grey65";"Grey28";"Grey";"Black"
  FillPattern         = 0 ;17 ;6 ;17;11
  FillScaleF          = 5.0
  FillDotSizeF        = 0.00002    ; increase dot size of contours
  FillOpacityF        = 0.5 ;0.15

;define # of desired nino indices
;Niño 3 (5N-5S, 150W-90W):  This region was once the primary focus for monitoring and predicting El Niño, 
;but researchers later learned that the key region for coupled ocean-atmosphere interactions for ENSO lies 
;further west (Trenberth, 1997).  Hence, the Niño 3.4 and ONI became favored for defining El Niño and La Niña events.
;Niño 3.4 (5N-5S, 170W-120W):  The  Niño 3.4 anomalies may be thought of as representing the
;average equatorial SSTs across the Pacific from about the dateline to the South American coast. 
;The Niño 3.4 index typically uses a 5-month running mean, and El Niño or La  Niña events are
;defined when the  Niño 3.4 SSTs exceed +/- 0.4C for a period of six months or more.
;Niño 4 (5N-5S, 160E-150W): The  Niño 4 index captures SST anomalies in the central equatorial Pacific. 
;This region tends to have less variance than the other Niño regions.
  nenso        = 3     ; Leading EOF only
  ninoreg      = (/"Nino 3", "Nino 3.4", "Nino 4"/)
  ninolats     = (/ -5,  -5,  -5/)
  ninolate     = (/  5,   5,   5/)
  ninolons     = (/210, 190, 160/)     
  ninolone     = (/270, 240, 210/)

 ;variable name in for caclulating nino index 
  modninovar   = ("TS")

  if(compare.eq."Model_vs_OBS")then

   if((case2name.eq."ERA5").or.(case2name.eq."ERA20C")) then
     obsninovar = ("sst")
   else if (case2name.eq."NOAA20C") then
     obsninovar = ("skt")
   else
     print("The observational source are not available; only allow ERA5, ERA20C or NOAA20C")
     exit
   end if
   end if

  end if 

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
   
 ;;;;read and calculate nino indices;;;;;;;;;;;;;;;;;;;;
  ensovar1                            = f1->$modninovar$
  if(compare.eq."Model_vs_OBS") then
    ensovar2                          = f2->$obsninovar$
  else
    ensovar2                          = f2->$modninovar$
  end if
 ;printVarSummary(ensovar1)
 ;printVarSummary(ensovar2)

  ensovar1@_FillValue                  = -9999.
  ensovar2@_FillValue                  = -9999.
  edd1                                = dimsizes(ensovar1)
  edd2                                = dimsizes(ensovar2)

 ;;check the two comparing files and see if they are in the same grid, otherwise, return the error message;;;;
  if ((edd1(1).ne.edd2(1)).or.(edd1(2).ne.edd2(2)))then
   print("Error: this scripts requires the two files must in the same grid to run!!!")
   return
  end if

 ; ==============================================================
 ; Nino X Index computation:
 ;(a) Compute area averaged total SST from Niño X region;
 ;(b) Compute monthly climatology (e.g., 1950-1979) for area averaged total SST from Niño X region,
 ;    and subtract climatology from area averaged total SST time series to obtain anomalies;
 ;(c) Smooth the anomalies with a 5-month running mean;
 ;(d) Normalize the smoothed values by its standard deviation over the climatological period.
 ; ==============================================================
  enso_ind1  = new((/nenso,edd1(0)/),typeof(ensovar1))
  enso_ind2  = new((/nenso,edd2(0)/),typeof(ensovar2))
  enso_ind1!0 = "nenso"
  enso_ind1!1 = "time"
  enso_ind2!0 = "nenso"
  enso_ind2!1 = "time"
  enso_ind1&time = ensovar1&time
  enso_ind2&time = ensovar2&time

  do ienso   = 0,nenso-1,1

   latm1     = ninolats(ienso)
   latm2     = ninolate(ienso)
   lonm1     = ninolons(ienso)
   lonm2     = ninolone(ienso)

   ensox     = ensovar1(:,{latm1:latm2},{lonm1:lonm2})
   ensoy     = ensovar2(:,{latm1:latm2},{lonm1:lonm2})

   ensoxClm  = clmMonTLL(ensox) ;(iClmStrt:iClmLast,:,:))
   ensoyClm  = clmMonTLL(ensoy) ;(iClmStrt:iClmLast,:,:))

   ensoxAnom = calcMonAnomTLL (ensox, ensoxClm )  ;ensox1
   ensoyAnom = calcMonAnomTLL (ensoy, ensoyClm )  ;ensoy1

   rad      = get_d2r("float")
   ensoxclat = ensox&lat
   ensoxclat = sqrt( cos(rad*ensoxclat) )                 ; gw for gaussian grid
   ensoyclat = ensoy&lat
   ensoyclat = sqrt( cos(rad*ensoyclat) )                 ; gw for gaussian grid

   ensox1    = wgt_areaave_Wrap(ensoxAnom,ensoxclat,1.0,0)
   ensoy1    = wgt_areaave_Wrap(ensoyAnom,ensoyclat,1.0,0)

   nave      = 5
   opt       = 1
   ;print(min(ensox1)+ " " +max(ensox1))
   ensox1    = runave_n_Wrap (ensox1, nave, opt, 0)
   ensoy1    = runave_n_Wrap (ensoy1, nave, opt, 0)
   ;print(min(ensox1)+ " " +max(ensox1))

   ;printVarSummary(ensox1)
   enso_ind1(ienso,:) = dim_standardize_n(ensox1,1,0)
   enso_ind2(ienso,:) = dim_standardize_n(ensoy1,1,0)
   delete([/ensox,ensoy,ensoxClm,ensoyClm,ensoxAnom,ensoyAnom,ensoxclat/])
   delete([/ensoyclat,ensox1,ensoy1,ensox1,ensoy1/])
  ;print(min(enso_ind1)+ " " +max(enso_ind2))

  end do

  ;;;;;;start to do the regression;;;;
  print ("Start to regress enso index on selected variables ")
  load "./share_info_for_regression_map.ncl"

  do jj = 0, dimsizes(modregvars)-1

     mvarnam                             = modregvars(jj)
     load "./function_read_model_var.ncl"

     if(compare.eq."Model_vs_OBS") then
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
     ddd1                                = dimsizes(var1)
     ddd2                                = dimsizes(var2)
     ;printVarSummary(var1)
     ;printVarSummary(var2)

     ;;check the two comparing files and see if they are in the same grid, otherwise, return the error message;;;;
     if ((ddd1(1).ne.ddd2(1)).or.(ddd1(2).ne.ddd2(2)))then
      print("Error: this scripts requires the two files must in the same grid to run!!!")
      return
     end if

  ;;;;;;start to process the regression variable ;;;;

   regx1  = var1(:,{latS:latN},:)
   regy1  = var2(:,{latS:latN},:)

 ; ==============================================================
 ; compute climatology and Anomalies
 ; ==============================================================
   regxClm1  = clmMonTLL(regx1) 
   regyClm1  = clmMonTLL(regy1) 

   regxAnom1 = calcMonAnomTLL (regx1, regxClm1 )  
   regyAnom1 = calcMonAnomTLL (regy1, regyClm1 )  

   delete([/regxClm1,regyClm1, regx1, regy1/])
 ; =================================================================
 ; Select different season for the enso
 ; =================================================================
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

   else

     print("User did not specify the season, use all of the monthly data")
     indx1 = ind ((monthx1.ge.1).and.(monthx1.le.12))
     indx2 = ind ((monthx2.ge.1).and.(monthx2.le.12))

   end if
   end if
   end if

   regxAnom = regxAnom1(indx1,:,:)
   regyAnom = regyAnom1(indx2,:,:)
   ensox    = enso_ind1(:,indx1)
   ensoy    = enso_ind2(:,indx2)

   delete([/indx1,indx2/])

   ;printVarSummary(regxClm)
   ;printVarSummary(regxAnom)         
   ;printMinMax(regxAnom, True)

   latx1  = doubletofloat(regxAnom&lat)
   lonx1  = doubletofloat(regxAnom&lon)

   latx2  = doubletofloat(regyAnom&lat)
   lonx2  = doubletofloat(regyAnom&lon)

 ; =================================================================
 ; Regress
 ; =================================================================
   ddenso1      = dimsizes(regxAnom)
   ddenso2      = dimsizes(regyAnom) 
   enso1_lat    = new((/nenso,ddenso1(1)*ddenso1(2)/),typeof(regxAnom))
   enso1_lon    = new((/nenso,ddenso1(1)*ddenso1(2)/),typeof(regxAnom))
   enso2_lat    = new((/nenso,ddenso2(1)*ddenso2(2)/),typeof(regyAnom))
   enso2_lon    = new((/nenso,ddenso2(1)*ddenso2(2)/),typeof(regyAnom))
   enso1_lat@_FillValue = -9999.
   enso1_lon@_FillValue = -9999.
   enso2_lat@_FillValue = -9999.
   enso2_lon@_FillValue = -9999.

   enso1_regres = new((/nenso,ddenso1(1),ddenso1(2)/),typeof(regxAnom))     ; create an array w meta data
   enso2_regres = new((/nenso,ddenso2(1),ddenso2(2)/),typeof(regyAnom))     ; create an array w meta data
   enso1_regres@_FillValue = -9999.
   enso2_regres@_FillValue = -9999.
   enso1_regres!0 = "nenso"
   enso1_regres!1 = "lat"
   enso1_regres!2 = "lon"
   enso1_regres&lat = regxAnom&lat
   enso1_regres&lon = regxAnom&lon
   enso2_regres!0 = "nenso"
   enso2_regres!1 = "lat"
   enso2_regres!2 = "lon"
   enso2_regres&lat = regyAnom&lat
   enso2_regres&lon = regyAnom&lon

   delete([/ddenso1,ddenso2/])

   do ne=0,nenso-1

      rc1   = regCoef_n(ensox(ne,:), regxAnom, 0, 0)
      rc2   = regCoef_n(ensoy(ne,:), regyAnom, 0, 0)

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
       ;printVarSummary(lon11)
       ;printVarSummary(lat11)
       ;printVarSummary(enso1_lon)
       lat11 = where(pb1.le.statistical_siglev,lat11,rc1@_FillValue)
       lon11 = where(pb1.le.statistical_siglev,lon11,rc1@_FillValue)
       enso1_lat(ne,:) = lat11
       enso1_lon(ne,:) = lon11 
      ;prob1 = reshape(pb1,(/drc1(0),drc1(1)/))
      ;prob1 = where(prob1.le.statistical_siglev,rc1,rc1@_FillValue)
      ;enso1_prob(ne,:,:) = (/ prob1 /)
       delete([/drc1,df1,tval1,xb1,pb1,lat11,lon11/])

       drc2  = dimsizes(rc2)
       df2   = rc2@nptxy-2   ; degrees of freedom
       tval2 = rc2@tval      ; t-statistic
       xb2   = tval2
       xb2   = 0.50
       pb2   = betainc(df2/(df2+tval2^2),df2/2.0,xb2)
       lat12 = ndtooned(conform(rc2,latx2,0))
       lon12 = ndtooned(conform(rc2,lonx2,1))
       lat12 = where(pb2.le.statistical_siglev,lat12,rc2@_FillValue)
       lon12 = where(pb2.le.statistical_siglev,lon12,rc2@_FillValue)
       enso2_lat(ne,:) = lat12
       enso2_lon(ne,:) = lon12
      ;prob2 = reshape(pb2,(/drc2(0),drc2(1)/))
      ;prob2 = where(prob2.le.statistical_siglev,rc2,rc2@_FillValue)
      ;enso2_prob(ne,:,:) = (/ prob2 /)
       delete([/drc2,df2,tval2,xb2,pb2,lat12,lon12/])
      end if 

      enso1_regres(ne,:,:) = (/ rc1 /)
      enso2_regres(ne,:,:) = (/ rc2 /)
      delete([/rc1,rc2/])

   end do

 ; =================================================================
 ; Extract the YYYYMM from the time coordinate 
 ; associated with enso_ts [same as x&time] 
 ; =================================================================

   utc_date1 = cd_calendar(regxAnom&time,-1)  
   utc_date2 = cd_calendar(regyAnom&time,-1)
   
   yyyy1     = yyyymm_to_yyyyfrac(utc_date1, 0.0) ;utc_date1(:,0)
   yyyy2     = yyyymm_to_yyyyfrac(utc_date2, 0.0) ;utc_date2(:,0)

  ;print(yyyy1)

 do n = 0, nenso-1

   fildir    = casedir+"/Regression_Contour_Maps/"
   filname   = str_sub_str(ninoreg(n)," ","")+"_regression_on_"+modregvars(jj) +"_"+seasons(kk)
   wks       = gsn_open_wks("eps",fildir+filname)
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
  ;tmpdat = (/enso1_regres,enso2_regres/)
  ;symMinMaxPlt(tmpdat, 16, False, res)      ; contributed.ncl
  ;delete(tmpdat)

  res@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following 3 resources
  if(n.eq.0)then
    mnmxint = nice_mnmxintvl( -lev_enso1(jj), lev_enso1(jj), maxlev, False)
  else if (n.eq.1)then 
    mnmxint = nice_mnmxintvl( -lev_enso2(jj), lev_enso2(jj), maxlev, False)
  else
    mnmxint = nice_mnmxintvl( -lev_enso3(jj), lev_enso3(jj), maxlev, False)
  end if 
  end if

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
    res@gsnLeftString     = "Regression ("+ninoreg(n)+")"
   ;res@gsnRightString    = sprintf("%5.1f", enso1@pcvar(n)) +"%"
    res@gsnCenterString   = "" ;panelstr1 
    res@tiMainString      = "Case: "+panelstr1
    plot(0)   = gsn_csm_contour_map_polar(wks,enso1_regres(n,:,:),res)

    ;---Draw second plot in upper right corner
    res@gsnLeftString     = "Regression ("+ninoreg(n)+")"
    res@gsnRightString    = "" ;sprintf("%5.1f", enso2@pcvar(n)) +"%"
    res@gsnCenterString   = "" ;panelstr2
    res@tiMainString      = "Case: "+panelstr2
    plot(1) = gsn_csm_contour_map_polar(wks,enso2_regres(n,:,:),res)

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
   ;;wrf_smooth_2d(enso1_regres(n,:,:),3)
   ;;wrf_smooth_2d(enso2_regres(n,:,:),3)
   ;plot@str1                = gsn_csm_contour_map_polar(wks,enso1_prob(n,:,:),res1)
   ;plot@str2                = gsn_csm_contour_map_polar(wks,enso2_prob(n,:,:),res1)
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
   ;wrf_smooth_2d(enso1_regres(n,:,:),3)
   ;wrf_smooth_2d(enso2_regres(n,:,:),3)
    plot@str1                = gsn_add_polymarker(wks,plot(0),enso2_lon(n,:),enso2_lat(n,:),mkres)
    plot@str2                = gsn_add_polymarker(wks,plot(1),enso2_lon(n,:),enso2_lat(n,:),mkres)

 ;*******************************************
 ; second plot
 ;*******************************************
  ; EOF time series  [bar form]

    rts           = True
    rts@gsnDraw   = False       ; don't draw yet
    rts@gsnFrame  = False       ; don't advance frame yet
    rts@gsnScale  = True        ; force text scaling               

    rts@tiYAxisString = "Standardized"          ; y-axis label      
    rts@tiXAxisString = "Year"

    rts@vpHeightF = 0.40        ; Changes the aspect ratio
    rts@vpWidthF  = 0.85
    rts@vpXF      = 0.10        ; change start locations
    rts@vpYF      = 0.75        ; the plot
 
    rts@gsnYRefLine           = 0.              ; reference line   
   ;rts@gsnXYBarChart         = True            ; create bar chart 
    rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
    rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

    rts@tmXTOn                = False
    rts@tmYLLabelFontHeightF  = 0.025
    rts@tmBorderThicknessF    = 1.0
    rts@tmXBMajorThicknessF   = 1.0
    rts@tmXBMinorThicknessF   = 1.0
    rts@tmYLMajorThicknessF   = 1.0
    rts@tmYLMinorThicknessF   = 1.0
    rts@tmYRMajorThicknessF   = 1.0
    rts@tmYRMinorThicknessF   = 1.0

    rts@trYMinF               = -4.0
    rts@trYMaxF               =  4.0

   ;create individual plots
   ;---Draw third plot in lower left corner
    rts@gsnLeftString        = ninoreg(n)+" index"
    rts@gsnRightString       = "" ;sprintf("%5.1f", enso1_regres@pcvar(n)) +"%"
    rts@tiMainString         = "" ;"Case: "+panelstr1
    plot(2) = gsn_csm_xy (wks,yyyy1,ensox(n,:),rts)
     
    rts1 = rts
    rts1@gsnXYBarChart       = False
    rts1@gsnLeftString       = ""
    rts1@gsnRightString      = ""
    rts1@gsnCenterString     = ""
    rts1@xyLineThicknesses   = 3            
    rts1@xyLineColors        = "Black"
    xyarr1                   = wgt_runave_Wrap(ensox(n,:),(/1.,3,5,6,5,3,1/), 0)   
    tsmap1(2)            = gsn_csm_xy(wks,yyyy1,xyarr1,rts1) 
    overlay(plot(2),tsmap1(2))
    delete([/xyarr1/])


    ;---Draw fourth plot in upper right corner
    rts@gsnLeftString        = ninoreg(n)+" index"
    rts@gsnRightString       = "";sprintf("%5.1f", enso2_regres@pcvar(n)) +"%"
    rts@tiMainString         = "" ;"Case: "+panelstr1
    plot(3) = gsn_csm_xy (wks,yyyy2,ensoy(n,:),rts)

    rts2 = rts
    rts2@gsnXYBarChart       = False
    rts2@gsnLeftString       = ""
    rts2@gsnRightString      = ""
    rts2@gsnCenterString     = ""
    rts2@xyLineThicknesses   = 3 
    rts2@xyLineColors        = "Black"
    xyarr2                   = wgt_runave_Wrap(ensoy(n,:),(/1.,3,5,6,5,3,1/), 0) 
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
    gsn_panel(wks,plot(2:3),(/1,2/),pres2)       ; create first panel
 
    frame(wks)                                   ; draw both on same page

  ;delete([/xyarr1,xyarr2,tsmap1,tsmap2/])
   end do ; end of enso modes
   delete([/utc_date1,utc_date2,yyyy1,yyyy2/])
   delete([/regxAnom,regyAnom/])
  ;delete([/f1,ps1,ha1,hb1,p0,p1,f2,ps2,ha2,hb2,p2/])
   delete([/ensox,ensoy,enso1_regres,enso2_regres/])

  end do                                              ; end of looping over seasons

  delete([/regxAnom1,regyAnom1,monthx1,monthx2/])

  end do                                              ; end of looping over variables

  delete([/enso_ind1,enso_ind2/])

end

