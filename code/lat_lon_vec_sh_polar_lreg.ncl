  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a 4-panel lat-lon plot
;          Data is vertically interpolated to pressure levels
;          1st panel: experiment 1
;          2nd panel: experiment 2
;          3rd panel: absolute difference (exp1-exp2)
;          4th panel: relative difference (exp1-exp2)/exp2
; Author : Po-Lun Ma
; Date   : Jan 22, 2013
;          Feb 06, 2020 - Jian Sun modified to add plots for aerosol number mixing ratios and cloud-borne aerosols
;          Feb 19, 2020 - Jian Sun changed the plot style and added unit conversion based on Kai's suggestion

begin

  compare                                    = getenv("COMPARE")
  tpath                                      = getenv("TPATH")
  cpath                                      = getenv("CPATH")
  case1name                                  = getenv("TEST_NAME")
  case2name                                  = getenv("CTRL_NAME")
  casedir                                    = getenv("CASEDIR")
  obstimtag                                  = getenv("OBS_TIME_TAG")
  statistical_test                           = getenv("DIFFERENCE_TEST")
  statistical_siglev                         = 0.05

;define constant
  pi                                         = 3.14159265
  rearth                                     = 6.37122e6
  grav                                       = 9.806

;define regions for plot
  latS                                       = -90.  ;negative for southern hemisphere
  latN                                       = -20.  ;negative for southern hemisphere
  pout                                       = "20S-90S"

;define time for the plot
  seasons                                    = (/"ANN","DJF","JJA"/)

;variable name in the climo file
 load "./share_info_for_vector_map.ncl"

;read in two files

 do kk = 0, dimsizes(seasons)-1

    f                                   = systemfunc("ls $TPATH/*"+seasons(kk)+"_means.nc")
    f1                                  = addfile(f,"r")
    gw1                                     = tofloat(f1->gw({latN:latS}))

    if(compare.ne."Model_vs_OBS") then
      f                                     = systemfunc("ls $CPATH/*"+seasons(kk)+"_means.nc")
      f2                                    = addfile(f,"r")
      gw2                                   = tofloat(f2->gw({latN:latS}))

    end if

    do jj = 0, dimsizes(plotvars)-1

      pltvarnam                              = plotvars(jj)
      presnew                              = prelev(jj)
      factor                               = facvar(jj)

      if(compare.eq."Model_vs_OBS") then
        if ( presnew.eq.-9999 ) then
          f                                = systemfunc("ls $CPATH/*_siglev_analysis_*_"+seasons(kk)+".nc")
          f2                               = addfile(f,"r")
          gw2                              = tofloat(f2->gw({latN:latS}))
        else
          f                                = systemfunc("ls $CPATH/*_prelev_analysis_*_"+seasons(kk)+".nc")
          f2                               = addfile(f,"r")
          gw2                              = tofloat(f2->gw({latN:latS}))
        end if
      end if

      print("working on variable "+ pltvarnam)
      load "./function_read_vector_var.ncl"

       var1_1@units                     = varunt(jj)
       var1_2@units                     = varunt(jj)
       var1_1@units                     = varunt(jj)
       var2_2@units                     = varunt(jj)
       var1_1@_FillValue                = -9999.
       var1_2@_FillValue                = -9999.
       var2_1@_FillValue                = -9999.
       var2_2@_FillValue                = -9999.

       ddd1                             = dimsizes(var1_1)
       ddd2                             = dimsizes(var2_1)

       ;;check the two comparing files and see if they are in the same grid, otherwise, return the error message;;;;
       if ((ddd1(1).ne.ddd2(1)).or.(ddd1(2).ne.ddd2(2)))then
        print("Error: this scripts requires the two files must in the same grid to run!!!")
        return
       end if

       ;;generate the weighting metrics 
       mcor                          = new((/ddd1(1),ddd1(2)/),float)
       mcor@_FillValue               = var1_1@_FillValue
       do i = 0, ddd2(1)-1
          mcor(i,:)                  = gw1(i)*(2.*pi/ddd1(2))*rearth^2.
       end do

       if(str_lower(statistical_test).eq."true")then 
       
       ;First variable 
        l_plot_ttest = True 
        xtmp = var1_1(lat|:,lon|:,time|:)       ; reorder but do it only once [temporary]
        ytmp = var2_1(lat|:,lon|:,time|:)
       ;printVarSummary(xtmp) 
        xAve = dim_avg (xtmp)              ; calculate means at each grid point
        yAve = dim_avg (ytmp)
        xVar = dim_variance (xtmp)         ; calculate variances
        yVar = dim_variance (ytmp)
        xEqv = equiv_sample_size (xtmp, statistical_siglev,0)
        yEqv = equiv_sample_size (ytmp, statistical_siglev,0)
        xN   = wgt_areaave2 (xEqv, mcor, 0)    ; wgty could be gaussian weights
        yN   = wgt_areaave2 (yEqv, mcor, 0)
       ;print(xN+  " "+yN)          
        iflag = True                       ; population variance similar
        prob1 = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False)
        delete([/xtmp,ytmp,xAve,yAve,xVar,yVar,xEqv,yEqv,xN,yN/])

       ;Second variable 
        xtmp = var1_2(lat|:,lon|:,time|:)       ; reorder but do it only once [temporary]
        ytmp = var2_2(lat|:,lon|:,time|:)
       ;printVarSummary(xtmp)
        xAve = dim_avg (xtmp)              ; calculate means at each grid point
        yAve = dim_avg (ytmp)
        xVar = dim_variance (xtmp)         ; calculate variances
        yVar = dim_variance (ytmp)
        xEqv = equiv_sample_size (xtmp, statistical_siglev,0)
        yEqv = equiv_sample_size (ytmp, statistical_siglev,0)
        xN   = wgt_areaave2 (xEqv, mcor, 0)    ; wgty could be gaussian weights
        yN   = wgt_areaave2 (yEqv, mcor, 0)
       ;print(xN+  " "+yN)
        iflag = True                       ; population variance similar
        prob2 = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False)
        delete([/xtmp,ytmp,xAve,yAve,xVar,yVar,xEqv,yEqv,xN,yN/])

       ;Third variable
        xtmp = var1_m(lat|:,lon|:,time|:)       ; reorder but do it only once [temporary]
        ytmp = var2_m(lat|:,lon|:,time|:)
       ;printVarSummary(xtmp)
        xAve = dim_avg (xtmp)              ; calculate means at each grid point
        yAve = dim_avg (ytmp)
        xVar = dim_variance (xtmp)         ; calculate variances
        yVar = dim_variance (ytmp)
        xEqv = equiv_sample_size (xtmp, statistical_siglev,0)
        yEqv = equiv_sample_size (ytmp, statistical_siglev,0)
        xN   = wgt_areaave2 (xEqv, mcor, 0)    ; wgty could be gaussian weights
        yN   = wgt_areaave2 (yEqv, mcor, 0)
       ;print(xN+  " "+yN)
        iflag = True                       ; population variance similar
        prob3 = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False)
        delete([/xtmp,ytmp,xAve,yAve,xVar,yVar,xEqv,yEqv,xN,yN/])

       end if 

       vp1x_1	         	    = dim_avg_n_Wrap(var1_1,0)
       vp2x_1		            = dim_avg_n_Wrap(var2_1,0)
       vp1x_2                           = dim_avg_n_Wrap(var1_2,0)
       vp2x_2                           = dim_avg_n_Wrap(var2_2,0)
       vp1x_m                           = dim_avg_n_Wrap(var1_m,0)
       vp2x_m                           = dim_avg_n_Wrap(var2_m,0)

       vdiff_1                          = vp1x_1
       vdiff_1                          = vp1x_1-vp2x_1
       vdiff_2                          = vp1x_2
       vdiff_2                          = vp1x_2-vp2x_2
       vdiff_m                          = vp1x_m
       vdiff_m                          = vp1x_m-vp2x_m

       vp1x_1@_FillValue                = -9999.
       vp1x_2@_FillValue                = -9999.
       vp2x_1@_FillValue                = -9999.
       vp2x_2@_FillValue                = -9999.
       vp1x_m@_FillValue                = -9999.
       vp2x_m@_FillValue                = -9999.

       vdiff_1@_FillValue               = -9999.
       vdiff_2@_FillValue               = -9999.
       vdiff_m@_FillValue               = -9999.

       vp11                             = where(ismissing(vp1x_m(:,:)), vp1x_m@_FillValue, vp1x_m(:,:)*mcor)
       vp1m                             = sum(vp11)
       mcor1                            = where(ismissing(vp1x_m(:,:)), mcor@_FillValue, mcor)
       vp1m                             = vp1m / sum(mcor1)
       
       vp22                             = where(ismissing(vp2x_m(:,:)), vp2x_m@_FillValue, vp2x_m(:,:)*mcor)
       vp2m                             = sum(vp22)
       mcor2                            = where(ismissing(vp2x_m(:,:)), mcor@_FillValue, mcor)
       vp2m                             = vp2m / sum(mcor2)

       vp33                             = where(ismissing(vdiff_m(:,:)), vdiff_m@_FillValue, vdiff_m(:,:)*mcor)
       vdmm                             = sum(vp33)
       mcor3                            = where(ismissing(vdiff_m(:,:)), mcor@_FillValue, mcor)
       vdmm                             = vdmm / sum(mcor3)

       delete([/var1_1,var1_2,var2_1,var2_2,var1_m,var2_m,mcor,mcor1,mcor2,mcor3,vp11,vp22,vp33/])

       if(l_plot_ttest)then 
         
       ;vdiff_1                         = where(prob1.le.statistical_siglev,vdiff_1,vdiff_1@_FillValue)
       ;vdiff_2                         = where(prob2.le.statistical_siglev,vdiff_2,vdiff_2@_FillValue)
        vdiff_m                         = where(prob3.le.statistical_siglev,vdiff_m,vdiff_m@_FillValue)

       end if 
      
       wtype                        = "eps"
      ;wtype@wkWidth                = 2500
      ;wtype@wkHeight               = 2500
       figdir                       = casedir+"/Latitude-Longitude_Contour_Maps_"+pout+"/"
       fe                           = pltvarnam+"_"+seasons(kk)+"_latlon_"+pout 
       wks                          = gsn_open_wks(wtype,figdir+ fe)

       load "./share_color_bar_for_vector_map.ncl"

       gsn_merge_colormaps(wks,"amwg","amwg_blueyellowred")  ; merge two color maps

       plot   = new (3,graphic)


;;;;;;;;;;;;;;;;;;;;;;;;;
;
;    Make the Plot
;
;;;;;;;;;;;;;;;;;;;;;;;;;
      res                  	        = True                  ; plot mods desired
      res@cnFillOn         	        = True                  ; turn on color fill
      res@cnLinesOn          	        = False                 ; no contour lines
      res@cnLineLabelsOn     	        = False
      res@tmXTOn    		 	= False

      FontHeightF = 0.018
      res@tiMainFontThicknessF          = 2.0
      res@tiMainFontHeightF             = FontHeightF*1.5
      res@tmYLLabelFontHeightF          = FontHeightF
      res@tmXBLabelFontHeightF          = FontHeightF
      res@tiXAxisFontHeightF            = FontHeightF
      res@tiYAxisFontHeightF            = FontHeightF
      res@gsnStringFontHeightF          = FontHeightF
      res@cnLineLabelFontHeightF        = FontHeightF
      res@lbLabelFontHeightF            = FontHeightF*0.8
      res@lbTitleFontHeightF            = FontHeightF*0.8

      res@tmBorderThicknessF            = 1.0
      res@tmXBMajorThicknessF           = 1.0
      res@tmXBMinorThicknessF           = 1.0
      res@tmYLMajorThicknessF           = 1.0
      res@tmYLMinorThicknessF           = 1.0
      res@tmYRMajorThicknessF           = 1.0
      res@tmYRMinorThicknessF           = 1.0
      res@mpGeophysicalLineThicknessF   = 2.0

      res@gsnPolarLabelFontHeightF      = 0.02
      res@gsnPolar                      = "SH"
      res@gsnScalarContour              = True              ; vectors over scalars

      res@mpFillOn                      = False        ; turn off map fill
      res@mpMaxLatF                     = latN

      res@gsnFrame          		= False                 ; Do not draw plot
      res@gsnDraw           		= False                 ; Do not advance frame
      res@tmYRMode          	   	= "Automatic"           ; turn off special labels on right axis
      res@lbLabelBarOn      		= True
      res@lbOrientation     		= "Vertical"
     ;res@pmLabelBarParallelPosF        = 0.61
      res@pmLabelBarOrthogonalPosF      = 0.15
      res@lbLabelFontHeightF            = 0.02               ; make labels smaller

      res@cnInfoLabelOn     		= False
      res@cnLevelSelectionMode      	= "ExplicitLevels"       ; manual levels
      res@cnMissingValFillColor 	= "White" ;"gray76"               ; black = 1

      res@gsnRightStringFontHeightF	= 0.025
      res@gsnRightStringOrthogonalPosF  = 0.06
      res@gsnLeftStringFontHeightF	= 0.025

      res@vcRefLengthF                  = 0.04              ; size of ref vector
      res@vcRefAnnoFontHeightF          = 0.022
      res@vcLineArrowColor              = "black"           ; white vectors
      res@vcMinDistanceF                = 0.025             ; thins arrows near pole
      res@vcGlyphStyle                  = "CurlyVector"     ; turns on curly vectors
      res@vcRefAnnoArrowLineColor       = "black"       ; black ref vector
      res@vcRefAnnoArrowUseVecColor     = False
      res@vcRefAnnoPerimOn              = False
      res@vcRefAnnoOrthogonalPosF       = -0.05
      res@vcRefAnnoParallelPosF         = 1.02

      res1 = res
      res1@vcRefMagnitudeF              = magm_vec              ; vec magnitude
      res1@cnLevels                     = sprintf("%5.2f",s1)
      res1@cnFillColors                 = (/3,4,5,6,7,8,9,10,11,12,13,29,30,15,16,17/)
      if(max(abs(s1)).ge.10.0)then
        res1@gsnRightString             = "mean: "+sprintf("%5.1f",vp1m)
        res1@lbLabelStrings             = sprintf("%5.1f",s1)
      else
        res1@gsnRightString             = "mean: "+sprintf("%5.2f",vp1m)
        res1@lbLabelStrings             = sprintf("%5.2f",s1)
      end if
      res1@tiMainString                 = case1name 
      res1@gsnLeftString                = str_upper(pltvarnam)+ " ("+unit+")"
      plot(0)   			= gsn_csm_vector_scalar_map_polar(wks,vp1x_1(:,:),vp1x_2(:,:),vp1x_m(:,:),res1)

      if(max(abs(s1)).ge.10.0)then
        res1@gsnRightString             = "mean: "+sprintf("%5.1f",vp2m)
        res1@lbLabelStrings             = sprintf("%5.1f",s1)
      else
        res1@gsnRightString             = "mean: "+sprintf("%5.2f",vp2m)
        res1@lbLabelStrings             = sprintf("%5.2f",s1)
      end if 
      res1@tiMainString                 = case2name 
      res1@gsnLeftString                = str_upper(pltvarnam)+ " ("+unit+")"            
      plot(1) 			        = gsn_csm_vector_scalar_map_polar(wks,vp2x_1(:,:),vp2x_2(:,:),vp2x_m(:,:),res1)

      res2 = res
      res2@vcRefMagnitudeF              = magd_vec              ; vec magnitude
      res2@cnLevels      		= sprintf("%5.2f",s2)
      res2@cnFillColors  		= (/18,20,22,23,24,25,26,27,28,30,31,33/)
      if(max(abs(s2)).ge.10.0)then
        res2@gsnRightString             = "mean: "+sprintf("%5.1f",vdmm)
        res2@lbLabelStrings             = sprintf("%5.1f",s2)
      else
        res2@gsnRightString             = "mean: "+sprintf("%5.2f",vdmm)
        res2@lbLabelStrings             = sprintf("%5.2f",s2)
      end if
      res2@tiMainString                 = case1name + " - " + case2name ; "absolute difference"
      res2@gsnLeftString                = str_upper(pltvarnam)+ " ("+unit+")"
      plot(2) 			        = gsn_csm_vector_scalar_map_polar(wks,vdiff_1(:,:),vdiff_2(:,:),vdiff_m(:,:),res2)

      pres                              = True        ; panel plot mods desired
      pres@gsnMaximize                  = False       ; fill the page
      pres@txFontHeightF                = 0.015
      pres@txFontThicknessF             = 10.
      pres@gsnPanelXWhiteSpacePercent   = 3.
      pres@gsnPanelYWhiteSpacePercent   = 5.
      pres@txString                     = "Ploat time: "+seasons(kk)
      gsn_panel(wks,plot(:),(/1,3/),pres)

      ;convert the figure 
      ;if (wtype .eq. "png") then
      ;  tmpa = systemfunc("convert "+figdir+fe+".png -trim del.png")
      ;  tmpb = systemfunc("mv del.png "+fe+".png")
      ;end if

      delete([/vp1x_1,vp1x_2,vp1x_m,vp2x_1,vp2x_2,vp2x_m,vdiff_1,vdiff_2,vdiff_m/])

   delete([/plot,res,pres,wks,ddd1,ddd2,s1,s2/])

  end do       ; end of looping over variables

  delete([/f1,gw1,f2,gw2/])

end  do          ; end of looping over seasons

end
