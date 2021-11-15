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

;define regions for eof analysis
  latS                                       = -20.  ;negative for southern hemisphere
  latN                                       =  20.  ;negative for southern hemisphere
  lonW                                       = 120.0
  lonE                                       = 300.0

;define # of desired EOFs
  neof                                       = 3     ; Leading EOF only

;define constants for unit conversion
  pi                                         = 3.14159265
  rearth                                     = 6.37122e6
  grav                                       = 9.80665

;variable name in the climo file
  modvars                                    = (/"TS"/)
  facmod                                     = (/1.0/)
  varunt                                     = (/"~S~o~N~C"/)
  panelstr1                                  = tname + " ("+tttag+")"
  panelstr2                                  = cname + " ("+cttag+")"

  if(compare.eq."Model_vs_OBS")then

   if((cname.eq."ERA5").or.(cname.eq."ERA20C").or.(cname.eq."ERA_20C")) then
     obsvars                                 = (/"sst"/)
     facobs                                  = (/1.0/)
   else if ((cname.eq."NOAA20C").or.(cname.eq."NOAA_20C")) then
     obsvars                                 = (/"skt"/)
     facobs                                  = (/1.0/)
   else
    print("The observational source are not available; only allow ERA5, ERA20C or NOAA20C")
    exit
   end if
   end if
  
  end if 

;declear the season or annual mean data to be used;;;;;
  seasons                                    = (/"ANN","DJF","JJA","MAM","SON"/)
  pout                                    = (/"Surface"/)

  maxlev                                     = 11 
  minlev_eof1                                = (/-1.2/)              
  maxlev_eof1                                = (/ 1.2/)
    
  minlev_eof2                                = (/-1.2/)
  maxlev_eof2                                = (/ 1.2/)

;read in two files

  do ll = 0,dimsizes(pout) - 1

      f                                       = systemfunc("ls "+tpath+"/"+tcase+"_*_"+tttag+".nc")
      f1                                      = addfile(f,"r")
      gw1                                     = f1->gw
      lndmsk                                  = f1->LANDFRAC(0,:,:)

      f                                       = systemfunc("ls "+cpath+"/"+ccase+"_*_"+cttag+".nc")
      f2                                      = addfile(f,"r")
      gw2                                     = f2->gw

      ;read the Hadley center SST and used it as reference 
      f                                       = systemfunc("ls "+obspath+"/pobs/"+"HadISST_sst_360x180*.nc")
      f3                                      = addfile(f,"r")

      do jj = 0, dimsizes(modvars)-1

        mvarnam  = modvars(jj)
        print("working on variable "+ mvarnam)
        load "./function_read_model_var.ncl"

        if (compare.eq."Model_vs_OBS") then
          ovarnam  = obsvars(jj)
          load "./function_read_obs_var.ncl"
        end if

        var1@_FillValue                      = -9999.
        var2@_FillValue                      = -9999.
        
        ;;read hadley center SST for the comparison;;;;
        ;;need to find the overlap time;;;
        ;shift the model time to be consistent with the observations;;;
         var1&time = var1&time - 1.0
         if(compare.ne."Model_vs_OBS")then
           var1&time = var1&time - 1.0
         end if
        utc_date1 = cd_calendar(var1&time,0)
        utc_date2 = cd_calendar(var2&time,0)
        miny = min((/min(utc_date1(:,0)),min(utc_date2(:,0))/))
        maxy = max((/max(utc_date1(:,0)),max(utc_date2(:,0))/))
        utc_date3 = cd_calendar(f3->time,0)
        indtim = ind(utc_date3(:,0).ge.miny.and.utc_date3(:,0).le.maxy)  
        var3 = f3->sst(indtim,:,:)
        var3@_FillValue                      = -9999.
        delete([/utc_date1,utc_date2,utc_date3,indtim/])

        ;;;mask out all values over land
        tmp1 = conform(var1,lndmsk,(/1,2/))
        tmp2 = conform(var2,lndmsk,(/1,2/))
        tmp3 = conform(var3,lndmsk,(/1,2/))

        var1 = where(tmp1.ge.1,var1@_FillValue,var1)
        var2 = where(tmp2.ge.1,var2@_FillValue,var2)
        var3 = where(tmp3.ge.1,var3@_FillValue,var3)
        delete([/tmp1,tmp2,tmp3/])

        if(compare.eq."Model_vs_OBS") then
          var1                               = var1*facmod(jj)
          var2                               = var2*facobs(jj)
        else
          var1                               = var1*facmod(jj)
          var2                               = var2*facmod(jj)
        end if

        if(mvarnam.eq."TS") then 
          var1 = var1 - 273.15 
          var2 = var2 - 273.15 
        end if 

        var1@units                           = varunt(jj)
        var2@units                           = varunt(jj)
        var3@units                           = varunt(jj)

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
        x1       = var1(:,{latS:latN},{lonW:lonE})
        y1       = var2(:,{latS:latN},{lonW:lonE})
        z1       = var3(:,{latS:latN},{lonW:lonE})
        delete([/var1,var2,var3/])

      ; ==============================================================
      ; compute climatology and Anomalies
      ; ==============================================================
        xClm1  = clmMonTLL(x1)                      ; (12,lat,lon)
        yClm1  = clmMonTLL(y1)
        zClm1  = clmMonTLL(z1)

        xAnom1 = calcMonAnomTLL(x1, xClm1)
        yAnom1 = calcMonAnomTLL(y1, yClm1)
        zAnom1 = calcMonAnomTLL(z1, zClm1)
       
        ;printVarSummary(xAnom1)         
        ;printMinMax(xAnom1, True)

      ; =================================================================
      ; create weights:  sqrt(cos(lat))   [or sqrt(gw) ]
      ; =================================================================
        rad    = get_d2r("float")
        xclat  = xAnom1&lat            
        xclat  = sqrt( cos(rad*xclat) )                 ; gw for gaussian grid
        yclat  = yAnom1&lat 
        yclat  = sqrt( cos(rad*yclat) )                 ; gw for gaussian grid
        zclat  = zAnom1&lat
        zclat  = sqrt( cos(rad*zclat) )                 ; gw for gaussian grid

      ; =================================================================
      ; weight all data 
      ; =================================================================
        xw1    = xAnom1*conform(xAnom1, xclat, 1)
        yw1    = yAnom1*conform(yAnom1, yclat, 1)
        zw1    = zAnom1*conform(zAnom1, zclat, 1)

        copy_VarMeta(x1, xw1)
        copy_VarMeta(y1, yw1) 
        copy_VarMeta(z1, zw1)

        xw1@long_name = "Wgt: "+x1@long_name
        yw1@long_name = "Wgt: "+y1@long_name
        zw1@long_name = "Wgt: "+z1@long_name

       ; =================================================================
       ; Select different season for the eof
       ; =================================================================
       ; shift the model time to be consistent with the observations;;;
         xw1&time = xw1&time - 1.0
         if(compare.ne."Model_vs_OBS")then
           yw1&time = yw1&time - 1.0
         end if

         utc_date1 = cd_calendar(xw1&time,0)
         utc_date2 = cd_calendar(yw1&time,0)
         utc_date3 = cd_calendar(zw1&time,0)
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

         xw    = xw1(indx1,:,:)
         yw    = yw1(indx2,:,:)
         zw    = zw1(indx3,:,:)

         xAnom = xAnom1(indx1,:,:)
         yAnom = yAnom1(indx2,:,:)
         zAnom = zAnom1(indx3,:,:)

         delete([/indx1,indx2,indx3/])

       ; =================================================================
       ; Compute EOFs & Standardize time series
       ; =================================================================
         optEOF  = True
         optETS  = False

         eof1    = eofunc_n_Wrap(xw, neof, optEOF, 0)      
         eof2    = eofunc_n_Wrap(yw, neof, optEOF, 0)
         eof3    = eofunc_n_Wrap(zw, neof, optEOF, 0)
    
         do n = 0,neof-1
          pcor = pattern_cor(eof1(n,:,:),eof3(n,:,:),1.0,0)
          if(pcor.lt.0)then
            eof1(n,:,:) = eof1(n,:,:) * -1.0
          end if
          pcor = pattern_cor(eof2(n,:,:),eof3(n,:,:),1.0,0)
          if(pcor.lt.0)then
            eof2(n,:,:) = eof2(n,:,:) * -1.0
          end if
         end do 

         eof1_ts = eofunc_ts_n_Wrap (xw, eof1, optETS, 0)
         eof2_ts = eofunc_ts_n_Wrap (yw, eof2, optETS, 0)
         eof3_ts = eofunc_ts_n_Wrap (zw, eof3, optETS, 0)

         eof1_ts = dim_standardize_n( eof1_ts, 0, 1)      ; normalize
         eof2_ts = dim_standardize_n( eof2_ts, 0, 1)      ; normalize
         eof3_ts = dim_standardize_n( eof3_ts, 0, 1)      ; normalize

        ;======================================================================
        ;Save the data for the regression analysis
        ;==================================================================
         setfileoption("nc", "Format",  "NetCDF4")
         out_file1  = bakpath +"/"+"ENSO_SST_EOF_PCS_"+tname+"_monthly_mean_at_"+pout(ll)+"_"+seasons(kk)+".nc"
         out_file2  = bakpath +"/"+"ENSO_SST_EOF_PCS_"+cname+"_monthly_mean_at_"+pout(ll)+"_"+seasons(kk)+".nc"
         out_file3  = bakpath +"/"+"ENSO_SST_EOF_PCS_HadISST_monthly_mean_at_"+pout(ll)+"_"+seasons(kk)+".nc"

         system("rm " + out_file1)
         system("rm " + out_file2)
         system("rm " + out_file3)

         fout1 = addfile(out_file1,"c")
         fout2 = addfile(out_file2,"c")
         fout3 = addfile(out_file3,"c")

         time1 = eof1_ts&time
         time2 = eof2_ts&time
         time3 = eof3_ts&time

         time1!0 = "time"
         time2!0 = "time"
         time3!0 = "time"

         time1&time = time1
         time2&time = time2
         time3&time = time3

         fout1->time         = time1
         fout2->time         = time2
         fout3->time         = time3

         eof1@description    = "EOF pattern"
         eof2@description    = "EOF pattern"
         eof3@description    = "EOF pattern"

         eof1_ts@description = "EOF PCs (standardized)"
         eof2_ts@description = "EOF PCs (standardized)"
         eof3_ts@description = "EOF PCs (standardized)"

         fout1->eof      = eof1
         fout2->eof      = eof2
         fout3->eof      = eof3

         fout1->eof_ts   = eof1_ts
         fout2->eof_ts   = eof2_ts
         fout3->eof_ts   = eof3_ts

         delete([/time1,time2,time3,fout1,fout2,fout3,out_file1,out_file2,out_file3/])

       ; =================================================================
       ; Regress
       ; =================================================================

         eof1_regres = eof1                               ; create an array w meta data
         eof2_regres = eof2                               ; create an array w meta data
         eof3_regres = eof3                               ; create an array w meta data

         do ne=0,neof-1

            eof1_regres(ne,:,:) = (/ regCoef_n(eof1_ts(ne,:), xAnom, 0, 0) /)
            eof2_regres(ne,:,:) = (/ regCoef_n(eof2_ts(ne,:), yAnom, 0, 0) /)
            eof3_regres(ne,:,:) = (/ regCoef_n(eof3_ts(ne,:), zAnom, 0, 0) /)

         end do

       ; =================================================================
       ; Extract the YYYYMM from the time coordinate 
       ; associated with eof_ts [same as x&time] 
       ; =================================================================

         utc_date1 = cd_calendar(eof1_ts&time,-1)  
         utc_date2 = cd_calendar(eof2_ts&time,-1)
         utc_date3 = cd_calendar(eof3_ts&time,-1)
        
         yyyy1     = yyyymm_to_yyyyfrac(utc_date1, 0.0) ;utc_date1(:,0)
         yyyy2     = yyyymm_to_yyyyfrac(utc_date2, 0.0) ;utc_date2(:,0)
         yyyy3     = yyyymm_to_yyyyfrac(utc_date3, 0.0) ;utc_date2(:,0)

         delete([/utc_date1,utc_date2, utc_date3/])

       do n = 0, neof - 1

         wtype                        = "eps"
        ;wtype@wkWidth                = 2500
        ;wtype@wkHeight               = 2500
         figdir                       = outdir+"/ENSO_EOF_Analysis/"
         fe                           = "ENSO_SST_EOF"+sprinti("%02d",n+1)+"_"+seasons(kk)+"_"+pout(ll) 
         wks                          = gsn_open_wks(wtype, figdir + fe)

         plot      = new((/6/),graphic)
         tsmap1    = new((/6/),graphic)
         tsmap2    = new((/6/),graphic)
      
       ;============================================================
       ; PLOTS
       ;============================================================
         res                      = True         
         res@gsnDraw              = False        ; don't draw yet
         res@gsnFrame             = False        ; don't advance frame yet
         res@gsnAddCyclic         = False        ; data not cyclic

         FontHeightF = 0.024
         res@tiMainFontHeightF        = FontHeightF*1.5
         res@tmYLLabelFontHeightF     = FontHeightF
         res@tmXBLabelFontHeightF     = FontHeightF
         res@lbLabelFontHeightF       = FontHeightF
         res@gsnStringFontHeightF     = FontHeightF*1.2

         res@cnFillOn                 = True         ; turn on color fill
         res@cnFillPalette            = "temp_diff_18lev"   ; specify colormap
         res@cnLinesOn                = True        ; True is default
         res@cnLineLabelsOn           = True        ; True is default

         res@lbLabelBarOn             = True
         res@lbOrientation            = "Vertical"
         res@lbTitleString            = "" ;mvarnam +" ("+xAnom@units+")" ;Geopential height (gpm)";
         res@lbTitlePosition          = "Right"                           ; title location
         res@lbTitleDirection         = "Across"                          ; letter angle
         res@lbTitleAngleF            = 90.                               ; title angle
         res@lbTitleFontHeightF       = FontHeightF                    ; font height
         
        ;res@pmLabelBarParallelPosF   = 0.61
        ;res@pmLabelBarOrthogonalPosF = 0.15

         res@tmXTOn                   = False
         res@tmBorderThicknessF       = 1.0
         res@tmXBMajorThicknessF      = 1.0
         res@tmXBMinorThicknessF      = 1.0
         res@tmYLMajorThicknessF      = 1.0
         res@tmYLMinorThicknessF      = 1.0
         res@tmYRMajorThicknessF      = 1.0
         res@tmYRMinorThicknessF      = 1.0

        res@cnLevelSelectionMode = "ManualLevels"  
        if(n.eq.0)then
          mnmxint = nice_mnmxintvl( minlev_eof1(jj), maxlev_eof1(jj), maxlev, False)
        else 
          mnmxint = nice_mnmxintvl( minlev_eof2(jj), maxlev_eof2(jj), maxlev, False)
        end if
  
        res@cnMinLevelValF           = mnmxint(0) ; set the minimum contour level
        res@cnMaxLevelValF           = mnmxint(1) ; set the maximum contour level     
        res@cnLevelSpacingF          = mnmxint(2) ; *special* match CPC

        delete([/mnmxint/])

       ;*******************************************
       ; first plot
       ;*******************************************
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

         res@tiYAxisString        = " " 
         res@tiXAxisString        = " "

         ;---Draw first plot in upper left corner
         res@gsnLeftString     = "EOF "+(n+1)+ " ("+sprintf("%4.1f", eof1@pcvar(n)) +"%)"
         res@gsnRightString    = mvarnam +" ("+xAnom@units+")" ;sprintf("%4.1f", eof1@pcvar(n)) +"%"
         res@gsnCenterString   = "" ;panelstr1
         res@tiMainString      = panelstr1
         plot(0)   = gsn_csm_contour_map(wks,eof1_regres(n,:,:),res)

         ;---Draw second plot in upper right corner
         res@gsnLeftString     = "EOF "+(n+1)+ " ("+sprintf("%4.1f", eof2@pcvar(n)) +"%)"
         res@gsnRightString    = "SST ("+xAnom@units+")" ; sprintf("%4.1f", eof2@pcvar(n)) +"%"
         res@gsnCenterString   = "" ;panelstr2
         res@tiMainString      = panelstr2
         plot(1) = gsn_csm_contour_map(wks,eof2_regres(n,:,:),res)
      
         ;---Draw second plot in upper right corner
         res@gsnLeftString     = "EOF "+(n+1)+ " ("+sprintf("%4.1f", eof3@pcvar(n)) +"%)"
         res@gsnRightString    = "SST ("+xAnom@units+")" ; sprintf("%4.1f", eof3@pcvar(n)) +"%"
         res@gsnCenterString   = "" 
         res@tiMainString      = "HadISST Obs."
         plot(2) = gsn_csm_contour_map(wks,eof3_regres(n,:,:),res)

       ;*******************************************
       ; second plot
       ;*******************************************
        ; EOF time series  [bar form]

          rts           = True
          rts@gsnDraw   = False       ; don't draw yet
          rts@gsnFrame  = False       ; don't advance frame yet
          rts@gsnScale  = True        ; force text scaling               

          rts@tiYAxisString = "" ;"Standardized Index"  
          rts@tiXAxisString = "Time"

          rts@vpHeightF = 0.40        ; Changes the aspect ratio
          rts@vpWidthF  = 0.85
          rts@vpXF      = 0.10        ; change start locations
          rts@vpYF      = 0.75        ; the plot

          rts@gsnYRefLine           = 0.              ; reference line   
         ;rts@gsnXYBarChart         = False ;True           ; create bar chart 
          rts@gsnAboveYRefLineColor = "salmon"           ; above ref line fill red
          rts@gsnBelowYRefLineColor = "skyblue2"          ; below ref line fill blue

         ;rts@xyLineThicknesses   = 2
         ;rts@xyLineColors       := "Black"

          rts@tmXTOn                       = False
          rts@tmYLLabelFontHeightF         = 0.025
          rts@tmBorderThicknessF           = 1.0
          rts@tmXBMajorThicknessF          = 1.0
          rts@tmXBMinorThicknessF          = 1.0
          rts@tmYLMajorThicknessF          = 1.0
          rts@tmYLMinorThicknessF          = 1.0
          rts@tmYRMajorThicknessF          = 1.0
          rts@tmYRMinorThicknessF          = 1.0

          rts@trYMinF                      = -4.0
          rts@trYMaxF                      =  4.0
          rts@trXMinF                      = miny
          rts@trXMaxF                      = maxy

         ;create individual plots
         ;---Draw third plot in lower left corner
          rts@gsnLeftString     = "EOF "+(n+1) + " ("+sprintf("%4.1f", eof1@pcvar(n)) +"%)"
          rts@gsnRightString    = "Standardized index" ;sprintf("%4.1f", eof1_regres@pcvar(n)) +"%"
          rts@tiMainString      = "" ;"Case: "+panelstr1

          xyarr1                = runave_Wrap (eof1_ts(n,:),3, 0)
          plot(3) = gsn_csm_xy (wks,yyyy1,xyarr1,rts)
          rts1 = rts
          rts1@gsnXYBarChart       = False
          rts1@gsnLeftString       = ""
          rts1@gsnRightString      = ""
          rts1@gsnCenterString     = ""
          xyarr1                   = wgt_runave_Wrap(eof1_ts(n,:),(/1.,3,5,6,5,3,1/), 0)
          tsmap1(1)                = gsn_csm_xy(wks,yyyy1,xyarr1,rts1) 
          overlay(plot(3),tsmap1(1))
          delete([/xyarr1/])

          ;---Draw fourth plot in upper right corner
          rts@gsnLeftString     = "EOF "+(n+1) + " ("+sprintf("%4.1f", eof2@pcvar(n)) +"%)"
          rts@gsnRightString    = "Standardized index" 
          rts@tiMainString      = "" 
          xyarr2                   = runave_Wrap(eof2_ts(n,:),3, 0)
          plot(4) = gsn_csm_xy (wks,yyyy2,xyarr2,rts)
          rts2 = rts
          rts2@gsnXYBarChart       = False
          rts2@gsnLeftString       = ""
          rts2@gsnRightString      = ""
          rts2@gsnCenterString     = ""
          xyarr2                   = wgt_runave_Wrap(eof2_ts(n,:),(/1.,3,5,6,5,3,1/), 0) 
          tsmap1(2)            = gsn_csm_xy(wks,yyyy2,xyarr2,rts2)
          overlay(plot(4),tsmap1(2))
          delete([/xyarr2/])

          ;---Draw fourth plot in upper right corner
          rts@gsnLeftString     = "EOF "+(n+1) + " ("+sprintf("%4.1f", eof3@pcvar(n)) +"%)"
          rts@gsnRightString    = "Standardized index" 
          rts@tiMainString      = "" 
          xyarr3                   = runave_Wrap(eof3_ts(n,:),3, 0)
          plot(5) = gsn_csm_xy (wks,yyyy3,xyarr3,rts)
          rts3 = rts
          rts3@gsnXYBarChart       = False
          rts3@gsnLeftString       = ""
          rts3@gsnRightString      = ""
          rts3@gsnCenterString     = ""
          xyarr3                   = wgt_runave_Wrap(eof3_ts(n,:),(/1.,3,5,6,5,3,1/), 0)
          tsmap1(3)            = gsn_csm_xy(wks,yyyy3,xyarr3,rts3)
          overlay(plot(5),tsmap1(3))
          delete([/xyarr3/])

       ; panel plot only resources
         
          pres1                          = True                ; mods desired
          pres1@gsnFrame                 = False               ; save panel until both ready
         ;pres1@gsnPanelBottom           = 0.45    ; space for label bar
         ;pres1@gsnPanelTop              = 0.85     ; only panel on lower half of page
         ;pres1@gsnPanelXF               = (/0.07,0.57/)
          gsn_panel(wks,plot(:),(/2,3/),pres1)          ; create first panel
          
          frame(wks)                                   ; draw both on same page

         end do ; end of eof mods 

         delete([/eof1_regres,eof2_regres,eof3_regres,yyyy1,yyyy2,yyyy3/])
         delete([/xw,yw,zw,xAnom,yAnom,zAnom,eof1,eof2,eof3,eof1_ts,eof2_ts,eof3_ts/])

        end do                                              ; end of looping over seasons

        delete([/xAnom1,yAnom1,xw1,yw1,x1,y1,xclat,yclat/])
        delete([/monthx1,monthx2/])

        end do                                                 ; end of looping over variables

        delete([/f1/])
        delete([/f2/])

  end do                                                    ; end of looping over pressure levels


end

