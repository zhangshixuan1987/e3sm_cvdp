  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

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
  wgtfile                                    = getenv("JET_RGDWGT_FILE")

  tpath                                      = getenv("TPATH")
  cpath                                      = getenv("CPATH")

  tcase                                      = getenv("TEST")
  ccase                                      = getenv("CTRL")

  tname                                      = getenv("TNAME")
  cname                                      = getenv("CNAME")

  tttag                                      = getenv("TTTAG")
  cttag                                      = getenv("CTTAG")

;define regions for eof analysis
  latS                                         = -70.  ;negative for southern hemisphere
  latN                                         = -20.  ;negative for southern hemisphere

;define constants for unit conversion
  pi                                           = 3.14159265
  rearth                                       = 6.37122e6
  grav                                         = 9.80665

 print(cname + " " +tname)
;variable name in the climo file
  modvars                                    = (/"TAUX"/)
  facmod                                     = (/-1.0/)
  varunt                                     = (/"m~S~2~N~ s~S~-2~N~"/)
  panelstr1                                  = tname + " ("+tttag+")"
  panelstr2                                  = cname + " ("+cttag+")"

  if(compare.eq."Model_vs_OBS")then

   if (cname.eq."ERA5") then
     obsvars                                 = (/"metss"/)
     facobs                                  = (/1.0/)
   else if (cname.eq."ERA20C") then
     obsvars                                 = (/"iews"/)
     facobs                                  = (/1.0/)
   else if (cname.eq."NOAA20C") then 
     obsvars                                 = (/"metss"/)
     facobs                                  = (/1.0/)
   else
     print("The observational source are not available; only allow ERA5, ERA20C or NOAA20C")
     exit
   end if
   end if
   end if 

  end if 

;declear the season or annual mean data to be used;;;;;
  seasons                                      = (/"ANN","DJF","JJA"/)
  pout                                         = (/"Surface"/)

;read in two files

  do ll = 0,dimsizes(pout) - 1

      f                                       = systemfunc("ls "+tpath+"/"+tcase+"*"+tttag+".nc")
      f1                                      = addfile(f,"r")
      gw1                                     = f1->gw

      f                                       = systemfunc("ls "+cpath+"/"+ccase+"*"+cttag+".nc")
      f2                                      = addfile(f,"r")
      gw2                                     = f2->gw

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
       ; User defined parameters that specify region of globe
       ; ==============================================================
         x1     = var1(:,{latS:latN},:)
         y1     = var2(:,{latS:latN},:)

       ; ==============================================================
       ; compute climatology and Anomalies
       ; ==============================================================
         xClm1  = clmMonTLL(x1)                      ; (12,lat,lon)
         yClm1  = clmMonTLL(y1)

         xAnom1 = calcMonAnomTLL(x1, xClm1)
         yAnom1 = calcMonAnomTLL(y1, yClm1)

         xClm   = dim_avg_n_Wrap(xClm1,0)
         yClm   = dim_avg_n_Wrap(yClm1,0)

         delete([/x1,y1/])

       ; ========================================================================
       ; The method for calculating the jet indices broadly follows previous 
       ; studies (e.g. Kidston and Gerber 2010; Son et al. 2010; Swart and Fyfe 2012) 
       ; whereby, as described above, the strength and latitude of the westerly jet 
       ; are identified in zonally-averaged lower-tropospheric (or near-surface) 
       ; time-mean westerly wind or surface wind stress. In this script, we mainly  
       ; follow the method used by  Swart and Fyfe (2012) and  Lee et al. (2019),
       ; and strength of the jet stream is represented by the latitudinal 
       ; position and magnitude of the zonal wind-stress maximum. The method 
       ; to derive the position and strength of the jet stream takes three steps 
       ; 1. climate ate model and reanalysis wind-stress data was first interpolated 
       ;    onto a common 0.5- by-0.5 degree horizontal grid and and to a common 
       ;    monthly no-leap-year calendar in time
       ; 2. calculate the the zonal-mean zonal surface wind-stress between 70S and 20S.
       ; 3. search for the latitude of the maximum in the zonal-mean zonal surface 
       ;    wind-stress, which is the jet position. The strength of the jet was 
       ;    defined as the stress at this position
       ;=====================================================================

       ;====================================================================
       ; First step: regrid the data within 70S to 20S to 0.5x0.5
       ;=====================================================================
        weightfile = systemfunc("ls "+wgtfile)
       ;print(weightfile)
        exists = isfilepresent(weightfile)

        if(.not.exists) then

         print("OPeNDAP test unsuccessful.")
         print("Either the file doesn't exist, or NCL does")
         print("not have OPeNDAP cabilities on this system.")
         print("Generate weighting files on the fly")
         Opt                = True
         Opt@SrcFileName    = "src_SCRIP.nc"
         Opt@DstFileName    = "dst_SCRIP.nc"
         Opt@WgtFileName    = "1deg_to_0.1deg.nc"
         Opt@ForceOverwrite = True
         Opt@DstGridType    = "0.1x0.1"
         Opt@DstLLCorner    = (/ latS,   0.25d/)
         Opt@DstURCorner    = (/ latN, 359.75d/)
         var1x               = ESMF_regrid(var1,Opt)
         var2x               = ESMF_regrid(var2,Opt)

        else

         var1x = ESMF_regrid_with_weights(var1,weightfile,False)
         var2x = ESMF_regrid_with_weights(var2,weightfile,False)

        end if

        ;printVarSummary(var1x)
        ;printVarSummary(var2x)
        ;delete([/var1,var2/])       

       ; ==============================================================
       ; Second step: calculate the zonal mean zonal surface wind-stress 
       ; between 70S and 20S. 
       ; ==============================================================
         x1     = dim_avg_n_Wrap(var1x,2)
         y1     = dim_avg_n_Wrap(var2x,2)

         x1_ins = dim_max_n_Wrap(x1,1)
         y1_ins = dim_max_n_Wrap(y1,1)

         xmax_ind = dim_maxind(x1(lat|:,time|:), 0)
         ymax_ind = dim_maxind(y1(lat|:,time|:), 0)

         x1_pos   = x1_ins
         y1_pos   = y1_ins
        
         if(.not.all(ismissing(xmax_ind)))then
           do ix = 0,dimsizes(x1_pos)-1
            x1_pos(ix) = tofloat(x1&lat(xmax_ind(ix)))
           end do
         else
           x1_pos = -9999.
           x1_pos@_FillValue = -9999.
         end if
 
         if(.not.all(ismissing(ymax_ind)))then
           do ix = 0,dimsizes(y1_pos)-1
            y1_pos(ix) = tofloat(y1&lat(ymax_ind(ix)))
           end do
         else
           y1_pos = -9999.
           y1_pos@_FillValue = -9999.
         end if 

       ;;;;calculate the anomalies;;;;
         xa1_ins = x1_ins
         ya1_ins = y1_ins
         xa1_pos = x1_pos
         ya1_pos = y1_pos
     
         do i = 0,11

           xsub = x1_ins(i::12)
           xa1_ins(i::12) = x1_ins(i::12) - avg(xsub)
           delete([/xsub/])

           xsub = y1_ins(i::12)
           ya1_ins(i::12) = y1_ins(i::12) - avg(xsub)
           delete([/xsub/])

           xsub = x1_pos(i::12)
           xa1_pos(i::12) = x1_pos(i::12) - avg(xsub)
           delete([/xsub/])

           xsub = y1_pos(i::12)
           ya1_pos(i::12) = y1_pos(i::12) - avg(xsub)
           delete([/xsub/])

         end do

       ; =================================================================
       ; Select different season for the eof
       ; =================================================================
        ;shift the model time to be consistent with the observations;;;
         x1_ins&time = x1_ins&time - 1.0
         if(compare.ne."Model_vs_OBS")then
           y1_ins&time = y1_ins&time - 1.0
         end if
         utc_date1 = cd_calendar(x1_ins&time(:),0)
         utc_date2 = cd_calendar(y1_ins&time,0)
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

         x_ins = x1_ins(indx1)
         y_ins = y1_ins(indx2)
         x_pos = x1_pos(indx1)
         y_pos = y1_pos(indx2)

         xa_ins = xa1_ins(indx1)
         ya_ins = ya1_ins(indx2)
         xa_pos = xa1_pos(indx1)
         ya_pos = ya1_pos(indx2)

         xAnom = xAnom1(indx1,:,:)
         yAnom = yAnom1(indx2,:,:)

         delete([/indx1,indx2/])

        ;======================================================================
        ;Save the data for the regression analysis
        ;==================================================================
         setfileoption("nc", "Format",  "NetCDF4")
         out_file1  = opath +"/"+"Jet_index_"+cname+"_monthly_mean_"+mvarnam+"_at_"+pout(ll)+"_"+seasons(kk)+".nc"
         out_file2  = opath +"/"+"Jet_index_"+tname+"_monthly_mean_"+mvarnam+"_at_"+pout(ll)+"_"+seasons(kk)+".nc"

         system("rm " + out_file1)
         system("rm " + out_file2)

         fout1 = addfile(out_file1,"c")
         fout2 = addfile(out_file2,"c")

         time1 = x_ins&time
         time2 = y_ins&time
         time1!0 = "time"
         time2!0 = "time"
         time1&time = time1
         time2&time = time2

         fout1->time         = time1
         fout2->time         = time2

         x_ins@description = "jet strength (original value)"
         y_ins@description = "jet strength (original value)"
         x_pos@description = "jet position (original value)"
         y_pos@description = "jet position (original value)"
         xa_ins@description = "jet strength (anomaly value)"
         ya_ins@description = "jet strength (anomaly value)"
         xa_pos@description = "jet position (anomaly value)"
         ya_pos@description = "jet position (anomaly value)"

         fout1->jeto_ins   = x_ins
         fout2->jeto_ins   = y_ins
         fout1->jeto_pos   = x_pos
         fout2->jeto_pos   = y_pos
         fout1->jetd_ins   = xa_ins
         fout2->jetd_ins   = ya_ins
         fout1->jetd_pos   = xa_pos
         fout2->jetd_pos   = ya_pos
         fout1->$mvarnam$  = xClm
         fout2->$mvarnam$  = yClm

         delete([/time1,time2,fout1,fout2,out_file1,out_file2/])

       ; =================================================================
       ; Extract the YYYYMM from the time coordinate
       ; =================================================================

         utc_date1 = cd_calendar(x_ins&time,-1)
         utc_date2 = cd_calendar(y_ins&time,-1)

         yyyy1     = yyyymm_to_yyyyfrac(utc_date1, 0.0) ;utc_date1(:,0)
         yyyy2     = yyyymm_to_yyyyfrac(utc_date2, 0.0) ;utc_date2(:,0)

         delete([/utc_date1,utc_date2/])

         wtype                        = "eps"
        ;wtype@wkWidth                = 2500
        ;wtype@wkHeight               = 2500
         figdir                       = outdir+"/Jet_Index_Analysis/"
         fe                           = "Jet_index_with_monthly_mean_"+modvars(jj)+"_"+seasons(kk)+"_"+pout(ll)
         wks                          = gsn_open_wks(wtype, figdir + fe)

         plot      = new((/6/),graphic)
         tsmapx    = new((/6/),graphic)
         tsmap1    = new((/6/),graphic)
         tsmap2    = new((/6/),graphic)


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

        ;define maximum and minimum range for plot
         maxlev = 11
         minval = -0.2
         maxval =  0.2
         res@cnLevelSelectionMode = "ManualLevels"
        ; manually set the contour levels with the following 3 resources
         mnmxint = nice_mnmxintvl( minval, maxval, maxlev, False)
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
          res@gsnLeftString     = modvars(jj)
          res@gsnRightString    = varunt(jj) ;"Case: "+panelstr1
          res@gsnCenterString   = ""
          res@tiMainString      = "Case: "+panelstr1
          plot(0)   = gsn_csm_contour_map_polar(wks,xClm,res)

          ;---Draw second plot in upper right corner
          res@gsnLeftString     = modvars(jj)
          res@gsnRightString    = varunt(jj) ;"Case: "+panelstr2
          res@gsnCenterString   = "" ;panelstr2
          res@tiMainString      = "Case: "+panelstr2
          plot(1) = gsn_csm_contour_map_polar(wks,yClm,res)

       ;*******************************************
       ; second plot: Jet Strength
       ;*******************************************
          xstring  = "Time (year)"
          ystring  = varunt(jj)

          rts           = True
          rts@gsnDraw   = False       ; don't draw yet
          rts@gsnFrame  = False       ; don't advance frame yet
          rts@gsnScale  = True        ; force text scaling

          rts@vpHeightF = 0.40        ; Changes the aspect ratio
          rts@vpWidthF  = 0.85
          rts@vpXF      = 0.10        ; change start locations
          rts@vpYF      = 0.75        ; the plot

          rts@gsnXYBarChart         = False            ; create bar chart
         ;rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
         ;rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue
          rts@xyLineThicknesses            = 3.0
          rts@xyLineColors                 = "Black"
          rts@gsnYRefLineThicknesses       = 3.0
          rts@gsnYRefLineColors            = "Red"
          rts@gsnXRefLineDashPatterns      = 5.0

          rts@tmXTOn                       = False
          rts@tmYLLabelFontHeightF         = 0.025
          rts@tmBorderThicknessF           = 1.0
          rts@tmXBMajorThicknessF          = 1.0
          rts@tmXBMinorThicknessF          = 1.0
          rts@tmYLMajorThicknessF          = 1.0
          rts@tmYLMinorThicknessF          = 1.0
          rts@tmYRMajorThicknessF          = 1.0
          rts@tmYRMinorThicknessF          = 1.0


          rts@trYMinF                      =  0.0
          rts@trYMaxF                      =  0.4
          rts@tiXAxisString                = xstring 
          rts@tiYAxisString                = ystring 

         ;create individual plots
         ;---Draw third plot in lower left corner
          rts@xyLineThicknesses     = 3.0
          rts@xyLineColors          = "Black"
          rts@gsnLeftString         = "Jet strength"
          rts@gsnRightString        = panelstr1
          if(.not.all(ismissing(x_ins)))then
            rts@gsnYRefLine         = avg(x_ins)   ; reference line
          else
            rts@gsnYRefLine         = 9999   ; reference line
          end if
          plot(2) = gsn_csm_xy (wks,yyyy1,x_ins,rts)

          rtsx1 = rts
          rtsx1@gsnXYBarChart       = False
          rtsx1@gsnLeftString       = ""
          rtsx1@gsnRightString      = ""
          rtsx1@gsnCenterString     = ""
          rtsx1@xyLineThicknesses   = 3
          rtsx1@xyLineColors       := "red"
          xyarrx1                   = wgt_runave_Wrap(x_ins,(/1.,3,5,6,5,3,1/), 0)
          tsmapx(2)                 = gsn_csm_xy(wks,yyyy1,xyarrx1,rtsx1)
         ;overlay(plot(2),tsmapx(2))
          delete([/xyarrx1,rtsx1/])

          ;---Draw fourth plot in lower right corner
          rts@gsnLeftString         = "Jet strength"
          rts@gsnRightString        = panelstr2
          if(.not.all(ismissing(y_ins)))then
            rts@gsnYRefLine         = avg(y_ins)   ; reference line
          else
            rts@gsnYRefLine         = 9999   ; reference line
          end if 
          plot(3) = gsn_csm_xy (wks,yyyy2,y_ins,rts)

          rtsx1 = rts
          rtsx1@gsnXYBarChart       = False
          rtsx1@gsnLeftString       = ""
          rtsx1@gsnRightString      = ""
          rtsx1@gsnCenterString     = ""
          rtsx1@xyLineThicknesses   = 3
          rtsx1@xyLineColors       := "red"
          xyarrx1                   = wgt_runave_Wrap(y_ins,(/1.,3,5,6,5,3,1/), 0)
          tsmapx(3)                 = gsn_csm_xy(wks,yyyy2,xyarrx1,rtsx1)
         ;overlay(plot(3),tsmapx(3))
          delete([/xyarrx1,rtsx1/])

       ;*******************************************
       ; second plot: Jet Position
       ;*******************************************
          xstring  = "Time (year)"
          ystring  = "Degree"

          rts1 = rts
          rts1@trYMinF              = -60.0
          rts1@trYMaxF              = -35.0
          rts1@tiXAxisString        = xstring 
          rts1@tiYAxisString        = ystring 
          rts1@gsnXYBarChart        = False
          rts1@xyLineThicknesses    = 3.0
          rts1@xyLineColors         = "Black"

         ;create individual plots
         ;---Draw fifth plot in lower left corner
          rts1@gsnLeftString        = "Jet position"
          rts1@gsnRightString       = panelstr1
          if(.not.all(ismissing(x_pos)))then
            rts1@gsnYRefLine        = avg(x_pos)   ; reference line
          else
            rts1@gsnYRefLine        = 9999   ; reference line
          end if
          plot(4) = gsn_csm_xy (wks,yyyy1,x_pos,rts1)

          rtsx1 = rts
          rtsx1@gsnXYBarChart       = False
          rtsx1@gsnLeftString       = ""
          rtsx1@gsnRightString      = ""
          rtsx1@gsnCenterString     = ""
          rtsx1@xyLineThicknesses   = 3
          rtsx1@xyLineColors       := "red"
          xyarrx1                   = wgt_runave_Wrap(x_pos,(/1.,3,5,6,5,3,1/), 0)
          tsmapx(4)                 = gsn_csm_xy(wks,yyyy1,xyarrx1,rtsx1)
         ;overlay(plot(4),tsmapx(4))
          delete([/xyarrx1,rtsx1/])


         ;---Draw sixth plot in lower right corner
          rts1@gsnLeftString        = "Jet position"
          rts1@gsnRightString       = panelstr2
          if(.not.all(ismissing(y_ins)))then
            rts1@gsnYRefLine        = avg(y_pos)   ; reference line
          else
            rts1@gsnYRefLine        = 9999   ; reference line
          end if
          plot(5) = gsn_csm_xy (wks,yyyy2,y_pos,rts1)
          rtsx1 = rts
          rtsx1@gsnXYBarChart       = False
          rtsx1@gsnLeftString       = ""
          rtsx1@gsnRightString      = ""
          rtsx1@gsnCenterString     = ""
          rtsx1@xyLineThicknesses   = 3
          rtsx1@xyLineColors       := "red"
          xyarrx1                   = wgt_runave_Wrap(y_pos,(/1.,3,5,6,5,3,1/), 0)
          tsmapx(5)                 = gsn_csm_xy(wks,yyyy2,xyarrx1,rtsx1)
         ;overlay(plot(5),tsmapx(5))
          delete([/xyarrx1,rtsx1/])

       ; panel plot only resources
          pres1                          = True                ; mods desired
          pres1@gsnFrame                 = False               ; save panel until both ready
          pres1@gsnPanelTop              = 0.95     ; only panel on lower half of page
          pres1@gsnPanelBottom           = 0.60     ; space for label bar
          pres1@gsnPanelXF               = (/0.07,0.57/)
          gsn_panel(wks,plot(0:1),(/1,2/),pres1)          ; create first panel

          pres2                           = True                ; mods desired
          pres2@gsnFrame                  = False               ; save panel until both ready
          pres2@gsnPanelTop               = 0.58                 ; draw from center to right edge
          pres2@gsnPanelBottom            = 0.33                ; draw from center to right edge
          pres2@gsnPanelXF               = (/0.08,0.57/)
          gsn_panel(wks,plot(2:3),(/1,2/),pres2)       ; create first panel

          pres3                           = True       ; mods desired
          pres3@gsnFrame                  = False      ; save panel until both ready
          pres3@gsnPanelTop               = 0.30       ; draw from center to right edge
          pres3@gsnPanelBottom            = 0.05       ; draw from center to right edge
          pres3@gsnPanelXF               = (/0.08,0.57/)
          gsn_panel(wks,plot(4:5),(/1,2/),pres3)       ; create first panel

          frame(wks)                                   ; draw both on same page

          delete([/xa_ins,ya_ins,xa_pos,ya_pos/])
          delete([/x_ins,y_ins,x_pos,y_pos,yyyy1,yyyy2/])
          delete([/xAnom,yAnom/])

       end do

         delete([/xAnom1,yAnom1,xClm1,yClm1,xClm,yClm,x1,y1,x1_ins,y1_ins,x1_pos,y1_pos/])
         delete([/monthx1,monthx2/])

     end do                                              ; end of looping over variables

     delete([/f1,f2/])

  end do                                                    ; end of looping over pressure levels

end

