  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a sam plot for AAO patterns 
;          Data is vertically interpolated to pressure levels
;          1st panel: EOFs for the first three modes
;          2nd panel: time series plot
; Author : Shixuan Zhang
; Date   : Dec 06, 2020

begin

  compare                                    = getenv("COMPARE")
  outdir                                     = getenv("CASEDIR")
  opath                                      = getenv("DIAG_DATA_ROOT")
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
  l_mashall_sam_ind                          = True 

;define regions for plot
  latS                                       = -90.  ;negative for southern hemisphere
  latN                                       = -20.  ;negative for southern hemisphere

;latitude for sam index 
  latS0                                      = -65.  ;negative for southern hemisphere
  latN0                                      = -40.  ;negative for southern hemisphere

;define constants for unit conversion
  pi                                         = 3.14159265
  rearth                                     = 6.37122e6
  grav                                       = 9.80665

;variable name in the climo file
  modvars                                    = (/"PSL"/)
  facmod                                     = (/1.0/100.0/)
  varunt                                     = (/"hPa"/)
  panelstr1                                  = tname + " ("+tttag+")"
  panelstr2                                  = cname + " ("+cttag+")"

  if(compare.eq."Model_vs_OBS") then

    if((cname.eq."ERA5").or.(cname.eq."ERA20C").or.(cname.eq."ERA_20C"))
       obsvars                                 = (/"msl"/)
       facobs                                  = (/1.0/100.0/)
    else if ((cname.eq."NOAA20C").or.(cname.eq."NOAA_20C")) then
       obsvars                                 = (/"prmsl"/)
       facobs                                  = (/1.0/100.0/)
    else
      print("The observational source are not available; only allow ERA5, ERA20C or NOAA20C")
      exit
    end if
    end if

  end if 

;declear the season or annual mean data to be used;;;;;
  seasons                                    = (/"monthly"/)
  pout                                       = (/"Surface"/)

  if (l_mashall_sam_ind) then

    fx1    = obspath+"/pobs/Marshall_mslp_monthly_"+toint(abs(latS0))+"S.txt"
    fx2    = obspath+"/pobs/Marshall_mslp_monthly_"+toint(abs(latN0))+"S.txt"
    ncol   = 13
    marshall_slp65 = readAsciiTable(fx1, ncol, "float", (/1/))
    marshall_slp40 = readAsciiTable(fx2, ncol, "float", (/1/))

   ; ==============================================================
   ; Zonal mean SLP at 40S and 65S
   ; ==============================================================
    obs_year   = toint(marshall_slp65(:,0))
    obs_time   = yyyymm_time(min(obs_year), max(obs_year), "integer")
    vp3_slp65  = ndtooned(marshall_slp65(:,1:))
    vp3_slp40  = ndtooned(marshall_slp40(:,1:))
    yyyy3      = yyyymm_to_yyyyfrac(obs_time, 0.0)

    vp3_slp65@_FillValue = -9999.0
    vp3_slp40@_FillValue = -9999.0
    
    ; ================================================================================================
    ; compute sam indices (Antarctic Oscillation index)
    ; Based on the numerical definition of the SAM by Gong and Wang (1999), which is:
    ; SAM = P*40?S -  P*65°S
    ; where P*40°S and P*65°S are the normalized monthly zonal sea level pressur(SLP) at 40°S and 65?
    ; ================================================================================================

    nyear     = dimsizes(yyyy3)/12
    a1        = reshape(vp3_slp40,(/nyear,12/))
    b1        = reshape(vp3_slp65,(/nyear,12/))
    vp3_samid = ndtooned(dim_standardize_n_Wrap(a1, 0, 0) - dim_standardize_n_Wrap(b1, 0, 0))
    copy_VarCoords (vp3_slp65,vp3_samid)
    delete([/a1,b1,nyear/])

    ;=============================================================================
    ;Save the data for the regression analysis
    ;=============================================================================
    setfileoption("nc", "Format",  "NetCDF4")
    out_file3  = opath +"/"+"SAM_AOI_index_Marshall_monthly_mean_monthly.nc"
    system("rm " + out_file3)

    fout3         = addfile(out_file3,"c")
    fout3->slp65  = vp3_slp40
    fout3->slp40  = vp3_slp65
    fout3->AOI    = vp3_samid
    delete([/fout3,out_file3/])
    delete([/obs_time,obs_year/])

  end if 

;read in two files

  do ll = 0,dimsizes(pout) - 1
 
     f                                       = systemfunc("ls "+tpath+"/"+tcase+"_*_"+tttag+".nc")
     f1                                      = addfile(f,"r")
     gw1                                     = f1->gw

     f                                       = systemfunc("ls "+cpath+"/"+ccase+"_*_"+cttag+".nc")
     f2                                      = addfile(f,"r")
     gw2                                     = f2->gw

     do kk = 0, dimsizes(seasons)-1

       do jj = 0, dimsizes(modvars)-1

       mvarnam                             = modvars(jj)
       vp1                                 = f1->$mvarnam$
       vp1                                 = vp1*facmod(jj)

       if(compare.eq."Model_vs_OBS") then
         ovarnam                           = obsvars(jj)
         vp2                               = f2->$ovarnam$
         vp2                               = vp2*facobs(jj)
       else
         vp2                               = f2->$mvarnam$
         vp2                               = vp2*facmod(jj)
       end if

       vp1@_FillValue                      = -9999.
       vp2@_FillValue                      = -9999.
       vp1@units                           = varunt(jj)
       vp2@units                           = varunt(jj)

       ;;check the two comparing files and see if they are in the same grid, 
       ;;otherwise, return the error message;;;;
       ddd1                                = dimsizes(vp1)
       ddd2                                = dimsizes(vp2)
       if ((ddd1(1).ne.ddd2(1)).or.(ddd1(2).ne.ddd2(2)))then
        print("Error: this scripts requires the two files must in the same grid to run!!!")
        return
       end if

       ;;;find the overlap of model and obs ;;;
       ;shift the model time to be consistent with the observations;;;
       vp1&time = vp1&time - 1.0
       if(compare.ne."Model_vs_OBS")then
         vp2&time = vp2&time - 1.0
       end if
       utc_date1  = cd_calendar(vp1&time,-1)
       utc_date2  = cd_calendar(vp2&time,-1)
      ;indx1      = get1Dindex(utc_date2,utc_date1)
       yyyy1      = yyyymm_to_yyyyfrac(utc_date1, 0.0)
       yyyy2      = yyyymm_to_yyyyfrac(utc_date2, 0.0)

       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;select the data to consturct the sam index
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       vp1_slp65 = dim_avg_n_Wrap(vp1(:,{latS0},:),1)
       vp1_slp40 = dim_avg_n_Wrap(vp1(:,{latN0},:),1)
       vp2_slp65 = dim_avg_n_Wrap(vp2(:,{latS0},:),1)
       vp2_slp40 = dim_avg_n_Wrap(vp2(:,{latN0},:),1)

       vp1_slp65@_FillValue = -9999.0
       vp1_slp40@_FillValue = -9999.0
       vp2_slp65@_FillValue = -9999.0
       vp2_slp40@_FillValue = -9999.0

       nyear     = dimsizes(yyyy1)/12
       a1        = reshape(vp1_slp40,(/nyear,12/))
       b1        = reshape(vp1_slp65,(/nyear,12/))
       vp1_samid = ndtooned(dim_standardize_n_Wrap(a1, 0, 0) - dim_standardize_n_Wrap(b1, 0, 0))

       nyear     = dimsizes(yyyy2)/12
       a1        = reshape(vp2_slp40,(/nyear,12/))
       b1        = reshape(vp2_slp65,(/nyear,12/))
       vp2_samid = ndtooned(dim_standardize_n_Wrap(a1, 0, 0) - dim_standardize_n_Wrap(b1, 0, 0))

       copy_VarCoords (vp1_slp65,vp1_samid)
       copy_VarCoords (vp2_slp65,vp2_samid)
    
      ;=============================================================================
      ;Save the data for the regression analysis
      ;=============================================================================
       setfileoption("nc", "Format",  "NetCDF4")
       out_file1  = opath +"/"+"SAM_AOI_index_"+tname+"_monthly_mean_"+seasons(kk)+".nc"
       out_file2  = opath +"/"+"SAM_AOI_index_"+cname+"_monthly_mean_"+seasons(kk)+".nc"
       out_file3  = opath +"/"+"SAM_AOI_index_Marshall_monthly_mean_"+seasons(kk)+".nc"

       system("rm " + out_file1)
       system("rm " + out_file2)

       fout1      = addfile(out_file1,"c")
       fout2      = addfile(out_file2,"c")

       fout1->slp65  = vp1_slp40
       fout1->slp40  = vp1_slp65
       fout1->AOI    = vp1_samid
 
       fout2->slp65  = vp2_slp40
       fout2->slp40  = vp2_slp65
       fout2->AOI    = vp2_samid

       delete([/fout1,fout2,out_file1,out_file2/])

       ;;;;;;start to process the regression variable ;;;;
       regx  = vp1(:,{latS:latN},:)
       regy  = vp2(:,{latS:latN},:)

      ;==============================================================
      ;compute climatology and Anomalies
      ;==============================================================
       regxClm  = clmMonTLL(regx)
       regyClm  = clmMonTLL(regy)
       regxAnom = calcMonAnomTLL (regx, regxClm )
       regyAnom = calcMonAnomTLL (regy, regyClm )
 
      ;=================================================================
      ; Regress
      ;=================================================================
       ddsam = dimsizes(regxAnom)
       sam1_regres = new((/ddsam(1),ddsam(2)/),typeof(regxAnom))     ; create an array w meta data
       sam1_regres!0 = "lat"
       sam1_regres!1 = "lon"
       sam1_regres&lat = regxAnom&lat
       sam1_regres&lon = regxAnom&lon
       sam1_regres@_FillValue = -9999.

       sam2_regres = sam1_regres
       sam1_rgprob = sam1_regres
       sam2_rgprob = sam1_regres

       rc1         = regCoef_n(vp1_samid, regxAnom, 0, 0)
       rc2         = regCoef_n(vp2_samid, regyAnom, 0, 0)

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
          sam1_rgprob = where(prob1.le.statistical_siglev,rc1,rc1@_FillValue)
          delete([/drc1,df1,tval1,xb1,pb1,prob1/])

          drc2  = dimsizes(rc2)
          df2   = rc2@nptxy-2   ; degrees of freedom
          tval2 = rc2@tval      ; t-statistic
          xb2   = tval2
          xb2   = 0.50
          pb2   = betainc(df2/(df2+tval2^2),df2/2.0,xb2)
          prob2 = reshape(pb2,(/drc2(0),drc2(1)/))
          sam2_rgprob = where(prob2.le.statistical_siglev,rc2,rc2@_FillValue)
          delete([/drc2,df2,tval2,xb2,pb2,prob2/])

        end if

        sam1_regres = (/ rc1 /) / facmod
        sam2_regres = (/ rc2 /) / facmod
        sam1_rgprob = (1.0 - sam1_rgprob)*100.0
        sam2_rgprob = (1.0 - sam2_rgprob)*100.0

        delete([/rc1,rc2/])
        delete([/regxAnom,regyAnom/])
        delete([/regxClm,regyClm, regx, regy/])
        delete([/utc_date1,utc_date2/])
        delete([/a1,b1,nyear/])

        ;;;calculate the rmsd and correlation;;
        rad    = 4.0*atan(1.0)/180.0
        wgty   = cos(sam1_regres&lat*rad)
        glCor1 = pattern_cor(sam1_regres,sam2_regres,1.0,0)
        glAve1 = wgt_arearmse(sam1_regres,sam2_regres, wgty, 1.0,0)
        delete([/rad,wgty/])

        mstr1  = "corr. w/r " + sprintf("%.2f", glCor1)
        mstr2  = "RMSD  w/r " + sprintf("%.2f", glAve1)
        mstrx  = mstr1 + "~C~" + mstr2

       ; =================================================================
       ; Extract the data for plot 
       ; ================================================================
        legends      = "  "+(/tname,cname,"Obs. (Marshall)"/)
        pltdat1      = new((/3,dimsizes(vp1_samid)/),typeof(vp1_samid))
        pltdat2      = new((/3,dimsizes(vp2_samid)/),typeof(vp2_samid))

        pltdat1(0,:) = (/vp1_slp40/)
        pltdat1(1,:) = (/vp1_slp65/)
        pltdat1(2,:) = (/vp1_samid/)

        pltdat2(0,:) = (/vp2_slp40/)
        pltdat2(1,:) = (/vp2_slp65/)
        pltdat2(2,:) = (/vp2_samid/)

        minbin = min((/min(vp1_samid),min(vp2_samid)/))
        maxbin = max((/max(vp1_samid),max(vp2_samid)/))

        if (l_mashall_sam_ind) then
          pltdat3      = new((/3,dimsizes(vp3_samid)/),typeof(vp3_samid))
          pltdat3(0,:) = (/vp3_slp40/)
          pltdat3(1,:) = (/vp3_slp65/)
          pltdat3(2,:) = (/vp3_samid/)
          minbin = min((/min(vp1_samid),min(vp2_samid),min(vp3_samid)/))
          maxbin = max((/max(vp1_samid),max(vp2_samid),max(vp3_samid)/))
          delete([/vp3_slp65,vp3_slp40,vp3_samid/])
        end if 
        delete([/vp1_slp65,vp1_slp40,vp1_samid,vp2_slp65,vp2_slp40,vp2_samid/])

       ; =================================================================
       ; Start to do plot
       ; =================================================================
         wtype                        = "eps"
         figdir                       = outdir+"/Polar_SAM_Index/"
         fe1                          = "SAM_AOI_"+seasons(kk)+"_sam_index_40S_65S_slp_pattern_"+pout(ll) 
         fe2                          = "SAM_AOI_"+seasons(kk)+"_sam_index_40S_65S_time_series_"+pout(ll)
         wks1                         = gsn_open_wks(wtype, figdir + fe1)
         wks2                         = gsn_open_wks(wtype, figdir + fe2)

         plot1     = new((/2/),graphic)
         plot2     = new((/3/),graphic)
         tsmap1    = new((/3/),graphic)
         tsmap2    = new((/3/),graphic)
      
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

         res@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following 3 resources
         maxlev        = 11
         minlev_sam    = -200.
         maxlev_sam    =  200.
         mnmxint = nice_mnmxintvl( minlev_sam, maxlev_sam, maxlev, False)
         res@cnMinLevelValF           = mnmxint(0) ; set the minimum contour level
         res@cnMaxLevelValF           = mnmxint(1) ; set the maximum contour level
         res@cnLevelSpacingF          = mnmxint(2) ; *special* match CPC

       ;*******************************************
       ; first plot
       ;*******************************************
         res@mpLabelFontHeightF           = FontHeightF*2.0
         res@gsnPolarLabelFontHeightF     = FontHeightF

         ;---Draw first plot in upper left corner
         res@gsnLeftString     = "AOI (" +mvarnam+")"
         res@gsnRightString    = mstrx
         res@gsnCenterString   = "" 
         res@tiMainString      = panelstr1
         res@tiMainOffsetYF    = 0.00
         plot1(0)   = gsn_csm_contour_map_polar(wks1,sam1_regres,res)

         ;---Draw second plot in upper right corner
         res@gsnLeftString     = "AOI (" +mvarnam+")" 
         res@gsnRightString    = " "
         res@gsnCenterString   = "" 
         res@tiMainString      = panelstr2
         res@tiMainOffsetYF    = 0.02
         plot1(1) = gsn_csm_contour_map_polar(wks1,sam2_regres,res)

       ; panel plot only resources
         pres1                          = True                ; mods desired
         pres1@gsnFrame                 = True               ; save panel until both ready
         pres1@gsnPanelYWhiteSpacePercent = 8
        ;pres1@gsnPanelBottom           = 0.45    ; space for label bar
        ;pres1@gsnPanelTop              = 0.85     ; only panel on lower half of page
        ;pres1@gsnPanelXF               = (/0.07,0.57/)
         gsn_panel(wks1,plot1,(/1,2/),pres1)          ; create first panel
         delete([/mnmxint/])

       ;*******************************************
       ; second plot
       ;*******************************************
         rts           = True
         rts@gsnDraw   = False       ; don't draw yet
         rts@gsnFrame  = False       ; don't advance frame yet
         rts@gsnScale  = True        ; force text scaling

         rts@vpHeightF = 0.40        ; Changes the aspect ratio
         rts@vpWidthF  = 0.90
         rts@vpXF      = 0.10        ; change start locations
         rts@vpYF      = 0.75        ; the plot

         rts@tiYAxisString         = " "          ; y-axis label
         rts@gsnXYBarChart         = False ;True           ; create bar chart

         rts@tmXTOn                = False
         rts@tmYLLabelFontHeightF  = 0.025
         rts@tmBorderThicknessF    = 1.0
         rts@tmXBMajorThicknessF   = 1.0
         rts@tmXBMinorThicknessF   = 1.0
         rts@tmXTMajorThicknessF   = 1.0
         rts@tmXTMinorThicknessF   = 1.0
         rts@tmYLMajorThicknessF   = 1.0
         rts@tmYLMinorThicknessF   = 1.0
         rts@tmYRMajorThicknessF   = 1.0
         rts@tmYRMinorThicknessF   = 1.0

         rts@pmLegendDisplayMode    = "Never"            ; turn on legend
         rts@pmLegendSide           = "Top"               ; Change location of 
         rts@pmLegendParallelPosF   = 0.25               ; move units right
         rts@pmLegendOrthogonalPosF = -0.3                ; move units down
         rts@pmLegendWidthF         = 0.15                ; Change width and
         rts@pmLegendHeightF        = 0.18                ; height of legend.
         rts@lgPerimOn              = False               ; turn off box around
         rts@lgLabelFontHeightF     = .03                 ; label font height

         rts@gsnYRefLine             = 0.              ; reference line
         rts@gsnYRefLineColor        = "black"
         rts@gsnYRefLineDashPattern  = 5
         rts@gsnYRefLineThicknessF   = 1.0
 
         rts@tiMainString            = "" ;"Case: "+panelstr1
         rts@gsnLeftString           = "" ;"Zonal mean MSLP at 40~S~o~N~S"
         rts@gsnRightString          = "" ;"unit: hPa"

        ;resources for "left" variablea
         resL                        = rts
         resL@tiYAxisString          = "Zonal mean MSLP (hPa)" 
         resL@trYMinF                = 970.0           ; Set min/max of right Y axis
         resL@trYMaxF                = 1024.0
         resL@xyDashPatterns         = (/0,0/)                   ; dashed line for 2nd
         resL@xyLineThicknesses      = (/2,2/)                   ; thicker line
         resL@xyLineColors          := (/"salmon","skyblue2"/)

        ;resources for "right" variable
         resR                        = rts                     
         resR@tiYAxisString          = "SAM Index (standard)"
         resR@trYMinF                = minbin - maxbin/10.0
         resR@trYMaxF                = maxbin + maxbin/10.0
         resR@xyDashPatterns         = (/0/)                   ; dashed line for 2nd
         resR@xyLineThicknesses      = (/2/)                   ; thicker line
         resR@xyLineColors          := (/"Grey20"/)

         resL@tiXAxisString          = ""
         resL@gsnLeftString          = tname
         xyarr1                      = wgt_runave_Wrap(pltdat1,(/1.,3,5,6,5,3,1/), 0)
         plot2(0) = gsn_csm_xy2(wks2,yyyy1,xyarr1(0:1,:),xyarr1(2,:),resL,resR)
         delete([/xyarr1/])

         resL@tiXAxisString          = ""
         resL@gsnLeftString          = cname
         xyarr1                      = wgt_runave_Wrap(pltdat2,(/1.,3,5,6,5,3,1/), 0)
         plot2(1) = gsn_csm_xy2(wks2,yyyy2,xyarr1(0:1,:),xyarr1(2,:),resL,resR)
         delete([/xyarr1/])

         resL@tiXAxisString          = "Model time (year)"
         resL@gsnLeftString          = (/"Obs. (Marshall)"/)         ; create explicit labels
         xyarr1                      = wgt_runave_Wrap(pltdat3,(/1.,3,5,6,5,3,1/), 0)
         plot2(2) = gsn_csm_xy2(wks2,yyyy3,xyarr1(0:1,:),xyarr1(2,:),resL,resR)
         delete([/xyarr1/])

          pres2                            = True                ; mods desired
          pres2@gsnFrame                   = False               ; save panel until both ready
          pres2@gsnPanelYWhiteSpacePercent = 4
         ;pres2@gsnPanelBottom             = 0.10                ; draw from center to right edge
         ;pres2@gsnPanelTop                = 0.5                ; draw from center to right edge
         ;pres2@gsnPanelMainString         = "Left: monthly mean;  Right: 3-month running average"
         ;pres2@gsnPanelMainFontHeightF    = 0.012
          pres2@gsnPanelYF                 = (/0.95,0.67,0.39/)
          gsn_panel(wks2,plot2(:),(/3,1/),pres2)       ; create first panel

          genres                     = True
          textres                    = True
          lineres                    = True

          genres@XPosPercent         = 26
          genres@YPosPercent         = 10

          textres@lgLabels           = "  "+(/"40~S~o~N~S","65~S~o~N~S","SAM"/) 
         ;textres@lgLabels           =  textres@lgLabels(::-1)
          textres@lgItemCount        = 4

          lineres@lgLineLabelFontHeightF   = 0.032                   ; font height
          lineres@lgLineThicknesses  = 3.5
          lineres@lgLineColors       = (/"salmon","skyblue2","Grey20"/)
          lineres@lgDashIndexes      = (/0,0,0/)
          lineres@LineLengthPercent  = 40
          simple_legend_ndc(wks2, genres, lineres, textres)
          frame(wks2)

          ;delete([/sam1_regres,sam2_regres,sam3_regres,sam4_regres/])
          ;delete([/sam1_rgprob,sam2_rgprob,sam3_rgprob,sam4_rgprob/])
          ;delete([/pltdat1,pltdat2,pltdat3,pltdat3/])

        end do                                      ; end of looping over seasons

        end do                                      ; end of looping over variables

        delete([/f1,gw1/])
        delete([/f2,gw2/])

  end do                                            ; end of looping over pressure levels


end

