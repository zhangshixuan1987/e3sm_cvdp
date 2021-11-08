  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: compare the pattern of EP-FLUX with reanalysis 
; Calculate and plot the EP-flux using monthly mean model output and reanalysis 
; Note: Eliassen-Palm flux (EP-flux) is a non-linear quantity. Hence, the correct way 
; to compute time averaged EP-flux is to compute it every time step and average the results. 
; Computing EP-flux from monthly mean U, V, T quantities will result in smooth results that 
; may compare well in terms of patterns but will likely lack the detailed structure of 
; the 'correct' monthly mean EP-flux.

;;NOTE for EP-FLUXES (NCL website)
; vector quantity with nonzero components in the latitude-height plane, 
; the direction and magnitude of which determine the relative importance 
; of eddy heat flux and momentum flux.
 
; When the Eliassen-Palm flux (EPF) vector points upward, the meridional heat flux 
; dominates; when the EPF vector points in the meridional direction, the meridional 
; flux of zonal momentum dominates. The divergence of the Eliassen-Palm flux is more 
; frequently used as a diagnostic tool, as it is proportional to the eddy potential 
; vorticity flux. In the special case when the EPF divergence is zero, as for steady, 
; frictionless, linear waves, thermal wind balance is maintained in an idealized 
; zonally symmetric atmosphere through the induction of a mean meridional circulation, 
; even though the waves produce significant eddy heat and momentum fluxes.
; Reference:
; Edmon, H.J., B.J. Hoskins, and M.E. McIntyre,1980:
; Eliassen-Palm cross sections for the troposphere.
; J. Atmos. Sci., 37:2600-2616
; doi: http://dx.doi.org/10.1175/1520-0469(1980)037<2600:EPCSFT>2.0.CO;2

; Author : Shixuan Zhang
; Date   : September 22, 2021

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

  refplev_file                               = getenv("REF_PRE_LEV")
  statistical_test                           = getenv("DIFFERENCE_TEST")
  statistical_siglev                         = 0.05

;define regions for plot
  latS                                       = -90.  ;negative for southern hemisphere
  latN                                       =  90.  ;negative for southern hemisphere
  pout                                       = "Global"

  pi                                         = 3.14159265
  rearth                                     = 6.37122e6
  grav                                       = 9.806
  sigma                                      = 5.67e-8 ; Stefan-Boltzmann constant

;declear the season or annual mean data to be used;;;;;
  seasons                                   = (/"ANN","DJF","JJA"/)

;define the pressure levels for cross-section plot 
  pinterp                                      = asciiread(refplev_file,-1,"float")
  pinterp@longname                             = "lev"
  pinterp@units                                = "hPa"
  intyp                                     = 2

  pi                                        = 3.14159265
  rearth                                    = 6.37122e6
  grav                                      = 9.806

;read in two files

  do ll = 0, dimsizes(pout)-1
 
     f                                       = systemfunc("ls "+tpath+"/"+tcase+"_*_"+tttag+".nc")
     f1                                      = addfile(f,"r")
     gw1                                     = f1->gw

     f                                       = systemfunc("ls "+cpath+"/"+ccase+"_*_"+cttag+".nc")
     f2                                      = addfile(f,"r")
     gw2                                     = f2->gw

     load "./function_ep_flux.ncl"
 
     in_file1  = opath +"/"+"EP_FLUXES_"+tname+"_monthly_mean.nc"
     in_file2  = opath +"/"+"EP_FLUXES_"+cname+"_monthly_mean.nc"
    
     fin1 = addfile(out_file1,"c")
     fin2 = addfile(out_file2,"c")

     Fphi1  = fin1->Fphi1
     Fp1    = fin1->Fp
     EPdiv1 = fin1->EPdiv
     dudt1  = fin1->dudt

     Fphi2  = fin2->Fphi1          
     Fp2    = fin2->Fp
     EPdiv2 = fin2->EPdiv
     dudt2  = fin2->dudt

     do kk = 0, dimsizes(seasons)-1

        ;;;;;;select the data for plots;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if(seasons(kk).eq."ANN")then
          xFphi1                       = month_to_annual(Fphi1(:,:,{latS:latN}),1)
          xFphi2                       = month_to_annual(Fphi2(:,:,{latS:latN}),1)
          xFp1                         = month_to_annual(Fp1(:,:,{latS:latN}),1)
          xFp2                         = month_to_annual(Fp2(:,:,{latS:latN}),1)
          xEPdiv1                      = month_to_annual(EPdiv1(:,:,{latS:latN}),1)
          xEPdiv2                      = month_to_annual(EPdiv2(:,:,{latS:latN}),1)
          xdudt1                       = month_to_annual(dudt1(:,:,{latS:latN}),1)
          xdudt2                       = month_to_annual(dudt2(:,:,{latS:latN}),1)
        else
          xFphi1                       = month_to_annual(Fphi1(:,:,{latS:latN}),seasons(kk))
          xFphi2                       = month_to_annual(Fphi2(:,:,{latS:latN}),seasons(kk))
          xFp1                         = month_to_annual(Fp1(:,:,{latS:latN}),seasons(kk))
          xFp2                         = month_to_annual(Fp2(:,:,{latS:latN}),seasons(kk))
          xEPdiv1                      = month_to_annual(EPdiv1(:,:,{latS:latN}),seasons(kk))
          xEPdiv2                      = month_to_annual(EPdiv2(:,:,{latS:latN}),seasons(kk))
          xdudt1                       = month_to_annual(dudt1(:,:,{latS:latN}),seasons(kk))
          xdudt2                       = month_to_annual(dudt2(:,:,{latS:latN}),seasons(kk))
        end if
       
       ;;;;;;;;;;start to process the figure ;;;;;;;
        plot                                = new((/4/),graphic)
        wtype                               = "eps"
        figdir                              = outdir+"/Pressure-Latitude_Zonal_Mean_Contour/"
        fe                                  = "EP_FLUX_"+seasons(kk)+"_lathgt"+"_"+pout(ll)
        wks                                 = gsn_open_wks(wtype, figdir + fe)

        gsn_merge_colormaps(wks,"amwg","amwg_blueyellowred")             ; merge two color maps

        load "./share_color_bar_for_cross_section.ncl"

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

           rescn2 = True
           rescn2@lbLabelBarOn    = False
           rescn2@gsnTickMarksOn  = False     ; no tickmarks
           rescn2@gsnDraw         = False     ; don't draw
           rescn2@gsnFrame        = False     ; don't advance frame
           rescn2@tiMainString    = ""
           rescn2@gsnLeftString   = ""
           rescn2@gsnRightString  = ""
           rescn2@cnMinLevelValF  = (1.0 - statistical_siglev)*100.0
           rescn2@cnMaxLevelValF  = 100.0
          ;rescn2@cnLevelSpacingF = 1.
           rescn2@cnMonoFillPattern = True
           rescn2@cnMonoFillColor = True
           rescn2@cnFillOn        = True      ; color fill
           rescn2@cnLinesOn       = False
           rescn2@cnLineLabelsOn  = False        ; True is default
           rescn2@cnInfoLabelOn   = False                ; turn off info label
           rescn2@cnFillMode      = "AreaFill" ; raster fill significance patterns
           rescn2@cnFillPattern   = 17
           rescn2@cnFillDotSizeF  = 0.002
           rescn2@cnFillColor     = "black"
           rescn2@cnFillOpacityF  = 0.5

           plotA = gsn_csm_contour(wks,prob0,rescn2) ; contours are at 95,100
           plotB = gsn_csm_contour(wks,prob0,rescn2) ; contours are at 95,100

           overlay(plot(2),plotA)
           overlay(plot(3),plotB)

           pres                             = True        ; panel plot mods desired
           pres@gsnMaximize                 = False       ; fill the page
           pres@txFontHeightF               = 0.015       
           pres@txFontThicknessF            = 2.
           pres@gsnPanelXWhiteSpacePercent  = 3.
           pres@gsnPanelYWhiteSpacePercent  = 5.
           pres@txString                    = str_upper(compare)+" ("+seasons(kk)+")"
           gsn_panel(wks,(/plot(:)/),(/2,2/),pres)

           delete([/plotA,plotB/])

           delete([/vp1x,vp2x,vp1a,vp2a,adiff,rdiff,vp1,vp2,vp1b,vp2b,wks/])

        delete([/plot,res,pres,s1,s2,s3/])

     end do       ; end of looping over variables

  end do          ; end of looping over seasonsons

     delete([/f1,gw1,var1,ddd1/])
     delete([/f2,gw2,var2,ddd2/])

 end do
 
end
