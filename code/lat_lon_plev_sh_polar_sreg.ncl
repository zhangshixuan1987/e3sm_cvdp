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
  latS                                          = -90.  ;negative for southern hemisphere
  latN                                          = -55.  ;negative for southern hemisphere
  pout                                          = "55S-90S"

  pi                                         = 3.14159265
  rearth                                     = 6.37122e6
  grav                                       = 9.806
  sigma                                      = 5.67e-8 ; Stefan-Boltzmann constant
  intyp                                      = 2

 ;define time for the plot
  seasons                                    = (/"ANN","DJF","JJA"/)

 ;define pressure levels for plot
  plevels                                    = (/1000, 975, 850, 700, 500, 200/)

 ;variable name in the climo file
 load "./share_info_for_plev_var.ncl"

 do ll = 0, dimsizes(pout)-1

   ;read in two files
   f                                       = systemfunc("ls "+tpath+"/"+tcase+"_*_"+tttag+".nc")
   f1                                      = addfile(f,"r")
   gw1                                     = f1->gw

   f                                       = systemfunc("ls "+cpath+"/"+ccase+"_*_"+cttag+".nc")
   f2                                      = addfile(f,"r")
   gw2                                     = f2->gw

   do jj = 0, dimsizes(modvars)-1

    mvarnam                             = modvars(jj)

    if(mvarnam.ne."U".and.mvarnam.ne."V") then 


    do ii = 0, dimsizes(plevels) -1

        varstr                              = mvarnam +plevels(ii)
        unit                                = varunt(jj)

        tmp1                                = vinth2p(f1->$mvarnam$,f1->hyam,f1->hybm,plevels(ii),f1->PS,intyp,f1->P0/100.0,1,False)
        var1                                = tmp1(:,0,:,:)
        delete([/tmp1/])

        if(compare.ne."Model_vs_OBS") then
          tmp2                              = vinth2p(f2->$mvarnam$,f2->hyam,f2->hybm,plevels(ii),f2->PS,intyp,f2->P0/100.0,1,False)
          var2                              = tmp2(:,0,:,:)
          delete([/tmp2/])
        end if

        if(compare.eq."Model_vs_OBS") then
           ovarnam                          = obsvars(jj)
           tmp2                             = int2p_n_Wrap(f2->lev,f2->$ovarnam$,plevels(ii), intyp, 1)
           var2                             = tmp2(:,0,:,:)
           delete([/tmp2/])
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

        var1@units                            = unit
        var2@units                            = unit

       ;;check the two comparing files and see if they are in the same grid,
       ddd1                             = dimsizes(var1)
       ddd2                             = dimsizes(var2)
       ;;otherwise, return the error message;;;;
       if ((ddd1(1).ne.ddd2(1)).or.(ddd1(2).ne.ddd2(2)))then
         print("Error: this scripts requires the two files must in the same grid to run!!!")
         return
       end if

       ;;generate the weighting metrics
       mcorx                         = var1(0,:,:)
       mcorx@_FillValue              = var1@_FillValue
       do i = 0, ddd1(1)-1
          mcorx(i,:)                 = tofloat(gw1(i))*(2.*pi/ddd1(2))*rearth^2.
       end do

      do kk = 0, dimsizes(seasons)-1

       ;;;;;;select the data for plots;;;;;;;;;;;;;;;;;;;;;;;;;;;
       if(seasons(kk).eq."ANN")then
         vp1                        = month_to_annual(var1(:,{latS:latN},:),1)
         vp2                        = month_to_annual(var2(:,{latS:latN},:),1)
       else
         vp1                        = month_to_season(var1(:,{latS:latN},:),seasons(kk))
         vp2                        = month_to_season(var2(:,{latS:latN},:),seasons(kk))
       end if
       vp1!0                        = "time"
       vp2!0                        = "time"
       mcor                         = mcorx({latS:latN},:)

       if(str_lower(statistical_test).eq."true")then 
       
       ;First variable 
        l_plot_ttest = True 
        xtmp = vp1(lat|:,lon|:,time|:)       ; reorder but do it only once [temporary]
        ytmp = vp2(lat|:,lon|:,time|:)
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

       end if 

       vp1x	         	        = dim_avg_n_Wrap(vp1,0)
       vp2x		                = dim_avg_n_Wrap(vp2,0)

       vdiff                            = vp1x
       vdiff                            = vp1x-vp2x

       vp1x@_FillValue                  = -9999.
       vp2x@_FillValue                  = -9999.
       vdiff@_FillValue                 = -9999.

       vp11                             = where(ismissing(vp1x(:,:)), vp1x@_FillValue, vp1x(:,:)*mcor)
       vp1m                             = sum(vp11)
       mcor1                            = where(ismissing(vp1x(:,:)), mcor@_FillValue, mcor)
       vp1m                             = vp1m / sum(mcor1)
       
       vp22                             = where(ismissing(vp2x(:,:)), vp2x@_FillValue, vp2x(:,:)*mcor)
       vp2m                             = sum(vp22)
       mcor2                            = where(ismissing(vp2x(:,:)), mcor@_FillValue, mcor)
       vp2m                             = vp2m / sum(mcor2)

       vp33                             = where(ismissing(vdiff(:,:)), vdiff@_FillValue, vdiff(:,:)*mcor)
       vdmm                             = sum(vp33)
       mcor3                            = where(ismissing(vdiff(:,:)), mcor@_FillValue, mcor)
       vdmm                             = vdmm / sum(mcor3)

       delete([/mcor,mcor1,mcor2,mcor3,vp11,vp22,vp33/])

       if(l_plot_ttest)then 
         
        vdiff                         = where(prob1.le.statistical_siglev,vdiff,vdiff@_FillValue)

       end if 
      
       wtype                        = "eps"
      ;wtype@wkWidth                = 2500
      ;wtype@wkHeight               = 2500
       figdir                       = outdir+"/Latitude-Longitude_Contour_Maps_"+pout(ll)+"/"
       fe                           = varstr+"_"+seasons(kk)+"_latlon_"+pout(ll) 
       wks                          = gsn_open_wks(wtype,figdir+ fe)

       load "./share_color_bar_for_plev_map.ncl"
                  
       gsn_merge_colormaps(wks,"amwg","amwg_blueyellowred")  ; merge two color maps

       plot   = new (3,graphic)


;;;;;;;;;;;;;;;;;;;;;;;;;
;
;    Make the Plot
;
;;;;;;;;;;;;;;;;;;;;;;;;;
   res                               = True                  ; plot mods desired
   res@cnFillOn                      = True                  ; turn on color fill
   res@cnLinesOn                     = False                 ; no contour lines
   res@cnLineLabelsOn                = False
   res@gsnFrame                      = False                 ; Do not draw plot
   res@gsnDraw                       = False                 ; Do not advance frame

   FontHeightF = 0.018
   res@tiMainFontThicknessF          = 3.0
   res@tiMainFontHeightF             = FontHeightF*1.2
   res@tmYLLabelFontHeightF          = FontHeightF
   res@tmXBLabelFontHeightF          = FontHeightF
   res@tiXAxisFontHeightF            = FontHeightF
   res@tiYAxisFontHeightF            = FontHeightF
   res@gsnStringFontHeightF          = FontHeightF
   res@cnLineLabelFontHeightF        = FontHeightF
   res@lbLabelFontHeightF            = FontHeightF*0.8
   res@lbTitleFontHeightF            = FontHeightF*0.8

   res@tmXTOn                        = False
   res@tmBorderThicknessF            = 1.0
   res@tmXBMajorThicknessF           = 1.0
   res@tmXBMinorThicknessF           = 1.0
   res@tmYLMajorThicknessF           = 1.0
   res@tmYLMinorThicknessF           = 1.0
   res@tmYRMajorThicknessF           = 1.0
   res@tmYRMinorThicknessF           = 1.0

   res@gsnPolarLabelFontHeightF      = 0.02
   res@gsnPolar                      = "SH"
   res@mpFillOn                      = False        ; turn off map fill
   res@mpMaxLatF                     = latN
   res@mpGeophysicalLineThicknessF   = 2.0

   res@lbLabelBarOn                  = True
   res@lbOrientation                 = "Vertical"
   res@lbPerimOn                     = False             ; default has box
  ;res@pmLabelBarParallelPosF        = 0.61
   res@pmLabelBarOrthogonalPosF      = 0.15
   res@lbLabelFontHeightF            = 0.02               ; make labels smaller
  ;res@pmLabelBarHeightF             = 0.38
  ;res@pmLabelBarWidthF              = 0.1
  ;res@lbTitleString                 = ""

   res@cnInfoLabelOn     		= False
   res@cnLevelSelectionMode      	= "ExplicitLevels"       ; manual levels
   res@cnMissingValFillColor 	= "White" ;"gray76"               ; black = 1

   res@mpFillOn                      = False        ; turn off map fill
   res@mpGeophysicalLineThicknessF   = 2.0

   res1 = res
   res1@cnLevels                     = sprintf("%5.2f",s1)
   res1@cnFillColors                 = (/3,4,5,6,7,8,9,10,11,12,13,29,30,15,16,17/)
   res1@tiMainString                   = panelstr1
   res1@gsnLeftString                  = str_upper(varstr)+ " ("+unit+")"
   if(max(abs(s1)).ge.10.0)then
     res1@gsnRightString               = "mean: "+sprintf("%5.1f",vp1m)
     res1@lbLabelStrings               = sprintf("%5.1f",s1)
   else
     res1@gsnRightString               = "mean: "+sprintf("%5.2f",vp1m)
     res1@lbLabelStrings               = sprintf("%5.2f",s1)
   end if
   plot(0)   			       = gsn_csm_contour_map(wks,vp1x,res1)
   res1@tiMainString                   = panelstr2
   res1@gsnLeftString                  = str_upper(varstr)+ " ("+unit+")"  
   if(max(abs(s1)).ge.10.0)then
     res1@gsnRightString               = "mean: "+sprintf("%5.1f",vp2m)
     res1@lbLabelStrings               = sprintf("%5.1f",s1)
   else
     res1@gsnRightString               = "mean: "+sprintf("%5.2f",vp2m)
     res1@lbLabelStrings               = sprintf("%5.2f",s1)
   end if
   plot(1) 			        = gsn_csm_contour_map(wks,vp2x,res1)

   res2 = res
   res2@cnLevels      		     = sprintf("%5.2f",s2)
   res2@cnFillColors  		     = (/18,20,22,23,24,25,26,27,28,30,31,33/)
   res2@tiMainString                 = "Difference (Test - Reference)" ;panelstr1 + " - " + panelstr2 ;
   res2@gsnLeftString 		     = str_upper(varstr)+ " ("+unit+")"  
   if(max(abs(s2)).ge.10.0)then
     res2@gsnRightString             = "mean: "+sprintf("%5.1f",vdmm)
     res2@lbLabelStrings             = sprintf("%5.1f",s2)
   else
     res2@gsnRightString             = "mean: "+sprintf("%5.2f",vdmm)
     res2@lbLabelStrings             = sprintf("%5.2f",s2)
   end if
   plot(2) 			     = gsn_csm_contour_map(wks,vdiff,res2)

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

      delete([/vp1,vp2,vp1x,vp2x,vdiff/])

   delete([/plot,res,pres,wks,s1,s2/])

  end do       ; end of looping over variables

 end do          ; end of looping over seasons

 delete([/var1,var1,var2,var2, ddd1,ddd2/])

 end if

end do

 delete([/f1,gw1,f2,gw2/])

end do

end
