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
  outdir                                     = getenv("CASEDIR")
  opath                                      = getenv("DIAG_DATA_ROOT")

  tpath                                      = getenv("TPATH")
  cpath                                      = getenv("CPATH")

  tcase                                      = getenv("TEST")
  ccase                                      = getenv("CTRL")

  tname                                      = getenv("TNAME")
  cname                                      = getenv("CNAME")

  tttag                                      = getenv("TTTAG")
  cttag                                      = getenv("CTTAG")

  refplev_file                               = getenv("REF_PRE_LEV")
  statistical_test                           = getenv("DIFFERENCE_TEST")
  statistical_siglev                         = 0.05

  panelstr1                                  = tname + " ("+tttag+")"
  panelstr2                                  = cname + " ("+cttag+")"

;define regions for plot
  latS                                       = -90.  ;negative for southern hemisphere
  latN                                       =  90.  ;negative for southern hemisphere
  pout                                       = "Global"

  pi                                         = 3.14159265
  rearth                                     = 6.37122e6
  grav                                       = 9.806
  sigma                                      = 5.67e-8 ; Stefan-Boltzmann constant

;declear the season or annual mean data to be used;;;;;
  seasons                                    = (/"ANN","DJF","JJA","MAM","SON"/)

;define the pressure levels for cross-section plot 
  pinterp                                   = asciiread(refplev_file,-1,"float")
  pinterp@longname                          = "lev"
  pinterp@units                             = "hPa"
  intyp                                     = 2

  pi                                        = 3.14159265
  rearth                                    = 6.37122e6
  grav                                      = 9.806

  do ll = 0, dimsizes(pout)-1

  ;read in two files
   file1  = opath +"/"+"HC_analysis_"+tname+"_monthly_mean.nc"
   file2  = opath +"/"+"HC_analysis_"+cname+"_monthly_mean.nc"
   exists = isfilepresent(file1).and.isfilepresent(file2)
    
   if(exists) then
     fin1 = addfile(file1,"r")
     fin2 = addfile(file2,"r")
     varexist = isfilevar(fin1,"SF").and.isfilevar(fin2,"SF").and.\
                isfilevar(fin1,"W").and.isfilevar(fin2,"W").and.\
                isfilevar(fin1,"U").and.isfilevar(fin2,"U").and.\
                isfilevar(fin1,"V").and.isfilevar(fin2,"V") 
     if(.not.varexist) then
      exists = False 
     end if 
   end if 
  
   if(.not.exists) then

     f                                       = systemfunc("ls "+tpath+"/"+tcase+"_*_"+tttag+".nc")
     f1                                      = addfile(f,"r")
     gw1                                     = f1->gw

     f                                       = systemfunc("ls "+cpath+"/"+ccase+"_*_"+cttag+".nc")
     f2                                      = addfile(f,"r")
     gw2                                     = f2->gw

     load "./function_hadley_cell_analysis.ncl"
     fin1 = addfile(file1,"r")
     fin2 = addfile(file2,"r")

   end if

    um    = fin1->U
    vm    = fin1->V
    wm    = fin1->W
    sfm   = fin1->SF

    uo    = fin2->U
    vo    = fin2->V                               
    wo    = fin2->W
    sfo   = fin2->SF
 
    sfm!0="time"
    sfm!1="lev"
    sfm!2="lat"
    sfm&lat = fin1->lat


    sfo!0="time"
    sfo!1="lev"
    sfo!2="lat"
    sfo&lat = fin2->lat

    copy_VarCoords(sfm,wm)
    copy_VarCoords(sfm,vm)
    copy_VarCoords(sfm,um)
    copy_VarCoords(sfo,wo)
    copy_VarCoords(sfo,vo)
    copy_VarCoords(sfo,uo)   

    ;printMinMax(sfm,False)
    ;printMinMax(sfo,False)       
    ;printMinMax(wm,False)
    ;printMinMax(wo,False)

    do kk = 0, dimsizes(seasons)-1

        ;;;;;;select the data for plots;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if(seasons(kk).eq."ANN")then
          u1                          = month_to_annual(um(:,:,{latS:latN}),1)
          v1                          = month_to_annual(vm(:,:,{latS:latN}),1)
          w1                          = month_to_annual(wm(:,:,{latS:latN}),1)
          sf1                         = month_to_annual(sfm(:,:,{latS:latN}),1)
          u2                          = month_to_annual(uo(:,:,{latS:latN}),1)
          v2                          = month_to_annual(vo(:,:,{latS:latN}),1)
          w2                          = month_to_annual(wo(:,:,{latS:latN}),1)
          sf2                         = month_to_annual(sfo(:,:,{latS:latN}),1)
        else
          u1                          = month_to_season(um(:,:,{latS:latN}),seasons(kk))
          v1                          = month_to_season(vm(:,:,{latS:latN}),seasons(kk))
          w1                          = month_to_season(wm(:,:,{latS:latN}),seasons(kk))
          sf1                         = month_to_season(sfm(:,:,{latS:latN}),seasons(kk))
          u2                          = month_to_season(uo(:,:,{latS:latN}),seasons(kk))
          v2                          = month_to_season(vo(:,:,{latS:latN}),seasons(kk))
          w2                          = month_to_season(wo(:,:,{latS:latN}),seasons(kk))
          sf2                         = month_to_season(sfo(:,:,{latS:latN}),seasons(kk))
        end if

       sf1!0="time"
       sf1!1="lev"
       sf1!2="lat"
       sf1&lat = fin1->lat

       sf2!0="time"
       sf2!1="lev"
       sf2!2="lat"
       sf2&lat = fin2->lat


       copy_VarCoords(sf1,u1)
       copy_VarCoords(sf1,v1)
       copy_VarCoords(sf1,w1)

       copy_VarCoords(sf2,u2)
       copy_VarCoords(sf2,v2)
       copy_VarCoords(sf2,w2)

       if(str_lower(statistical_test).eq."true")then

         rad   = 4.0*atan(1.0)/180.0
         gw1   = cos(fin1->lat*rad)
         gw2   = cos(fin2->lat*rad)
         l_plot_ttest = True
         vpt1 = sf1
         vpt2 = sf2
         xtmp = vpt1(lev|:,lat|:,time|:)       ; reorder but do it only once [temporary]
         ytmp = vpt2(lev|:,lat|:,time|:)
         xAve = dim_avg (xtmp)              ; calculate means at each grid point
         yAve = dim_avg (ytmp)
         xVar = dim_variance (xtmp)         ; calculate variances
         yVar = dim_variance (ytmp)
         xEqv = equiv_sample_size (xtmp, statistical_siglev,0)
         yEqv = equiv_sample_size (ytmp, statistical_siglev,0)
         xN   = dim_avg_n(dim_avg_wgt_n(xEqv, gw1, 0, 1),0)
         yN   = dim_avg_n(dim_avg_wgt_n(yEqv, gw2, 0, 1),0)
         iflag = True                       ; population variance similar
         prob  = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False)
         delete([/vpt1,vpt2,xtmp,ytmp,xAve,yAve,xVar,yVar,xEqv,yEqv,xN,yN,gw1,gw2/])

       end if

       u1a                                = dim_avg_n_Wrap(u1,0)
       v1a                                = dim_avg_n_Wrap(v1,0)
       w1a                                = dim_avg_n_Wrap(w1,0)
       sf1a                               = dim_avg_n_Wrap(sf1,0)

       u2a                                = dim_avg_n_Wrap(u2,0)
       v2a                                = dim_avg_n_Wrap(v2,0)
       w2a                                = dim_avg_n_Wrap(w2,0)
       sf2a                               = dim_avg_n_Wrap(sf2,0)

       ;;mask the missing values in two datasets;;;
       u1a = where (ismissing(u2a), u1a@_FillValue, u1a)
       u2a = where (ismissing(u1a), u2a@_FillValue, u2a)
       v1a = where (ismissing(v2a), v1a@_FillValue, v1a)
       v2a = where (ismissing(v1a), v2a@_FillValue, v2a)
       w1a = where (ismissing(w2a), w1a@_FillValue, w1a)
       w2a = where (ismissing(w1a), w2a@_FillValue, w2a)
       sf1a = where (ismissing(sf2a), sf1a@_FillValue, sf1a)
       sf2a = where (ismissing(sf1a), sf2a@_FillValue, sf2a)

       u1a@_FillValue                     = -9999.
       v1a@_FillValue                     = -9999.
       w1a@_FillValue                     = -9999.
       sf1a@_FillValue                    = -9999.

       u2a@_FillValue                     = -9999.
       v2a@_FillValue                     = -9999.
       w2a@_FillValue                     = -9999.
       sf2a@_FillValue                    = -9999.

       uadiff                             = u2a
       uadiff                             = u1a-u2a

       vadiff                             = v2a
       vadiff                             = v1a-v2a

       wadiff                             = w2a
       wadiff                             = w1a-w2a

       sfadiff                            = sf2a
       sfadiff                            = sf1a-sf2a

       prob0                              = sfadiff
       prob0                              = (1.0 - prob)*100.0
       prob0                              = where(prob.le.statistical_siglev,prob0,prob0@_FillValue)

       ;;;;;;;;;;start to process the figure ;;;;;;;
       plot                                = new((/3/),graphic)
       wtype                               = "eps"
       figdir                              = outdir+"/Mean_Circulation_Analysis/"
       fe                                  = "Hadelay_circulation_"+seasons(kk)+"_lathgt"+"_"+pout(ll)
       wks                                 = gsn_open_wks(wtype, figdir + fe)

       gsn_merge_colormaps(wks,"amwg","amwg_blueyellowred")             ; merge two color maps

       load "./share_color_bar_for_hadley_analysis.ncl"
       sf1a    = sf1a*facsfm
       sf2a    = sf2a*facsfm
       sfadiff = sfadiff*facsfm
       w1a     = w1a*100.0
       w2a     = w2a*100.0
       wadiff  = wadiff*100.0
    ;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ;    Make the Plot
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;
           res                              = True                  ; plot mods desired
           res@vpWidthF                     = 1.0
           res@vpHeightF                    = 0.5
           res@gsnFrame                     = False                 ; Do not draw plot
           res@gsnDraw                      = False                 ; Do not advance frame
          ;res@gsnMajorLatSpacing           =  10             ;-- change major lat tickmark spacing
          ;res@gsnMinorLatSpacing           =  2.5            ;-- change major lat tickmark spacing

           FontHeightF = 0.028
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
           res@lbLabelFontHeightF            = FontHeightF*0.8
           res@lbTitleFontHeightF            = FontHeightF*0.8

           res@cnFillOn                     = True                  ; turn on color fill
           res@cnLinesOn                    = False                 ; no contour lines
           res@cnLineLabelsOn               = False
           res@cnMissingValFillColor        = "White" ;"gray76"               ; black = 1

           res@tmXTOn                       = False
           res@tmBorderThicknessF           = 1.0
           res@tmXBMajorThicknessF          = 1.0
           res@tmXBMinorThicknessF          = 1.0
           res@tmYLMajorThicknessF          = 1.0
           res@tmYLMinorThicknessF          = 1.0
           res@tmYRMajorThicknessF          = 1.0
           res@tmYRMinorThicknessF          = 1.0
           res@tmYRMode                     = "Automatic"          ; turn off special labels on right axis

           res@tmXBMode                     = "Explicit"	
           res@tmXBValues                   = XBValues
           res@tmXBLabels                   = XBLabels
           res@tmXBMinorValues              = XBMinorValues
           res@tmYLMode                     = "Explicit"                ; explicit labels
           res@tmYLValues                   = YLValues 
           res@tmYLLabels                   = ""+res@tmYLValues         ; make strings

           res@cnInfoLabelOn                = False
           res@gsnRightStringOrthogonalPosF = 0.02
           res@trYReverse                   = True
           res@tiYAxisString                = "Pressure (hPa)"
           res@gsnLeftStringOrthogonalPosF  = 0.015
           res@tiMainString                 = panelstr1
           res@gsnLeftString                = leftstring
           res@gsnRightString               = "Global mean: "+sprintf("%5.2f",avg(sf1a(:,:)))

           res0 = res
           res0@cnFillOn                     = False                  ; turn on color fill
           res0@cnLinesOn                    = True                 ; no contour lines
           res0@cnLineLabelsOn               = True
           res0@cnMissingValFillColor        = "White" ;"gray76"               ; black = 1
           res0@cnLineColor                  = "Blue3"
           res0@cnInfoLabelOn                = False
           res0@cnLevelSelectionMode         = "ExplicitLevels"       ; manual levels
           res0@cnLevels                    := s3
           res0@cnLineLabelInterval          = 1             ; default = 2
           res0@cnLineLabelFontColor         = res0@cnLineColor
           res0@cnLineLabelPlacementMode     = "constant"    ; choose constant label method
           res0@tiMainString                 = ""
           res0@gsnLeftString                = ""
           res0@gsnRightString               = ""
           plotC   = gsn_csm_contour(wks,u1a,res0)
           plotD   = gsn_csm_contour(wks,u2a,res0)

           vecres                           = True            ; vector only resources
           vecres@gsnDraw                   = False           ; don't draw
           vecres@gsnFrame                  = False           ; don't advance frame
           vecres@vcGlyphStyle              = "LineArrow";"CurlyVector"   ; curly vectors
           vecres@vcRefLengthF              = 0.04            ; define length of vec ref
           vecres@vcMinDistanceF            = 0.015 
           vecres@gsnRightString            = " "             ; turn off right string
           vecres@gsnLeftString             = " "             ; turn off left string
           vecres@tiXAxisString             = " "             ; turn off axis label 
           vecres@vcMapDirection            = False
           vecres@vcRefAnnoOrthogonalPosF   = -0.12    ; move ref vector into plot
           vecres@vcRefAnnoPerimOn          = False
           vecres@vcRefAnnoParallelPosF     = 1.2    ; move ref vector into plot
           vecres@vcRefAnnoFontHeightF      = FontHeightF*0.5
           vecres@vcRefAnnoSide             = "Bottom"
           vecres@vcRefMagnitudeF           = 1.0              ; define vector ref mag
           vecres@vcRefAnnoString1          = vecres@vcRefMagnitudeF
           vecres@vcRefAnnoString2          = "(v,wx100)"
    
           res1 = res
           res1@lbLabelBarOn                 = True
           res1@lbOrientation                = "Vertical"
           res1@cnInfoLabelOn                = False
           res1@cnLevelSelectionMode         = "ExplicitLevels"       ; manual levels
           res1@cnFillPalette                = Contour_color_bar
           res1@cnLevels                     = sprintf("%5.2f",s1)
          ;res1@cnFillColors                 = (/3,4,5,6,7,8,9,10,11,12,13,14,15/)
           res1@tiMainString                 = panelstr1
           res1@gsnLeftString                = leftstring
           res1@gsnRightString               = "Global mean: "+sprintf("%5.2f",avg(sf1a(:,:)))

           plotA   = gsn_csm_contour(wks,sf1a,res1)
           plotB   = gsn_csm_vector(wks,v1a,w1a,vecres)
           overlay(plotA,plotB)                      ; result will be plotA
           overlay(plotA,plotC)                      ; result will be plotA
           plot(0) = plotA                           ; now assign plotA to array

           res1@tiMainString                 = panelstr2
           res1@gsnLeftString                = leftstring
           res1@gsnRightString               = "Global mean: "+sprintf("%5.2f",avg(sf2a(:,:)))
           plotA   = gsn_csm_contour(wks,sf2a,res1)
           plotB   = gsn_csm_vector(wks,v2a,w2a,vecres)
           overlay(plotA,plotB)                      ; result will be plotA
           overlay(plotA,plotD)                      ; result will be plotA
           plot(1) = plotA                           ; now assign plotA to array

           res2 = res
           res2@lbLabelBarOn                 = True
           res2@lbOrientation                = "Vertical"
           res2@cnInfoLabelOn                = False
           res2@cnLevelSelectionMode         = "ExplicitLevels"       ; manual levels
           res2@cnFillPalette                = Diff_corlor_bar
           res2@cnLevels                     = sprintf("%7.2e",s2)
           res2@cnFillColors                 = (/3,4,5,6,7,8,9,10,11,12,13,14,15/)
           res2@tiMainString                 = panelstr1 + " - " + panelstr2 ; "absolute difference"
           res2@gsnLeftString                = leftstring
           res2@gsnRightString               = "Global mean: "+sprintf("%5.2f",avg(sfadiff(:,:)))
           plotA   = gsn_csm_contour(wks,sfadiff,res2)
           vecres@vcRefAnnoSide             = "Bottom"
           vecres@vcRefMagnitudeF           = 0.5        ; define vector ref mag
           vecres@vcRefAnnoString1          = vecres@vcRefMagnitudeF 
           vecres@vcRefAnnoString2          = "(~F33~D~N~~F~v,~F33~D~N~~F~wx100)"
           plotB   = gsn_csm_vector(wks,vadiff,wadiff,vecres)
           overlay(plotA,plotB)                      ; result will be plotA
           plot(2) = plotA                           ; now assign plotA to array

           rescn2 = res
           rescn2@lbLabelBarOn    = False 
           rescn2@tiMainString    = ""
           rescn2@gsnLeftString   = ""
           rescn2@gsnRightString  = ""
           rescn2@cnMinLevelValF  = (1.0 - statistical_siglev)*100.0
           rescn2@cnMaxLevelValF  = 100.0
           rescn2@cnLevelSpacingF = 1.
           rescn2@cnMonoFillPattern = True  
           rescn2@cnMonoFillColor = True 
           rescn2@cnFillMode      = "AreaFill" ; raster fill significance patterns
           rescn2@cnFillPattern   = 17
           rescn2@cnFillDotSizeF  = 0.002
           rescn2@cnFillColor     = "black"
           rescn2@cnFillOpacityF  = 0.5 
           ;plotA = gsn_csm_contour(wks,prob0,rescn2) ; contours are at 95,100
           ;plotB = gsn_csm_contour(wks,prob0,rescn2) ; contours are at 95,100
           ;overlay(plot(2),plotA)

           pres                             = True        ; panel plot mods desired
           pres@gsnMaximize                 = False       ; fill the page
           pres@txFontHeightF               = 0.015       
           pres@txFontThicknessF            = 2.
           pres@gsnPanelXWhiteSpacePercent  = 3.
           pres@gsnPanelYWhiteSpacePercent  = 5.
           pres@txString                    = str_upper(compare)+" ("+seasons(kk)+")"
           gsn_panel(wks,(/plot(:)/),(/3,1/),pres)

           delete([/plotA,plotB/])

           delete([/u1a,v1a,w1a,sf1a,u2a,v2a,w2a,sf2a/])
           delete([/uadiff,wadiff,sfadiff,wks/])

        delete([/plot,res,res0,res1,res2,vecres,rescn2,pres,s1,s2,s3/])

     end do          ; end of looping over seasonsons

 end do
 
end
