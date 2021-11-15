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

  tpath                                      = getenv("TCLIM_PATH")
  tcase                                      = getenv("TEST")
  tname                                      = getenv("TNAME")
  tttag                                      = getenv("TTTAG")
  refplev_file                               = getenv("REF_PRE_LEV")
  latS                                       = -90.  ;negative for southern hemisphere
  latN                                       =  90.  ;negative for southern hemisphere
  pout                                       = "Global"

  pi                                         = 3.14159265
  rearth                                     = 6.37122e6
  grav                                       = 9.806
  sigma                                      = 5.67e-8 ; Stefan-Boltzmann constant
  MinY                                       = 1.0

  ;declear the season or annual mean data to be used;;;;;
  seasons                                    = (/"ANN","DJF","JJA"/)

  ;define the pressure levels for cross-section plot 
  pinterp                                    = asciiread(refplev_file,-1,"float")
  pinterp@longname                           = "lev"
  pinterp@units                              = "hPa"
  intyp                                      = 2

  ;read in two files

  do ll = 0, dimsizes(pout)-1

   do kk = 0, dimsizes(seasons) -1
 
    f                                    = systemfunc("ls "+tpath+"/"+tcase+"/"+tcase+"*"+seasons(kk)+"_climo.nc")
    f1                                   = addfile(f,"r")
    gw1                                  = f1->gw

    ; =================================================================
    print ("Start to process the cross-section of selected budget variables")
    load "./share_info_for_budget_var.ncl"

    do jj = 1, dimsizes(modvars)-1

      mvarnam                          = modvars(0)
      cld                              = vinth2p(f1->$mvarnam$,f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      cld@_FillValue                   = -9999.
      cld                              = cld*facmod(jj)
      cld@units                        = varunt(jj)

      mvarnam                          = modvars(jj)
      var1                             = vinth2p(f1->$mvarnam$,f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      var1@_FillValue                  = -9999.
      var1                             = var1*facmod(jj)
      var1@units                       = varunt(jj)

      do ii = 0, dimsizes(process) -1 

       load "./function_read_budget_var.ncl" 
       if(.not.all(ismissing(tmp1))) then 
         var2                              = vinth2p(tmp1,f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
       else
         var2 = var1
         var2 = -9999.0
       end if 
       var2@_FillValue                   = -9999.
       var2                              = var2*facmod(jj)*factnd(jj)
       var2@units                        = tndunt(jj)
       delete([/tmp1/])

       ;;mask out the missing values;;;;
       var1 = where (ismissing(var2), var1@_FillValue, var1)
       var2 = where (ismissing(var1), var2@_FillValue, var2)

       ;;;;;;select the data for plots;;;;;;;;;;;;;;;;;;;;;;;;;;;
       vpr   = cld(:,:,{latS:latN},:)
       vpr!0 = "time"
       vpr!1 = "lev"
       vpr!2 = "lat"
       vpr!3 = "lon"

       vp1   = var1(:,:,{latS:latN},:)
       vp1!0 = "time"
       vp1!1 = "lev"
       vp1!2 = "lat"
       vp1!3 = "lon"

       vp2   = var2(:,:,{latS:latN},:)
       vp2!0 = "time"
       vp2!1 = "lev"
       vp2!2 = "lat"
       vp2!3 = "lon"

       vpra                               = dim_avg_n_Wrap(dim_avg_n_Wrap(vpr,3),0)
       vp1a                               = dim_avg_n_Wrap(dim_avg_n_Wrap(vp1,3),0)
       vp2a                               = dim_avg_n_Wrap(dim_avg_n_Wrap(vp2,3),0)
       vp1a@_FillValue                    = -9999.
       vp2a@_FillValue                    = -9999.
       vpra@_FillValue                    = -9999.

       ;;;;;;;;;;start to process the figure ;;;;;;;

       if(ii.eq.0) then 

        plot                              = new((/dimsizes(process)+1/),graphic)
        wtype                             = "eps"
        figdir                            = outdir+"/Budget_Analysis/"
        fe                                = modvars(jj)+"_"+seasons(kk)+"_lathgt"+"_"+pout(ll)
        wks                               = gsn_open_wks(wtype, figdir + fe)
        gsn_merge_colormaps(wks,"amwg","amwg_blueyellowred")             ; merge two color maps
        load "./share_color_bar_for_budget_var.ncl"

       end if 

    ;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ;    Make the Plot
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;
           res                              = True                  ; plot mods desired
           res@vpWidthF                     = 0.8
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
           res@tmXBLabels                   = (/"90S","60S","30S","0", \
                                                "30N","60N","90N"/)
           res@tmXBMinorValues              = ispan(toint(latS),toint(latN),15)

           res@tmYLMode                     = "Explicit"                ; explicit labels
           res@tmYLValues                   = (/ 1000, 850, 700, 500, 300, 200, 100, 10, 1/)
           res@tmYLLabels                   = ""+res@tmYLValues         ; make strings

           res@lbLabelBarOn                 = True
           res@lbOrientation                = "Vertical"
           res@cnInfoLabelOn                = False
           res@gsnRightStringFontHeightF    = 0.025
           res@gsnRightStringOrthogonalPosF = 0.02
           res@trYReverse                   = True
           res@tiYAxisString                = "Pressure (hPa)"
           res@gsnLeftStringFontHeightF     = 0.025
           res@gsnLeftStringOrthogonalPosF  = 0.015
           res@tiMainString                 = ""

           if(ii.eq.0) then 
             res0 = res 
             res0@cnLevelSelectionMode      = "ExplicitLevels"       ; manual levels
             res0@cnLevels                  = sprintf("%5.2f",s1)
             res0@cnFillColors              = (/3,4,5,6,7,8,9,10,11,12,13,14,15/)
             res0@cnLevels                  = sprintf("%7.2e",s1)
             res0@gsnLeftString             = str_upper(modvars(jj))+" (unit: "+ vp1a@units+")" ;"relative diff. (%)"
             res0@gsnRightString            = "mean: "+sprintf("%5.2f",avg(vp1a(:,:)))
             plot(0)                        = gsn_csm_contour(wks,vp1a(:,:),res0)
           end if 

           res1 = res 
           res1@cnLevelSelectionMode        = "ExplicitLevels"       ; manual levels
           res1@cnLevels                    = sprintf("%7.2e",s2)
           res1@cnFillColors                = (/18,20,22,23,24,25,26,27,28,30,31,33/)              ; contour interval
           res1@gsnLeftString               = str_upper(modvars(jj))+" tend ("+process(ii)+"; "+ vp2a@units+")" 
           res1@gsnRightString              = "mean: "+sprintf("%5.2f",avg(vp2a(:,:)))
           plot(ii+1)                       = gsn_csm_contour(wks,vp2a(:,:),res1)

           if(ii.eq.0) then 
             rescn2 = True
             rescn2@lbLabelBarOn    = False
             rescn2@gsnTickMarksOn  = False     ; no tickmarks
             rescn2@gsnDraw         = False     ; don't draw
             rescn2@gsnFrame        = False     ; don't advance frame
             rescn2@tiMainString    = ""
             rescn2@gsnLeftString   = ""
             rescn2@gsnRightString  = ""
             rescn2@cnLevels       := (/0.01,0.05,0.1,0.2,0.4,0.5,0.6,0.7/)
            ;rescn2@cnLevelSpacingF = 1.
             rescn2@cnMonoFillPattern = True
             rescn2@cnMonoFillColor = True
             rescn2@cnFillOn        = False      ; color fill
             rescn2@cnLinesOn       = True
             rescn2@cnLineLabelsOn  = False        ; True is default
             rescn2@cnInfoLabelOn   = False                ; turn off info label
             rescn2@cnFillMode      = "AreaFill" ; raster fill significance patterns
             rescn2@cnFillPattern   = 17
             rescn2@cnFillDotSizeF  = 0.002
             rescn2@cnFillColor     = "black"
             rescn2@cnFillOpacityF  = 0.5
             plotA = gsn_csm_contour(wks,vpra,rescn2) ; contours are at 95,100
            ;overlay(plot(0),plotA)
            ;overlay(plot(ii),plotB)
            ;delete([/plotA/])

           end if 

           delete([/vpra,vp1a,vp2a,vp1,vp2,vpr/])

          end do       ; end of looping over processes

           pres                             = True        ; panel plot mods desired
           pres@gsnMaximize                 = False       ; fill the page
           pres@txFontHeightF               = 0.012
           pres@txFontThicknessF            = 2.
           pres@gsnPanelXWhiteSpacePercent  = 3.
           pres@gsnPanelYWhiteSpacePercent  = 5.
           pres@txString                    = panelstr1+" ("+seasons(kk)+")"
           gsn_panel(wks,(/plot(:)/),(/2,3/),pres)

        delete([/plot,res,rescn2,pres,s1,s2,s3/])

     end do       ; end of looping over variables

     delete([/var1,cld/])
     delete([/f1,gw1/])

  end do          ; end of looping over seasonsons

 end do
 
end
