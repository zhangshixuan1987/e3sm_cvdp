  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a 4-panel lat-lon plot
;          Data is vertically interpolated to pressure levels
;          1st panel: experiment 1
;          2nd panel: experiment 2
;          3rd panel: absolute difference (exp1-exp2)
;          4th panel: relative difference (exp1-exp2)/exp2

begin

  compare                                    = getenv("COMPARE")
  outdir                                     = getenv("CASEDIR")

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
  l_plot_ttest                               = False

 ;define regions for plot
  latS                                       = -90.  ;negative for southern hemisphere
  latN                                       =  90.  ;negative for southern hemisphere
  pout                                       = "Global"

  pi                                         = 3.14159265
  rearth                                     = 6.37122e6
  grav                                       = 9.806
  sigma                                      = 5.67e-8 ; Stefan-Boltzmann constant

 ;define time for the plot
  seasons                                    = (/"ANN","DJF","JJA","MAM","SON"/)

 ;variable name in the climo file
  load "./share_info_for_vector_map.ncl"

 do ll = 0, dimsizes(pout)-1

   ;read in two files
   f                                       = systemfunc("ls "+tpath+"/"+tcase+"_*_"+tttag+".nc")
   f1                                      = addfile(f,"r")
   gw1                                     = f1->gw

   f                                       = systemfunc("ls "+cpath+"/"+ccase+"_*_"+cttag+".nc")
   f2                                      = addfile(f,"r")
   gw2                                     = f2->gw

   do jj = 0, dimsizes(plotvars)-1

      pltvarnam                            = plotvars(jj)
      presnew                              = prelev(jj)
      factor                               = facvar(jj)

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

       ;;check the two comparing files and see if they are in the same grid,
       ddd1                             = dimsizes(var1_1)
       ddd2                             = dimsizes(var2_1)
       ;;otherwise, return the error message;;;;
       if ((ddd1(1).ne.ddd2(1)).or.(ddd1(2).ne.ddd2(2)))then
         print("Error: this scripts requires the two files must in the same grid to run!!!")
         return
       end if

       ;;generate the weighting metrics
       mcorx                         = var1_1(0,:,:)
       mcorx@_FillValue              = var1_1@_FillValue
       do i = 0, ddd1(1)-1
          mcorx(i,:)                 = tofloat(gw1(i))*(2.*pi/ddd1(2))*rearth^2.
       end do

      do kk = 0, dimsizes(seasons)-1

       ;;;;;;select the data for plots;;;;;;;;;;;;;;;;;;;;;;;;;;;
       if(seasons(kk).eq."ANN")then
         vp1_1                        = month_to_annual(var1_1(:,{latS:latN},:),1)
         vp1_2                        = month_to_annual(var1_2(:,{latS:latN},:),1)
         vp2_1                        = month_to_annual(var2_1(:,{latS:latN},:),1)
         vp2_2                        = month_to_annual(var2_2(:,{latS:latN},:),1)
       else
         vp1_1                        = month_to_season(var1_1(:,{latS:latN},:),seasons(kk))
         vp1_2                        = month_to_season(var1_2(:,{latS:latN},:),seasons(kk))
         vp2_1                        = month_to_season(var2_1(:,{latS:latN},:),seasons(kk))
         vp2_2                        = month_to_season(var2_2(:,{latS:latN},:),seasons(kk))
       end if
       vp1_1!0                        = "time"
       vp1_2!0                        = "time"
       vp2_1!0                        = "time"
       vp2_2!0                        = "time"
       mcor                           = mcorx({latS:latN},:)

       vp1_m                          = vp1_1
       vp2_m                          = vp2_1
       vp1_m                          = sqrt(vp1_1*vp1_1+vp1_2*vp1_2)
       vp2_m                          = sqrt(vp2_1*vp2_1+vp2_2*vp2_2)

       if(str_lower(statistical_test).eq."true")then 
       
       ;First variable 
        l_plot_ttest = True 
        xtmp = vp1_1(lat|:,lon|:,time|:)       ; reorder but do it only once [temporary]
        ytmp = vp2_1(lat|:,lon|:,time|:)
        xAve = dim_avg (xtmp)              ; calculate means at each grid point
        yAve = dim_avg (ytmp)
        xVar = dim_variance (xtmp)         ; calculate variances
        yVar = dim_variance (ytmp)
        xEqv = equiv_sample_size (xtmp, statistical_siglev,0)
        yEqv = equiv_sample_size (ytmp, statistical_siglev,0)
        xN   = wgt_areaave2 (xEqv, mcor, 0)    ; wgty could be gaussian weights
        yN   = wgt_areaave2 (yEqv, mcor, 0)
        iflag = True                       ; population variance similar
        prob1 = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False)
        delete([/xtmp,ytmp,xAve,yAve,xVar,yVar,xEqv,yEqv,xN,yN/])

       ;Second variable 
        xtmp = vp1_2(lat|:,lon|:,time|:)       ; reorder but do it only once [temporary]
        ytmp = vp2_2(lat|:,lon|:,time|:)
        xAve = dim_avg (xtmp)              ; calculate means at each grid point
        yAve = dim_avg (ytmp)
        xVar = dim_variance (xtmp)         ; calculate variances
        yVar = dim_variance (ytmp)
        xEqv = equiv_sample_size (xtmp, statistical_siglev,0)
        yEqv = equiv_sample_size (ytmp, statistical_siglev,0)
        xN   = wgt_areaave2 (xEqv, mcor, 0)    ; wgty could be gaussian weights
        yN   = wgt_areaave2 (yEqv, mcor, 0)
        iflag = True                       ; population variance similar
        prob2 = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False)
        delete([/xtmp,ytmp,xAve,yAve,xVar,yVar,xEqv,yEqv,xN,yN/])

       ;Third variable
        xtmp = vp1_m(lat|:,lon|:,time|:)       ; reorder but do it only once [temporary]
        ytmp = vp2_m(lat|:,lon|:,time|:)
        xAve = dim_avg (xtmp)              ; calculate means at each grid point
        yAve = dim_avg (ytmp)
        xVar = dim_variance (xtmp)         ; calculate variances
        yVar = dim_variance (ytmp)
        xEqv = equiv_sample_size (xtmp, statistical_siglev,0)
        yEqv = equiv_sample_size (ytmp, statistical_siglev,0)
        xN   = wgt_areaave2 (xEqv, mcor, 0)    ; wgty could be gaussian weights
        yN   = wgt_areaave2 (yEqv, mcor, 0)
        iflag = True                       ; population variance similar
        prob3 = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False)
        delete([/xtmp,ytmp,xAve,yAve,xVar,yVar,xEqv,yEqv,xN,yN/])

       end if 

       vp1x_1	         	        = dim_avg_n_Wrap(vp1_1,0)
       vp2x_1		                = dim_avg_n_Wrap(vp2_1,0)
       vp1x_2                           = dim_avg_n_Wrap(vp1_2,0)
       vp2x_2                           = dim_avg_n_Wrap(vp2_2,0)
       vp1x_m                           = dim_avg_n_Wrap(vp1_m,0)
       vp2x_m                           = dim_avg_n_Wrap(vp2_m,0)

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

       delete([/vp1_1,vp1_2,vp2_1,vp2_2,vp1_m,vp2_m,mcor,mcor1,mcor2,mcor3,vp11,vp22,vp33/])

       if(l_plot_ttest)then 
         
       ;vdiff_1                         = where(prob1.le.statistical_siglev,vdiff_1,vdiff_1@_FillValue)
       ;vdiff_2                         = where(prob2.le.statistical_siglev,vdiff_2,vdiff_2@_FillValue)
        vdiff_m                         = where(prob3.le.statistical_siglev,vdiff_m,vdiff_m@_FillValue)

       end if 
      
       wtype                        = "eps"
      ;wtype@wkWidth                = 2500
      ;wtype@wkHeight               = 2500
       figdir                       = outdir+"/Latitude-Longitude_Contour_Maps_"+pout(ll)+"/"
       fe                           = pltvarnam+"_"+seasons(kk)+"_latlon_"+pout(ll) 
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
   res@gsnFrame                      = False                 ; Do not draw plot
   res@gsnDraw                       = False                 ; Do not advance frame


   FontHeightF = 0.018
   res@tiMainFontThicknessF          = 2.0
   res@tiMainFontHeightF             = FontHeightF*1.5
   res@tmYLLabelFontHeightF          = FontHeightF
   res@tmXBLabelFontHeightF          = FontHeightF
   res@tiXAxisFontHeightF            = FontHeightF
   res@tiYAxisFontHeightF            = FontHeightF
   res@gsnStringFontHeightF          = FontHeightF*1.2
   res@cnLineLabelFontHeightF        = FontHeightF
   res@lbLabelFontHeightF            = FontHeightF ;*0.8
   res@lbTitleFontHeightF            = FontHeightF ;*0.8

   res@gsnMajorLatSpacing            = 30
   res@gsnMajorLonSpacing            = 45
   res@gsnMinorLatSpacing            = 15
   res@gsnMinorLonSpacing            = 15

   res@tmBorderThicknessF            = 1.0
   res@tmXBMajorThicknessF           = 1.0
   res@tmXBMinorThicknessF           = 1.0
   res@tmYLMajorThicknessF           = 1.0
   res@tmYLMinorThicknessF           = 1.0
   res@tmYRMajorThicknessF           = 1.0
   res@tmYRMinorThicknessF           = 1.0
   res@mpGeophysicalLineThicknessF   = 0.5

   res@tmXTOn                        = False
  ;res@tmYRMode          	   	= "Automatic"           ; turn off special labels on right axis

   res@lbLabelBarOn                  = True
   res@lbOrientation                 = "Vertical"
   res@lbPerimOn                     = False             ; default has box
   res@pmLabelBarHeightF             = 0.38
   res@pmLabelBarWidthF              = 0.1
   res@pmLabelBarParallelPosF        = 0.50
   res@pmLabelBarOrthogonalPosF      = 0.05
  ;res@lbTitleString                 = ""

   res@cnInfoLabelOn     		= False
   res@cnLevelSelectionMode      	= "ExplicitLevels"       ; manual levels
   res@cnMissingValFillColor 	= "White" ;"gray76"               ; black = 1

   res@gsnScalarContour              = True              ; vectors over scalars
   res@mpFillOn                      = False        ; turn off map fill
   res@mpGeophysicalLineThicknessF   = 2.0
   res@mpMinLonF                     =   0
   res@mpMaxLonF                     = 360
   res@mpCenterLonF                  = 180     ; This is necessary to get the correct map

   res@vcRefLengthF                  = 0.04              ; size of ref vector
   res@vcRefAnnoFontHeightF          = FontHeightF*0.8
   res@vcLineArrowColor              = "black"           ; white vectors
   res@vcMinDistanceF                = 0.025              ; thins arrows near pole
   res@vcGlyphStyle                  = "CurlyVector"     ; turns on curly vectors
   res@vcRefAnnoArrowLineColor       = "black"       ; black ref vector
   res@vcRefAnnoArrowUseVecColor     = False
   res@vcRefAnnoPerimOn              = False
   res@vcRefAnnoSide                 = "Bottom"
   res@vcRefAnnoOrthogonalPosF       = 0.02
   res@vcRefAnnoParallelPosF         = 1.15

   res1 = res
   res1@vcRefMagnitudeF              = magm_vec              ; vec magnitude
   res1@cnLevels                     = sprintf("%5.2f",s1)
   res1@cnFillColors                 = (/3,4,5,6,7,8,9,10,11,12,13,29,30,15,16,17/)
   res1@tiMainString                   = panelstr1
   res1@gsnLeftString                  = str_upper(pltvarnam)+ " ("+unit+")"
   if(max(abs(s1)).ge.10.0)then
     res1@gsnRightString               = "mean: "+sprintf("%5.1f",vp1m)
     res1@lbLabelStrings               = sprintf("%5.1f",s1)
   else
     res1@gsnRightString               = "mean: "+sprintf("%5.2f",vp1m)
     res1@lbLabelStrings               = sprintf("%5.2f",s1)
   end if
   plot(0)   			       = gsn_csm_vector_scalar_map_ce(wks,vp1x_1(:,:),vp1x_2(:,:),vp1x_m(:,:),res1)
   res1@tiMainString                   = panelstr2
   res1@gsnLeftString                  = str_upper(pltvarnam)+ " ("+unit+")"  
   if(max(abs(s1)).ge.10.0)then
     res1@gsnRightString               = "mean: "+sprintf("%5.1f",vp2m)
     res1@lbLabelStrings               = sprintf("%5.1f",s1)
   else
     res1@gsnRightString               = "mean: "+sprintf("%5.2f",vp2m)
     res1@lbLabelStrings               = sprintf("%5.2f",s1)
   end if
   plot(1) 			        = gsn_csm_vector_scalar_map_ce(wks,vp2x_1(:,:),vp2x_2(:,:),vp2x_m(:,:),res1)

   res2 = res
   res2@vcRefMagnitudeF              = magd_vec              ; vec magnitude
   res2@cnLevels      		     = sprintf("%5.2f",s2)
   res2@cnFillColors  		     = (/18,20,22,23,24,25,26,27,28,30,31,33/)
   res2@tiMainString                 = "Difference (Test - Reference)" ;panelstr1 + " - " + panelstr2 ;
   res2@gsnLeftString 		     = str_upper(pltvarnam)+ " ("+unit+")"  
   if(max(abs(s2)).ge.10.0)then
     res2@gsnRightString               = "mean: "+sprintf("%5.1f",vdmm)
     res2@lbLabelStrings               = sprintf("%5.1f",s2)
   else
     res2@gsnRightString               = "mean: "+sprintf("%5.2f",vdmm)
     res2@lbLabelStrings               = sprintf("%5.2f",s2)
   end if
   plot(2) 			        = gsn_csm_vector_scalar_map_ce(wks,vdiff_1(:,:),vdiff_2(:,:),vdiff_m(:,:),res2)

   pres                              = True        ; panel plot mods desired
   pres@gsnMaximize                  = False       ; fill the page
   pres@txFontHeightF                = 0.012
   pres@txFontThicknessF             = 10.
   pres@gsnPanelXWhiteSpacePercent   = 3.
   pres@gsnPanelYWhiteSpacePercent   = 5.
   pres@txString                     = "Plot time: "+seasons(kk)
   gsn_panel(wks,plot(:),(/3,1/),pres)

   ;convert the figure 
   ;if (wtype .eq. "png") then
   ;  tmpa = systemfunc("convert "+figdir+fe+".png -trim del.png")
   ;  tmpb = systemfunc("mv del.png "+fe+".png")
   ;end if

      delete([/vp1x_1,vp1x_2,vp1x_m,vp2x_1,vp2x_2,vp2x_m,vdiff_1,vdiff_2,vdiff_m/])

   delete([/plot,res,res1,res2,pres,wks,s1,s2/])

  end do       ; end of looping over variables

 end do          ; end of looping over seasons

 delete([/f1,gw1,f2,gw2,ddd1,ddd2/])
 delete([/var1_1,var1_2,var2_1,var2_2/])

end do 

end
