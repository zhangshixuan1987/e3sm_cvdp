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
  bakpath                                    = getenv("DIAG_DATA_ROOT")
  obspath                                    = getenv("WKROOT")

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
  latS                                       = -20.  ;negative for southern hemisphere
  latN                                       =  20.  ;negative for southern hemisphere
  lonW                                       = 120.0
  lonE                                       = 300.0

;declear the season or annual mean data to be used;;;;;
  seasons                                      = (/"ANN","DJF","JJA","MAM","SON"/)

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
  nenso        = 1     ; Leading EOF only
  ninoreg      = (/"Nino 3.4"/)
  ninolats     = (/ -5/)
  ninolate     = (/  5/)
  ninolons     = (/190/)
  ninolone     = (/240/)

 ;variable name in for caclulating nino index 
  modninovar   = ("TS")
  if(compare.eq."Model_vs_OBS")then
   if((cname.eq."ERA5").or.(cname.eq."ERA20C").or.(cname.eq."ERA_20C")) then
     obsninovar = ("sst")
   else if ((cname.eq."NOAA20C").or.(cname.eq."NOAA_20C")) then
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

   ;read the Hadley center SST and used it as reference
   f                                       = systemfunc("ls "+obspath+"/pobs/"+"HadISST_sst_360x180*.nc")
   f3                                      = addfile(f,"r")

 ;;;;read and calculate nino indices;;;;;;;;;;;;;;;;;;;;
  ensovar1                            = f1->$modninovar$
  if(compare.eq."Model_vs_OBS") then
    ensovar2                          = f2->$obsninovar$
  else
    ensovar2                          = f2->$modninovar$
  end if

  ;;read hadley center SST for the comparison;;;;
  ;;need to find the overlap time;;;
  ensovar1&time = ensovar1&time - 1.0
  if(compare.ne."Model_vs_OBS")then
     ensovar2&time = ensovar2&time - 1.0
  end if
  utc_date1 = cd_calendar(ensovar1&time,0)
  utc_date2 = cd_calendar(ensovar2&time,0)
  miny = min((/min(utc_date1(:,0)),min(utc_date2(:,0))/))
  maxy = max((/max(utc_date1(:,0)),max(utc_date2(:,0))/))
  utc_date3 = cd_calendar(f3->time,0)
  indtim    = ind(utc_date3(:,0).ge.miny.and.utc_date3(:,0).le.maxy)
  ensovar3  = f3->sst(indtim,:,:)
  ensovar3@_FillValue                      = -9999.
  delete([/utc_date1,utc_date2,utc_date3,indtim/])

  ;printVarSummary(ensovar1)
  ;printVarSummary(ensovar2)
 

  ensovar1@_FillValue                  = -9999.
  ensovar2@_FillValue                  = -9999.
  ensovar3@_FillValue                  = -9999.
  edd1                                = dimsizes(ensovar1)
  edd2                                = dimsizes(ensovar2)
  edd3                                = dimsizes(ensovar3)

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
  enso_ind1  = new((/edd1(0)/),typeof(ensovar1))
  enso_ind2  = new((/edd2(0)/),typeof(ensovar2))
  enso_ind3  = new((/edd3(0)/),typeof(ensovar2))
  enso_ind1!0 = "time"
  enso_ind2!0 = "time"
  enso_ind3!0 = "time"
  enso_ind1&time = ensovar1&time
  enso_ind2&time = ensovar2&time
  enso_ind3&time = ensovar3&time

  latm1     = ninolats
  latm2     = ninolate
  lonm1     = ninolons
  lonm2     = ninolone

  ensox     = ensovar1(:,{latm1:latm2},{lonm1:lonm2})
  ensoy     = ensovar2(:,{latm1:latm2},{lonm1:lonm2})
  ensoz     = ensovar3(:,{latm1:latm2},{lonm1:lonm2})

  ensoxClm  = clmMonTLL(ensox) ;(iClmStrt:iClmLast,:,:))
  ensoyClm  = clmMonTLL(ensoy) ;(iClmStrt:iClmLast,:,:))
  ensozClm  = clmMonTLL(ensoz) ;(iClmStrt:iClmLast,:,:))

  ensoxAnom = calcMonAnomTLL (ensox, ensoxClm )  ;ensox1
  ensoyAnom = calcMonAnomTLL (ensoy, ensoyClm )  ;ensoy1
  ensozAnom = calcMonAnomTLL (ensoz, ensozClm )  ;ensoy1

  rad      = get_d2r("float")
  ensoxclat = ensox&lat
  ensoxclat = sqrt( cos(rad*ensoxclat) )                 ; gw for gaussian grid
  ensoyclat = ensoy&lat
  ensoyclat = sqrt( cos(rad*ensoyclat) )                 ; gw for gaussian grid
  ensozclat = ensoz&lat
  ensozclat = sqrt( cos(rad*ensozclat) )                 ; gw for gaussian grid

  ensox1    = wgt_areaave_Wrap(ensoxAnom,ensoxclat,1.0,0)
  ensoy1    = wgt_areaave_Wrap(ensoyAnom,ensoyclat,1.0,0)
  ensoz1    = wgt_areaave_Wrap(ensozAnom,ensozclat,1.0,0)

  nave      = 5
  opt       = 1
  ;print(min(ensox1)+ " " +max(ensox1))
  ensox1    = runave_n_Wrap (ensox1, nave, opt, 0)
  ensoy1    = runave_n_Wrap (ensoy1, nave, opt, 0)
  ensoz1    = runave_n_Wrap (ensoz1, nave, opt, 0)

  ;print(min(ensox1)+ " " +max(ensox1))

  ;printVarSummary(ensox1)
  enso_ind1 = dim_standardize_n(ensox1,1,0)
  enso_ind2 = dim_standardize_n(ensoy1,1,0)
  enso_ind3 = dim_standardize_n(ensoz1,1,0)

  delete([/ensox1,ensoy1,ensoz1,ensox,ensoy,ensoz,ensoxClm,ensoyClm,ensozClm,ensoxAnom,ensoyAnom,ensozAnom/])

  ; =================================================================
  ; Select different season for the eof regression
  ; =================================================================
  ;shift the model time to be consistent with the observations;;;
   enso_ind1&time = enso_ind1&time - 1.0
   if(compare.ne."Model_vs_OBS")then
     enso_ind2&time = enso_ind2&time - 1.0
   end if
   utc_date1 = cd_calendar(enso_ind1&time,0)
   utc_date2 = cd_calendar(enso_ind2&time,0)
   utc_date3 = cd_calendar(enso_ind3&time,0)
   monthx1   = tointeger(utc_date1(:,1))
   monthx2   = tointeger(utc_date2(:,1))
   monthx3   = tointeger(utc_date3(:,1))
   delete([/utc_date1,utc_date2,utc_date3/])

   do kk = 0,dimsizes(seasons) - 1

     if(seasons(kk).eq."ANN")then

       indx1 = ind ((monthx1.ge.1).and.(monthx1.le.12))
       indx2 = ind ((monthx2.ge.1).and.(monthx2.le.12))
       indx3 = ind ((monthx3.ge.1).and.(monthx3.le.12))

     else if (seasons(kk).eq."DJF")then

       indx1 = ind ((monthx1.eq.12).or.(monthx1.eq.1).or.(monthx1.eq.2))
       indx2 = ind ((monthx2.eq.12).or.(monthx2.eq.1).or.(monthx2.eq.2))
       indx3 = ind ((monthx3.eq.12).or.(monthx3.eq.1).or.(monthx3.eq.2))

     else if (seasons(kk).eq."JJA") then

       indx1 = ind ((monthx1.eq.6).or.(monthx1.eq.7).or.(monthx1.eq.8))
       indx2 = ind ((monthx2.eq.6).or.(monthx2.eq.7).or.(monthx2.eq.8))
       indx3 = ind ((monthx3.eq.6).or.(monthx3.eq.7).or.(monthx3.eq.8))

     else if (seasons(kk).eq."MAM") then

       indx1 = ind ((monthx1.eq.3).or.(monthx1.eq.4).or.(monthx1.eq.5))
       indx2 = ind ((monthx2.eq.3).or.(monthx2.eq.4).or.(monthx2.eq.5))
       indx3 = ind ((monthx3.eq.3).or.(monthx3.eq.4).or.(monthx3.eq.5))

     else if (seasons(kk).eq."SON") then

       indx1 = ind ((monthx1.eq.9).or.(monthx1.eq.10).or.(monthx1.eq.11))
       indx2 = ind ((monthx2.eq.9).or.(monthx2.eq.10).or.(monthx2.eq.11))
       indx3 = ind ((monthx3.eq.9).or.(monthx3.eq.10).or.(monthx3.eq.11))

     else

       print("User did not specify the season, use all of the monthly data")
       indx1 = ind ((monthx1.ge.1).and.(monthx1.le.12))
       indx2 = ind ((monthx2.ge.1).and.(monthx2.le.12))
       indx3 = ind ((monthx3.ge.1).and.(monthx3.le.12))

     end if
     end if
     end if
     end if
     end if

   ;=============================================================================
   ;Save the data for the regression analysis
   ;=============================================================================
    eof1 = enso_ind1(indx1)
    eof2 = enso_ind2(indx2)
    eof3 = enso_ind3(indx3)

    setfileoption("nc", "Format",  "NetCDF4")
    out_file1  = bakpath +"/"+"Nino34_ENSO_index_"+tname+"_monthly_mean_"+seasons(kk)+".nc"
    out_file2  = bakpath +"/"+"Nino34_ENSO_index_"+cname+"_monthly_mean_"+seasons(kk)+".nc"
    out_file3  = bakpath +"/"+"Nino34_ENSO_index_HadISST_monthly_mean_"+seasons(kk)+".nc"

    system("rm " + out_file1)
    system("rm " + out_file2)
    system("rm " + out_file3)

    fout1      = addfile(out_file1,"c")
    fout2      = addfile(out_file2,"c")
    fout3      = addfile(out_file3,"c")

    time1      = eof1&time
    time2      = eof2&time
    time3      = eof3&time

    time1!0    = "time"
    time2!0    = "time"
    time3!0    = "time"
    time1&time = time1
    time2&time = time2
    time3&time = time3

    fout1->time         = time1
    fout2->time         = time2
    fout3->time         = time3
    eof1!0              = "time"
    eof2!0              = "time"
    eof3!0              = "time"
    eof1@description    = "ENSO Index: Nino34"
    eof2@description    = "ENSO Index: Nino34"
    eof3@description    = "ENSO Index: Nino34"
    fout1->enso         = eof1
    fout2->enso         = eof2
    fout3->enso         = eof3
    delete([/time1,time2,time3,fout1,fout2,fout3,out_file1,out_file2,out_file3,eof1,eof2,eof3/])

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; prepare the data for regression
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ensox     = ensovar1(:,{latS:latN},{lonW:lonE})
    ensoy     = ensovar2(:,{latS:latN},{lonW:lonE})
    ensoz     = ensovar3(:,{latS:latN},{lonW:lonE})
    ensoxClm  = clmMonTLL(ensox) ;(iClmStrt:iClmLast,:,:))
    ensoyClm  = clmMonTLL(ensoy) ;(iClmStrt:iClmLast,:,:))
    ensozClm  = clmMonTLL(ensoz) ;(iClmStrt:iClmLast,:,:))
    ensoxAnom = calcMonAnomTLL (ensox, ensoxClm )  ;ensox1
    ensoyAnom = calcMonAnomTLL (ensoy, ensoyClm )  ;ensoy1
    ensozAnom = calcMonAnomTLL (ensoz, ensozClm )  ;ensoy1

    regxAnom = ensoxAnom(indx1,:,:)
    regyAnom = ensoyAnom(indx2,:,:)
    regzAnom = ensozAnom(indx3,:,:) 
    delete([/ensox,ensoy,ensoz,ensoxClm,ensoyClm,ensozClm,ensoxAnom,ensoyAnom,ensozAnom/])

    idensox  = enso_ind1(indx1)
    idensoy  = enso_ind2(indx2)
    idensoz  = enso_ind3(indx3)
   ;;;;;;start to do the regression;;;;
   print ("Start to regress mslp eof index on selected variables ")
   load "./share_info_for_regression_map.ncl"

 ; =================================================================
 ; Regress
 ; =================================================================
   ddenso1      = dimsizes(regxAnom)
   ddenso2      = dimsizes(regyAnom) 
   ddenso3      = dimsizes(regzAnom)
   enso1_regres = new((/ddenso1(1),ddenso1(2)/),typeof(regxAnom))     ; create an array w meta data
   enso2_regres = new((/ddenso2(1),ddenso2(2)/),typeof(regyAnom))     ; create an array w meta data
   enso3_regres = new((/ddenso3(1),ddenso3(2)/),typeof(regzAnom))     ; create an array w meta data

   enso1_regres@_FillValue = -9999.
   enso2_regres@_FillValue = -9999.
   enso3_regres@_FillValue = -9999.

   enso1_regres!0 = "lat"
   enso1_regres!1 = "lon"
   enso1_regres&lat = regxAnom&lat
   enso1_regres&lon = regxAnom&lon

   enso2_regres!0 = "lat"
   enso2_regres!1 = "lon"
   enso2_regres&lat = regyAnom&lat
   enso2_regres&lon = regyAnom&lon

   enso3_regres!0 = "lat"
   enso3_regres!1 = "lon"
   enso3_regres&lat = regzAnom&lat
   enso3_regres&lon = regzAnom&lon

   enso1_rgprob = enso1_regres
   enso2_rgprob = enso2_regres
   enso3_rgprob = enso2_regres

   delete([/ddenso1,ddenso2,ddenso3/])

   rc1   = regCoef_n(idensox, regxAnom, 0, 0)
   rc2   = regCoef_n(idensoy, regyAnom, 0, 0)
   rc3   = regCoef_n(idensoz, regzAnom, 0, 0)

   rc1@_FillValue = -9999.
   rc2@_FillValue = -9999.
   rc3@_FillValue = -9999.

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
    enso1_rgprob(:,:) = (/ prob1 /)
    delete([/drc1,df1,tval1,xb1,pb1,prob1/])

    drc2  = dimsizes(rc2)
    df2   = rc2@nptxy-2   ; degrees of freedom
    tval2 = rc2@tval      ; t-statistic
    xb2   = tval2
    xb2   = 0.50
    pb2   = betainc(df2/(df2+tval2^2),df2/2.0,xb2)
    prob2 = reshape(pb2,(/drc2(0),drc2(1)/))
    prob2 = where(prob2.le.statistical_siglev,rc2,rc2@_FillValue)
    enso2_rgprob(:,:) = (/ prob2 /)
    delete([/drc2,df2,tval2,xb2,pb2,prob2/])

    drc3  = dimsizes(rc3)
    df3   = rc3@nptxy-2   ; degrees of freedom
    tval3 = rc3@tval      ; t-statistic
    xb3   = tval3
    xb3   = 0.50
    pb3   = betainc(df3/(df3+tval3^2),df3/2.0,xb3)
    prob3 = reshape(pb3,(/drc3(0),drc3(1)/))
    prob3 = where(prob3.le.statistical_siglev,rc2,rc2@_FillValue)
    enso3_rgprob(:,:) = (/ prob3 /)
    delete([/drc3,df3,tval3,xb3,pb3,prob3/])

   end if 

   enso1_regres(:,:) = (/ rc1 /)
   enso2_regres(:,:) = (/ rc2 /)
   enso3_regres(:,:) = (/ rc3 /)

   enso1_rgprob = (1.0 - enso1_rgprob)*100.0
   enso2_rgprob = (1.0 - enso2_rgprob)*100.0
   enso3_rgprob = (1.0 - enso3_rgprob)*100.0

   ;;check the two comparing files and see if they are in the same grid,
   ddd1                                  = dimsizes(enso1_regres)
   ddd2                                  = dimsizes(enso2_regres)
   ;;otherwise, return the error message;;;;
   if ((ddd1(0).ne.ddd2(0)).or.(ddd1(1).ne.ddd2(1)))then
     print("Error: this scripts requires the two files must in the same grid to run!!!")
     return
   end if

   ;;;calculate the error metrix
   rad     = 4.*atan(1.)/180.    ;
   cost    = tofloat(cos(enso1_regres&lat*rad))       ; cosine weights
   mean1   = wgt_areaave (enso1_regres,cost,1.0,0)
   mean2   = wgt_areaave (enso3_regres,cost,1.0,0)
   mbias   = wgt_areaave (enso1_regres-enso3_regres,cost,1.0,0)
   mrmsd   = wgt_arearmse(enso1_regres-conform(enso1_regres,mean1,0),enso3_regres-conform(enso3_regres,mean2,0),cost,1.0,0)
   mcorr   = pattern_cor(enso1_regres,enso2_regres,cost, 1)

   smbias    = "Mean diff:   " + sprintf("%5.2f", mbias)
   smrmsd    = "RMS  diff:   " + sprintf("%5.2f", mrmsd)
   smcorr    = "Correlation: " + sprintf("%5.2f", mcorr)
   pstring1  = smbias + "~C~" + smrmsd + "~C~" + smcorr

   mean1   = wgt_areaave (enso2_regres,cost,1.0,0)
   mean2   = wgt_areaave (enso3_regres,cost,1.0,0)
   mbias   = wgt_areaave (enso2_regres-enso3_regres,cost,1.0,0)
   mrmsd   = wgt_arearmse(enso2_regres-conform(enso2_regres,mean1,0),enso3_regres-conform(enso3_regres,mean2,0),cost,1.0,0)
   mcorr   = pattern_cor(enso1_regres,enso2_regres,cost, 1)
   delete([/rad,cost,mean1,mean2/])

   smbias    = "Mean diff:   " + sprintf("%5.2f", mbias)
   smrmsd    = "RMS  diff:   " + sprintf("%5.2f", mrmsd)
   smcorr    = "Correlation: " + sprintf("%5.2f", mcorr)
   pstring2  = smbias + "~C~" + smrmsd + "~C~" + smcorr


 ; =================================================================
 ; Extract the YYYYMM from the time coordinate 
 ; associated with enso_ts [same as x&time] 
 ; =================================================================
   utc_date1 = cd_calendar(regxAnom&time,1)  
   utc_date2 = cd_calendar(regyAnom&time,1)
   utc_date3 = cd_calendar(regzAnom&time,1)
   
   yyyy1     = yyyymm_to_yyyyfrac(utc_date1, 0.0) ;utc_date1(:,0)
   yyyy2     = yyyymm_to_yyyyfrac(utc_date2, 0.0) ;utc_date2(:,0)
   yyyy3     = yyyymm_to_yyyyfrac(utc_date3, 0.0) ;utc_date2(:,0)
   delete([/utc_date1,utc_date2,utc_date3/]) 

   delete([/rc1,rc2,rc3,regxAnom,regyAnom,regzAnom/])
   

  ;;;;start to plot;;;;;;;;;;;;;;
  wtype     = "eps"
  fildir    = outdir+"/ENSO_Index_Analysis/"
  filname   = str_sub_str(ninoreg," ","")+"_regression_on_PSL_"+seasons(kk)
  wks       = gsn_open_wks("eps",fildir+filname)
  plot      = new (6,graphic)
  dum       = new (6,graphic)

 ;============================================================
 ; PLOTS
 ;============================================================
   res                      = True
   res@gsnDraw              = False        ; don't draw yet
   res@gsnFrame             = False        ; don't advance frame yet
   res@gsnAddCyclic         = False        ; data not cyclic

   FontHeightF = 0.024
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

   res@mpLabelFontHeightF           = FontHeightF*2.0
   res@mpFillOn             = False        ; turn off map fill

   res@mpCenterLonF         = 180.         ; default is 0 [GM]
   res@mpMinLatF            = latS
   res@mpMaxLatF            = latN
   res@mpMinLonF            = lonW
   res@mpMaxLonF            = lonE

   res@mpShapeMode          = "FreeAspect"
   res@vpHeightF            = 0.40        ; Changes the aspect ratio
   res@vpWidthF             = 0.85
   res@vpXF                 = 0.25        ; change start locations
   res@vpYF                 = 0.75        ; the plot

   ;res@gsnMajorLatSpacing            = 30
   ;res@gsnMajorLonSpacing            = 45
   ;res@gsnMinorLatSpacing            = 15
   ;res@gsnMinorLonSpacing            = 15

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
   mnmxint = nice_mnmxintvl( -1.2, 1.2, maxlev, False)
   res@cnMinLevelValF           = mnmxint(0) ; set the minimum contour level
   res@cnMaxLevelValF           = mnmxint(1) ; set the maximum contour level     
   res@cnLevelSpacingF          = mnmxint(2) ; *special* match CPC

   delete([/mnmxint/])

 ;*******************************************
 ; first plot
 ;*******************************************
  ;---Draw first plot in upper left corner
   res@gsnLeftString     = "Regress on TS (~S~o~N~C)"
   res@gsnRightString    = ninoreg 
   res@gsnCenterString   = ""
   res@tiMainString      = panelstr1
   plot(0)   = gsn_csm_contour_map(wks,enso1_regres(:,:),res)

  ;---Draw second plot in upper right corner
   res@gsnLeftString     = "Regress on SST (~S~o~N~C)"
   res@gsnRightString    = ninoreg 
   res@gsnCenterString   = "";
   res@tiMainString      = "" + panelstr2
   plot(1) = gsn_csm_contour_map(wks,enso2_regres(:,:),res)

  ;---Draw second plot in upper right corner
   res@gsnLeftString     = "Regress on SST (~S~o~N~C)"
   res@gsnRightString    = ninoreg 
   res@gsnCenterString   = "";
   res@tiMainString      = "" +"HadISST" 
   plot(2) = gsn_csm_contour_map(wks,enso3_regres(:,:),res)

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
   dum(0)   = gsn_csm_contour(wks,enso1_rgprob(:,:),rescn2) ; contours are at 95,100
   dum(1)   = gsn_csm_contour(wks,enso2_rgprob(:,:),rescn2) ; contours are at 95,100
   dum(2)   = gsn_csm_contour(wks,enso3_rgprob(:,:),rescn2) ; contours are at 95,100

   overlay(plot(0),dum(0))
   overlay(plot(1),dum(1))
   overlay(plot(2),dum(2))

 ;*******************************************
 ; second plot
 ;*******************************************
 ; EOF time series  [bar form]
   rts           = True
   rts@gsnDraw   = False       ; don't draw yet
   rts@gsnFrame  = False       ; don't advance frame yet
   rts@gsnScale  = True        ; force text scaling               

   rts@tiYAxisString = ""
   rts@tiXAxisString = "Time"

   rts@vpHeightF = 0.40        ; Changes the aspect ratio
   rts@vpWidthF  = 0.90
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
   rts@gsnLeftString        = ninoreg+" index"
   rts@gsnRightString       = "Standardized index" 
   rts@tiMainString         = "" ;""+panelstr2
   plot(3) = gsn_csm_xy (wks,yyyy1,idensox(:),rts)
    
   rts1 = rts
   rts1@gsnXYBarChart       = False
   rts1@gsnLeftString       = ""
   rts1@gsnRightString      = ""
   rts1@gsnCenterString     = ""
   rts1@xyLineThicknesses   = 3            
   rts1@xyLineColors        = "Black"
   xyarr1                   = wgt_runave_Wrap(idensox(:),(/1.,3,5,6,5,3,1/), 0)   
   dum(3)                   = gsn_csm_xy(wks,yyyy1,xyarr1,rts1) 
   overlay(plot(3),dum(3))
   delete([/xyarr1/])


   ;---Draw fourth plot in upper right corner
   rts@gsnLeftString        = ninoreg+" index"
   rts@gsnRightString       = "Standardized index" 
   rts@tiMainString         = "" ;""+panelstr2
   plot(4) = gsn_csm_xy (wks,yyyy2,idensoy(:),rts)

   rts2 = rts
   rts2@gsnXYBarChart       = False
   rts2@gsnLeftString       = ""
   rts2@gsnRightString      = ""
   rts2@gsnCenterString     = ""
   rts2@xyLineThicknesses   = 3 
   rts2@xyLineColors        = "Black"
   xyarr2                   = wgt_runave_Wrap(idensoy(:),(/1.,3,5,6,5,3,1/), 0) 
   dum(4)               = gsn_csm_xy(wks,yyyy2,xyarr2,rts2)
   overlay(plot(4),dum(4))
   delete([/xyarr2/])

   ;---Draw fourth plot in upper right corner
   rts@gsnLeftString        = ninoreg+" index"
   rts@gsnRightString       = "Standardized index" 
   rts@tiMainString         = "" 
   plot(5) = gsn_csm_xy (wks,yyyy3,idensoz(:),rts)

   rts2 = rts
   rts2@gsnXYBarChart       = False
   rts2@gsnLeftString       = ""
   rts2@gsnRightString      = ""
   rts2@gsnCenterString     = ""
   rts2@xyLineThicknesses   = 3
   rts2@xyLineColors        = "Black"
   xyarr3                   = wgt_runave_Wrap(idensoz(:),(/1.,3,5,6,5,3,1/), 0)
   dum(5)               = gsn_csm_xy(wks,yyyy3,xyarr3,rts2)
   overlay(plot(5),dum(5))
   delete([/xyarr3/])

 ; panel plot only resources
   pres1                          = True                ; mods desired
   pres1@gsnFrame                 = True               ; save panel until both ready
   gsn_panel(wks,plot,(/2,3/),pres1)          ; create first panel
     
  ;pres2                           = True          ; mods desired
  ;pres2@gsnFrame                  = False          ; save panel until both ready
  ;pres2@gsnPanelBottom            = 0.18          ; draw from center to right edge
  ;pres2@gsnPanelTop               = 0.45		       ; draw from center to right edge 
  ;pres2@gsnPanelXF                = (/0.05,0.55/)
  ; gsn_panel(wks,plot(3:5),(/1,3/),pres2)       ; create first panel
  ; frame(wks)                                   ; draw both on same page

   delete([/plot,dum/])
   delete([/idensox,idensoy,idensoz/])
   delete([/yyyy1,yyyy2,yyyy3/])
   delete([/indx1,indx2,indx3/])
  end do                                              ; end of looping over variables

  delete([/ensovar1,ensovar2,ensovar3,ensoxclat,ensoyclat,ensozclat/])

  delete([/monthx1,monthx2/])
  delete([/enso_ind1,enso_ind2/])

end

