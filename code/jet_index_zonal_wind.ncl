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
  tpath                                      = getenv("TPATH")
  cpath                                      = getenv("CPATH")
  case1name                                  = getenv("TEST_NAME")
  case2name                                  = getenv("CTRL_NAME")
  casedir                                    = getenv("CASEDIR")
  opath                                      = getenv("DIAG_DATA_ROOT")
 
;define regions for jet position analysi
  latS                                         = -70.  ;negative for southern hemisphere
  latN                                         = -20.  ;negative for southern hemisphere

;define maximum and minimum range for plot
  maxlev = 11
  minval = -20
  maxval =  20

;define constants for unit conversion
  pi                                           = 3.14159265
  rearth                                       = 6.37122e6
  grav                                         = 9.80665

;variable name in the climo file
  modvars                                      = (/"U"/)
  obsvars                                      = (/"u"/)
  seasons                                      = (/"ANN","DJF","JJA"/)
  preslev                                      = (/850/)

;read in two files

  do ll = 0,dimsizes(preslev) - 1

        f                                      = systemfunc("ls "+tpath+"/*_monthly_means.nc")
        f1                                     = addfile(f,"r")
        ps1                                    = f1->PS
        ha1                                    = doubletofloat(f1->hyam)
        hb1                                    = doubletofloat(f1->hybm)
        p0                                     = doubletofloat(f1->P0)
        p1                                     = pres_hybrid_ccm(ps1,p0,ha1,hb1)
        p1                                     = p1/100.
        gw1                                    = doubletofloat(f1->gw)
        landmsk                                = f1->LANDFRAC(0,:,:) 
                               
        if(compare.eq."Model_vs_OBS") then
          f                                    = systemfunc("ls "+cpath+"/*_prelev_monthly_analysis_*.nc")
          f2                                   = addfile(f,"r")
          gw2                                  = doubletofloat(f2->gw)
        else
          f                                    = systemfunc("ls "+cpath+"/*_monthly_means.nc")
          f2                                   = addfile(f,"r")
          ps2                                  = f2->PS
          ha2                                  = doubletofloat(f2->hyai)
          hb2                                  = doubletofloat(f2->hybi)
          p2                                   = pres_hybrid_ccm(ps2,p0,ha2,hb2)
          gw2                                  = doubletofloat(f2->gw)
        end if


        do jj = 0, dimsizes(modvars)-1

           mvarnam                             = modvars(jj)
           var1                                = f1->$mvarnam$
           tmp1                                = int2p_n_Wrap(p1,var1,preslev(ll),2,1)
           vp1                                 = tmp1(:,0,:,:)
           delete([/tmp1/])

           if(compare.eq."Model_vs_OBS") then
              ovarnam                          = obsvars(jj)
              var2                             = f2->$ovarnam$
              vp2                              = var2(:,{preslev(ll)},:,:)
              if(ovarnam.eq."z")then
                 vp2                           = vp2/grav ; covert geopoential to geoptential height
              end if
           else
              var2                             = f2->$mvarnam$
              tmp2                             = int2p_n_Wrap(p1,var2,preslev(ll),2,1)
              vp2                              = tmp2(:,0,:,:)
              delete([/tmp2/])
           end if

           if  ( preslev(ll) .gt. 1000. ) then
               vp1(:,0,:,:)                    = (/var1(:,ddd1(1)-1,:,:)/)
               vp2(:,0,:,:)                    = (/var2(:,ddd2(1)-1,:,:)/)
           end if
           delete([/var1,var2/])

           vp1@_FillValue                      = -9999.
           vp2@_FillValue                      = -9999.
           ddd1                                = dimsizes(vp1)
           ddd2                                = dimsizes(vp2)

           ;printVarSummary(vp1)
           ;printVarSummary(vp2)


           ;;check the two comparing files and see if they are in the same grid, otherwise, 
           ;;return the error message;;;;
           if ((ddd1(1).ne.ddd2(1)).or.(ddd1(2).ne.ddd2(2)))then
            print("Error: this scripts requires the two files must in the same grid to run!!!")
            return
           end if

       ; ==============================================================
       ; User defined parameters that specify region of globe
       ; ==============================================================
         x1     = vp1(:,{latS:latN},:)
         y1     = vp2(:,{latS:latN},:)

       ; ==============================================================
       ; compute climatology and Anomalies
       ; ==============================================================
         xClm1  = clmMonTLL(x1)                      ; (12,lat,lon)
         yClm1  = clmMonTLL(y1)

         xAnom1 = calcMonAnomTLL(x1, xClm1)
         yAnom1 = calcMonAnomTLL(y1, yClm1)

         xClm   = dim_avg_n_Wrap(xClm1,0)
         yClm   = dim_avg_n_Wrap(yClm1,0)

         ;printVarSummary(xAnom1)
         ;printMinMax(xAnom1, True)

         ;printVarSummary(xAnom1)
         ;printMinMax(xAnom1, True)

         delete([/x1,y1/])

       ; ========================================================================
       ; The method for calculating the jet indices broadly follows previous 
       ; studies (e.g. Kidston and Gerber 2010; Son et al. 2010; Swart and Fyfe 2012) 
       ; whereby, as described above, the strength and latitude of the westerly jet 
       ; are identified in zonally-averaged lower-tropospheric (or near-surface) 
       ; time-mean westerly wind or surface wind stress. In this script, the specific 
       ; approach used follows that of (Bracegirdle et al. 2018), who calculate 
       ; jet diagnostics from latitudinally-interpolated zonal mean westerly wind 
       ; on the 850 hPa level (U850) between the latitudes of 75°S and 10°S
       ; The main reason for choosing 850 hPa is that it captures the lower-tropospheric 
       ; jet whilst also avoiding uncertainties associated with reanalysis estimates of 
       ; wind in the atmospheric boundary layer (Kent et al. 2012), therefore 
       ; allowing for more direct model-observation comparisons. 
       ; =====================================================================

       ; ====================================================================
       ; First step: regrid the data to 0.1x0.1 within 70S and 20S region
       ;=====================================================================
       weightfile = systemfunc("ls "+opath+"/1deg_to_0.1deg.nc")
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
         vp1x               = ESMF_regrid(vp1,Opt)
         vp2x               = ESMF_regrid(vp2,Opt)

       else
         
         vp1x = ESMF_regrid_with_weights(vp1,weightfile,False)
         vp2x = ESMF_regrid_with_weights(vp2,weightfile,False)

       end if 

       ; ======================================================================
       ; Second step: Calculate the zonal mean zonal wind at 850hPa
       ; between 70S and 20S, and find the lattitude of maximum zonal
       ; mean zonal wind (which is the jet position), and its corresponding
       ; magnitude (which is the jet strength)
       ; ==================================================================
         x1     = dim_avg_n_Wrap(vp1x,2)
         y1     = dim_avg_n_Wrap(vp2x,2)

         x1_ins = dim_max_n_Wrap(x1,1)
         y1_ins = dim_max_n_Wrap(y1,1)

         xmax_ind = dim_maxind(x1(lat|:,time|:), 0)
         ymax_ind = dim_maxind(y1(lat|:,time|:), 0)

         x1_pos   = x1_ins
         y1_pos   = y1_ins

         do ix = 0,dimsizes(x1_pos)-1
          x1_pos(ix) = tofloat(x1&lat(xmax_ind(ix)))
         end do

         do ix = 0,dimsizes(y1_pos)-1
          y1_pos(ix) = tofloat(y1&lat(ymax_ind(ix)))
         end do

        ;======================================================================
        ;Third step: save the data for the regression analysis 
        ;==================================================================
         setfileoption("nc", "Format",  "NetCDF4")
         out_file1  = opath +"/"+"Jet_index_"+case1name+"_monthly_mean_"+mvarnam+"_at_"+toint(preslev(ll))+"hPa.nc"
         out_file2  = opath +"/"+"Jet_index_"+case2name+"_monthly_mean_"+mvarnam+"_at_"+toint(preslev(ll))+"hPa.nc"

         system("rm " + out_file1)
         system("rm " + out_file2)

         fout1 = addfile(out_file1,"c")
         fout2 = addfile(out_file2,"c")

         time1 = x1_ins&time
         time2 = y1_ins&time
         time1!0 = "time"
         time2!0 = "time"
         time1&time = time1
         time2&time = time2

         fout1->time         = time1
         fout2->time         = time2

         x1_ins@description = "jet strength"
         y1_ins@description = "jet strength"
         x1_pos@description = "jet position"
         y1_pos@description = "jet position"

         fout1->jet_ins   = x1_ins
         fout2->jet_ins   = y1_ins
         fout1->jet_pos   = x1_pos
         fout2->jet_pos   = y1_pos

         delete([/time1,time2,fout1,fout2,out_file1,out_file2/])

       ;;;;loop the season and do the plot;;;;
 
       do kk = 0,dimsizes(seasons) - 1

       ; =================================================================
       ; Select different season for the analysis
       ; =================================================================
         utc_date1 = cd_calendar(x1_ins&time,0)
         utc_date2 = cd_calendar(y1_ins&time,0)
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

         x_ins = x1_ins(indx1)
         y_ins = y1_ins(indx2)
         x_pos = x1_pos(indx1)
         y_pos = y1_pos(indx2)
       
         xAnom = xAnom1(indx1,:,:)
         yAnom = yAnom1(indx2,:,:)
         delete([/indx1,indx2,utc_date1,utc_date2,monthx1,monthx2/])

         print(min(x_ins)+ " " +max(x_ins)+" "+ avg(x_ins))
         print(min(y_ins)+ " " +max(y_ins)+" "+ avg(y_ins))
         print(min(x_pos)+ " " +max(x_pos)+" "+ avg(x_pos))
         print(min(y_pos)+ " " +max(y_pos)+" "+ avg(y_pos))

       ; =================================================================
       ; Regress
       ; =================================================================
         jet_ins1        = dim_standardize_n( x_ins, 0, 0)      ; normalize
         jet_ins2        = dim_standardize_n( y_ins, 0, 0)      ; normalize
         jet_ins1_regres = xClm                              ; create an array w meta data
         jet_ins2_regres = yClm                              ; create an array w meta data
         jet_ins1_regres = (/ regCoef_n(jet_ins1, xAnom, 0, 0) /)
         jet_ins2_regres = (/ regCoef_n(jet_ins2, yAnom, 0, 0) /)

         jet_pos1        = dim_standardize_n( x_pos, 0, 0)      ; normalize
         jet_pos2        = dim_standardize_n( y_pos, 0, 0)      ; normalize
         jet_pos1_regres = xClm                             ; create an array w meta data
         jet_pos2_regres = yClm                              ; create an array w meta data
         jet_pos1_regres = (/ regCoef_n(jet_pos1, xAnom, 0, 0) /)
         jet_pos2_regres = (/ regCoef_n(jet_pos2, yAnom, 0, 0) /)

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
         figdir                       = casedir+"/Jet_Index_Analysis/"
         fe                        = "Jet_analysis_monthly_mean_"+modvars(jj)+"_"+seasons(kk)+"_"+preslev(ll) 
         wks                                 = gsn_open_wks(wtype, figdir + fe)

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
         res@lbTitleString            = mvarnam +" ("+xAnom@units+")" ;Geopential height (gpm)";
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
          res@gsnLeftString     = "Zonal wind at 850hPa"
          res@gsnRightString    = "Case: "+case1name
          res@gsnCenterString   = "" 
          res@tiMainString      = " " ;"Case: "+case1name
          plot(0)   = gsn_csm_contour_map_polar(wks,xClm,res)

          ;---Draw second plot in upper right corner
          res@gsnLeftString     = "Zonal wind at 850hPa"
          res@gsnRightString    = "Case: "+case2name
          res@gsnCenterString   = "" ;case2name
          res@tiMainString      = "" ;"Case: "+case2name
          plot(1) = gsn_csm_contour_map_polar(wks,yClm,res)
      
       ;*******************************************
       ; second plot: Jet Strength
       ;*******************************************
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

          rts@trYMinF                      =  5.0
          rts@trYMaxF                      = 20.0
          rts@tiXAxisString                = "Time"          
          rts@tiYAxisString                = "m s~S~-1~N~"

         ;create individual plots
         ;---Draw third plot in lower left corner
          rts@xyLineThicknesses     = 3.0
          rts@xyLineColors          = "Black"
          rts@gsnLeftString         = "Jet strength"
          rts@gsnRightString        = "Case: "+case2name
          rts@gsnYRefLine           = avg(x_pos)   ; reference line
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
          rts@gsnRightString        = "Case: "+case2name
          rts@gsnYRefLine          = avg(y_ins)   ; reference line
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
          rts1 = rts

          rts1@trYMinF                      = -60.0
          rts1@trYMaxF                      = -35.0
          rts1@tiXAxisString                = "Time"
          rts1@tiYAxisString                = "Degree"

          rts1@gsnXYBarChart                = False
          rts1@xyLineThicknesses            = 3.0
          rts1@xyLineColors                 = "Black"

         ;create individual plots
         ;---Draw fifth plot in lower left corner
          rts1@gsnLeftString        = "Jet position"
          rts1@gsnRightString       = "Case: "+case2name
          rts1@gsnYRefLine          = avg(x_pos)   ; reference line
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
          rts1@gsnRightString       = "Case: "+case2name
          rts1@gsnYRefLine          = avg(y_pos)   ; reference line
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
          gsn_panel(wks,plot(2:3),(/1,2/),pres2)       ; create first panel

          pres3                           = True       ; mods desired
          pres3@gsnFrame                  = False      ; save panel until both ready
          pres3@gsnPanelTop               = 0.30       ; draw from center to right edge
          pres3@gsnPanelBottom            = 0.05       ; draw from center to right edge
          gsn_panel(wks,plot(4:5),(/1,2/),pres3)       ; create first panel
       
          frame(wks)                                   ; draw both on same page

          ;if (wtype .eq. "png") then
          ;   tmpa = systemfunc("convert "+fe+".png -trim del.png")
          ;   tmpb = systemfunc("mv del.png "+fe+".png")
          ;end if

          ;delete([/xyarr1,xyarr2,tsmap1,tsmap2/])
          delete([/x_ins,y_ins,x_pos,y_pos,jet_ins1,jet_ins2,jet_pos1,jet_pos2,yyyy1,yyyy2/])
          delete([/jet_ins1_regres,jet_ins2_regres,jet_pos1_regres,jet_pos2_regres/])
          delete([/xAnom,yAnom/])

       end do 

         delete([/xAnom1,yAnom1,xClm1,yClm1,xClm,yClm,x1,y1,x1_ins,y1_ins,x1_pos,y1_pos/])

     end do                                              ; end of looping over variables
     
     delete([/f1,ps1,ha1,hb1,p0,p1,gw1/])
     if(compare.eq."Model_vs_OBS") then
        delete([/f2,gw2/])
     else
        delete([/f2,ps2,ha2,hb2,p2/])
     end if

  end do                                                    ; end of looping over pressure levels


end

