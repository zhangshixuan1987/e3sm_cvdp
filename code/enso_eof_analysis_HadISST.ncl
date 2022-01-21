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
  modvars                                    = (/"SST"/)
  facmod                                     = (/1.0/)
  varunt                                     = (/"~S~o~N~C"/)
  panelstr1                                  = tname + " ("+tttag+")"
  panelstr2                                  = cname + " ("+cttag+")"

  if(compare.eq."Model_vs_OBS")then

   if((cname.eq."HadISST")) then 
     obsvars                                 = (/"sst"/)
     facobs                                  = (/1.0/)
   else
    print("This script requires the HadISST observations, please check your setup")
    exit
   end if
  
  end if 

;declear the season or annual mean data to be used;;;;;
  seasons                                   = (/"ANN","DJF","JJA","MAM","SON"/)
  pout                                      = (/"Surface"/)

  maxlev                                    = 11 
  minlev_eof                                = (/-1.2/)              
  maxlev_eof                                = (/ 1.2/)
    
;read in two files

  do ll = 0,dimsizes(pout) - 1

      f                                       = systemfunc("ls "+tpath+"/"+tcase+"*"+tttag+".nc")
      f1                                      = addfile(f,"r")
      gw1                                     = f1->gw
      if (isfilevar(f1, "time")) then
        time1                                 = f1->time
      else 
        tstr = str_split(tttag,"-") 
        yyyymm = yyyymm_time(toint(tstr(0)),toint(tstr(1)),"integer") 
        ntim   = dimsizes(yyyymm)
        yyyy   = yyyymm/100 
        mm     = yyyymm-yyyy*100   
        dd     = mm
        hh     = mm
        mn     = mm
        sc     = mm
        dd     = 1
        hh     = 0                                  ; array syntax
        mn     = 0
        sc     = 0
        units   = "months since 1800-01-01 00:00:00" 
        time1   = cd_inv_calendar(yyyy,mm,dd,hh,mn,sc,units, 0)
        time1!0 = "time"
        delete([/tstr,yyyymm,ntim,yyyy,mm,dd,hh,mn,sc,units/])
      end if 
      delete(f)

      if (compare.eq."Model_vs_OBS") then
        f                                     = systemfunc("ls "+cpath+"/"+ccase+"_sst_*"+cttag+".nc")
        f2                                    = addfile(f,"r")
        gw2                                   = f2->gw
        time2                                 = f2->time
        delete(f)
      else
        f                                       = systemfunc("ls "+cpath+"/"+ccase+"*"+cttag+".nc")
        f2                                      = addfile(f,"r")
        gw2                                     = f2->gw
        if (isfilevar(f2, "time")) then
          time2                                 = f2->time
        else
          tstr = str_split(cttag,"-")
          yyyymm = yyyymm_time(toint(tstr(0)),toint(tstr(1)),"integer")
          ntim   = dimsizes(yyyymm)
          yyyy   = yyyymm/100
          mm     = yyyymm-yyyy*100
          dd     = mm
          hh     = mm
          mn     = mm
          sc     = mm
          dd     = 1
          hh     = 0                                  ; array syntax
          mn     = 0
          sc     = 0
          units   = "days since 1800-01-01 00:00:00"
          time2   = cd_inv_calendar(yyyy,mm,dd,hh,mn,sc,units, 0)
          time2!0 = "time"
          delete([/tstr,yyyymm,ntim,yyyy,mm,dd,hh,mn,sc,units/])
        end if
        delete(f)
      end if 

      ;;Find the overlap of time slices
      utc_date1 = cd_calendar(time1,-1)
      utc_date2 = cd_calendar(time2,-1)
      indtim    = get1Dindex(utc_date1,utc_date2)
      inddx     = ind(.not.ismissing(indtim))
      utc_date  = utc_date1(indtim(inddx))
      ind1      = get1Dindex(utc_date1,utc_date)
      ind2      = get1Dindex(utc_date2,utc_date)
      yyyyFrac  = yyyymm_to_yyyyfrac(utc_date, 0.0)
     ;print(utc_date1(ind1) +  " " +utc_date2(ind2)+" " +yyyyFrac)
      delete([/utc_date1,utc_date2,indtim,inddx,utc_date/])
      
      do jj = 0, dimsizes(modvars)-1

        mvarnam  = modvars(jj)
        print("working on variable "+ mvarnam)
        var1 = f1->$mvarnam$(ind1,:,:)

        if (compare.eq."Model_vs_OBS") then
          ovarnam  = obsvars(jj)
          var2 = f2->$ovarnam$(ind2,:,:)
        else 
          var2 = f2->$mvarnam$(ind2,:,:)
        end if

        var1!0 = "time"
        var1&time = time1(ind1)
        if (compare.ne."Model_vs_OBS") then
          var2!0 = "time"
          var2&time = time2(ind2)
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

        ;;;check the two comparing files and see if they are in the same grid,
        ddd1                                  = dimsizes(var1)
        ddd2                                  = dimsizes(var2)
        ;;;otherwise, return the error message;;;;
        if ((ddd1(1).ne.ddd2(1)).or.(ddd1(2).ne.ddd2(2)))then
          print("Warning: the two files are not in the same grid, regrid the var1 to var2 grid with bilinear interpolation")
          varx = var1 
          delete(var1)
          var1 = linint2_Wrap (varx&lon,varx&lat,varx, True, var2&lon,var2&lat, 0)
          delete(varx)
        end if
        
      ; ==============================================================
      ; User defined parameters that specify region of globe and
      ; ==============================================================
        x1       = var1(:,{latS:latN},{lonW:lonE})
        y1       = var2(:,{latS:latN},{lonW:lonE})
        delete([/var1,var2/])
      ; ==============================================================
      ; compute climatology and Anomalies
      ; ==============================================================
        xClm1  = clmMonTLL(x1)                      ; (12,lat,lon)
        yClm1  = clmMonTLL(y1)

        xAnom1 = calcMonAnomTLL(x1, xClm1)
        yAnom1 = calcMonAnomTLL(y1, yClm1)
       
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

      ; =================================================================
      ; weight all data 
      ; =================================================================
        xw1    = xAnom1*conform(xAnom1, xclat, 1)
        yw1    = yAnom1*conform(yAnom1, yclat, 1)

        copy_VarMeta(x1, xw1)
        copy_VarMeta(y1, yw1) 

        xw1@long_name = "Wgt: "+x1@long_name
        yw1@long_name = "Wgt: "+y1@long_name

       ; =================================================================
       ; Select different season for the eof
       ; =================================================================
         utc_date1 = cd_calendar(xw1&time,0)
         utc_date2 = cd_calendar(yw1&time,0)
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

           indx1 = ind ((monthx1.eq.3).or.(monthx1.eq.4).or.(monthx1.eq.5))
           indx2 = ind ((monthx2.eq.3).or.(monthx2.eq.4).or.(monthx2.eq.5))

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

         xw    = xw1(indx1,:,:)
         yw    = yw1(indx2,:,:)

         xAnom = xAnom1(indx1,:,:)
         yAnom = yAnom1(indx2,:,:)

         delete([/indx1,indx2/])

       ; =================================================================
       ; Compute EOFs & Standardize time series
       ; =================================================================
         optEOF  = True
         optETS  = False

         eof1    = eofunc_n_Wrap(xw, neof, optEOF, 0)      
         eof2    = eofunc_n_Wrap(yw, neof, optEOF, 0)
    
         do n = 0,neof-1
          pcor = pattern_cor(eof1(n,:,:),eof2(n,:,:),1.0,0)
          if(pcor.lt.0)then
            eof1(n,:,:) = eof1(n,:,:) * -1.0
          end if
         end do 

         eof1_ts = eofunc_ts_n_Wrap (xw, eof1, optETS, 0)
         eof2_ts = eofunc_ts_n_Wrap (yw, eof2, optETS, 0)

         eof1_ts = dim_standardize_n( eof1_ts, 0, 1)      ; normalize
         eof2_ts = dim_standardize_n( eof2_ts, 0, 1)      ; normalize

       ; =================================================================
       ; Regress
       ; =================================================================
         eof1_regres = eof1                               ; create an array w meta data
         eof2_regres = eof2                               ; create an array w meta data
         do ne=0,neof-1
            eof1_regres(ne,:,:) = (/ regCoef_n(eof1_ts(ne,:), xAnom, 0, 0) /)
            eof2_regres(ne,:,:) = (/ regCoef_n(eof2_ts(ne,:), yAnom, 0, 0) /)
         end do

        ;======================================================================
        ;Save the data for the regression analysis
        ;==================================================================
         setfileoption("nc", "Format",  "NetCDF4")
         out_file1  = bakpath +"/"+"ENSO_SST_EOF_PCS_"+tname+"_monthly_mean_at_"+pout(ll)+"_"+seasons(kk)+".nc"
         out_file2  = bakpath +"/"+"ENSO_SST_EOF_PCS_"+cname+"_monthly_mean_at_"+pout(ll)+"_"+seasons(kk)+".nc"

         system("rm " + out_file1)
         system("rm " + out_file2)

         fout1 = addfile(out_file1,"c")
         fout2 = addfile(out_file2,"c")

         timex1 = eof1_ts&time
         timex2 = eof2_ts&time

         timex1!0 = "time"
         timex2!0 = "time"

         timex1&time = timex1
         timex2&time = timex2

         fout1->time         = timex1
         fout2->time         = timex2

         eof1@description    = "EOF pattern"
         eof2@description    = "EOF pattern"

         eof1_ts@description = "EOF PCs (standardized)"
         eof2_ts@description = "EOF PCs (standardized)"

         fout1->eof      = eof1_regres
         fout2->eof      = eof2_regres

         fout1->eof_ts   = eof1_ts
         fout2->eof_ts   = eof2_ts

         delete([/timex1,timex2,fout1,fout2,out_file1,out_file2/])

       ; =================================================================
       ; Extract the YYYYMM from the time coordinate 
       ; associated with eof_ts [same as x&time] 
       ; =================================================================

         utc_date1 = cd_calendar(eof1_ts&time,-1)  
         utc_date2 = cd_calendar(eof2_ts&time,-1)
        
         yyyy1     = yyyymm_to_yyyyfrac(utc_date1, 0.0) ;utc_date1(:,0)
         yyyy2     = yyyymm_to_yyyyfrac(utc_date2, 0.0) ;utc_date2(:,0)

         delete([/utc_date1,utc_date2/])

       do n = 0, neof - 1

         wtype                        = "eps"
        ;wtype@wkWidth                = 2500
        ;wtype@wkHeight               = 2500
         figdir                       = outdir+"/ENSO_EOF_Analysis/"
         fe                           = "ENSO_SST_EOF"+sprinti("%02d",n+1)+"_"+seasons(kk)+"_"+pout(ll) 
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
        mnmxint = nice_mnmxintvl( minlev_eof(jj), maxlev_eof(jj), maxlev, False)
  
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

          rts@gsnYRefLine             = 0.              ; reference line
          rts@gsnYRefLineColor        = "grey25"
          rts@gsnYRefLineDashPattern  = 5
          rts@gsnYRefLineThicknessF   = 0.5

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
         ;rts@trXMinF                      = miny
         ;rts@trXMaxF                      = maxy

         ;create individual plots
         ;---Draw third plot in lower left corner
          rts@gsnLeftString     = "EOF "+(n+1) + " ("+sprintf("%4.1f", eof1@pcvar(n)) +"%)"
          rts@gsnRightString    = "Standardized index" ;sprintf("%4.1f", eof1_regres@pcvar(n)) +"%"
          rts@tiMainString      = "" ;"Case: "+panelstr1

          xyarr1                = runave_Wrap (eof1_ts(n,:),3, 0)
          plot(2) = gsn_csm_xy (wks,yyyy1,xyarr1,rts)
          rts1 = rts
          rts1@gsnXYBarChart       = False
          rts1@gsnLeftString       = ""
          rts1@gsnRightString      = ""
          rts1@gsnCenterString     = ""
          xyarr1                   = wgt_runave_Wrap(eof1_ts(n,:),(/1.,3,5,6,5,3,1/), 0)
          tsmap1(1)                = gsn_csm_xy(wks,yyyy1,xyarr1,rts1) 
          overlay(plot(2),tsmap1(1))
          delete([/xyarr1/])

          ;---Draw fourth plot in upper right corner
          rts@gsnLeftString     = "EOF "+(n+1) + " ("+sprintf("%4.1f", eof2@pcvar(n)) +"%)"
          rts@gsnRightString    = "Standardized index" 
          rts@tiMainString      = "" 
          xyarr2                   = runave_Wrap(eof2_ts(n,:),3, 0)
          plot(3) = gsn_csm_xy (wks,yyyy2,xyarr2,rts)
          rts2 = rts
          rts2@gsnXYBarChart       = False
          rts2@gsnLeftString       = ""
          rts2@gsnRightString      = ""
          rts2@gsnCenterString     = ""
          xyarr2                   = wgt_runave_Wrap(eof2_ts(n,:),(/1.,3,5,6,5,3,1/), 0) 
          tsmap1(2)            = gsn_csm_xy(wks,yyyy2,xyarr2,rts2)
          overlay(plot(3),tsmap1(2))
          delete([/xyarr2/])

       ; panel plot only resources
         
          pres1                          = True                ; mods desired
          pres1@gsnFrame                 = False               ; save panel until both ready
         ;pres1@gsnPanelBottom           = 0.45    ; space for label bar
         ;pres1@gsnPanelTop              = 0.85     ; only panel on lower half of page
         ;pres1@gsnPanelXF               = (/0.07,0.57/)
          gsn_panel(wks,plot(:),(/2,2/),pres1)          ; create first panel
          
          frame(wks)                                   ; draw both on same page

         end do ; end of eof mods 

         delete([/eof1_regres,eof2_regres, yyyy1,yyyy2/])
         delete([/xw,yw,xAnom,yAnom,eof1,eof2,eof1_ts,eof2_ts/])

        end do                                              ; end of looping over seasons

        delete([/xAnom1,yAnom1,xw1,yw1,x1,y1,xclat,yclat/])
        delete([/monthx1,monthx2/])

        end do                                                 ; end of looping over variables

        delete([/f1,time1,time2,ind1,ind2/])
        delete([/f2/])

  end do                                                    ; end of looping over pressure levels


end

