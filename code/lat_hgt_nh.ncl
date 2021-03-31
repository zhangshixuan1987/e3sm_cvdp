  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a 4-panel lat-height plot
;          Data is vertically interpolated to pressure levels
;          1st panel: experiment 1
;          2nd panel: experiment 2
;          3rd panel: absolute difference (exp1-exp2)
;          4th panel: relative difference (exp1-exp2)/exp2
; Author : Shixuan Zhang
; Date   : Feb 22, 2021

begin

  compare                                    = getenv("COMPARE")
  tpath                                      = getenv("TPATH")
  cpath                                      = getenv("CPATH")
  case1name                                  = getenv("TEST_NAME")
  case2name                                  = getenv("CTRL_NAME")
  casedir                                    = getenv("CASEDIR")
  obstimtag                                  = getenv("OBS_TIME_TAG")
  refplev_file                               = getenv("REF_PRE_LEV")
  statistical_test                           = getenv("DIFFERENCE_TEST")
  statistical_siglev                         = 0.05

;declear the season or annual mean data to be used;;;;;
  seasons                                   = (/"ANN","DJF","JJA"/)

;define regions for plot
  latS                                      =   0.  ;negative for southern hemisphere
  latN                                      =  90.  ;negative for southern hemisphere
  figstr                                    = "0-90N"

;define the pressure levels for cross-section plot 
  pout                                      = asciiread(refplev_file,-1,"float")
  pout@longname                             = "lev"
  pout@units                                = "hPa"
  intyp                                     = 2

  pi                                        = 3.14159265
  rearth                                    = 6.37122e6
  grav                                      = 9.806

;read in two files

  do kk = 0, dimsizes(seasons)-1
 
       f                                       = systemfunc("ls $TPATH/*"+seasons(kk)+"_means.nc")
       f1                                      = addfile(f,"r")
       gw1                                     = doubletofloat(f1->gw({latS:latN}))

       if(compare.eq."Model_vs_OBS") then
         f                                     = systemfunc("ls $CPATH/*_prelev_analysis_*_"+seasons(kk)+".nc")
         f2                                    = addfile(f,"r")
         gw2                                   = doubletofloat(f2->gw({latS:latN}))
       else
         f                                     = systemfunc("ls $CPATH/*"+seasons(kk)+"_means.nc")
         f2                                    = addfile(f,"r")
         gw2                                   = doubletofloat(f2->gw({latS:latN}))
       end if

     ; =================================================================
     print ("Start to process the cross-section of  selected variables ")
     load "./share_info_for_3d_var.ncl"

     do jj = 0, dimsizes(modvars)-1

        mvarnam                             = modvars(jj)
        tmp1                                = f1->$mvarnam$
        var1                                = vinth2p(tmp1,f1->hyam,f1->hybm,pout,f1->PS,intyp,f1->P0/100.0,1,False)
        delete([/tmp1/])

        if(compare.ne."Model_vs_OBS") then
          tmp2                              = f2->$mvarnam$
          var2                              = vinth2p(tmp2,f2->hyam,f2->hybm,pout,f2->PS,intyp,f2->P0/100.0,1,False)
          delete([/tmp2/])
        end if

        if(compare.eq."Model_vs_OBS") then
           ovarnam                          = obsvars(jj)
           tmp2                             = f2->$ovarnam$
           lev                              = f2->lev
           var2                             = int2p_n_Wrap(lev, tmp2, pout, intyp, 1)
           delete([/tmp2,lev/])
        end if

        var1@_FillValue                       = -9999.
        var2@_FillValue                       = -9999.

        if(compare.eq."Model_vs_OBS") then
          var1                                = var1*facmod(jj)
          var2                                = var2*facobs(jj)
        else
          var1                                = var1*facmod(jj)
          var2                                = var2*facmod(jj)
        end if

        var1@units                            = varunt(jj)
        var2@units                            = varunt(jj)

        ddd1                                  = dimsizes(var1)
        ddd2                                  = dimsizes(var2)

        ;printVarSummary(var1)
        ;printVarSummary(var2)
 
        ;interpolate the data to the same pressure levels ;;;;;
        vp1 = var1(:,:,{latS:latN},:)
        vp2 = var2(:,:,{latS:latN},:)

        vp1!0="time"
        vp1!1="lev"
        vp1!2="lat"
        vp1!3="lon"

        vp2!0="time"
        vp2!1="lev"
        vp2!2="lat"
        vp2!3="lon"

        if(str_lower(statistical_test).eq."true")then

         l_plot_ttest = True
         vpt1 = dim_avg_n_Wrap(vp1,3)
         vpt2 = dim_avg_n_Wrap(vp2,3) 
         xtmp = vpt1(lev|:,lat|:,time|:)       ; reorder but do it only once [temporary]
         ytmp = vpt2(lev|:,lat|:,time|:)
         ;printVarSummary(xtmp)
         xAve = dim_avg (xtmp)              ; calculate means at each grid point
         yAve = dim_avg (ytmp)
         xVar = dim_variance (xtmp)         ; calculate variances
         yVar = dim_variance (ytmp)
         xEqv = equiv_sample_size (xtmp, statistical_siglev,0)
         yEqv = equiv_sample_size (ytmp, statistical_siglev,0)
        ;printVarSummary(xEqv)
         xN   = dim_avg_n(dim_avg_wgt_n(xEqv, gw1, 0, 1),0)
         yN   = dim_avg_n(dim_avg_wgt_n(yEqv, gw2, 0, 1),0)
        ;print(xN+  " "+yN)
         iflag = True                       ; population variance similar
         prob  = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False)
        ;print(min(prob)+ " " +max(prob))
        ;printVarSummary(prob)
         delete([/xtmp,ytmp,xAve,yAve,xVar,yVar,xEqv,yEqv,xN,yN/])

       end if

       vp1a                                = dim_avg_n_Wrap(dim_avg_n_Wrap(vp1,3),0)
       vp2a                                = dim_avg_n_Wrap(dim_avg_n_Wrap(vp2,3),0)

       vp1a@_FillValue                     = -9999.
       vp2a@_FillValue                     = -9999.

       vp1b                                = where(abs(vp1a) .lt. 1.e-1, vp1a@_FillValue, vp1a)
       vp2b                                = where(abs(vp2a) .lt. 1.e-1, vp2a@_FillValue, vp2a)
       vp1b                                = where(ismissing(vp2b), vp1a@_FillValue, vp1b)
       vp2b                                = where(ismissing(vp1b), vp2a@_FillValue, vp2b)

       adiff                               = vp1a
       adiff                               = vp1a-vp2a

       rdiff                               = vp1a
       rdiff                               = (vp1b-vp2b)/abs(vp2b)*100.

       if(l_plot_ttest)then
        adiff                              = where(prob.le.statistical_siglev,adiff,adiff@_FillValue)
        rdiff                              = where(prob.le.statistical_siglev,rdiff,rdiff@_FillValue)
       end if

       ;;;;;;;;;;start to process the figure ;;;;;;;
        plot                                = new((/4/),graphic)
        wtype                               = "eps"
       ;wtype@wkWidth                       = 2500
       ;wtype@wkHeight                      = 2500
        figdir                              = casedir+"/Pressure-Latitude_Zonal_Mean_Contour/"
        fe                                  = modvars(jj)+"_"+seasons(kk)+"_lathgt"+"_"+figstr
        wks                                 = gsn_open_wks(wtype, figdir + fe)

        gsn_merge_colormaps(wks,"amwg","amwg_blueyellowred")             ; merge two color maps

        load "./share_color_bar_for_cross_section.ncl"

    ;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ;    Make the Plot
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;
           res                              = True                  ; plot mods desired
           res@vpWidthF                     = 0.6
           res@vpHeightF                    = 0.6
           res@gsnFrame                     = False                 ; Do not draw plot
           res@gsnDraw                      = False                 ; Do not advance frame
          ;res@gsnMajorLatSpacing           =  10             ;-- change major lat tickmark spacing
          ;res@gsnMinorLatSpacing           =  2.5            ;-- change major lat tickmark spacing

           res@cnFillOn                     = True                  ; turn on color fill
           res@cnLinesOn                    = False                 ; no contour lines
           res@cnLineLabelsOn               = False
           res@cnMissingValFillColor        = "White" ;"gray76"               ; black = 1

           res@tmXTOn                       = False
           res@tmYLLabelFontHeightF         = 0.025
           res@tmBorderThicknessF           = 1.0
           res@tmXBMajorThicknessF          = 1.0
           res@tmXBMinorThicknessF          = 1.0
           res@tmYLMajorThicknessF          = 1.0
           res@tmYLMinorThicknessF          = 1.0
           res@tmYRMajorThicknessF          = 1.0
           res@tmYRMinorThicknessF          = 1.0
           res@tmYRMode                     = "Automatic"          ; turn off special labels on right axis

           res@tmXBMode                     = "Explicit"
           res@tmXBValues                   = ispan(toint(latS),toint(latN),30)
           res@tmXBLabels                   = (/"90S","75S","60S","45S","30S","15S","0", \
                                                "15N","30N","45N","60N","75N","90N"/)
           res@tmXBMinorValues              = ispan(toint(latS),toint(latN),15)

           res@tmYLMode                     = "Explicit"                ; explicit labels
           res@tmYLValues                   = (/ 1000, 850, 700, 500, 300, 200, 100, 10, 1/)
           res@tmYLLabels                   = ""+res@tmYLValues         ; make strings

           res@lbLabelBarOn                 = True
           res@lbOrientation                = "Vertical"
           res@cnInfoLabelOn                = False
           res@cnLevelSelectionMode         = "ExplicitLevels"       ; manual levels
           res@cnLevels                     = sprintf("%5.2f",s1)
           res@cnFillColors                 = (/3,4,5,6,7,8,9,10,11,12,13,14,15/)
           res@gsnRightStringFontHeightF    = 0.025
           res@gsnRightStringOrthogonalPosF = 0.02
           res@trYReverse                   = True
           res@tiYAxisString                = "Pressure (hPa)"
           res@gsnLeftStringFontHeightF     = 0.025
           res@gsnLeftStringOrthogonalPosF  = 0.015

           res@tiMainString                 = panelstr1
           res@gsnLeftString                = str_upper(modvars(jj))+" (unit: "+ vp1a@units+")" ;"relative diff. (%)"
           res@gsnRightString               = "mean: "+sprintf("%5.2f",avg(vp1a(:,:)))
           plot(0)              = gsn_csm_contour(wks,vp1a(:,:),res)

           res@tiMainString                 = panelstr2
           res@gsnLeftString                = str_upper(modvars(jj))+" (unit: "+ vp1a@units+")" ;"relative diff. (%)"
           res@gsnRightString               = "mean: "+sprintf("%5.2f",avg(vp2a(:,:)))
           plot(1)              = gsn_csm_contour(wks,vp2a(:,:),res)

           res@cnLevels                     = sprintf("%7.2e",s2)
           res@cnFillColors                 = (/18,20,21,22,23,24,0,27,28,29,30,31,33/)              ; contour interval

           res@tiMainString                 = panelstr1 + " - " + panelstr2 ; "absolute difference"
           res@gsnLeftString                = str_upper(modvars(jj))+" (unit: "+ vp1a@units+")" ;"relative diff. (%)"
           res@gsnRightString               = "mean: "+sprintf("%5.2f",avg(adiff(:,:)))
           plot(2)              = gsn_csm_contour(wks,adiff(:,:),res)

           res@cnLevels                     = sprintf("%7.2f",s3)
           res@tiMainString                 = "relative diff. (%)"
           res@gsnLeftString                = str_upper(modvars(jj))+" (unit: "+ vp1a@units+")" ;"relative diff. (%)"
           res@gsnRightString               = "mean: "+sprintf("%5.2f",avg(rdiff(:,:)))
           plot(3)              = gsn_csm_contour(wks,rdiff(:,:),res)

           pres                             = True        ; panel plot mods desired
           pres@gsnMaximize                 = False       ; fill the page
           pres@txFontHeightF               = 0.015       
           pres@txFontThicknessF            = 2.
           pres@gsnPanelXWhiteSpacePercent  = 3.
           pres@gsnPanelYWhiteSpacePercent  = 5.
           pres@txString                    = str_upper(compare)+" ("+seasons(kk)+")"
           gsn_panel(wks,(/plot(:)/),(/2,2/),pres)

          ;if (wtype .eq. "png") then
          ;   tmpa = systemfunc("convert "+fe+".png -trim del.png")
          ;   tmpb = systemfunc("mv del.png "+fe+".png")
          ;end if

           delete([/var1,var2,vp1a,vp2a,adiff,rdiff,vp1,vp2,vp1b,vp2b,wks/])

        delete([/plot,res,pres,ddd1,ddd2,s1,s2,s3/])

     end do       ; end of looping over variables

     delete([/f1,gw1/])
     delete([/f2,gw2/])

  end do          ; end of looping over seasonsons

end
