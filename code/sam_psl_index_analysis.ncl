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

;define regions for plot
  latS                                       = -90.  ;negative for southern hemisphere
  latN                                       = -20.  ;negative for southern hemisphere

;define constants for unit conversion
  pi                                         = 3.14159265
  rearth                                     = 6.37122e6
  grav                                       = 9.80665

 print(cname + " " +tname)
;variable name in the climo file
  modvars                                    = (/"PSL"/)
  facmod                                     = (/1.0/100.0/)
  varunt                                     = (/"hPa"/)
  panelstr1                                  = tname + " ("+tttag+")"
  panelstr2                                  = cname + " ("+cttag+")"

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

;declear the season or annual mean data to be used;;;;;
  seasons                                    = (/"monthly"/)
  pout                                       = (/"Surface"/)

;read the sam index file constructed by observational data;;;;
  latS0                                      = -65.  ;negative for southern hemisphere
  latN0                                      = -40.  ;negative for southern hemisphere
  fx1    = obspath+"/pobs/Marshall_mslp_monthly_"+toint(abs(latS0))+"S.txt"
  fx2    = obspath+"/pobs/Marshall_mslp_monthly_"+toint(abs(latN0))+"S.txt"
  ncol   = 13
  marshall_slp65 = readAsciiTable(fx1, ncol, "float", (/1/))
  marshall_slp40 = readAsciiTable(fx2, ncol, "float", (/1/))

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

           if(compare.ne."Model_vs_OBS") then
             vp2                               = f2->$mvarnam$(:,{latS:latN},:)
           end if 

           if(compare.eq."Model_vs_OBS") then
             ovarnam                           = obsvars(jj)
             vp2                               = f2->$ovarnam$
           end if

           vp1                                 = vp1*facmod(jj)
           vp2                                 = vp2*facobs(jj)

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

       ; ==============================================================
       ; Zonal mean SLP at 40S and 65S 
       ; ==============================================================
       ; observerd SLP
         obs_year   = toint(marshall_slp65(:,0))
         obs_time   = yyyymm_time(min(obs_year), max(obs_year), "integer")
         obs_slp65  = ndtooned(marshall_slp65(:,1:))
         obs_slp40  = ndtooned(marshall_slp40(:,1:))

        ;;;find the overlap of model and obs ;;; 
        ;shift the model time to be consistent with the observations;;;
        vp1&time = vp1&time - 1.0
        if(compare.ne."Model_vs_OBS")then
          vp2&time = vp2&time - 1.0
        end if
        utc_date1  = cd_calendar(vp1&time,-1)
        utc_date2  = cd_calendar(vp2&time,-1)
        indx1      = get1Dindex(utc_date2,utc_date1)
        indx2      = get1Dindex(obs_time,utc_date1)

        if(all(ismissing(indx1)).or. all(ismissing(indx2))) then
          print("there is not overlappy, the comparision is invalide")
          exit
        else 
          ix1     = ind(.not.ismissing(indx1))
          ix2     = ind(.not.ismissing(indx2)) 
          ind1    = indx1(ix1)
          ind2    = indx2(ix2)
          otime1  = utc_date2(ind1)
          otime2  = obs_time(ind2)

          if(dimsizes(otime1).lt.dimsizes(otime2)) then 
            otime = otime1
          else
            otime = otime2
          end if 
          delete([/ix1,ix2,ind1,ind2,otime1,otime2/])
        end if 


        id1      = get1Dindex(utc_date1,otime)
        id2      = get1Dindex(utc_date2,otime)
        id3      = get1Dindex(obs_time,otime)
        time     = vp1&time(id1)
        utc_date = cd_calendar(time,1)
        yyyy     = yyyymm_to_yyyyfrac(utc_date, 0.0)

       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;select the data to consturct the sam index
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        vp1_slp65 = dim_avg_n_Wrap(vp1(id1,{latS0},:),1)
        vp1_slp40 = dim_avg_n_Wrap(vp1(id1,{latN0},:),1)
        vp2_slp65 = dim_avg_n_Wrap(vp2(id2,{latS0},:),1)
        vp2_slp40 = dim_avg_n_Wrap(vp2(id2,{latN0},:),1)
        vp3_slp65 = obs_slp65 (id3)
        vp3_slp40 = obs_slp40 (id3)

        vp1_slp65@_FillValue = -9999.0
        vp1_slp40@_FillValue = -9999.0
        vp2_slp65@_FillValue = -9999.0
        vp2_slp40@_FillValue = -9999.0
        vp3_slp65@_FillValue = -9999.0
        vp3_slp40@_FillValue = -9999.0

       ; ================================================================================================
       ; compute sam indices (Antarctic Oscillation index)
       ; Based on the numerical definition of the SAM by Gong and Wang (1999), which is:
       ; SAM = P*40�S -  P*65°S
       ; where P*40°S and P*65°S are the normalized monthly zonal sea level pressur(SLP) at 40°S and 65�
       ; ================================================================================================

        nyear     = dimsizes(otime)/12
        a1        = reshape(vp1_slp40,(/nyear,12/))
        b1        = reshape(vp1_slp65,(/nyear,12/))
        vp1_samid = ndtooned(dim_standardize_n_Wrap(a1, 0, 0) - dim_standardize_n_Wrap(b1, 0, 0))
        a1        = reshape(vp2_slp40,(/nyear,12/))
        b1        = reshape(vp2_slp65,(/nyear,12/))
        vp2_samid = ndtooned(dim_standardize_n_Wrap(a1, 0, 0) - dim_standardize_n_Wrap(b1, 0, 0))
        a1        = reshape(vp3_slp40,(/nyear,12/))
        b1        = reshape(vp3_slp65,(/nyear,12/))
        vp3_samid = ndtooned(dim_standardize_n_Wrap(a1, 0, 0) - dim_standardize_n_Wrap(b1, 0, 0))
    
      ;=============================================================================
      ;Save the data for the regression analysis
      ;=============================================================================
       setfileoption("nc", "Format",  "NetCDF4")
       out_file1  = opath +"/"+"SAM_AOI_index_"+tname+"_monthly_mean_"+seasons(kk)+".nc"
       out_file2  = opath +"/"+"SAM_AOI_index_"+cname+"_monthly_mean_"+seasons(kk)+".nc"
       out_file3  = opath +"/"+"SAM_AOI_index_Marshall_monthly_mean_"+seasons(kk)+".nc"

       system("rm " + out_file1)
       system("rm " + out_file2)
       system("rm " + out_file3)

       fout1      = addfile(out_file1,"c")
       fout2      = addfile(out_file2,"c")
       fout3      = addfile(out_file3,"c")

       copy_VarCoords (vp1_slp65,vp1_samid)
       copy_VarCoords (vp2_slp65,vp2_samid)
       copy_VarCoords (vp3_slp65,vp3_samid)

       fout1->slp65  = vp1_slp40
       fout1->slp40  = vp1_slp65
       fout1->AOI    = vp1_samid
 
       fout2->slp65  = vp2_slp40
       fout2->slp40  = vp2_slp65
       fout2->AOI    = vp2_samid

       fout3->slp65  = vp3_slp40
       fout3->slp40  = vp3_slp65
       fout3->AOI    = vp3_samid

       delete([/fout1,fout2,fout3, out_file1,out_file2,out_file3/])

       ;;;;;;start to process the regression variable ;;;;
       regx  = vp1(id1,{latS:latN},:)
       regy  = vp2(id2,{latS:latN},:)

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
       sam1_regres@_FillValue = -9999.

       sam1_regres!0 = "lat"
       sam1_regres!1 = "lon"
       sam1_regres&lat = regxAnom&lat
       sam1_regres&lon = regxAnom&lon

       sam2_regres = sam1_regres
       sam3_regres = sam1_regres
       sam4_regres = sam1_regres

       sam1_rgprob = sam1_regres
       sam2_rgprob = sam1_regres
       sam3_rgprob = sam1_regres
       sam4_rgprob = sam1_regres

       rc1    = regCoef_n(vp1_samid, regxAnom, 0, 0)
       rc2    = regCoef_n(vp2_samid, regyAnom, 0, 0)
       rc3    = regCoef_n(vp3_samid, regxAnom, 0, 0)
       rc4    = regCoef_n(vp3_samid, regyAnom, 0, 0)

       rc1@_FillValue = -9999.
       rc2@_FillValue = -9999.
       rc3@_FillValue = -9999.
       rc4@_FillValue = -9999.

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

          drc3  = dimsizes(rc3)
          df3   = rc3@nptxy-2   ; degrees of freedom
          tval3 = rc3@tval      ; t-statistic
          xb3   = tval3
          xb3   = 0.50
          pb3   = betainc(df3/(df3+tval3^2),df3/2.0,xb3)
          prob3 = reshape(pb3,(/drc3(0),drc3(1)/))
          sam3_rgprob = where(prob3.le.statistical_siglev,rc3,rc3@_FillValue)
          delete([/drc3,df3,tval3,xb3,pb3,prob3/])

          drc4  = dimsizes(rc4)
          df4   = rc4@nptxy-2   ; degrees of freedom
          tval4 = rc4@tval      ; t-statistic
          xb4   = tval4
          xb4   = 0.50
          pb4   = betainc(df4/(df4+tval4^2),df4/2.0,xb4)
          prob4 = reshape(pb4,(/drc4(0),drc4(1)/))
          sam3_rgprob = where(prob4.le.statistical_siglev,rc4,rc4@_FillValue)
          delete([/drc4,df4,tval4,xb4,pb4,prob4/])

        end if

        sam1_regres = (/ rc1 /) / facmod
        sam2_regres = (/ rc2 /) / facmod
        sam3_regres = (/ rc3 /) / facmod
        sam4_regres = (/ rc4 /) / facmod

        sam1_rgprob = (1.0 - sam1_rgprob)*100.0
        sam2_rgprob = (1.0 - sam2_rgprob)*100.0
        sam3_rgprob = (1.0 - sam3_rgprob)*100.0
        sam4_rgprob = (1.0 - sam4_rgprob)*100.0

        delete([/rc1,rc2,rc3,rc4/])
        delete([/regxAnom,regyAnom/])
        delete([/regxClm,regyClm, regx, regy/])
        delete([/utc_date,utc_date1,utc_date2,otime,indx1,indx2,id1,id2,id3/])
        delete([/a1,b1,nyear/])
        delete([/obs_time,obs_year,obs_slp65,obs_slp40/])

        ;;;calculate the rmsd and correlation;;
        rad    = 4.0*atan(1.0)/180.0
        wgty   = cos(sam1_regres&lat*rad)
        glCor1 = pattern_cor(sam1_regres,sam2_regres,1.0,0)
        glAve1 = wgt_arearmse(sam1_regres,sam2_regres, wgty, 1.0,0)
        glCor2 = pattern_cor(sam3_regres,sam4_regres,1.0,0)
        glAve2 = wgt_arearmse(sam3_regres,sam4_regres, wgty, 1.0,0)
        delete([/rad,wgty/])

        mstr1  = "corr. w/r " + sprintf("%.2f", glCor1)
        mstr2  = "RMSD  w/r " + sprintf("%.2f", glAve1)
        mstrx  = mstr1 + "~C~" + mstr2

        mstr1  = "corr. w/r " + sprintf("%.2f", glCor2)
        mstr2  = "RMSD  w/r " + sprintf("%.2f", glAve2)
        mstry  = mstr1 + "~C~" + mstr2

       ; =================================================================
       ; Extract the data for plot 
       ; ================================================================
        legends      = "  "+(/tname,cname,"Obs. (Marshall)"/)
        pltdat1      = new((/3,dimsizes(vp1_samid)/),typeof(vp1_samid))
        pltdat2      = new((/3,dimsizes(vp2_samid)/),typeof(vp2_samid))
        pltdat3      = new((/3,dimsizes(vp3_samid)/),typeof(vp3_samid))

        pltdat1(0,:) = (/vp1_slp40/)
        pltdat1(1,:) = (/vp2_slp40/)
        pltdat1(2,:) = (/vp3_slp40/)
        pltdat2(0,:) = (/vp1_slp65/)
        pltdat2(1,:) = (/vp2_slp65/)
        pltdat2(2,:) = (/vp3_slp65/)
        pltdat3(0,:) = (/vp1_samid/)
        pltdat3(1,:) = (/vp2_samid/)
        pltdat3(2,:) = (/vp3_samid/)

        delete([/vp1_slp65,vp1_slp40,vp1_samid,vp2_slp65,vp2_slp40,vp2_samid,vp3_slp65,vp3_slp40,vp3_samid/])

       ; =================================================================
       ; Start to do plot
       ; =================================================================
         wtype                        = "eps"
         figdir                       = outdir+"/Polar_SAM_Index/"
         fe1                          = "SAM_AOI_"+seasons(kk)+"_sam_index_40S_65S_slp_pattern_"+pout(ll) 
         fe2                          = "SAM_AOI_"+seasons(kk)+"_sam_index_40S_65S_time_series_"+pout(ll)
         wks1                         = gsn_open_wks(wtype, figdir + fe1)
         wks2                         = gsn_open_wks(wtype, figdir + fe2)

         plot1     = new((/4/),graphic)
         plot2     = new((/6/),graphic)
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

         ;---Draw second plot in upper right corner
         resx = res
         resx@gsnLeftString     = "AOI (" +mvarnam+")"
         resx@gsnRightString    = mstry
         resx@gsnCenterString   = "" 
         resx@tiMainString      = "Marshall Obs. on " + tname
         resx@tiMainOffsetYF    = 0.00
         resx@cnMinLevelValF    = mnmxint(0)/5 ; set the minimum contour level
         resx@cnMaxLevelValF    = mnmxint(1)/5 ; set the maximum contour level
         resx@cnLevelSpacingF   = mnmxint(2)/5 ; *special* match CPC
         plot1(2) = gsn_csm_contour_map_polar(wks1,sam3_regres,resx)

         ;---Draw second plot in upper right corner
         res@gsnLeftString     = "AOI (" +mvarnam+")"
         res@gsnRightString    = " "
         res@gsnCenterString   = "" 
         res@tiMainOffsetYF    = 0.02
         res@tiMainString      = "Marshall obs. on " + cname
         plot1(3) = gsn_csm_contour_map_polar(wks1,sam4_regres,res)

       ; panel plot only resources
         pres1                          = True                ; mods desired
         pres1@gsnFrame                 = True               ; save panel until both ready
         pres1@gsnPanelYWhiteSpacePercent = 8
        ;pres1@gsnPanelBottom           = 0.45    ; space for label bar
        ;pres1@gsnPanelTop              = 0.85     ; only panel on lower half of page
        ;pres1@gsnPanelXF               = (/0.07,0.57/)
         gsn_panel(wks1,plot1,(/2,2/),pres1)          ; create first panel

         delete([/mnmxint/])

       ;*******************************************
       ; second plot
       ;*******************************************
          rts           = True
          rts@gsnDraw   = False       ; don't draw yet
          rts@gsnFrame  = False       ; don't advance frame yet
          rts@gsnScale  = True        ; force text scaling

          rts@tiYAxisString = " "          ; y-axis label
          rts@tiXAxisString = "Time"

          rts@vpHeightF = 0.30        ; Changes the aspect ratio
          rts@vpWidthF  = 0.90
          rts@vpXF      = 0.10        ; change start locations
          rts@vpYF      = 0.75        ; the plot

          rts@gsnXYBarChart         = False ;True           ; create bar chart
          rts@tmXTOn                = False
          rts@tmYLLabelFontHeightF  = 0.025
          rts@tmBorderThicknessF    = 1.0
          rts@tmXBMajorThicknessF   = 1.0
          rts@tmXBMinorThicknessF   = 1.0
          rts@tmYLMajorThicknessF   = 1.0
          rts@tmYLMinorThicknessF   = 1.0
          rts@tmYRMajorThicknessF   = 1.0
          rts@tmYRMinorThicknessF   = 1.0

          ;rts@pmLegendDisplayMode    = "Always"            ; turn on legend
          ;rts@pmLegendSide           = "Top"               ; Change location of 
          ;rts@pmLegendParallelPosF   = 0.25               ; move units right
          ;rts@pmLegendOrthogonalPosF = -0.3                ; move units down
          ;rts@pmLegendWidthF         = 0.15                ; Change width and
          ;rts@pmLegendHeightF        = 0.18                ; height of legend.
          ;rts@lgPerimOn              = False               ; turn off box around
          ;rts@lgLabelFontHeightF     = .03                 ; label font height
          ;rts@xyExplicitLegendLabels = (/tname,cname,"Marshall"/)         ; create explicit labels

          rts@gsnYRefLine             = 0.              ; reference line
          rts@gsnYRefLineColor        = "black"
          rts@gsnYRefLineDashPattern  = 5
          rts@gsnYRefLineThicknessF   = 0.5

          res0 = rts
          res0@tiYAxisString          = ""          ; y-axis label      
          res0@trYMinF                = 1008.0 
          res0@trYMaxF                = 1024.0
          res0@gsnLeftString          = "Zonal mean MSLP at 40~S~o~N~S"
          res0@gsnRightString         = "unit: hPa" 
          res0@tiMainString           = "" ;"Case: "+panelstr1
          res0@xyLineOpacities        = (/ 1, 1, 0.3/)
          res0@xyLineThicknesses      = (/2, 2, 4/)
          res0@xyDashPatterns         = (/0,0,0/)
          res0@xyLineColors          := (/"salmon","skyblue2","Grey20"/)
          plot2(0)                    = gsn_csm_xy (wks2,yyyy,pltdat1,res0)
 
          xyarr1                      = wgt_runave_Wrap(pltdat1,(/1.,3,5,6,5,3,1/), 0)
          plot2(1)                    = gsn_csm_xy(wks2,yyyy,xyarr1,res0)
          delete([/xyarr1/])

        ;*******************************************
        ; Second plot
        ;*******************************************
          res0 = rts
          res0@tiYAxisString           = ""          ; y-axis label
          res0@trYMinF                 = 970.0
          res0@trYMaxF                 = 1000.0
          res0@gsnLeftString           = "Zonal mean MSLP at 65~S~o~N~S"
          res0@gsnRightString          = "unit: hPa"
          res0@tiMainString            = "" ;"Case: "+panelstr1
          res0@xyLineOpacities         = (/ 1, 1, 0.3/)
          res0@xyLineThicknesses       = (/2, 2, 4/)
          res0@xyDashPatterns          = (/0,0,0/)
          res0@xyLineColors           := (/"salmon","skyblue2","Grey20"/)
          plot2(2)                     = gsn_csm_xy (wks2,yyyy,pltdat2,res0)

          xyarr1                       = wgt_runave_Wrap(pltdat2,(/1.,3,5,6,5,3,1/), 0)
          plot2(3)                     = gsn_csm_xy(wks2,yyyy,xyarr1,res0)

        ;*******************************************
        ; Thrid plot
        ;*******************************************
          res0 = rts
          res0@tiYAxisString           = ""          ; y-axis label
          res0@trYMinF                 = min(pltdat3) - max(abs(pltdat3))/10.0
          res0@trYMaxF                 = max(pltdat3) + max(abs(pltdat3))/10.0
          res0@gsnLeftString           = "AOI index (SAM)"
          res0@gsnRightString          = "Standardized index"
          res0@tiMainString            = "" ;"Case: "+panelstr1
          res0@xyLineOpacities         = (/ 1, 1, 0.3/)
          res0@xyLineThicknesses       = (/2, 2, 4/)
          res0@xyDashPatterns          = (/0,0,0/)
          res0@xyLineColors           := (/"salmon","skyblue2","Grey20"/)
          plot2(4)                     = gsn_csm_xy (wks2,yyyy,pltdat3,res0)

          xyarr1                       = wgt_runave_Wrap(pltdat3,(/1.,3,5,6,5,3,1/), 0)
          plot2(5)                     = gsn_csm_xy (wks2,yyyy,xyarr1,res0)
          delete([/xyarr1/])

          pres2                           = True                ; mods desired
          pres2@gsnFrame                  = False               ; save panel until both ready
          pres2@gsnPanelYWhiteSpacePercent = 8
         ;pres2@gsnPanelBottom            = 0.10                ; draw from center to right edge
         ;pres2@gsnPanelTop               = 0.5                ; draw from center to right edge
          pres2@gsnPanelMainString        = "Left: monthly mean;  Right: 3-month running average"
          pres2@gsnPanelMainFontHeightF   = 0.012
          gsn_panel(wks2,plot2(:),(/3,2/),pres2)       ; create first panel

          genres                     = True
          textres                    = True
          lineres                    = True
          genres@XPosPercent         = 26
          genres@YPosPercent         = 4
          textres@lgLabels           = "  "+(/tname,cname,"Marshall"/) 
          textres@lgLabels           =  textres@lgLabels(::-1)
          textres@lgItemCount        = 4
          lineres@lgLineLabelFontHeightF   = 0.032                   ; font height
          lineres@lgLineThicknesses  = 3.5
          lineres@lgLineColors       = res0@xyLineColors(::-1)     ; reverse color order for legend
          lineres@lgDashIndexes      = res0@xyDashPatterns(::-1)   ; reverse pattern order for legend
          lineres@LineLengthPercent  = 40
          simple_legend_ndc(wks2, genres, lineres, textres)
          frame(wks2)

          delete([/sam1_regres,sam2_regres,sam3_regres,sam4_regres/])
          delete([/sam1_rgprob,sam2_rgprob,sam3_rgprob,sam4_rgprob/])
          delete([/pltdat1,pltdat2,pltdat3,pltdat3/])

        end do                                      ; end of looping over seasons

        end do                                      ; end of looping over variables

        delete([/f1,gw1/])
        delete([/f2,gw2/])

  end do                                            ; end of looping over pressure levels


end

