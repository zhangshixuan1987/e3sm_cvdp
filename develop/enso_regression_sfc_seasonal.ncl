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
  tpath                                      = getenv("TPATH")
  cpath                                      = getenv("CPATH")
  case1name                                  = getenv("TEST_NAME")
  case2name                                  = getenv("CTRL_NAME")
  casedir                                    = getenv("CASEDIR")
  statistical_test                           = getenv("REGRESSION_TEST")
  statistical_siglev                         = 0.1

;define regions for eof analysis
  latS                                         = -90.  ;negative for southern hemisphere
  latN                                         = -20.  ;negative for southern hemisphere

;define color for the plot of signiticant test 
  FillColor           = "Black";"Grey75" ;"Grey65";"Grey28";"Grey";"Black"
  FillPattern         = 0 ;17 ;6 ;17;11
  FillScaleF          = 5.0
  FillDotSizeF        = 0.00002    ; increase dot size of contours
  FillOpacityF        = 0.5 ;0.15

;define constants for unit conversion
  pi                                           = 3.14159265
  rearth                                       = 6.37122e6
  grav                                         = 9.80665

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

  modninovar                                   = ("TS")
  obsninovar                                   = ("sst")
  nenso                                        = 3     ; Leading EOF only
  ninoreg                                      = (/"Nino 3", "Nino 3.4", "Nino 4"/)
  ninolats                                     = (/ -5,  -5,  -5/)
  ninolate                                     = (/  5,   5,   5/)
  ninolons                                     = (/210, 190, 160/)     
  ninolone                                     = (/270, 240, 210/)

;variable name in the climo file
  modvars                                      = (/"PSL", "TS","TREFHT",  "U10", "PRECT", "CLDLOW","CLDTOT","SWCF","LWCF", "NETCF"/)
  obsvars                                      = (/"msl","skt", "t2m"  , "si10", "mtpr" , "lcc",    "tcc",   "tsr", "ttr", "netcf"/)

  seasons                                      = (/"ANN","DJF","JJA"/)
  preslev                                      = (/"Surface"/)

  maxlev                                       = 11
  minlev_enso1                                 = (/-100.,-0.5, -0.5, -0.5, -0.5, -0.01, -0.01, -2., -1., -1./)
  maxlev_enso1                                 = (/ 100., 0.5,  0.5,  0.5,  0.5,  0.01,  0.01,  2.,  1.,  1./)

  minlev_enso2                                 = (/-100.,-0.5, -0.5, -0.5, -0.5, -0.01, -0.01, -2., -1., -1./)
  maxlev_enso2                                 = (/ 100., 0.5,  0.5,  0.5,  0.5,  0.01,  0.01,  2.,  1.,  1./)

  minlev_enso3                                 = (/-100.,-0.5, -0.5, -0.5, -0.5, -0.01, -0.01, -2., -1., -1./)
  maxlev_enso3                                 = (/ 100., 0.5,  0.5,  0.5,  0.5,  0.01,  0.01,  2.,  1.,  1./)

;read in two files

  do ll = 0,dimsizes(preslev) - 1

     do kk = 0,dimsizes(seasons) - 1

        f                                      = systemfunc("ls $TPATH/*_monthly_means.nc")
        f1                                     = addfile(f,"r")
        ps1                                    = f1->PS
        ha1                                    = doubletofloat(f1->hyam)
        hb1                                    = doubletofloat(f1->hybm)
        p0                                     = doubletofloat(f1->P0)
        p1                                     = pres_hybrid_ccm(ps1,p0,ha1,hb1)
        p1                                     = p1/100.
        gw1                                    = doubletofloat(f1->gw)

        if(compare.eq."Model_vs_OBS") then
          f                                       = systemfunc("ls $CPATH/*_siglev_monthly_analysis*.nc")
          f2                                      = addfile(f,"r")
          gw2                                     = doubletofloat(f2->gw)
        else
          f                                       = systemfunc("ls $CPATH/*_monthly_means.nc")
          f2                                      = addfile(f,"r")
          ps2                                     = f2->PS
          ha2                                     = doubletofloat(f2->hyai)
          hb2                                     = doubletofloat(f2->hybi)
          p2                                      = pres_hybrid_ccm(ps2,p0,ha2,hb2)
          p2                                      = p2/100.
          gw2                                     = doubletofloat(f2->gw)
        end if

         
       ;;;;read and calculate nino indices;;;;;;;;;;;;;;;;;;;;
        ensovp1                            = f1->$modninovar$

        if(compare.eq."Model_vs_OBS") then
          ensovp2                          = f2->$obsninovar$
        else
          ensovp2                          = f2->$modninovar$
        end if

       ;printVarSummary(ensovp1)
       ;printVarSummary(ensovp2)

        ensovp1@_FillValue                  = -9999.
        ensovp2@_FillValue                  = -9999.
        edd1                                = dimsizes(ensovp1)
        edd2                                = dimsizes(ensovp2)

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

        enso_ind1  = new((/nenso,edd1(0)/),typeof(ensovp1))
        enso_ind2  = new((/nenso,edd2(0)/),typeof(ensovp2))
        enso_ind1!0 = "nenso"
        enso_ind1!1 = "time"
        enso_ind2!0 = "nenso"
        enso_ind2!1 = "time"
        enso_ind1&time = ensovp1&time
        enso_ind2&time = ensovp2&time



        do ienso   = 0,nenso-1,1

         latm1     = ninolats(ienso)
         latm2     = ninolate(ienso)
         lonm1     = ninolons(ienso)
         lonm2     = ninolone(ienso)

         ensox     = ensovp1(:,{latm1:latm2},{lonm1:lonm2})
         ensoy     = ensovp2(:,{latm1:latm2},{lonm1:lonm2})

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


        do jj = 0, dimsizes(modvars)-1

           mvarnam                             = modvars(jj)
           if(mvarnam.eq."PRECT") then
             vp1                               = f1->PRECC
             vp1                               = f1->PRECC + f1->PRECL
             vp1                               = vp1 * 1000.0 * 24.0 * 3600.0 
             vp1@units                         = "mm day~S~-1~N~"
           else if (mvarnam.eq."NETCF") then

             vp1                               = f1->SWCF
             vp1                               = f1->SWCF + f1->LWCF
             vp1@units                         = "W m~S~-2~N~"
           else
             vp1                               = f1->$mvarnam$
           end if 
           end if 

           if(compare.eq."Model_vs_OBS") then

              ovarnam                          = obsvars(jj)
              if(mvarnam.eq."PRECT") then
                vp2                            = f2->$ovarnam$
                vp2                            = vp2 * 24.0 * 3600.0
                vp2@units                      = "mm day~S~-1~N~"
              else if (mvarnam.eq."SWCF") then 
                vp2                            = f2->tsr
                vp2                            = f2->tsr - f2->tsrc
                vp2                            = vp2/86400.0 ; convert to W m^-2
                vp2@units                      = "W m~S~-2~N~"
              else if (mvarnam.eq."LWCF") then 
                vp2                            = f2->ttr
                vp2                            = f2->ttr - f2->ttrc
                vp2                            = vp2/86400.0 ; convert to W m^-2
                vp2@units                      = "W m~S~-2~N~"
              else if (mvarnam.eq."NETCF") then
                vp2                            = f2->ttr
                vp2                            = f2->ttr - f2->ttrc + \
                                                 f2->tsr - f2->tsrc
                vp2                            = vp2/86400.0 ; convert to W m^-2
                vp2@units                      = "W m~S~-2~N~"
              else                
                vp2                            = f2->$ovarnam$
              end if 
              end if 
              end if 
              end if 

           else

             if(mvarnam.eq."PRECT") then

               vp2                             = f2->PRECC
               vp2                             = f2->PRECC + f2->PRECL
               vp2                             = vp2 * 1000.0 * 24.0 * 3600.0 
               vp2@units                       = "mm day~S~-1~N~"
 
             else if (mvarnam.eq."NETCF") then

               vp2                             = f2->SWCF
               vp2                             = f2->SWCF + f2->LWCF
               vp2@units                       = "W m~S~-2~N~"
            
             else

               vp2                             = f2->$mvarnam$

             end if 
             end if 

           end if

           vp1@_FillValue                      = -9999.
           vp2@_FillValue                      = -9999.
           ddd1                                = dimsizes(vp1)
           ddd2                                = dimsizes(vp2)

           ;printVarSummary(vp1)
           ;printVarSummary(vp2)

           ;;check the two comparing files and see if they are in the same grid, otherwise, return the error message;;;;
           if ((ddd1(1).ne.ddd2(1)).or.(ddd1(2).ne.ddd2(2)))then
            print("Error: this scripts requires the two files must in the same grid to run!!!")
            return
           end if

        ;;;;;;start to process the regression variable ;;;;

         regx1  = vp1(:,{latS:latN},:)
         regy1  = vp2(:,{latS:latN},:)

       ; ==============================================================
       ; compute climatology and Anomalies
       ; ==============================================================
         regxClm1  = clmMonTLL(regx1) 
         regyClm1  = clmMonTLL(regy1) 

         regxAnom1 = calcMonAnomTLL (regx1, regxClm1 )  
         regyAnom1 = calcMonAnomTLL (regy1, regyClm1 )  

       ; =================================================================
       ; Select different season for the eof
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

         delete([/indx1,indx2,regxAnom1,regyAnom1,utc_date1,utc_date2,monthx1,monthx2/])

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

         ddenso1      = dimsizes(regx1)
         ddenso2      = dimsizes(regy1) 
         enso1_lat    = new((/ddenso1(0),ddenso1(1)*ddenso1(2)/),typeof(regxAnom))
         enso1_lon    = new((/ddenso1(0),ddenso1(1)*ddenso1(2)/),typeof(regxAnom))
         enso2_lat    = new((/ddenso2(0),ddenso2(1)*ddenso2(2)/),typeof(regyAnom))
         enso2_lon    = new((/ddenso2(0),ddenso2(1)*ddenso2(2)/),typeof(regyAnom))
         enso1_lat@_FillValue = -9999.
         enso1_lon@_FillValue = -9999.
         enso2_lat@_FillValue = -9999.
         enso2_lon@_FillValue = -9999.

         enso1_regres = new((/nenso,ddenso1(1),ddenso1(2)/),typeof(regx1))     ; create an array w meta data
         enso2_regres = new((/nenso,ddenso2(1),ddenso2(2)/),typeof(regy1))     ; create an array w meta data
         enso1_regres@_FillValue = -9999.
         enso2_regres@_FillValue = -9999.
         enso1_regres!0 = "nenso"
         enso1_regres!1 = "lat"
         enso1_regres!2 = "lon"
         enso1_regres&lat = regx1&lat
         enso1_regres&lon = regx1&lon
         enso2_regres!0 = "nenso"
         enso2_regres!1 = "lat"
         enso2_regres!2 = "lon"
         enso2_regres&lat = regx1&lat
         enso2_regres&lon = regx1&lon

         do ne=0,nenso-1

            rc1   = regCoef_n(enso_ind1(ne,:), regxAnom, 0, 0)
            rc2   = regCoef_n(enso_ind2(ne,:), regyAnom, 0, 0)

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
       ; associated with eof_ts [same as x&time] 
       ; =================================================================

         utc_date1 = cd_calendar(enso_ind1&time,-1)  
         utc_date2 = cd_calendar(enso_ind2&time,-1)
         
         yyyy1     = yyyymm_to_yyyyfrac(utc_date1, 0.0) ;utc_date1(:,0)
         yyyy2     = yyyymm_to_yyyyfrac(utc_date2, 0.0) ;utc_date2(:,0)
 
        ;print(yyyy1)

       do n = 0, nenso-1

         fildir    = casedir+"/Regression_Contour_Maps/"
         filname   = str_sub_str(ninoreg(n)," ","")+"_regression_on_"+modvars(jj) +"_"+seasons(kk)
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
          mnmxint = nice_mnmxintvl( minlev_enso1(jj), maxlev_enso1(jj), maxlev, False)
        else if (n.eq.1)then 
          mnmxint = nice_mnmxintvl( minlev_enso2(jj), maxlev_enso2(jj), maxlev, False)
        else
          mnmxint = nice_mnmxintvl( minlev_enso3(jj), maxlev_enso3(jj), maxlev, False)
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
          res@gsnCenterString   = "" ;case1name
          res@tiMainString      = "Case: "+case1name
          plot(0)   = gsn_csm_contour_map_polar(wks,enso1_regres(n,:,:),res)

          ;---Draw second plot in upper right corner
          res@gsnLeftString     = "Regression ("+ninoreg(n)+")"
          res@gsnRightString    = "" ;sprintf("%5.1f", enso2@pcvar(n)) +"%"
          res@gsnCenterString   = "" ;case2name
          res@tiMainString      = "Case: "+case2name
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
          rts@tiMainString         = "" ;"Case: "+case1name
          plot(2) = gsn_csm_xy (wks,yyyy1,enso_ind1(n,:),rts)
           
          rts1 = rts
          rts1@gsnXYBarChart       = False
          rts1@gsnLeftString       = ""
          rts1@gsnRightString      = ""
          rts1@gsnCenterString     = ""
          rts1@xyLineThicknesses   = 3            
          rts1@xyLineColors        = "Black"
          xyarr1                   = wgt_runave_Wrap(enso_ind1(n,:),(/1.,3,5,6,5,3,1/), 0)   
          tsmap1(2)            = gsn_csm_xy(wks,yyyy1,xyarr1,rts1) 
          overlay(plot(2),tsmap1(2))
          delete([/xyarr1/])


          ;---Draw fourth plot in upper right corner
          rts@gsnLeftString        = ninoreg(n)+" index"
          rts@gsnRightString       = "";sprintf("%5.1f", enso2_regres@pcvar(n)) +"%"
          rts@tiMainString         = "" ;"Case: "+case2name
          plot(3) = gsn_csm_xy (wks,yyyy2,enso_ind2(n,:),rts)

          rts2 = rts
          rts2@gsnXYBarChart       = False
          rts2@gsnLeftString       = ""
          rts2@gsnRightString      = ""
          rts2@gsnCenterString     = ""
          rts2@xyLineThicknesses   = 3 
          rts2@xyLineColors        = "Black"
          xyarr2                   = wgt_runave_Wrap(enso_ind2(n,:),(/1.,3,5,6,5,3,1/), 0) 
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
         delete([/regxAnom,regyAnom,regx1,regy1,utc_date1,utc_date2/])
        ;delete([/f1,ps1,ha1,hb1,p0,p1,f2,ps2,ha2,hb2,p2/])
        end do                                              ; end of looping over variables
         delete([/enso_ind1,enso_ind2,enso1_regres,enso2_regres/])

     end do                                                 ; end of looping over seasons

  end do                                                    ; end of looping over pressure levels


end

