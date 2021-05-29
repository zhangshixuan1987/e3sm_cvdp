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

  statistical_test                           = getenv("DIFFERENCE_TEST")
  statistical_siglev                         = 0.05
  l_regress                                  = "l_regress_enso"

;define regions for enso analysis
  latS                                       = -90.  ;negative for southern hemisphere
  latN                                       =  90.  ;negative for southern hemisphere

;declear the season or annual mean data to be used;;;;;
  seasons                                      = (/"ANN","DJF","JJA"/)

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
   if((cname.eq."ERA5").or.(cname.eq."ERA20C")) then
     obsninovar = ("sst")
   else if (cname.eq."NOAA20C") then
     obsninovar = ("skt")
   else
     print("The observational source are not available; only allow ERA5, ERA20C or NOAA20C")
     exit
   end if
   end if
  end if 

  ;read in two files
   f                                       = systemfunc("ls "+tpath+"/"+tcase+"*"+tttag+".nc")
   f1                                      = addfile(f,"r")
   gw1                                     = f1->gw

   f                                       = systemfunc("ls "+cpath+"/"+ccase+"*"+cttag+".nc")
   f2                                      = addfile(f,"r")
   gw2                                     = f2->gw

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

  ; =================================================================
  ; Select different season for the eof regression
  ; =================================================================
  ;shift the model time to be consistent with the observations;;;
   enso_ind1&time = enso_ind1&time - 1.0
   if(compare.ne."Model_vs_OBS")then
     enso_ind1&time = enso_ind1&time - 1.0
   end if
   utc_date1 = cd_calendar(enso_ind1&time,0)
   utc_date2 = cd_calendar(enso_ind2&time,0)
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

   ;=============================================================================
   ;Save the data for the regression analysis
   ;=============================================================================
    eof1 = enso_ind1(:,indx1)
    eof2 = enso_ind2(:,indx2)
    setfileoption("nc", "Format",  "NetCDF4")
    out_file1  = opath +"/"+"ENSO_index_"+cname+"_monthly_mean_"+seasons(kk)+".nc"
    out_file2  = opath +"/"+"ENSO_index_"+tname+"_monthly_mean_"+seasons(kk)+".nc"

    system("rm " + out_file1)
    system("rm " + out_file2)

    fout1      = addfile(out_file1,"c")
    fout2      = addfile(out_file2,"c")

    time1      = eof1&time
    time2      = eof2&time
    time1!0    = "time"
    time2!0    = "time"
    time1&time = time1
    time2&time = time2

    fout1->time         = time1
    fout2->time         = time2
    eof1!0              = "nenso"
    eof1!1              = "time"
    eof2!0              = "nenso"
    eof2!1              = "time"
    eof1@description    = "ENSO Index: Nino3, Nino34, Nino4"
    eof2@description    = "ENSO Index: Nino3, Nino34, Nino4"
     
    fout1->enso         = eof1
    fout2->enso         = eof2
   
    delete([/time1,time2,fout1,fout2,out_file1,out_file2,eof1,eof2/])

  ;;;;;;start to do the regression and do plot;;;;
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

     ;;check the two comparing files and see if they are in the same grid,
     ddd1                                  = dimsizes(var1)
     ddd2                                  = dimsizes(var2)
     ;;otherwise, return the error message;;;;
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

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; prepare the data for regression
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    regxAnom = regxAnom1(indx1,:,:)
    regyAnom = regyAnom1(indx2,:,:)
    ensox    = enso_ind1(:,indx1)
    ensoy    = enso_ind2(:,indx2)

 ; =================================================================
 ; Regress
 ; =================================================================
   ddenso1      = dimsizes(regxAnom)
   ddenso2      = dimsizes(regyAnom) 
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

   enso1_rgprob = enso1_regres
   enso2_rgprob = enso2_regres

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
       prob1 = reshape(pb1,(/drc1(0),drc1(1)/))
       prob1 = where(prob1.le.statistical_siglev,rc1,rc1@_FillValue)
       enso1_rgprob(ne,:,:) = (/ prob1 /)
       delete([/drc1,df1,tval1,xb1,pb1,prob1/])

       drc2  = dimsizes(rc2)
       df2   = rc2@nptxy-2   ; degrees of freedom
       tval2 = rc2@tval      ; t-statistic
       xb2   = tval2
       xb2   = 0.50
       pb2   = betainc(df2/(df2+tval2^2),df2/2.0,xb2)
       prob2 = reshape(pb2,(/drc2(0),drc2(1)/))
       prob2 = where(prob2.le.statistical_siglev,rc2,rc2@_FillValue)
       enso2_rgprob(ne,:,:) = (/ prob2 /)
       delete([/drc2,df2,tval2,xb2,pb2,prob2/])
      end if 

      enso1_regres(ne,:,:) = (/ rc1 /)
      enso2_regres(ne,:,:) = (/ rc2 /)
      delete([/rc1,rc2/])

   end do

   enso1_rgprob = (1.0 - enso1_rgprob)*100.0
   enso2_rgprob = (1.0 - enso2_rgprob)*100.0

   ;;;calculate the error metrix
   rad     = 4.*atan(1.)/180.    ;
   cost    = tofloat(cos(enso1_regres&lat*rad))       ; cosine weights
   mean1   = wgt_areaave (enso1_regres,cost,1.0,0)
   mean2   = wgt_areaave (enso2_regres,cost,1.0,0)
   mbias   = wgt_areaave (enso1_regres-enso2_regres,cost,1.0,0)
   mrmsd   = wgt_arearmse(enso1_regres-conform(enso1_regres,mean1,0),enso2_regres-conform(enso2_regres,mean2,0),cost,1.0,0)
   mcorr   = pattern_cor(enso1_regres,enso2_regres,cost, 1)
   delete([/rad,cost,mean1,mean2/])

 ; =================================================================
 ; Extract the YYYYMM from the time coordinate 
 ; associated with enso_ts [same as x&time] 
 ; =================================================================

   utc_date1 = cd_calendar(regxAnom&time,-1)  
   utc_date2 = cd_calendar(regyAnom&time,-1)
   
   yyyy1     = yyyymm_to_yyyyfrac(utc_date1, 0.0) ;utc_date1(:,0)
   yyyy2     = yyyymm_to_yyyyfrac(utc_date2, 0.0) ;utc_date2(:,0)

 do n = 0, nenso-1

  ;;;;start to plot;;;;;;;;;;;;;;
  wtype     = "eps"
  fildir    = outdir+"/ENSO_Index_Analysis/"
  filname   = str_sub_str(ninoreg(n)," ","")+"_regression_on_"+modregvars(jj) +"_"+seasons(kk)
  wks       = gsn_open_wks("eps",fildir+filname)
  plot      = new (4,graphic)
  dum       = new (4,graphic)

  smbias    = "Mean diff:   " + sprintf("%5.2f", mbias(n))
  smrmsd    = "RMS  diff:   " + sprintf("%5.2f", mrmsd(n))
  smcorr    = "Correlation: " + sprintf("%5.2f", mcorr(n))
  pstring   = smbias + "~C~" + smrmsd + "~C~" + smcorr

 ;print(smbias + " " + smrmsd + " "+smcorr)
 ;print(pstring)

 ;============================================================
 ; PLOTS
 ;============================================================
   res                               = True                  ; plot mods desired
   res@cnFillOn                      = True                  ; turn on color fill
   res@cnLinesOn                     = False                 ; no contour lines
   res@cnLineLabelsOn                = False
   res@gsnFrame                      = False                 ; Do not draw plot
   res@gsnDraw                       = False                 ; Do not advance frame

   FontHeightF = 0.018
   res@tiMainFontThicknessF          = 3.0
   res@tiMainFontHeightF             = FontHeightF*1.2
   res@tmYLLabelFontHeightF          = FontHeightF
   res@tmXBLabelFontHeightF          = FontHeightF
   res@tiXAxisFontHeightF            = FontHeightF*0.95
   res@tiYAxisFontHeightF            = FontHeightF*0.95
   res@gsnStringFontHeightF          = FontHeightF*1.2
   res@cnLineLabelFontHeightF        = FontHeightF
   res@lbLabelFontHeightF            = FontHeightF*0.95
   res@lbTitleFontHeightF            = FontHeightF

   res@tmXTOn                        = False
   res@tmYROn                        = False
   res@tmBorderThicknessF            = 1.0
   res@tmXBMajorThicknessF           = 1.0
   res@tmXBMinorThicknessF           = 1.0
   res@tmYLMajorThicknessF           = 1.0
   res@tmYLMinorThicknessF           = 1.0
   res@tmYRMajorThicknessF           = 1.0
   res@tmYRMinorThicknessF           = 1.0

   res@mpFillOn                      = False        ; turn off map fill
   res@mpGeophysicalLineThicknessF   = 1.0
   res@mpMinLonF                     =   0
   res@mpMaxLonF                     = 360
   res@mpCenterLonF                  = 180     ; This is necessary to get the correct map

   res@gsnMajorLatSpacing            = 30
   res@gsnMajorLonSpacing            = 45
   res@gsnMinorLatSpacing            = 15
   res@gsnMinorLonSpacing            = 15

   res@cnFillOn                 = True         ; turn on color fill
   res@cnFillPalette            = "BlueDarkRed18"  
   res@cnLinesOn                = False        ; True is default
   res@cnLineLabelsOn           = False        ; True is default

   res@lbLabelBarOn                  = True
   res@lbOrientation                 = "Vertical"
   res@lbPerimOn                     = False             ; default has box
   res@pmLabelBarHeightF             = 0.38
   res@pmLabelBarWidthF              = 0.1
   res@pmLabelBarParallelPosF        = 0.48
   res@pmLabelBarOrthogonalPosF      = 0.02
  ;res@lbTitleString                 = ""

   res@cnInfoLabelOn                 = False
   res@cnLevelSelectionMode          = "ExplicitLevels"       ; manual levels
   res@cnMissingValFillColor         = "White" ;"gray76"               ; black = 1

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
  ;---Draw first plot in upper left corner
   res@gsnLeftString     = "Regress on " + str_upper(mvarnam)+ " ("+varunt(jj)+")"
   res@gsnRightString    = ninoreg(n) ;sprintf("%5.1f", enso2@pcvar(n)) +"%"
   res@gsnCenterString   = ""
   res@tiMainString      = panelstr1
   plot(0)   = gsn_csm_contour_map_ce(wks,enso1_regres(n,:,:),res)

  ;---Draw second plot in upper right corner
   res@gsnLeftString     = "Regress on " + str_upper(mvarnam)+ " ("+varunt(jj)+")"
   res@gsnRightString    = ninoreg(n) ;sprintf("%5.1f", enso2@pcvar(n)) +"%"
   res@gsnCenterString   = "";
   res@tiMainString      = "" + panelstr2
   plot(1) = gsn_csm_contour_map_ce(wks,enso2_regres(n,:,:),res)

   rescn2 = True
   rescn2@lbLabelBarOn    = False
   rescn2@gsnTickMarksOn  = False     ; no tickmarks
   rescn2@gsnDraw         = False     ; don't draw
   rescn2@gsnFrame        = False     ; don't advance frame
   rescn2@tiMainString    = ""
   rescn2@gsnLeftString   = ""
   rescn2@gsnRightString  = ""
   rescn2@cnMinLevelValF  = (1.0 - statistical_siglev)*100.0
   rescn2@cnMaxLevelValF  = 100.0
  ;rescn2@cnLevelSpacingF = 1.
   rescn2@cnMonoFillPattern = True
   rescn2@cnMonoFillColor = True
   rescn2@cnFillOn        = True      ; color fill
   rescn2@cnLinesOn       = False
   rescn2@cnLineLabelsOn  = False        ; True is default
   rescn2@cnInfoLabelOn   = False                ; turn off info label
   rescn2@cnFillMode      = "AreaFill" ; raster fill significance patterns
   rescn2@cnFillPattern   = 17
   rescn2@cnFillDotSizeF  = 0.002
   rescn2@cnFillColor     = "black"
   rescn2@cnFillOpacityF  = 0.5
   dum(0)   = gsn_csm_contour(wks,enso1_rgprob(n,:,:),rescn2) ; contours are at 95,100
   dum(1)   = gsn_csm_contour(wks,enso2_rgprob(n,:,:),rescn2) ; contours are at 95,100

   overlay(plot(0),dum(0))
   overlay(plot(1),dum(1))

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

   rts@vpHeightF = 0.35        ; Changes the aspect ratio
   rts@vpWidthF  = 0.75
   rts@vpXF      = 0.00        ; change start locations
   rts@vpYF      = 0.75        ; the plot

   rts@tiMainFontThicknessF    = 3.0
   rts@tiMainFontHeightF       = FontHeightF*1.4
   rts@tmYLLabelFontHeightF    = FontHeightF
   rts@tmXBLabelFontHeightF    = FontHeightF
   rts@tiXAxisFontHeightF      = FontHeightF
   rts@tiYAxisFontHeightF      = FontHeightF
   rts@gsnStringFontHeightF    = FontHeightF*1.2

   rts@gsnYRefLine           = 0.              ; reference line   
  ;rts@gsnXYBarChart         = True            ; create bar chart 
   rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
   rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

   rts@tmXTOn                = False
   rts@tmYROn                = False
   rts@tmYLLabelFontHeightF  = FontHeightF*1.2
   rts@tmXBLabelFontHeightF  = FontHeightF*1.2
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
   rts@gsnRightString       = "" ;panelstr1 
   rts@tiMainString         = "" ;""+panelstr2
   plot(2) = gsn_csm_xy (wks,yyyy1,ensox(n,:),rts)
    
   rts1 = rts
   rts1@gsnXYBarChart       = False
   rts1@gsnLeftString       = ""
   rts1@gsnRightString      = ""
   rts1@gsnCenterString     = ""
   rts1@xyLineThicknesses   = 3            
   rts1@xyLineColors        = "Black"
   xyarr1                   = wgt_runave_Wrap(ensox(n,:),(/1.,3,5,6,5,3,1/), 0)   
   dum(2)                   = gsn_csm_xy(wks,yyyy1,xyarr1,rts1) 
   overlay(plot(2),dum(2))
   delete([/xyarr1/])


   ;---Draw fourth plot in upper right corner
   rts@gsnLeftString        = ninoreg(n)+" index"
   rts@gsnRightString       = "" ;panelstr2 ;sprintf("%5.1f", enso2_regres@pcvar(n)) +"%"
   rts@tiMainString         = "" ;""+panelstr2
   plot(3) = gsn_csm_xy (wks,yyyy2,ensoy(n,:),rts)

   rts2 = rts
   rts2@gsnXYBarChart       = False
   rts2@gsnLeftString       = ""
   rts2@gsnRightString      = ""
   rts2@gsnCenterString     = ""
   rts2@xyLineThicknesses   = 3 
   rts2@xyLineColors        = "Black"
   xyarr2                   = wgt_runave_Wrap(ensoy(n,:),(/1.,3,5,6,5,3,1/), 0) 
   dum(3)               = gsn_csm_xy(wks,yyyy2,xyarr2,rts2)
   overlay(plot(3),dum(3))
   delete([/xyarr2/])

 ; panel plot only resources
   pres1                          = True                ; mods desired
   pres1@gsnFrame                 = False               ; save panel until both ready
   pres1@gsnPanelBottom           = 0.45    ; space for label bar
   pres1@gsnPanelTop              = 0.75     ; only panel on lower half of page
   pres1@gsnPanelXF               = (/0.05,0.55/)
   gsn_panel(wks,plot(0:1),(/1,2/),pres1)          ; create first panel
     
   pres2                           = True          ; mods desired
   pres2@gsnFrame                  = False          ; save panel until both ready
   pres2@gsnPanelBottom            = 0.18          ; draw from center to right edge
   pres2@gsnPanelTop               = 0.45		       ; draw from center to right edge 
   pres2@gsnPanelXF                = (/0.05,0.55/)
   gsn_panel(wks,plot(2:3),(/1,2/),pres2)       ; create first panel
   frame(wks)                                   ; draw both on same page
   delete([/plot,dum/])

   end do

   delete([/utc_date1,utc_date2,yyyy1,yyyy2/])
   delete([/regxAnom,regyAnom/])
   delete([/ensox,ensoy,enso1_regres,enso2_regres/])

   end do                                              ; end of looping over seasons

   delete([/indx1,indx2/])
   delete([/regxAnom1,regyAnom1/])

  end do                                              ; end of looping over variables

  delete([/monthx1,monthx2/])
  delete([/enso_ind1,enso_ind2/])

end

